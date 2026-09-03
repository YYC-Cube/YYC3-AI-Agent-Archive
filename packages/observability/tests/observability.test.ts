/**
 * Observability 测试套件
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { HealthRegistry } from '../src/health.js';
import { Logger } from '../src/logger.js';
import { MetricsRegistry } from '../src/metrics.js';
import { Tracer } from '../src/tracer.js';

// ============================================================
// Logger 测试
// ============================================================
describe('Logger', () => {
  let logger: Logger;

  beforeEach(() => {
    logger = new Logger({ enableConsole: false });
  });

  it('应记录不同级别的日志', () => {
    logger.info('test info');
    logger.warn('test warn');
    logger.error('test error');
    const entries = logger.getEntries();
    expect(entries).toHaveLength(3);
    expect(entries[0].level).toBe('info');
    expect(entries[1].level).toBe('warn');
    expect(entries[2].level).toBe('error');
  });

  it('应携带上下文', () => {
    logger.info('action', { userId: '123', action: 'login' });
    const entry = logger.getEntries()[0];
    expect(entry.context).toEqual({ userId: '123', action: 'login' });
  });

  it('应遵循最小日志级别过滤', () => {
    const strict = new Logger({ minLevel: 'warn', enableConsole: false });
    strict.info('should not appear');
    strict.warn('should appear');
    strict.error('should also appear');
    expect(strict.getEntries()).toHaveLength(2);
  });

  it('debug 应被默认过滤', () => {
    logger.debug('debug msg');
    expect(logger.getEntries()).toHaveLength(0);
  });

  it('fatal 应始终记录', () => {
    logger.fatal('critical failure');
    expect(logger.getEntries()).toHaveLength(1);
    expect(logger.getEntries()[0].level).toBe('fatal');
  });

  it('filterByLevel 应正确过滤', () => {
    logger.info('i');
    logger.warn('w');
    logger.error('e');
    expect(logger.filterByLevel('warn')).toHaveLength(2);
    expect(logger.filterByLevel('error')).toHaveLength(1);
  });

  it('应支持自定义传输器', () => {
    const transport = vi.fn();
    const l = new Logger({ enableConsole: false, transports: [transport] });
    l.info('test');
    expect(transport).toHaveBeenCalledTimes(1);
    expect(transport).toHaveBeenCalledWith(expect.objectContaining({ message: 'test' }));
  });

  it('传输器失败不应影响主流程', () => {
    const badTransport = vi.fn().mockImplementation(() => { throw new Error('transport down'); });
    const goodTransport = vi.fn();
    const l = new Logger({ enableConsole: false, transports: [badTransport, goodTransport] });
    l.info('test');
    expect(goodTransport).toHaveBeenCalled();
  });

  it('toJSON 应导出 JSON', () => {
    logger.info('test');
    const json = logger.toJSON();
    const parsed = JSON.parse(json);
    expect(parsed).toHaveLength(1);
    expect(parsed[0].message).toBe('test');
  });

  it('clear 应清空日志', () => {
    logger.info('test');
    logger.clear();
    expect(logger.getEntries()).toHaveLength(0);
  });

  it('child 应创建子日志器', () => {
    const child = logger.child('api', { version: 'v1' });
    child.info('request');
    const entry = child.getEntries()[0];
    expect(entry).toBeDefined();
    expect(entry.context).toBeDefined();
  });

  it('文本格式应正确输出', () => {
    const textLogger = new Logger({ enableConsole: false, formatter: 'text' });
    textLogger.info('hello');
    const entry = textLogger.getEntries()[0];
    expect(entry.message).toBe('hello');
  });

  it('控制台输出调用对应级别方法', () => {
    const errorSpy = vi.spyOn(console, 'error').mockImplementation(() => { });
    const warnSpy = vi.spyOn(console, 'warn').mockImplementation(() => { });
    const logSpy = vi.spyOn(console, 'log').mockImplementation(() => { });

    const consoleLogger = new Logger({ enableConsole: true });
    consoleLogger.error('to-error');
    consoleLogger.warn('to-warn');
    consoleLogger.info('to-log');

    expect(errorSpy).toHaveBeenCalledTimes(1);
    expect(warnSpy).toHaveBeenCalledTimes(1);
    expect(logSpy).toHaveBeenCalled();

    errorSpy.mockRestore();
    warnSpy.mockRestore();
    logSpy.mockRestore();
  });

  it('JSON 与文本 formatter 输出格式区分', () => {
    const jsonSpy = vi.spyOn(console, 'log').mockImplementation(() => { });
    const textSpy = vi.spyOn(console, 'log').mockImplementation(() => { });

    new Logger({ enableConsole: true }).info('json-line');
    expect(jsonSpy).toHaveBeenCalledWith(expect.stringContaining('{'));

    const tl = new Logger({ enableConsole: true, formatter: 'text' });
    tl.clear();
    tl.info('text-line');
    expect(textSpy).toHaveBeenCalledWith(expect.stringMatching(/^\[/));

    jsonSpy.mockRestore();
    textSpy.mockRestore();
  });

  it('无 context 的文本日志不含额外字段', () => {
    const spy = vi.spyOn(console, 'log').mockImplementation(() => { });
    new Logger({ enableConsole: true, formatter: 'text' }).info('bare');
    expect(spy).toHaveBeenCalledWith(expect.not.stringContaining('{'));
    spy.mockRestore();
  });

  it('child 覆盖 component 与运行时 context 合并', () => {
    const child = logger.child('gw', { route: '/x' });
    child.warn('msg', { extra: 1 });
    const entry = child.getEntries()[0];
    expect(entry.context).toMatchObject({ component: 'gw', route: '/x', extra: 1 });
  });
});

// ============================================================
// MetricsRegistry 测试
// ============================================================
describe('MetricsRegistry', () => {
  let registry: MetricsRegistry;

  beforeEach(() => {
    registry = new MetricsRegistry();
  });

  describe('Counter', () => {
    it('应递增计数', () => {
      const c = registry.counter('requests_total', 'Total requests');
      c.inc();
      c.inc(2);
      expect(c.get()).toBe(3);
    });

    it('初始值应为 0', () => {
      const c = registry.counter('errors', 'Error count');
      expect(c.get()).toBe(0);
    });
  });

  describe('Gauge', () => {
    it('应设置值', () => {
      const g = registry.gauge('memory_bytes', 'Memory usage');
      g.set(1024);
      expect(g.get()).toBe(1024);
    });

    it('应递增和递减', () => {
      const g = registry.gauge('active_connections', 'Active connections');
      g.set(10);
      g.inc(5);
      g.dec(3);
      expect(g.get()).toBe(12);
    });
  });

  describe('Histogram', () => {
    it('应记录观测值', () => {
      const h = registry.histogram('latency_ms', 'Request latency', [10, 50, 100]);
      h.observe(5);
      h.observe(25);
      h.observe(75);
      expect(h.get()).toBe(3);
    });

    it('应正确分桶', () => {
      const h = registry.histogram('duration', 'Duration', [10, 50, 100]);
      h.observe(5);   // 5 <= 10 → bucket 10
      h.observe(25);  // 25 <= 50 → bucket 50
      h.observe(75);  // 75 <= 100 → bucket 100
      h.observe(200); // 200 > 100 → total only

      const snap = registry.snapshot().find(s => s.name === 'duration');
      expect(snap).toBeDefined();
      expect(snap!.buckets!['10']).toBe(1);
      expect(snap!.buckets!['50']).toBe(1);
      expect(snap!.buckets!['100']).toBe(1);
      expect(snap!.count).toBe(4);
      expect(snap!.sum).toBe(305);
    });
  });

  describe('snapshot', () => {
    it('应返回所有指标快照', () => {
      registry.counter('c', 'counter');
      registry.gauge('g', 'gauge');
      const snap = registry.snapshot();
      expect(snap).toHaveLength(2);
    });
  });

  describe('toPrometheus', () => {
    it('应导出 Prometheus 格式', () => {
      registry.counter('test_total', 'Test counter');
      const output = registry.toPrometheus();
      expect(output).toContain('# HELP test_total');
      expect(output).toContain('# TYPE test_total counter');
      expect(output).toContain('test_total 0');
    });
  });

  it('重复注册应抛出错误', () => {
    registry.counter('dup', 'first');
    expect(() => registry.counter('dup', 'second')).toThrow('already registered');
  });

  it('clear 应清空指标', () => {
    registry.counter('c', 'counter');
    registry.clear();
    expect(registry.snapshot()).toHaveLength(0);
  });

  it('snapshot 包含 histogram 的 count/sum 与 counter 的 labels', () => {
    registry.counter('labeled', 'with labels', { env: 'prod' });
    registry.histogram('h', 'hist', [10]);
    registry.snapshot(); // 触发分支
    const snap = registry.snapshot();
    expect(snap.find(s => s.name === 'labeled')!.labels).toEqual({ env: 'prod' });
    const h = snap.find(s => s.name === 'h')!;
    expect(h.count).toBe(0);
    expect(h.sum).toBe(0);
  });

  it('toPrometheus 导出 histogram 桶与 Inf', () => {
    const h = registry.histogram('ph', 'prom hist', [10, 100]);
    h.observe(5);   // 命中 le=10
    h.observe(50);  // 命中 le=100
    h.observe(500); // 超出所有桶，仅计入 +Inf
    const output = registry.toPrometheus();
    expect(output).toContain('ph_bucket{le="10"} 1');
    expect(output).toContain('ph_bucket{le="100"} 1');
    expect(output).toContain('ph_bucket{le="+Inf"} 3');
  });

  it('gauge/counter 的 inc 与 dec 在 registry 快照中一致', () => {
    const c = registry.counter('cc', 'c');
    const g = registry.gauge('gg', 'g');
    c.inc(4);
    g.set(9);
    g.dec(4);
    const snap = registry.snapshot();
    expect(snap.find(s => s.name === 'cc')!.value).toBe(4);
    expect(snap.find(s => s.name === 'gg')!.value).toBe(5);
  });
});

// ============================================================
// Tracer 测试
// ============================================================
describe('Tracer', () => {
  let tracer: Tracer;

  beforeEach(() => {
    tracer = new Tracer({ sampleRate: 1.0 });
  });

  it('应创建 Span', () => {
    const span = tracer.startSpan('test-operation');
    expect(span.name).toBe('test-operation');
    expect(span.id).toBeTruthy();
    expect(span.traceId).toBeTruthy();
  });

  it('应支持父子 Span', () => {
    const parent = tracer.startSpan('parent');
    const child = tracer.startSpan('child', parent.id);
    expect(child.parentId).toBe(parent.id);
    expect(child.traceId).toBe(parent.traceId);
  });

  it('应支持结束 Span', () => {
    const span = tracer.startSpan('op');
    tracer.endSpan(span.id);
    const ended = tracer.getSpan(span.id);
    expect(ended!.endTime).toBeTruthy();
    expect(ended!.status).toBe('ok');
  });

  it('应支持添加事件', () => {
    const span = tracer.startSpan('op');
    tracer.addEvent(span.id, 'db.query', { sql: 'SELECT 1' });
    const result = tracer.getSpan(span.id);
    expect(result!.events).toHaveLength(1);
    expect(result!.events![0].name).toBe('db.query');
  });

  it('应支持按 traceId 获取所有 Span', () => {
    const root = tracer.startSpan('root');
    tracer.startSpan('child1', root.id);
    tracer.startSpan('child2', root.id);
    const trace = tracer.getTrace(root.traceId);
    expect(trace).toHaveLength(3);
  });

  it('应生成追踪树', () => {
    const root = tracer.startSpan('root');
    const child = tracer.startSpan('child', root.id);
    tracer.endSpan(child.id);
    tracer.endSpan(root.id);
    const tree = tracer.getTraceTree(root.traceId);
    expect(tree.name).toBe('root');
  });

  it('应支持采样', () => {
    const samplingTracer = new Tracer({ sampleRate: 0 }); // 0% 采样
    const span = samplingTracer.startSpan('sampled');
    expect(span.id).toBe(''); // 未采样
  });

  it('禁用时应返回空 Span', () => {
    const disabled = new Tracer({ enabled: false });
    expect(disabled.startSpan('test').id).toBe('');
  });

  it('应追踪活跃 Span', () => {
    tracer.startSpan('a');
    tracer.startSpan('b');
    expect(tracer.getActiveSpans()).toHaveLength(2);
  });

  it('clear 应清空', () => {
    tracer.startSpan('test');
    tracer.clear();
    expect(tracer.getActiveSpans()).toHaveLength(0);
  });

  it('endSpan 不存在的 span 返回 undefined', () => {
    expect(tracer.endSpan('nope')).toBeUndefined();
  });

  it('addEvent 到不存在的 span 不抛错', () => {
    expect(() => tracer.addEvent('nope', 'ev')).not.toThrow();
  });

  it('无根 span 的 trace 树返回空对象', () => {
    expect(tracer.getTraceTree('unknown-trace')).toEqual({});
  });

  it('span 可携带 tags', () => {
    const span = tracer.startSpan('tagged', undefined, { region: 'cn-north' });
    expect(tracer.getSpan(span.id)!.tags).toEqual({ region: 'cn-north' });
  });

  it('父 span 不存在时生成新 traceId', () => {
    const span = tracer.startSpan('orphan', 'ghost-parent');
    expect(span.traceId).toBeTruthy();
  });
});

// ============================================================
// HealthRegistry 测试
// ============================================================
describe('HealthRegistry', () => {
  let registry: HealthRegistry;

  beforeEach(() => {
    registry = new HealthRegistry();
  });

  it('未注册检查器时默认为 healthy', () => {
    expect(registry.getOverallStatus()).toBe('healthy');
  });

  it('应执行健康检查', async () => {
    registry.register({
      name: 'database',
      check: async () => ({ component: 'database', status: 'healthy', latency: 0, message: 'ok' }),
    });
    const results = await registry.runAll();
    expect(results.get('database')!.status).toBe('healthy');
  });

  it('应聚合整体健康状态', async () => {
    registry.register({
      name: 'db',
      check: async () => ({ component: 'db', status: 'healthy', latency: 0 }),
    });
    registry.register({
      name: 'cache',
      check: async () => ({ component: 'cache', status: 'degraded', latency: 0, message: 'slow' }),
    });
    await registry.runAll();
    expect(registry.getOverallStatus()).toBe('degraded');
  });

  it('unhealthy 应优先于 degraded', async () => {
    registry.register({
      name: 'a',
      check: async () => ({ component: 'a', status: 'degraded', latency: 0 }),
    });
    registry.register({
      name: 'b',
      check: async () => ({ component: 'b', status: 'unhealthy', latency: 0 }),
    });
    await registry.runAll();
    expect(registry.getOverallStatus()).toBe('unhealthy');
  });

  it('检查失败应标记为 unhealthy', async () => {
    registry.register({
      name: 'failing',
      check: async () => { throw new Error('boom'); },
    });
    await registry.runAll();
    expect(registry.getResult('failing')!.status).toBe('unhealthy');
    expect(registry.getResult('failing')!.message).toBe('boom');
  });

  it('应记录延迟', async () => {
    registry.register({
      name: 'fast',
      check: async () => ({ component: 'fast', status: 'healthy', latency: 0 }),
    });
    await registry.runAll();
    expect(registry.getResult('fast')!.latency).toBeGreaterThanOrEqual(0);
  });

  it('应支持注销', () => {
    registry.register({ name: 'x', check: async () => ({ component: 'x', status: 'healthy', latency: 0 }) });
    expect(registry.unregister('x')).toBe(true);
    expect(registry.unregister('y')).toBe(false);
  });

  it('重复注册应抛出错误', () => {
    registry.register({ name: 'dup', check: async () => ({ component: 'dup', status: 'healthy', latency: 0 }) });
    expect(() => registry.register({ name: 'dup', check: async () => ({ component: 'dup', status: 'healthy', latency: 0 }) })).toThrow('already registered');
  });

  it('getResults 应返回所有结果', async () => {
    registry.register({ name: 'a', check: async () => ({ component: 'a', status: 'healthy', latency: 0 }) });
    registry.register({ name: 'b', check: async () => ({ component: 'b', status: 'healthy', latency: 0 }) });
    await registry.runAll();
    expect(registry.getResults()).toHaveLength(2);
  });

  it('clear 应清空', () => {
    registry.register({ name: 'x', check: async () => ({ component: 'x', status: 'healthy', latency: 0 }) });
    registry.clear();
    expect(registry.getResults()).toHaveLength(0);
  });
});
