---
@file: API-DOCUMENTATION.md
@description: YYC³-CLI API-DOCUMENTATION.md
@author: YanYuCloudCube Team
@version: v1.0.0
@created: 2026-02-17
@updated: 2026-02-17
@status: published
@tags: [文档],[YYC³-CLI]
---

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for the Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***

---

# YYC³ CLI API 文档

## 📚 概述

YYC³ CLI提供完整的API接口，支持通过编程方式调用所有功能。本文档描述CLI的JavaScript API和Shell API。

## 🏗️ 架构设计

### 模块架构

yyc3-cli/
├── bin/yyc3-cli.js          # 命令行入口点
├── lib/index.js             # 核心API模块
├── lib/config-manager.js    # 配置管理
├── lib/validator.js         # 输入验证
└── lib/logger.js            # 日志系统

### 依赖关系

```javascript
const {
  initProject,
  deployProject,
  buildProject,
  runTests,
  configureSettings,
  logger,
  validator,
  configManager
} = require('yyc3-cli');
```

## 🔧 JavaScript API

### 核心模块

#### 1. 项目初始化 API

```javascript
/**
 * @description 初始化新的YYC³项目
 * @param {string} projectName - 项目名称（必须）
 * @param {Object} options - 配置选项
 * @param {string} options.template - 项目模板（默认: 'basic'）
 * @param {number} options.port - 服务端口（默认: 3200）
 * @param {boolean} options.yes - 跳过确认提示（默认: false）
 * @returns {Promise<Object>} 初始化结果
 * @throws {Error} 当初始化失败时抛出错误
 */
async function initProject(projectName, options = {}) {
  // 实现
}
```

**使用示例:**

```javascript
const { initProject } = require('yyc3-cli');

async function createProject() {
  try {
    const result = await initProject('my-project', {
      template: 'ai',
      port: 3228,
      yes: true
    });

    console.log(`✅ 项目创建成功: ${result.projectPath}`);
    console.log(`📊 端口: ${result.port}`);
    console.log(`📁 目录: ${result.projectPath}`);

    return result;
  } catch (error) {
    console.error(`❌ 项目创建失败: ${error.message}`);
    throw error;
  }
}
```

#### 2. 部署 API

```javascript
/**
 * @description 部署应用到指定环境
 * @param {string} environment - 部署环境（默认: 'dev'）
 * @param {Object} options - 部署选项
 * @param {string} options.env - 环境别名
 * @param {boolean} options.force - 强制部署
 * @param {string} options.config - 自定义配置文件路径
 * @returns {Promise<Object>} 部署结果
 */
async function deployProject(environment = 'dev', options = {}) {
  // 实现
}
```

**使用示例:**

```javascript
const { deployProject } = require('yyc3-cli');

async function deployToProduction() {
  const result = await deployProject('prod', {
    force: false,
    config: './deploy-config.yaml'
  });

  console.log(`🚀 部署完成到: ${result.environment}`);
  console.log(`🌐 主机: ${result.config.host}`);
  console.log(`🔌 端口: ${result.config.port}`);

  return result;
}
```

#### 3. 构建 API

```javascript
/**
 * @description 构建项目
 * @param {Object} options - 构建选项
 * @param {string} options.mode - 构建模式（development/production）
 * @param {string} options.output - 输出目录
 * @param {boolean} options.analyze - 启用包分析
 * @returns {Promise<Object>} 构建结果
 */
async function buildProject(options = {}) {
  // 实现
}
```

**使用示例:**

```javascript
const { buildProject } = require('yyc3-cli');

async function buildForProduction() {
  const result = await buildProject({
    mode: 'production',
    output: 'dist',
    analyze: true
  });

  console.log(`🏗️ 构建完成: ${result.mode}模式`);
  console.log(`📦 输出目录: ${result.output}`);

  return result;
}
```

### 工具模块

#### 1. 配置管理器

```javascript
const { configManager } = require('yyc3-cli');

// 加载配置
const config = await configManager.loadConfig();

// 保存配置
await configManager.saveConfig(newConfig);

// 获取默认配置
const defaults = configManager.getDefaultConfig();
```

**配置结构:**

```json
{
  "version": "2.0.0",
  "defaultPort": 3200,
  "defaultTemplate": "basic",
  "deploymentEnvironments": {
    "dev": {
      "port": 3200,
      "host": "localhost",
      "protocol": "http"
    },
    "staging": {
      "port": 3300,
      "host": "staging.yyc3.com",
      "protocol": "https"
    },
    "prod": {
      "port": 3400,
      "host": "app.yyc3.com",
      "protocol": "https"
    }
  },
  "logLevel": "info",
  "autoUpdate": true,
  "telemetry": {
    "enabled": true,
    "anonymous": true
  }
}
```

#### 2. 输入验证器

```javascript
const { validator } = require('yyc3-cli');

// 验证项目名称
const validName = validator.validateProjectName('my-project');

// 验证端口
const validPort = validator.validatePort(3228);

// 验证环境名称
const validEnv = validator.validateEnvironment('prod');
```

**验证规则:**

- 项目名称: `[a-z][a-z0-9-]*`，长度≤50
- 端口范围: 1024-65535，避开3000-3199限制范围
- 环境名称: dev/staging/prod

#### 3. 日志系统

```javascript
const { logger } = require('yyc3-cli');

// 设置日志级别
logger.setLevel('debug');

// 记录日志
logger.info('应用程序启动');
logger.warn('磁盘空间不足');
logger.error('部署失败', error);
logger.debug('调试信息', { data: value });

// 不同级别输出
// 🔴 ERROR: 红色错误
// 🟡 WARN: 黄色警告
// 🔵 INFO: 蓝色信息
// ⚪ DEBUG: 白色调试
```

## 📡 Shell API

### 命令行接口

#### 基本语法

```bash
yyc3 <command> [options] [arguments]
```

#### 退出代码

| 代码 | 含义     | 描述               |
| ---- | -------- | ------------------ |
| 0    | 成功     | 命令执行成功       |
| 1    | 通用错误 | 未分类的错误       |
| 2    | 配置错误 | 配置问题导致失败   |
| 3    | 输入错误 | 用户输入验证失败   |
| 4    | 网络错误 | 网络连接问题       |
| 5    | 权限错误 | 权限不足           |
| 130  | 中断     | 用户中断（Ctrl+C） |

### 管理脚本API

#### 1. 服务管理

```bash
# 启动服务
./yyc3-management.sh start [service]

# 停止服务
./yyc3-management.sh stop [service]

# 重启服务
./yyc3-management.sh restart [service]

# 状态检查
./yyc3-management.sh status

# 健康检查
./yyc3-management.sh health
```

#### 2. 环境变量

```bash
# 控制日志级别
export LOG_LEVEL=debug

# 自定义配置目录
export YYC3_HOME=/custom/path

# 启用调试模式
export DEBUG=true

# AI服务配置
export AI_MODELS_DIR=/path/to/models
```

### 钩子脚本

CLI支持以下钩子脚本，可在特定事件触发：

#### 1. 项目初始化钩子

```bash
# 在项目创建后执行
# 放置于项目根目录: scripts/post-init.sh

#!/bin/bash
echo "🎉 项目初始化完成!"
echo "📦 安装额外依赖..."
npm install axios lodash
```

#### 2. 构建前钩子

```bash
# 在构建开始前执行
# 放置于项目根目录: scripts/pre-build.sh

#!/bin/bash
echo "🔧 运行构建前检查..."
# 检查环境变量
# 清理旧构建
# 验证依赖
```

#### 3. 部署后钩子

```bash
# 在部署完成后执行
# 放置于项目根目录: scripts/post-deploy.sh

#!/bin/bash
echo "🚀 部署完成!"
# 发送通知
# 更新状态
# 清理临时文件
```

## 🔌 插件系统

### 插件结构

plugins/
├── my-plugin/
│   ├── index.js           # 插件入口
│   ├── package.json       # 插件配置
│   └── README.md         # 插件文档
└── plugin-manifest.json   # 插件清单

### 插件开发

```javascript
// plugins/my-plugin/index.js
module.exports = {
  name: 'my-plugin',
  version: '1.0.0',

  // 注册命令
  commands: [
    {
      name: 'my-command',
      description: '自定义命令',
      action: async (args, options) => {
        console.log('自定义命令执行');
        // 插件逻辑
      }
    }
  ],

  // 生命周期钩子
  hooks: {
    'init:after': async (projectInfo) => {
      console.log('项目初始化后执行');
    },
    'deploy:before': async (deployInfo) => {
      console.log('部署前执行');
    }
  }
};
```

### 插件配置

```json
{
  "name": "yyc3-plugin-myplugin",
  "version": "1.0.0",
  "description": "YYC³ CLI插件示例",
  "main": "index.js",
  "yyc3": {
    "pluginType": "command",
    "compatibility": ">=2.0.0"
  }
}
```

## 📊 监控指标

### CLI性能指标

```javascript
// 获取CLI性能统计
const { performance } = require('perf_hooks');

const startTime = performance.now();
await initProject('test-project');
const endTime = performance.now();

console.log(`执行时间: ${(endTime - startTime).toFixed(2)}ms`);
```

### 资源使用统计

```bash
# 查看CLI内存使用
ps aux | grep yyc3

# 监控CPU使用
top -pid $(pgrep -f yyc3)
```

## 🔐 安全API

### 加密功能

```javascript
const { security } = require('yyc3-cli/lib/security');

// 加密敏感数据
const encrypted = await security.encrypt('secret-data', 'password');

// 解密数据
const decrypted = await security.decrypt(encrypted, 'password');

// 生成安全哈希
const hash = await security.hash('data-to-hash');
```

### 权限检查

```javascript
const { permissions } = require('yyc3-cli/lib/permissions');

// 检查文件权限
const canWrite = await permissions.canWrite('/path/to/file');

// 检查网络访问
const canConnect = await permissions.canConnect('api.yyc3.com', 443);

// 检查系统资源
const hasResources = await permissions.hasResources({
  memory: '2GB',
  storage: '1GB'
});
```

## 🧪 测试API

### 测试工具

```javascript
const { testUtils } = require('yyc3-cli/lib/test-utils');

// 创建测试项目
const testProject = await testUtils.createTestProject({
  name: 'test-project',
  template: 'basic'
});

// 运行测试命令
const testResults = await testUtils.runTestCommand('npm test', {
  timeout: 30000
});

// 清理测试环境
await testUtils.cleanupTestProject(testProject);
```

### 模拟环境

```javascript
const { mocks } = require('yyc3-cli/lib/mocks');

// 模拟文件系统
const mockFS = mocks.createMockFS({
  '/project/package.json': '{}',
  '/project/src/index.js': 'console.log("test")'
});

// 模拟网络请求
const mockNetwork = mocks.createMockNetwork({
  'api.yyc3.com': {
    GET: { '/health': { status: 'healthy' } }
  }
});
```

## 📝 错误处理

### 错误类型

```javascript
const { errors } = require('yyc3-cli/lib/errors');

// 定义自定义错误
class DeploymentError extends errors.CliError {
  constructor(message, environment) {
    super(`部署到${environment}失败: ${message}`);
    this.environment = environment;
    this.code = 'DEPLOYMENT_ERROR';
  }
}

// 使用错误
throw new DeploymentError('网络连接超时', 'prod');
```

### 错误恢复

```javascript
const { errorHandler } = require('yyc3-cli/lib/error-handler');

// 注册错误处理器
errorHandler.registerHandler('DEPLOYMENT_ERROR', async (error) => {
  console.error(`🔄 尝试恢复部署错误: ${error.message}`);
  // 重试逻辑
  return await retryDeployment(error.environment);
});

// 全局错误处理
process.on('uncaughtException', errorHandler.handleUncaught);
process.on('unhandledRejection', errorHandler.handleUnhandled);
```

## 🔄 更新机制

### 自动更新

```javascript
const { updater } = require('yyc3-cli/lib/updater');

// 检查更新
const updateInfo = await updater.checkForUpdates();

if (updateInfo.available) {
  console.log(`发现新版本: ${updateInfo.latest}`);

  // 执行更新
  const result = await updater.performUpdate();

  if (result.success) {
    console.log(`✅ 更新成功到版本: ${result.version}`);
  }
}

// 配置更新设置
await updater.configure({
  channel: 'stable', // stable/beta/nightly
  autoUpdate: true,
  checkInterval: '24h'
});
```

## 📡 网络API

### API客户端

```javascript
const { apiClient } = require('yyc3-cli/lib/api-client');

// 创建客户端实例
const client = apiClient.create({
  baseURL: 'https://api.yyc3.com',
  timeout: 10000,
  retry: 3
});

// 调用API
const response = await client.get('/v1/projects');
const project = await client.post('/v1/projects', { name: '新项目' });

// 处理响应
if (response.success) {
  console.log('API调用成功:', response.data);
} else {
  console.error('API调用失败:', response.error);
}
```

---

<div align="center">

**📚 文档版本: 2.0.0 | 最后更新: 2025-01-30**

**如需更多帮助，请访问 [docs.yyc3.com](https://docs.yyc3.com)**

</div>
