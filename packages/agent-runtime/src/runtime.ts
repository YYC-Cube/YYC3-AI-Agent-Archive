/**
 * Agent Runtime — 智能体运行时引擎
 *
 * 核心能力：
 * - 智能体生命周期管理（创建/销毁/状态切换）
 * - 对话上下文管理（消息历史/内存存储）
 * - 工具调用（桥接 MCP 运行时）
 * - 多智能体通信（Family Message 协议）
 * - 事件驱动架构
 */
import { EventEmitter } from 'eventemitter3';
import type {
  Agent,
  AgentProfile,
  AgentStatus,
  AgentRuntimeConfig,
  AgentRuntimeEvents,
  Message,
  MessageRole,
  ToolCall,
  FamilyMessage,
} from './types.js';

const DEFAULT_CONFIG: AgentRuntimeConfig = {
  maxMessages: 1000,
  defaultTimeout: 30_000,
  autoHeartbeat: false,
  heartbeatInterval: 30_000,
};

let instanceCounter = 0;

export class AgentRuntime extends EventEmitter<AgentRuntimeEvents> {
  readonly config: AgentRuntimeConfig;
  private agents = new Map<string, Agent>();
  private heartbeatTimers = new Map<string, ReturnType<typeof setInterval>>();

  constructor(config: Partial<AgentRuntimeConfig> = {}) {
    super();
    this.config = { ...DEFAULT_CONFIG, ...config };
  }

  /** 创建智能体实例 */
  createAgent(profile: AgentProfile, id?: string): Agent {
    const agentId = id ?? `${profile.nameEN}-${++instanceCounter}`;

    if (this.agents.has(agentId)) {
      throw new Error(`Agent '${agentId}' already exists`);
    }

    const agent: Agent = {
      id: agentId,
      profile,
      status: 'idle',
      messages: [],
      memory: new Map(),
      createdAt: new Date().toISOString(),
      lastActiveAt: new Date().toISOString(),
    };

    this.agents.set(agentId, agent);
    this.emit('agent:created', agent);

    if (this.config.autoHeartbeat) {
      this.startHeartbeat(agentId);
    }

    return agent;
  }

  /** 销毁智能体 */
  destroyAgent(agentId: string): boolean {
    this.stopHeartbeat(agentId);
    const deleted = this.agents.delete(agentId);
    if (deleted) {
      this.emit('agent:destroyed', agentId);
    }
    return deleted;
  }

  /** 获取智能体 */
  getAgent(agentId: string): Agent | undefined {
    return this.agents.get(agentId);
  }

  /** 列出所有智能体 */
  listAgents(): Agent[] {
    return Array.from(this.agents.values());
  }

  /** 按状态筛选 */
  listByStatus(status: AgentStatus): Agent[] {
    return this.listAgents().filter(a => a.status === status);
  }

  /** 设置智能体状态 */
  setStatus(agentId: string, status: AgentStatus): boolean {
    const agent = this.agents.get(agentId);
    if (!agent) return false;

    const from = agent.status;
    agent.status = status;
    agent.lastActiveAt = new Date().toISOString();
    this.emit('agent:status', agentId, from, status);
    return true;
  }

  /** 发送消息（用户→智能体 或 智能体→智能体） */
  sendMessage(
    content: string,
    from: string,
    to: string,
    role: MessageRole = 'user',
    meta?: Record<string, unknown>
  ): Message {
    const agent = this.agents.get(to);
    if (!agent) {
      throw new Error(`Target agent '${to}' not found`);
    }

    const message: Message = {
      id: `msg-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      role,
      content,
      senderId: from,
      targetId: to,
      timestamp: new Date().toISOString(),
      meta,
    };

    agent.messages.push(message);
    agent.lastActiveAt = new Date().toISOString();

    // 裁剪历史
    if (agent.messages.length > this.config.maxMessages) {
      agent.messages = agent.messages.slice(-this.config.maxMessages);
    }

    this.emit('message:sent', message);
    this.emit('message:received', message);

    return message;
  }

  /** 智能体回复（模拟 LLM 响应） */
  agentReply(
    agentId: string,
    content: string,
    targetId?: string,
    toolCalls?: ToolCall[]
  ): Message {
    const agent = this.agents.get(agentId);
    if (!agent) {
      throw new Error(`Agent '${agentId}' not found`);
    }

    const message: Message = {
      id: `reply-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      role: 'agent',
      content,
      senderId: agentId,
      targetId,
      timestamp: new Date().toISOString(),
      toolCalls,
    };

    agent.messages.push(message);
    agent.lastActiveAt = new Date().toISOString();

    this.emit('message:sent', message);
    return message;
  }

  /** 智能体间通信（Family Message 协议） */
  familyMessage(msg: Omit<FamilyMessage, 'timestamp'>): FamilyMessage {
    const fullMsg: FamilyMessage = {
      ...msg,
      timestamp: new Date().toISOString(),
    };

    // 更新双方智能体活跃时间
    const from = this.agents.get(msg.from);
    const to = this.agents.get(msg.to);
    if (from) from.lastActiveAt = fullMsg.timestamp;
    if (to) to.lastActiveAt = fullMsg.timestamp;

    this.emit('family:message', fullMsg);
    return fullMsg;
  }

  /** 广播给所有智能体 */
  broadcast(content: string, from: string): void {
    for (const [id] of this.agents) {
      if (id !== from) {
        this.familyMessage({ from, to: id, type: 'broadcast', content });
      }
    }
  }

  /** 记录工具调用 */
  recordToolCall(agentId: string, toolCall: ToolCall): void {
    const agent = this.agents.get(agentId);
    if (!agent) return;

    agent.lastActiveAt = new Date().toISOString();
    this.emit('tool:called', agentId, toolCall);
  }

  /** 获取对话历史 */
  getMessages(agentId: string, limit?: number): Message[] {
    const agent = this.agents.get(agentId);
    if (!agent) return [];
    if (limit) return agent.messages.slice(-limit);
    return [...agent.messages];
  }

  /** 设置内存值 */
  setMemory(agentId: string, key: string, value: unknown): boolean {
    const agent = this.agents.get(agentId);
    if (!agent) return false;
    agent.memory.set(key, value);
    return true;
  }

  /** 获取内存值 */
  getMemory<T = unknown>(agentId: string, key: string): T | undefined {
    return this.agents.get(agentId)?.memory.get(key) as T | undefined;
  }

  /** 清除智能体内存 */
  clearMemory(agentId: string): boolean {
    const agent = this.agents.get(agentId);
    if (!agent) return false;
    agent.memory.clear();
    return true;
  }

  /** 获取统计信息 */
  stats(): { total: number; perStatus: Record<AgentStatus, number> } {
    const agents = this.listAgents();
    const perStatus: Record<AgentStatus, number> = {
      idle: 0, thinking: 0, acting: 0, waiting: 0, error: 0, offline: 0,
    };
    for (const a of agents) {
      perStatus[a.status]++;
    }
    return { total: agents.length, perStatus };
  }

  /** 心跳 */
  private startHeartbeat(agentId: string): void {
    this.stopHeartbeat(agentId);
    const timer = setInterval(() => {
      const agent = this.agents.get(agentId);
      if (agent) {
        agent.lastActiveAt = new Date().toISOString();
      }
    }, this.config.heartbeatInterval);
    this.heartbeatTimers.set(agentId, timer);
  }

  private stopHeartbeat(agentId: string): void {
    const timer = this.heartbeatTimers.get(agentId);
    if (timer) {
      clearInterval(timer);
      this.heartbeatTimers.delete(agentId);
    }
  }
}