# 团队yyc3 应用镜像构建规则
FROM node:18-alpine AS base
WORKDIR /app
USER node

# 依赖安装阶段
FROM base AS deps
COPY --chown=node:node package.json package-lock.json ./
RUN npm ci --only=production

# 构建阶段
FROM base AS builder
COPY --chown=node:node package.json package-lock.json ./
RUN npm ci
COPY --chown=node:node . .
RUN npm run build

# 运行阶段（最小镜像）
FROM base AS runner
COPY --chown=node:node --from=deps /app/node_modules ./node_modules
COPY --chown=node:node --from=builder /app/dist ./dist
COPY --chown=node:node --from=builder /app/package.json ./
COPY --chown=node:node .env.docker ./

# 权限限制
RUN chmod 600 .env.docker
EXPOSE 3200
CMD ["node", "dist/index.js"]
