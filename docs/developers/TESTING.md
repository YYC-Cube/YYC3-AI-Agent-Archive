# YYC³ 测试文档

> 核心平台测试策略、框架与规范。

## 一、测试框架

| 工具 | 版本 | 用途 |
| ---- | ---- | ---- |
| Vitest | ^4.1.11 | 单元/集成测试 |
| @vitest/coverage-v8 | ^4.1.11 | 覆盖率 |
| tsup | 8.4.0 | 构建验证 |

## 二、测试矩阵

| 层级 | 范围 | 框架 | 位置 |
| ---- | ---- | ---- | ---- |
| 单元测试 | 函数/类级 | Vitest | `packages/*/tests/**/*.test.ts` |
| 集成测试 | 模块交互 | Vitest | `packages/*/tests/**/*.test.ts` |
| E2E 测试 | 服务端到端 | Vitest + 工厂 App | `packages/*/tests/*.test.ts` |
| 审计测试 | 安全/合规 | Vitest | `packages/*/tests/*.test.ts` |

## 三、运行测试

### 3.1 全量测试

```bash
pnpm run test              # 默认 locale（zh-CN）
LANG=en_US.UTF-8 pnpm run test   # 英文 locale（i18n 双跑）
```

### 3.2 单包测试

```bash
pnpm --filter @yyc3/skill-registry test
```

### 3.3 覆盖率

```bash
pnpm --filter @yyc3/i18n-core test -- --coverage
```

各包 `vitest.config.ts` 配置覆盖率阈值（语句/分支/函数/行）。

## 四、i18n 双跑规范

所有涉及用户可见文本的测试**必须**在中英文 locale 下均通过：

```bash
pnpm run test                          # 中文
LANG=en_US.UTF-8 pnpm run test         # 英文
```

**已知 flaky**：turbo 并行下偶发单包失败（如 yyc3-cli、plugin-marketplace），单独跑或重跑全仓可通过。这是 turbo 共享状态问题，非代码缺陷。

## 五、测试编写规范

### 5.1 文件命名

```
packages/<pkg>/tests/<feature>.test.ts
```

### 5.2 结构

```typescript
import { describe, it, expect, beforeEach } from 'vitest';

describe('<Feature>', () => {
  beforeEach(() => { /* 准备 */ });

  it('should <behavior>', () => {
    // 1. arrange
    // 2. act
    // 3. assert
  });
});
```

### 5.3 工厂模式（服务端测试）

服务端应用使用工厂函数构建，便于测试注入：

```typescript
const app = createSkillGatewayApp({ apiKeys: ['test-key'] });
const res = await app.request('/health');
expect(res.status).toBe(200);
```

### 5.4 断言要求

- 使用 `expect()` 断言，禁止 `console.log` 替代断言
- 异步测试使用 `async/await` 或 `return promise`
- 测试必须可独立运行，不依赖执行顺序

## 六、安全测试

安全相关测试必须覆盖：

| 场景 | 断言 |
| ---- | ---- |
| 命令黑名单 | rm/sudo/chmod/killall 等 28 条命令被拒绝 |
| 路径穿越 | `../` 等路径被拦截 |
| 环境泄漏 | 子进程环境不含主机 API Key |
| 超时 | 超时值钳制在 30-300s |
| 输出截断 | stdout/stderr 截断至 1MB |
| 认证 | 无密钥 503、缺凭证 401、错凭证 403 |
| 限流 | 超限返回 429 |

## 七、CI 门禁

`.github/workflows/ci.yml` 执行：

```
pnpm install
→ pnpm run lint
→ pnpm run typecheck
→ pnpm run test（Node 22/24 矩阵）
→ pnpm run build
→ skills 审计（validate/dedup/score）
```

**全部通过**才能合并 PR。

## 八、质量门禁（doctor）

```bash
pnpm run doctor
```

六检聚合：

| 检查 | 说明 |
| ---- | ---- |
| validate | Skill frontmatter 校验 |
| dedup | 资产去重 |
| score | Skill 质量评分 |
| registry | 注册中心一致性 |
| graph | 依赖图 |
| example | 示例构建 |

---

**YanYuCloudCube** · 言启千行代码，语枢万物智能
