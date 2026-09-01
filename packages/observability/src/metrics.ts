/**
 * Observability — 指标收集器
 *
 * 支持 Counter（计数器）、Gauge（仪表盘）、Histogram（直方图）
 * 提供指标注册、快照导出、Prometheus 格式输出
 */
import type { Labels, MetricDef, MetricSnapshot, MetricType } from './types.js';

interface MetricValue {
  def: MetricDef;
  value: number;
  buckets?: Map<number, number>;
  values?: number[];
}

export class MetricsRegistry {
  private metrics = new Map<string, MetricValue>();

  /** 注册 Counter */
  counter(name: string, help: string, labels?: Labels): Counter {
    const def: MetricDef = { name, type: 'counter', help, labels };
    if (this.metrics.has(name)) {
      throw new Error(`Metric "${name}" already registered`);
    }
    this.metrics.set(name, { def, value: 0 });
    return new Counter(name, this.metrics);
  }

  /** 注册 Gauge */
  gauge(name: string, help: string, labels?: Labels): Gauge {
    const def: MetricDef = { name, type: 'gauge', help, labels };
    if (this.metrics.has(name)) {
      throw new Error(`Metric "${name}" already registered`);
    }
    this.metrics.set(name, { def, value: 0 });
    return new Gauge(name, this.metrics);
  }

  /** 注册 Histogram */
  histogram(name: string, help: string, buckets: number[], labels?: Labels): Histogram {
    const def: MetricDef = { name, type: 'histogram', help, labels };
    if (this.metrics.has(name)) {
      throw new Error(`Metric "${name}" already registered`);
    }
    const bmap = new Map<number, number>();
    for (const b of buckets.sort((a, b) => a - b)) {
      bmap.set(b, 0);
    }
    this.metrics.set(name, { def, value: 0, buckets: bmap, values: [] });
    return new Histogram(name, this.metrics);
  }

  /** 获取所有指标快照 */
  snapshot(): MetricSnapshot[] {
    return Array.from(this.metrics.values()).map(({ def, value, buckets, values }) => {
      const snap: MetricSnapshot = {
        name: def.name,
        type: def.type,
        help: def.help,
        value,
        labels: def.labels,
      };
      if (buckets) {
        snap.buckets = Object.fromEntries(buckets);
      }
      if (values) {
        snap.count = values.length;
        snap.sum = values.reduce((a, b) => a + b, 0);
      }
      return snap;
    });
  }

  /** 导出 Prometheus 格式 */
  toPrometheus(): string {
    const lines: string[] = [];
    for (const { def, value, buckets } of this.metrics.values()) {
      lines.push(`# HELP ${def.name} ${def.help}`);
      lines.push(`# TYPE ${def.name} ${def.type}`);
      if (buckets) {
        for (const [le, count] of buckets) {
          lines.push(`${def.name}_bucket{le="${le}"} ${count}`);
        }
        lines.push(`${def.name}_bucket{le="+Inf"} ${value}`);
      }
      lines.push(`${def.name} ${value}`);
    }
    return lines.join('\n') + '\n';
  }

  /** 清空所有指标 */
  clear(): void {
    this.metrics.clear();
  }
}

// ---- Metric 类型 ----

class Counter {
  constructor(readonly name: string, private store: Map<string, MetricValue>) {}

  inc(by = 1): void {
    const m = this.store.get(this.name);
    if (m) m.value += by;
  }

  get(): number {
    return this.store.get(this.name)?.value ?? 0;
  }
}

class Gauge {
  constructor(readonly name: string, private store: Map<string, MetricValue>) {}

  set(value: number): void {
    const m = this.store.get(this.name);
    if (m) m.value = value;
  }

  inc(by = 1): void {
    const m = this.store.get(this.name);
    if (m) m.value += by;
  }

  dec(by = 1): void {
    const m = this.store.get(this.name);
    if (m) m.value -= by;
  }

  get(): number {
    return this.store.get(this.name)?.value ?? 0;
  }
}

class Histogram {
  constructor(readonly name: string, private store: Map<string, MetricValue>) {}

  observe(value: number): void {
    const m = this.store.get(this.name);
    if (!m) return;
    m.value++;
    m.values?.push(value);
    if (m.buckets) {
      for (const [le] of m.buckets) {
        if (value <= le) {
          m.buckets.set(le, (m.buckets.get(le) ?? 0) + 1);
          break;
        }
      }
    }
  }

  get(): number {
    return this.store.get(this.name)?.value ?? 0;
  }
}