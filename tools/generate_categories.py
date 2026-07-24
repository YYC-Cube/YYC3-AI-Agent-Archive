#!/usr/bin/env python3
"""
技能分类索引生成脚本
功能: 扫描所有 SKILL.md，提取元数据和分类信息，生成 _categories.json 索引
使用: python3 generate_categories.py
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict

def parse_skill_md(file_path):
    """解析 SKILL.md 的 YAML frontmatter"""
    fields = {}
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
        if match:
            yaml_block = match.group(1)
            for line in yaml_block.split('\n'):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                m = re.match(r'^(\w[\w_-]*)\s*:\s*(.*)$', line)
                if m:
                    key = m.group(1).strip()
                    value = m.group(2).strip().strip('"').strip("'")
                    fields[key] = value

        # 提取正文摘要（前200字符）
        body_match = re.sub(r'^---\s*\n.*?\n---\s*\n', '', content, flags=re.DOTALL)
        summary = body_match[:200].replace('\n', ' ').strip()
    except Exception:
        pass
    return fields

def determine_category(fields, dir_name, file_path):
    """智能推断技能分类"""
    # 1. 优先使用已声明的 category
    if 'category' in fields and fields['category']:
        return fields['category']

    # 2. 基于路径和名称的关键词推断
    path_lower = file_path.lower()
    name_lower = dir_name.lower()

    category_keywords = {
        'email': ['email', 'gmail', 'mail', 'smtp', 'imap', 'inbox'],
        'deployment': ['deploy', 'netlify', 'vercel', 'edgeone', 'github-pages'],
        'document-processing': ['pdf', 'docx', 'pptx', 'xlsx', 'document', 'canvas'],
        'devops': ['github', 'gitlab', 'ci-cd', 'cicd', 'jenkins', 'docker', 'kubernetes'],
        'design': ['brand', 'design', 'theme', 'ui-ux', 'figma'],
        'data-analysis': ['data', 'analytics', 'chart', 'visualization'],
        'security': ['security', 'audit', 'vulnerability', 'crypto'],
        'testing': ['test', 'qa', 'quality', 'e2e', 'unit-test'],
        'automation': ['automation', 'workflow', 'bot', 'auto'],
        'research': ['research', 'arxiv', 'paper', 'academic'],
        'content': ['novel', 'writing', 'content', 'blog', 'article', 'book'],
        'communication': ['slack', 'discord', 'telegram', 'chat', 'message'],
        'database': ['database', 'sql', 'postgres', 'mysql', 'redis', 'mongo'],
        'ai-ml': ['ai', 'ml', 'machine-learning', 'llm', 'gpt', 'embedding'],
        'cloud-infrastructure': ['cloud', 'aws', 'gcp', 'azure', 'terraform'],
        'game-development': ['game', 'unity', 'unreal'],
        'mobile': ['mobile', 'ios', 'android', 'flutter', 'react-native'],
        'marketing': ['marketing', 'seo', 'ad', 'campaign', 'growth'],
        'finance': ['finance', 'trading', 'stock', 'payment', 'invoice'],
        'media-processing': ['image', 'video', 'audio', 'media', 'ffmpeg'],
        'web-scraping': ['scrap', 'crawl', 'spider'],
    }

    for cat, keywords in category_keywords.items():
        for kw in keywords:
            if kw in name_lower or kw in path_lower:
                return cat

    # 3. 默认分类
    return 'other'

def main():
    root = Path(__file__).parent
    skip_dirs = {'node_modules', 'target', '.git', 'dist', 'build', '__pycache__'}

    # 收集所有技能
    skills = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        if 'SKILL.md' in filenames:
            skill_path = os.path.join(dirpath, 'SKILL.md')
            rel_path = os.path.relpath(skill_path, root)

            fields = parse_skill_md(skill_path)
            dir_name = Path(dirpath).name

            # 确定来源目录
            if rel_path.startswith('skills/'):
                source = 'skills'
            elif rel_path.startswith('all-skills/'):
                source = 'all-skills'
            elif rel_path.startswith('external_plugins/'):
                source = 'external_plugins'
            elif rel_path.startswith('claude-plugins/'):
                source = 'claude-plugins'
            else:
                source = 'other'

            category = determine_category(fields, dir_name, skill_path)

            skills.append({
                'name': fields.get('name', dir_name),
                'dir_name': dir_name,
                'path': rel_path,
                'source': source,
                'category': category,
                'version': fields.get('version', ''),
                'description': fields.get('description', ''),
                'description_zh': fields.get('description_zh', ''),
                'has_plugin_json': os.path.exists(os.path.join(dirpath, '.ai-family-plugin', 'plugin.json')),
            })

    # 按分类组织
    categories = defaultdict(list)
    for skill in skills:
        categories[skill['category']].append(skill)

    # 排序
    for cat in categories:
        categories[cat].sort(key=lambda x: x['name'])

    # 生成索引
    index = {
        '_meta': {
            'total_skills': len(skills),
            'total_categories': len(categories),
            'generated_at': str(Path(__file__).stat().st_mtime),
        },
        'categories': dict(sorted(categories.items())),
        'all_skills': sorted(skills, key=lambda x: x['name']),
    }

    # 写入文件
    output_path = root / '_categories.json'
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(index, f, ensure_ascii=False, indent=2)

    print(f"技能分类索引已生成: {output_path}")
    print(f"  总计技能: {len(skills)}")
    print(f"  总计分类: {len(categories)}")
    print()
    print("分类分布:")
    for cat, items in sorted(categories.items(), key=lambda x: -len(x[1])):
        print(f"  {cat:30s} {len(items):4d}")

if __name__ == '__main__':
    main()
