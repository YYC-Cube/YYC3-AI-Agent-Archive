# ============================================================
# YYC³ AI Agent Archive — Monorepo 多阶段构建
# 目标：Skill Gateway + MCP Runtime + Agent Runtime
# 策略：pnpm + turborepo + 最小镜像
# ============================================================

# ---- Stage 1: 依赖安装 ----
FROM node:22-alpine AS deps
RUN corepack enable && corepack prepare pnpm@9 --activate
WORKDIR /app

# 仅复制锁文件和包清单，最大化缓存
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY package.json tsconfig.json tsconfig.base.json ./
COPY packages/yyc3-i18n/package.json packages/yyc3-i18n/
COPY packages/skill-registry/package.json packages/skill-registry/
COPY packages/mcp-runtime/package.json packages/mcp-runtime/
COPY packages/skill-gateway/package.json packages/skill-gateway/
COPY packages/skill-sandbox/package.json packages/skill-sandbox/
COPY packages/plugin-marketplace/package.json packages/plugin-marketplace/
COPY packages/conductor/package.json packages/conductor/
COPY packages/agent-runtime/package.json packages/agent-runtime/
COPY packages/orchestrator/package.json packages/orchestrator/
COPY packages/observability/package.json packages/observability/

RUN pnpm install --frozen-lockfile --prod=false

# ---- Stage 2: 构建 ----
FROM deps AS builder
WORKDIR /app

# 复制全部源码
COPY packages/ packages/

# 构建所有包（turborepo 并行构建）
RUN pnpm turbo build

# 清理 node_modules 仅保留生产依赖
RUN pnpm install --frozen-lockfile --prod=true

# ---- Stage 3: Skill Gateway 运行镜像 ----
FROM node:22-alpine AS skill-gateway
RUN corepack enable && corepack prepare pnpm@9 --activate
WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages/yyc3-i18n/dist ./packages/yyc3-i18n/dist
COPY --from=builder /app/packages/yyc3-i18n/package.json ./packages/yyc3-i18n/
COPY --from=builder /app/packages/skill-registry/dist ./packages/skill-registry/dist
COPY --from=builder /app/packages/skill-registry/package.json ./packages/skill-registry/
COPY --from=builder /app/packages/mcp-runtime/dist ./packages/mcp-runtime/dist
COPY --from=builder /app/packages/mcp-runtime/package.json ./packages/mcp-runtime/
COPY --from=builder /app/packages/skill-gateway/dist ./packages/skill-gateway/dist
COPY --from=builder /app/packages/skill-gateway/package.json ./packages/skill-gateway/
COPY --from=builder /app/packages/skill-sandbox/dist ./packages/skill-sandbox/dist
COPY --from=builder /app/packages/skill-sandbox/package.json ./packages/skill-sandbox/
COPY --from=builder /app/packages/plugin-marketplace/dist ./packages/plugin-marketplace/dist
COPY --from=builder /app/packages/plugin-marketplace/package.json ./packages/plugin-marketplace/
COPY --from=builder /app/packages/conductor/dist ./packages/conductor/dist
COPY --from=builder /app/packages/conductor/package.json ./packages/conductor/
COPY --from=builder /app/packages/observability/dist ./packages/observability/dist
COPY --from=builder /app/packages/observability/package.json ./packages/observability/

RUN addgroup -g 1001 -S yyc3 && adduser -u 1001 -S yyc3 -G yyc3
USER yyc3
EXPOSE 3030
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:3030/health || exit 1
CMD ["node", "packages/skill-gateway/dist/index.js"]

# ---- Stage 4: MCP Runtime 运行镜像 ----
FROM node:22-alpine AS mcp-runtime
RUN corepack enable && corepack prepare pnpm@9 --activate
WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages/yyc3-i18n/dist ./packages/yyc3-i18n/dist
COPY --from=builder /app/packages/yyc3-i18n/package.json ./packages/yyc3-i18n/
COPY --from=builder /app/packages/mcp-runtime/dist ./packages/mcp-runtime/dist
COPY --from=builder /app/packages/mcp-runtime/package.json ./packages/mcp-runtime/
COPY --from=builder /app/packages/observability/dist ./packages/observability/dist
COPY --from=builder /app/packages/observability/package.json ./packages/observability/

RUN addgroup -g 1001 -S yyc3 && adduser -u 1001 -S yyc3 -G yyc3
USER yyc3
EXPOSE 3031
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:3031/health || exit 1
CMD ["node", "packages/mcp-runtime/dist/index.js"]

# ---- Stage 5: Agent Runtime 运行镜像 ----
FROM node:22-alpine AS agent-runtime
RUN corepack enable && corepack prepare pnpm@9 --activate
WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages/yyc3-i18n/dist ./packages/yyc3-i18n/dist
COPY --from=builder /app/packages/yyc3-i18n/package.json ./packages/yyc3-i18n/
COPY --from=builder /app/packages/agent-runtime/dist ./packages/agent-runtime/dist
COPY --from=builder /app/packages/agent-runtime/package.json ./packages/agent-runtime/
COPY --from=builder /app/packages/orchestrator/dist ./packages/orchestrator/dist
COPY --from=builder /app/packages/orchestrator/package.json ./packages/orchestrator/
COPY --from=builder /app/packages/observability/dist ./packages/observability/dist
COPY --from=builder /app/packages/observability/package.json ./packages/observability/

RUN addgroup -g 1001 -S yyc3 && adduser -u 1001 -S yyc3 -G yyc3
USER yyc3
EXPOSE 3032
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:3032/health || exit 1
CMD ["node", "packages/agent-runtime/dist/index.js"]
