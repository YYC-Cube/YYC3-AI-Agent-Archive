/**
 * Skill Gateway — 独立服务入口
 *
 * 用途：容器化部署（Dockerfile stage: skill-gateway）
 * 组装 registry + loader + executor 并启动 HTTP 服务
 */
import { SkillLoader, SkillExecutor, globalSkillRegistry } from '@yyc3/skill-registry';
import { SkillGateway } from './gateway.js';

const port = Number(process.env.PORT ?? 3030);
const skillsRootDir = process.env.SKILLS_ROOT_DIR ?? './skills';

const loader = new SkillLoader(globalSkillRegistry, {
  rootDir: skillsRootDir,
  maxDepth: 3,
});

const executor = new SkillExecutor(globalSkillRegistry);

const gateway = new SkillGateway(
  { registry: globalSkillRegistry, loader, executor },
  { port }
);

await gateway.start(port);

// Node 下 serve() 为异步启动，周期性健康检查由容器 HEALTHCHECK 接管
process.on('SIGTERM', () => process.exit(0));
process.on('SIGINT', () => process.exit(0));
