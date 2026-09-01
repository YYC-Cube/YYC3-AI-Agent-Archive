#!/usr/bin/env node

/**
 * YYC³ Skill/Plugin 模板生成器
 *
 * 用法:
 *   node scripts/create-skill.js <domain> <name> <type> [runtime]
 *   node scripts/create-plugin.js <domain> <name> <type>
 *
 * 示例:
 *   node scripts/create-skill.js ai-ml my-rag-agent agent python
 *   node scripts/create-plugin.js dev-tools code-formatter tool
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');

// ================================================================
// AYNC 命名规范
// ================================================================
const AYNC_TYPES = {
  agent: 'A',
  tool: 'T',
  workflow: 'W',
  hybrid: 'H',
  module: 'M',
};

const VALID_DOMAINS = [
  'ai-ml', 'dev-workflow', 'devops', 'security', 'data-engineering',
  'cloud-infrastructure', 'api-scaffolding', 'frontend', 'backend',
  'mobile', 'testing', 'documentation', 'monitoring', 'ci-cd',
  'marketplace', 'glm', 'b2b', 'social-search', 'ui-ux', 'marketing',
  'yyc3', 'community',
];

function generateAYNCId(domain, name, type) {
  const t = AYNC_TYPES[type] || 'M';
  const d = domain.toUpperCase().replace(/[^A-Z0-9]/g, '-');
  const n = name.toUpperCase().replace(/[^A-Z0-9]/g, '-');
  return `AYNC-${t}-${d}-${n}`;
}

function generateSkillMD(domain, name, type, runtime, title, description) {
  const ayncId = generateAYNCId(domain, name, type);
  const now = new Date().toISOString().split('T')[0];

  return `---
id: ${ayncId}
name: ${name}
description: ${description}
category: ${domain}
type: ${type}
runtime: ${runtime}
version: 1.0.0
author: YYC³ Team <admin@0379.email>
created: ${now}
tags: [${domain}, ${type}]
inputs:
  - name: input
    type: string
    description: 输入参数
    required: true
outputs:
  - type: text
    description: 处理结果
---

# ${title}

${description}

## 功能概述

- 功能点 1
- 功能点 2
- 功能点 3

## 使用场景

描述在什么场景下使用此技能。

## 输入参数

| 参数名 | 类型   | 必填 | 默认值 | 描述         |
| ------ | ------ | ---- | ------ | ------------ |
| input  | string | 是   | -      | 输入参数说明 |

## 输出格式

\`\`\`json
{
  "result": "处理结果",
  "metadata": {
    "duration": 0,
    "status": "success"
  }
}
\`\`\`

## 使用示例

\`\`\`typescript
import { createSkillGateway } from '@yyc3/skill-gateway';

const gateway = createSkillGateway();
const result = await gateway.execute('${name}', { input: '示例输入' });
console.log(result);
\`\`\`

## 依赖

- 列出依赖的其他技能或插件
- 列出所需的运行时环境

## 注意事项

- 注意事项 1
- 注意事项 2
`;
}

function generatePluginMD(domain, name, type, title, description) {
  const now = new Date().toISOString().split('T')[0];

  return `---
id: PLUGIN-${domain.toUpperCase()}-${name.toUpperCase().replace(/[^A-Z0-9]/g, '-')}
name: ${name}
description: ${description}
category: ${domain}
type: ${type}
version: 1.0.0
author: YYC³ Team <admin@0379.email>
created: ${now}
tags: [${domain}, ${type}]
---

# ${title}

${description}

## 插件功能

- 功能点 1
- 功能点 2
- 功能点 3

## 安装

\`\`\`bash
yyc3 plugins install ${name}
\`\`\`

## 配置

\`\`\`json
{
  "${name}": {
    "enabled": true,
    "option1": "value1"
  }
}
\`\`\`

## API

### \`activate()\`

激活插件，执行初始化逻辑。

### \`deactivate()\`

停用插件，清理资源。

### \`execute(params)\`

执行插件功能。

## 依赖

- 列出依赖的其他插件或技能

## 注意事项

- 注意事项 1
- 注意事项 2
`;
}

// ================================================================
// CLI
// ================================================================

const [, , command, ...args] = process.argv;

function showHelp() {
  console.log(`
YYC³ Skill/Plugin 模板生成器

用法:
  node scripts/create-skill.js <domain> <name> <type> <runtime> <title>

参数:
  domain  领域 (${VALID_DOMAINS.join(', ')})
  name    技能名称 (kebab-case)
  type    类型 (agent|tool|workflow|hybrid|module)
  runtime 运行时 (node|python|shell|native|docker)
  title   显示标题 (引号包裹)

示例:
  node scripts/create-skill.js ai-ml my-rag-agent agent python "我的 RAG 智能体"
  node scripts/create-plugin.js dev-tools code-formatter tool "代码格式化工具"
`);
}

if (!command || command === '--help' || command === '-h') {
  showHelp();
  process.exit(0);
}

if (command === 'create-skill' || command === 'skill') {
  const [domain, name, type, runtime, ...titleParts] = args;
  const title = titleParts.join(' ');

  if (!domain || !name || !type || !runtime) {
    console.error('用法: node scripts/create-skill.js <domain> <name> <type> <runtime> <title>');
    process.exit(1);
  }

  if (!VALID_DOMAINS.includes(domain)) {
    console.warn(`警告: 领域 "${domain}" 不在已知领域列表中，将创建新领域目录。`);
  }

  const description = title || `${name} - ${domain} 领域 ${type} 类型技能`;
  const dir = path.join(ROOT, 'skills-hub', domain, name);

  if (fs.existsSync(dir)) {
    console.error(`错误: 技能目录已存在: ${dir}`);
    process.exit(1);
  }

  fs.mkdirSync(dir, { recursive: true });
  const md = generateSkillMD(domain, name, type, runtime, title, description);
  fs.writeFileSync(path.join(dir, 'SKILL.md'), md);

  const ayncId = generateAYNCId(domain, name, type);
  console.log(`✅ 技能模板已创建: ${dir}`);
  console.log(`   AYNC ID: ${ayncId}`);
  console.log(`   文件: ${dir}/SKILL.md`);
  console.log(`\n提示: 编辑 SKILL.md 完善技能定义后，运行 yyc3 skills validate 验证。`);
}

if (command === 'create-plugin' || command === 'plugin') {
  const [domain, name, type, ...titleParts] = args;
  const title = titleParts.join(' ');

  if (!domain || !name || !type) {
    console.error('用法: node scripts/create-plugin.js <domain> <name> <type> <title>');
    process.exit(1);
  }

  const description = title || `${name} - ${domain} 领域 ${type} 类型插件`;
  const dir = path.join(ROOT, 'plugins-hub', domain, name);

  if (fs.existsSync(dir)) {
    console.error(`错误: 插件目录已存在: ${dir}`);
    process.exit(1);
  }

  fs.mkdirSync(dir, { recursive: true });
  const md = generatePluginMD(domain, name, type, title, description);
  fs.writeFileSync(path.join(dir, 'PLUGIN.md'), md);

  console.log(`✅ 插件模板已创建: ${dir}`);
  console.log(`   文件: ${dir}/PLUGIN.md`);
  console.log(`\n提示: 编辑 PLUGIN.md 完善插件定义。`);
}
