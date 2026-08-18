---
@file: yyc3-knowledge-base.sh
@description: YYC³-CLI Shell脚本: yyc3-knowledge-base.sh
@author: YanYuCloudCube Team
@version: v1.0.0
@created: 2026-02-17
@updated: 2026-02-17
@status: published
@tags: [脚本],[Shell],[YYC³-CLI]
---

> ***YanYuCloudCube***
> 言启象限 | 语枢未来
> ***Words Initiate Quadrants, Language Serves as Core for the Future***
> 万象归元于云枢 | 深栈智启新纪元
> ***All things converge in the cloud pivot; Deep stacks ignite a new era of intelligence***

---

#!/usr/bin/env python3
"""
yyc3-knowledge-base 项目文件树生成脚本
基于行业标准和智能化AI知识库最佳实践
"""

import os
import sys
from pathlib import Path

def create_directory_structure(base_path):
    """创建完整的目录结构"""
    
    structure = {
        'public': [
            'index.html',
            'favicon.ico',
            'robots.txt',
            'manifest.json'
        ],
        'src': {
            '': [
                'index.jsx',
                'App.jsx',
                'App.css',
                'main.jsx',
                'vite-env.d.ts',
                'index.css'
            ],
            'api': [
                'index.js',
                'auth.js',
                'docs.js',
                'users.js',
                'recommendations.js',
                'feedback.js',
                'notifications.js',
                'collaboration.js',
                'creation.js'
            ],
            'assets': {
                'images': [],
                'icons': [],
                'fonts': [],
                'styles': []
            },
            'components': {
                'KnowledgeCard': ['KnowledgeCard.jsx', 'KnowledgeCard.css'],
                'MarkdownViewer': ['MarkdownViewer.jsx', 'MarkdownViewer.css'],
                'CodeBlock': ['CodeBlock.jsx', 'CodeBlock.css'],
                'TagFilter': ['TagFilter.jsx', 'TagFilter.css'],
                'VersionViewer': ['VersionViewer.jsx', 'VersionViewer.css'],
                'EditModal': ['EditModal.jsx', 'EditModal.css'],
                'VersionDiff': ['VersionDiff.jsx', 'VersionDiff.css'],
                'VersionLabelEditor': ['VersionLabelEditor.jsx', 'VersionLabelEditor.css'],
                'ReviewAlert': ['ReviewAlert.jsx', 'ReviewAlert.css'],
                'FavoriteTagFilter': ['FavoriteTagFilter.jsx', 'FavoriteTagFilter.css'],
                'Auth': [
                    'LoginForm.jsx', 'LoginForm.css', 
                    'RegisterModal.jsx', 'RegisterModal.css', 
                    'ProtectedRoute.jsx', 'AuthGuard.jsx'
                ],
                'UserManagement': ['RoleEditor.jsx', 'RoleEditor.css', 'UserList.jsx'],
                'Visualization': [
                    'ScoreRadar.jsx', 'ScoreRadar.css',
                    'UserProfileRadar.jsx', 'UserProfileRadar.css',
                    'ProfileTrendChart.jsx', 'ProfileTrendChart.css',
                    'KnowledgeGraphViz.jsx', 'KnowledgeGraphViz.css'
                ],
                'ScoreManagement': [
                    'ScoreTuner.jsx', 'ScoreTuner.css',
                    'ProfileTuner.jsx', 'ProfileTuner.css',
                    'ScoringConfig.jsx'
                ],
                'Feedback': [
                    'FeedbackForm.jsx', 'FeedbackForm.css',
                    'FeedbackAnalytics.jsx', 'FeedbackList.jsx'
                ],
                'Notifications': [
                    'NotificationBell.jsx', 'NotificationBell.css',
                    'NotificationCenter.jsx', 'NotificationItem.jsx'
                ],
                'FileManager': [
                    'FileUploader.jsx', 'FileUploader.css',
                    'FileList.jsx', 'FileList.css',
                    'FilePreview.jsx', 'FileExplorer.jsx'
                ],
                'KnowledgeSearch': [
                    'SemanticSearch.jsx', 'SemanticSearch.css',
                    'SearchResults.jsx', 'SearchFilters.jsx',
                    'AdvancedSearch.jsx'
                ],
                'Collaboration': [
                    'CollaborativeEditor.jsx', 'CollaborativeEditor.css',
                    'ParticipantList.jsx', 'ChatPanel.jsx',
                    'CommentThread.jsx', 'VersionControl.jsx'
                ],
                'Creation': [
                    'CreationEngine.jsx', 'MaterialLibrary.jsx',
                    'AIGenerator.jsx', 'TemplateSelector.jsx',
                    'ContentBuilder.jsx'
                ],
                'Recommendations': [
                    'RecommendationLogger.jsx', 'RecommendationLogger.css',
                    'RecommendationPanel.jsx', 'RecommendationPanel.css',
                    'ReviewSuggestionPanel.jsx', 'ReviewSuggestionPanel.css',
                    'PersonalizedFeed.jsx'
                ],
                'Layout': [
                    'Sidebar.jsx', 'Sidebar.css',
                    'Header.jsx', 'Header.css',
                    'MainLayout.jsx', 'Footer.jsx',
                    'Breadcrumb.jsx'
                ],
                'Common': [
                    'LoadingScreen.jsx', 'ErrorBoundary.jsx',
                    'EmptyState.jsx', 'ConfirmModal.jsx'
                ],
                '': ['index.js']  # components 根目录的 index.js
            },
            'context': [
                'AuthProvider.jsx',
                'ThemeProvider.jsx',
                'NotificationProvider.jsx',
                'CollaborationProvider.jsx'
            ],
            'pages': {
                'Dashboard': ['Dashboard.jsx', 'Dashboard.css'],
                'FileManager': ['FileManager.jsx', 'FileManager.css'],
                'KnowledgeSearch': ['KnowledgeSearch.jsx', 'KnowledgeSearch.css'],
                'KnowledgeGraph': ['KnowledgeGraph.jsx', 'KnowledgeGraph.css'],
                'CollaborativeSpace': ['CollaborativeSpace.jsx', 'CollaborativeSpace.css'],
                'CreationEngine': ['CreationEngine.jsx', 'CreationEngine.css'],
                'Settings': ['Settings.jsx', 'Settings.css'],
                'Auth': ['Login.jsx', 'Login.css', 'Register.jsx', 'Register.css'],
                'UserCenter': [
                    'UserDashboard.jsx', 'UserDashboard.css',
                    'VersionHistory.jsx', 'VersionHistory.css',
                    'ProfileSettings.jsx'
                ],
                'Admin': [
                    'AdminPanel.jsx', 'AdminPanel.css',
                    'RecommendationDashboard.jsx', 'RecommendationDashboard.css',
                    'AssignmentAnalytics.jsx', 'UserManagement.jsx',
                    'SystemMetrics.jsx'
                ],
                'Review': [
                    'ReviewPanel.jsx', 'ReviewPanel.css',
                    'ReviewAssignmentPanel.jsx', 'ReviewAssignmentPanel.css',
                    'Unauthorized.jsx', 'ReviewQueue.jsx'
                ],
                'Favorites': ['FavoriteList.jsx', 'FavoriteList.css'],
                'Notifications': ['NotificationCenter.jsx', 'NotificationCenter.css'],
                'Analytics': [
                    'UsageAnalytics.jsx', 'KnowledgeAnalytics.jsx',
                    'UserAnalytics.jsx'
                ]
            },
            'hooks': [
                'useDebounce.js',
                'useDocs.js',
                'useVersions.js',
                'useAuth.js',
                'useNotifications.js',
                'useRecommendations.js',
                'useCollaboration.js',
                'useLocalStorage.js',
                'useApi.js',
                'useFileUpload.js',
                'useSearch.js',
                'usePermissions.js'
            ],
            'store': {
                '': ['index.js', 'persist.js'],
                'slices': [
                    'authSlice.js',
                    'uiSlice.js',
                    'fileManagerSlice.js',
                    'knowledgeSlice.js',
                    'collaborationSlice.js',
                    'creationSlice.js',
                    'userSlice.js',
                    'recommendationSlice.js',
                    'feedbackSlice.js',
                    'notificationSlice.js',
                    'searchSlice.js'
                ]
            },
            'styles': {
                '': [
                    'index.css',
                    'variables.css',
                    'animations.css',
                    'components.css',
                    'layouts.css',
                    'responsive.css',
                    'utilities.css'
                ],
                'themes': ['light.css', 'dark.css', 'high-contrast.css']
            },
            'utils': [
                'fileUtils.js',
                'formatUtils.js',
                'validationUtils.js',
                'constantUtils.js',
                'aiUtils.js',
                'dateUtils.js',
                'stringUtils.js',
                'permissionUtils.js',
                'exportUtils.js',
                'importUtils.js'
            ],
            'constants': [
                'apiConstants.js',
                'routeConstants.js',
                'roleConstants.js',
                'typeConstants.js',
                'permissionConstants.js',
                'errorConstants.js'
            ],
            'tests': {
                '__mocks__': ['fileMock.js', 'styleMock.js'],
                'components': [],
                'hooks': [],
                'utils': [],
                'pages': [],
                'store': [],
                '': ['setup.js', 'scoreModel.test.js', 'auth.test.js']
            },
            'services': [
                'fileService.js',
                'knowledgeService.js',
                'collaborationService.js',
                'creationService.js',
                'authService.js',
                'userService.js',
                'recommendationService.js',
                'notificationService.js',
                'searchService.js',
                'analyticsService.js',
                'exportService.js'
            ],
            'types': [
                'global.d.ts',
                'api.types.js',
                'component.types.js',
                'store.types.js'
            ],
            'middleware': [
                'authMiddleware.js',
                'loggingMiddleware.js',
                'errorMiddleware.js',
                'cacheMiddleware.js'
            ]
        },
        'docs': {
            'api': ['README.md', 'endpoints.md'],
            'architecture': ['system-design.md', 'data-flow.md'],
            'development': ['setup.md', 'coding-standards.md'],
            'deployment': ['production.md', 'ci-cd.md']
        },
        'scripts': [
            'setup.sh',
            'build.sh',
            'deploy.sh',
            'test.sh',
            'lint.sh',
            'type-check.sh'
        ],
        'config': [
            'vite.config.js',
            'jest.config.js',
            'eslint.config.js',
            'prettier.config.js',
            'tailwind.config.js'
        ]
    }

    # 根目录文件
    root_files = [
        '.env',
        '.env.example',
        '.env.production',
        '.gitignore',
        '.eslintignore',
        '.prettierignore',
        'package.json',
        'package-lock.json',
        'vite.config.js',
        'jest.config.js',
        'README.md',
        'CHANGELOG.md',
        'CONTRIBUTING.md',
        'LICENSE',
        'tsconfig.json',
        'jsconfig.json',
        'index.html'
    ]

    def create_structure(current_path, structure_dict):
        """递归创建目录和文件结构"""
        for item, contents in structure_dict.items():
            item_path = current_path / item
            
            if isinstance(contents, list):
                # 创建文件
                for file_name in contents:
                    file_path = item_path / file_name
                    file_path.parent.mkdir(parents=True, exist_ok=True)
                    file_path.touch()
                    print(f"创建文件: {file_path}")
            else:
                # 创建目录并递归处理子结构
                item_path.mkdir(parents=True, exist_ok=True)
                print(f"创建目录: {item_path}")
                create_structure(item_path, contents)

    # 创建项目根目录
    base_path = Path(base_path)
    base_path.mkdir(parents=True, exist_ok=True)
    print(f"创建项目根目录: {base_path}")

    # 创建根目录文件
    for file_name in root_files:
        file_path = base_path / file_name
        file_path.touch()
        print(f"创建根文件: {file_path}")

    # 创建主要目录结构
    create_structure(base_path, structure)

    # 创建一些重要的配置文件内容模板
    create_config_templates(base_path)

def create_config_templates(base_path):
    """创建重要的配置文件模板"""
    
    # package.json 模板
    package_json = {
        "name": "yyc3-knowledge-base",
        "version": "1.0.0",
        "type": "module",
        "scripts": {
            "dev": "vite",
            "build": "vite build",
            "preview": "vite preview",
            "test": "jest",
            "test:watch": "jest --watch",
            "lint": "eslint src --ext .js,.jsx",
            "lint:fix": "eslint src --ext .js,.jsx --fix",
            "type-check": "tsc --noEmit",
            "format": "prettier --write src/",
            "setup": "bash scripts/setup.sh"
        },
        "dependencies": {
            "react": "^18.2.0",
            "react-dom": "^18.2.0",
            "react-router-dom": "^6.8.0",
            "redux": "^4.2.1",
            "@reduxjs/toolkit": "^1.9.2",
            "react-redux": "^8.0.5",
            "redux-persist": "^6.0.0",
            "antd": "^5.2.0",
            "axios": "^1.3.0",
            "framer-motion": "^8.5.0",
            "marked": "^4.2.12",
            "prismjs": "^1.29.0",
            "react-markdown": "^8.0.4",
            "socket.io-client": "^4.6.0",
            "uuid": "^9.0.0",
            "dayjs": "^1.11.7",
            "lodash": "^4.17.21"
        },
        "devDependencies": {
            "vite": "^4.1.0",
            "@vitejs/plugin-react": "^3.1.0",
            "jest": "^29.4.0",
            "@testing-library/react": "^13.4.0",
            "@testing-library/jest-dom": "^5.16.5",
            "eslint": "^8.35.0",
            "prettier": "^2.8.4",
            "typescript": "^4.9.5",
            "tailwindcss": "^3.2.0"
        }
    }

    # 写入 package.json
    package_path = base_path / 'package.json'
    import json
    with open(package_path, 'w', encoding='utf-8') as f:
        json.dump(package_json, f, indent=2, ensure_ascii=False)
    print(f"创建 package.json: {package_path}")

    # 创建 README.md 模板
    readme_content = """# YYC3 Knowledge Base

现代化的智能化AI知识库管理系统，集成了知识管理、协作编辑、智能推荐和数据分析功能。

## 特性

- 🧠 智能知识管理
- 👥 实时协作编辑  
- 🔍 语义搜索
- 📊 可视化分析
- 🤖 AI内容生成
- 📱 响应式设计

## 技术栈

- **前端**: React 18 + Vite
- **状态管理**: Redux Toolkit
- **UI组件**: Ant Design
- **路由**: React Router v6
- **构建工具**: Vite
- **测试**: Jest + Testing Library

## 快速开始

```bash
# 安装依赖
npm install

# 开发模式
npm run dev

# 构建生产版本
npm run build
```

## 项目结构

详见项目文档。
"""

    readme_path = base_path / 'README.md'
    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write(readme_content)
    print(f"创建 README.md: {readme_path}")

    # 创建 .gitignore 模板
    gitignore_content = """# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production builds
dist/
build/

# Environment variables
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs
*.log

# Coverage
coverage/

# TypeScript
*.tsbuildinfo
"""
    gitignore_path = base_path / '.gitignore'
    with open(gitignore_path, 'w', encoding='utf-8') as f:
        f.write(gitignore_content)
    print(f"创建 .gitignore: {gitignore_path}")

def main():
    """主函数"""
    if len(sys.argv) > 1:
        project_path = sys.argv[1]
    else:
        project_path = 'yyc3-knowledge-base'
    
    print(f"开始创建 YYC3 Knowledge Base 项目结构...")
    print(f"项目路径: {os.path.abspath(project_path)}")
    print("-" * 50)
    
    try:
        create_directory_structure(project_path)
        print("-" * 50)
        print("✅ 项目结构创建完成！")
        print("\n下一步操作:")
        print("1. cd yyc3-knowledge-base")
        print("2. npm install  # 安装依赖")
        print("3. npm run dev  # 启动开发服务器")
    except Exception as e:
        print(f"❌ 创建过程中出现错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
