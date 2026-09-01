/**
 * Observability — 链路追踪器
 *
 * 支持 Span 创建、父子关系、事件记录、采样控制
 * 遵循 OpenTelemetry 语义约定
 */
import type { Span, SpanEvent, TracerConfig } from './types.js';

const DEFAULT_CONFIG: TracerConfig = {
  sampleRate: 1.0,
  enabled: true,
};

export class Tracer {
  readonly config: TracerConfig;
  private spans = new Map<string, Span>();
  private activeSpans = new Map<string, Span>();

  constructor(config: Partial<TracerConfig> = {}) {
    this.config = { ...DEFAULT_CONFIG, ...config };
  }

  /** 开始一个新的 Span */
  startSpan(name: string, parentId?: string, tags?: Record<string, string>): Span {
    if (!this.config.enabled) {
      return { id: '', traceId: '', name, startTime: 0, status: 'ok' };
    }

    // 采样判定
    if (Math.random() > this.config.sampleRate) {
      return { id: '', traceId: '', name, startTime: 0, status: 'ok' };
    }

    const traceId = parentId
      ? (this.spans.get(parentId)?.traceId ?? this.generateId())
      : this.generateId();

    const span: Span = {
      id: this.generateId(),
      traceId,
      parentId,
      name,
      startTime: Date.now(),
      status: 'ok',
      tags,
      events: [],
    };

    this.spans.set(span.id, span);
    this.activeSpans.set(span.id, span);
    return span;
  }

  /** 结束 Span */
  endSpan(spanId: string, status: Span['status'] = 'ok'): Span | undefined {
    const span = this.spans.get(spanId);
    if (!span) return undefined;

    span.endTime = Date.now();
    span.status = status;
    this.activeSpans.delete(spanId);
    return span;
  }

  /** 添加事件到 Span */
  addEvent(spanId: string, name: string, attributes?: Record<string, string>): void {
    const span = this.spans.get(spanId);
    if (!span) return;

    const event: SpanEvent = {
      name,
      timestamp: Date.now(),
      attributes,
    };
    span.events = span.events ?? [];
    span.events.push(event);
  }

  /** 获取 Span */
  getSpan(spanId: string): Span | undefined {
    return this.spans.get(spanId);
  }

  /** 按 traceId 获取所有 Span */
  getTrace(traceId: string): Span[] {
    return Array.from(this.spans.values()).filter(s => s.traceId === traceId);
  }

  /** 获取所有 Span 的树形结构 */
  getTraceTree(traceId: string): Record<string, unknown> {
    const spans = this.getTrace(traceId);
    const root = spans.find(s => !s.parentId);
    if (!root) return {};

    const buildTree = (span: Span): Record<string, unknown> => {
      const children = spans
        .filter(s => s.parentId === span.id)
        .map(buildTree);
      return {
        id: span.id,
        name: span.name,
        status: span.status,
        duration: (span.endTime ?? Date.now()) - span.startTime,
        children: children.length > 0 ? children : undefined,
      };
    };
    return buildTree(root);
  }

  /** 获取活跃 Span */
  getActiveSpans(): Span[] {
    return Array.from(this.activeSpans.values());
  }

  /** 清空 */
  clear(): void {
    this.spans.clear();
    this.activeSpans.clear();
  }

  private generateId(): string {
    return Math.random().toString(36).slice(2, 10) + Date.now().toString(36);
  }
}