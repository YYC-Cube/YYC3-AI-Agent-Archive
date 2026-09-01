/**
 * Orchestrator 测试套件
 */
import type { AgentProfile } from '@yyc3/agent-runtime';
import { AI_FAMILY_PROFILES } from '@yyc3/agent-runtime';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { TaskDecomposer } from '../src/decomposer.js';
import { Orchestrator } from '../src/orchestrator.js';
import { SmartScheduler } from '../src/scheduler.js';
import type { AtomicTask } from '../src/types.js';

// ============================================================
// TaskDecomposer 测试
// ============================================================
describe('TaskDecomposer', () => {
  let decomposer: TaskDecomposer;

  beforeEach(() => {
    decomposer = new TaskDecomposer();
  });

  it('应根据能力分解目标为子任务', () => {
    const result = decomposer.decompose('进行代码审查', ['代码审查', '性能分析']);
    expect(result.tasks.length).toBeGreaterThan(0);
    expect(result.reasoning).toContain('代码审查');
  });

  it('应生成合理的子任务描述', () => {
    const result = decomposer.decompose('分析数据', ['深度数据分析', '归纳推理']);
    const descriptions = result.tasks.map(t => t.description);
    expect(descriptions).toContain('数据清洗');
    expect(descriptions).toContain('模式识别');
  });

  it('当无法匹配能力时应使用通用模板', () => {
    const result = decomposer.decompose('do something', ['unknown-capability']);
    expect(result.tasks.length).toBeGreaterThan(0);
    expect(result.tasks[0].description).toBe('理解需求');
  });

  it('应设置任务依赖关系', () => {
    const result = decomposer.decompose('构建应用', ['build']);
    const tasks = result.tasks;
    // 第一个任务应无依赖
    expect(tasks[0].dependencies).toHaveLength(0);
    // 后续任务应有依赖
    if (tasks.length > 1) {
      expect(tasks[1].dependencies.length).toBeGreaterThan(0);
    }
  });

  it('应限制最大子任务数', () => {
    const limited = new TaskDecomposer({ maxSubTasks: 3 });
    // 使用多个能力来产生更多子任务
    const result = limited.decompose('test', [
      '自然语言理解', '语义推理', '意图分类', '深度数据分析',
      '归纳推理', '代码审查', '性能分析', '安全防护',
    ]);
    expect(result.tasks.length).toBeLessThanOrEqual(3);
  });

  it('LLM 策略未配置端点时应抛出错误', () => {
    const llm = new TaskDecomposer({ strategy: 'llm' });
    expect(() => llm.decompose('test', [])).toThrow('not yet implemented');
  });
});

// ============================================================
// SmartScheduler 测试
// ============================================================
describe('SmartScheduler', () => {
  let scheduler: SmartScheduler;
  const agents: AgentProfile[] = AI_FAMILY_PROFILES;

  const makeTask = (id: string, capabilities: string[]): AtomicTask => ({
    id,
    description: 'test task',
    requiredCapabilities: capabilities,
    priority: 'medium',
    status: 'pending',
    dependencies: [],
    estimatedComplexity: 3,
    createdAt: new Date().toISOString(),
  });

  beforeEach(() => {
    scheduler = new SmartScheduler();
  });

  it('应交由能力最匹配的智能体', () => {
    const task = makeTask('t1', ['代码审查']);
    const decision = scheduler.schedule(task, agents);
    expect(decision.agentName).toBe('格物·宗师');
    expect(decision.score).toBeGreaterThan(0);
  });

  it('安全任务应交由智云·守护', () => {
    const task = makeTask('t2', ['安全防护', '威胁检测']);
    const decision = scheduler.schedule(task, agents);
    expect(decision.agentName).toBe('智云·守护');
  });

  it('创意任务应交由创想·灵韵', () => {
    const task = makeTask('t3', ['创意生成', '设计思维']);
    const decision = scheduler.schedule(task, agents);
    expect(decision.agentName).toBe('创想·灵韵');
  });

  it('多能力交叉任务应交由匹配度最高的', () => {
    const task = makeTask('t4', ['深度数据分析', '归纳推理', '知识图谱构建']);
    const decision = scheduler.schedule(task, agents);
    // 语枢·万物 拥有全部三种能力
    expect(decision.agentName).toBe('语枢·万物');
    expect(decision.score).toBe(1.0);
  });

  it('无匹配能力时应抛出错误', () => {
    const task = makeTask('t5', ['不存在的技能X', '天体物理']);
    expect(() => scheduler.schedule(task, agents)).toThrow('threshold');
  });

  it('轮询策略应循环分配', () => {
    const rr = new SmartScheduler({ strategy: 'round-robin' });
    const t1 = makeTask('a', ['代码审查']);
    const t2 = makeTask('b', ['代码审查']);
    const d1 = rr.schedule(t1, agents);
    const d2 = rr.schedule(t2, agents);
    expect(d1.assignedAgentId).not.toBe(d2.assignedAgentId);
  });

  describe('scoreAgents', () => {
    it('应返回所有智能体的能力分数', () => {
      const task = makeTask('t6', ['代码审查']);
      const scores = scheduler.scoreAgents(task, agents);
      expect(scores).toHaveLength(agents.length);
      // 格物·宗师应得分最高
      const grandmaster = scores.find(s => s.agentName === '格物·宗师');
      expect(grandmaster!.score).toBeGreaterThan(0);
    });
  });

  describe('sortByPriority', () => {
    it('应按优先级排序', () => {
      const tasks: AtomicTask[] = [
        makeTask('a', []), makeTask('b', []), makeTask('c', []), makeTask('d', []),
      ];
      tasks[0].priority = 'low';
      tasks[1].priority = 'critical';
      tasks[2].priority = 'medium';
      tasks[3].priority = 'high';
      const sorted = scheduler.sortByPriority(tasks);
      expect(sorted[0].priority).toBe('critical');
      expect(sorted[1].priority).toBe('high');
      expect(sorted[2].priority).toBe('medium');
      expect(sorted[3].priority).toBe('low');
    });
  });

  describe('getReadyTasks', () => {
    it('应返回依赖已满足的任务', () => {
      const tasks: AtomicTask[] = [
        { ...makeTask('a', []), status: 'completed' },
        { ...makeTask('b', []), dependencies: ['a'], status: 'pending' },
        { ...makeTask('c', []), dependencies: ['a', 'b'], status: 'pending' },
        { ...makeTask('d', []), dependencies: ['x'], status: 'pending' },
      ];
      const ready = scheduler.getReadyTasks(tasks);
      expect(ready).toHaveLength(1);
      expect(ready[0].id).toBe('b');
    });
  });
});

// ============================================================
// Orchestrator 集成测试
// ============================================================
describe('Orchestrator', () => {
  let orchestrator: Orchestrator;
  const agents = AI_FAMILY_PROFILES;

  beforeEach(() => {
    orchestrator = new Orchestrator();
  });

  it('应创建并执行工作流', async () => {
    const workflow = await orchestrator.execute(
      '审查代码并分析性能',
      ['代码审查', '性能分析'],
      agents
    );
    expect(workflow.status).toBe('completed');
    expect(workflow.tasks.length).toBeGreaterThan(0);
    expect(workflow.completedAt).toBeTruthy();
  });

  it('应触发 workflow:created 事件', async () => {
    const handler = vi.fn();
    orchestrator.on('workflow:created', handler);
    await orchestrator.execute('test', ['代码审查'], agents);
    expect(handler).toHaveBeenCalledTimes(1);
  });

  it('应触发 workflow:completed 事件', async () => {
    const handler = vi.fn();
    orchestrator.on('workflow:completed', handler);
    await orchestrator.execute('test', ['代码审查'], agents);
    expect(handler).toHaveBeenCalledTimes(1);
  });

  it('应触发 task:decomposed 事件', async () => {
    const handler = vi.fn();
    orchestrator.on('task:decomposed', handler);
    await orchestrator.execute('test', ['代码审查'], agents);
    expect(handler).toHaveBeenCalledTimes(1);
  });

  it('应触发 scheduled 事件', async () => {
    const handler = vi.fn();
    orchestrator.on('scheduled', handler);
    await orchestrator.execute('test', ['代码审查', '性能分析'], agents);
    expect(handler).toHaveBeenCalled();
  });

  it('应支持注册自定义处理器', async () => {
    const handler = vi.fn().mockResolvedValue('custom result');
    orchestrator.registerHandler('代码审查', handler);
    await orchestrator.execute('review', ['代码审查'], agents);
    expect(handler).toHaveBeenCalled();
  });

  it('应通过 getWorkflow 获取工作流', async () => {
    const wf = await orchestrator.execute('test', ['代码审查'], agents);
    const found = orchestrator.getWorkflow(wf.id);
    expect(found).toBeDefined();
    expect(found!.id).toBe(wf.id);
  });

  it('应支持 listWorkflows', async () => {
    await orchestrator.execute('wf1', ['代码审查'], agents);
    await orchestrator.execute('wf2', ['性能分析'], agents);
    expect(orchestrator.listWorkflows()).toHaveLength(2);
  });

  it('无可用智能体时应触发 workflow:failed', async () => {
    const handler = vi.fn();
    orchestrator.on('workflow:failed', handler);
    await orchestrator.execute('test', ['不存在的技能'], agents);
    expect(handler).toHaveBeenCalled();
  });
});
