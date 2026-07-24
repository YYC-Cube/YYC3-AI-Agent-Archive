#!/usr/bin/env python3
"""
Agent 全量扫描编目脚本 agent_indexer.py
功能: 扫描仓库中所有 Agent 定义（YAML frontmatter .md），生成统一索引
使用: python3 agent_indexer.py
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent
SKIP_DIRS = {'node_modules', 'target', '.git', 'dist', 'build', '__pycache__', '.next'}

AGENT_PATTERNS = [
    '**/agents/*.md',
    '**/agents/**/*.md',
]

def is_agent_file(filepath: str) -> bool:
    """判断是否是 Agent 定义文件（含 YAML frontmatter + name + tools + model 字段）"""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read(2000)
        m = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
        if not m:
            return False
        front = m.group(1)
        has_name = bool(re.search(r'^name:\s*\S', front, re.MULTILINE))
        has_tools = bool(re.search(r'^tools:\s*\S', front, re.MULTILINE))
        # Agent 必须至少含 name + description + tools 或 model 之一
        has_desc = bool(re.search(r'^description:\s*\S', front, re.MULTILINE))
        has_model = bool(re.search(r'^model:\s*\S', front, re.MULTILINE))
        return has_name and has_desc and (has_tools or has_model)
    except Exception:
        return False


def parse_agent_md(filepath: str) -> dict:
    """解析 Agent .md 文件的 YAML frontmatter"""
    fields = {}
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            raw = f.read()

        m = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)', raw, re.DOTALL)
        if m:
            yaml_block = m.group(1)
            body = m.group(2).strip()
            for line in yaml_block.split('\n'):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                kv = re.match(r'^(\w[\w_-]*)\s*:\s*(.*)$', line)
                if kv:
                    key = kv.group(1).strip()
                    value = kv.group(2).strip().strip('"').strip("'")
                    # 处理多值字段 (tools: Read, Write, Edit)
                    if ',' in value and key in ('tools', 'skills', 'mcps'):
                        value = [v.strip() for v in value.split(',') if v.strip()]
                    fields[key] = value
        fields['_body_len'] = len(body) if body else 0
        fields['_body_preview'] = body[:150].replace('\n', ' ') if body else ''
    except Exception as e:
        fields['_parse_error'] = str(e)
    return fields


def categorize_agent(name: str, fields: dict, rel_path: str) -> str:
    """推断 Agent 分类"""
    if 'category' in fields and fields['category']:
        return fields['category']
    path_lower = rel_path.lower()
    for kw, cat in [
        ('development', 'development-code'), ('dev-team', 'development-code'),
        ('data-ai', 'ai-ml'), ('data', 'data-analysis'),
        ('research', 'research'), ('security', 'security'),
        ('testing', 'testing'), ('devops', 'devops'),
        ('design', 'design'), ('marketing', 'marketing'),
        ('finance', 'finance'), ('mobile', 'mobile'),
        ('game', 'game-development'), ('blockchain', 'security'),
        ('business', 'business-productivity'), ('content', 'content'),
        ('infrastructure', 'cloud-infrastructure'),
    ]:
        if kw in path_lower:
            return cat
    return 'other'


def determine_team(name: str, fields: dict, rel_path: str) -> str:
    """确定 Agent 所属团队"""
    if 'team' in fields:
        return fields['team']
    # 从路径推断（claude-code-templates 按子目录命名团队）
    parts = Path(rel_path).parts
    for p in parts:
        if p.endswith('-team') or p.endswith('-experts') or '-' in p:
            if len(p) > 3 and p not in ('agents', 'skills', 'components'):
                return p
    return 'unassigned'


def main():
    print("=" * 60)
    print("  Agent 全量扫描编目")
    print("=" * 60)

    agents = []
    errors = []

    # 遍历所有 Agent 文件
    for pattern in AGENT_PATTERNS:
        for fpath in sorted(ROOT.glob(pattern)):
            fpath = str(fpath)
            # 跳过无关目录
            parts = Path(fpath).parts
            if any(s in parts for s in SKIP_DIRS):
                continue

            if not is_agent_file(fpath):
                continue

            rel_path = os.path.relpath(fpath, ROOT)
            fields = parse_agent_md(fpath)

            name = fields.get('name', Path(fpath).stem)
            description = fields.get('description', '')
            tools = fields.get('tools', [])
            if isinstance(tools, str):
                tools = [t.strip() for t in tools.replace(',', ' ').split() if t.strip()]
            model = fields.get('model', '')
            category = categorize_agent(name, fields, rel_path)
            team = determine_team(name, fields, rel_path)

            agent = {
                'name': name,
                'team': team,
                'category': category,
                'source_path': rel_path,
                'source_dir': parts[0] if parts else '',
                'description': description[:200] if description else '',
                'tools': tools,
                'model': model,
                'body_len': fields.get('_body_len', 0),
                'fields_present': sorted([k for k in fields.keys() if not k.startswith('_')]),
            }
            agents.append(agent)

    # 聚合统计
    teams = defaultdict(list)
    categories = defaultdict(list)
    source_dirs = defaultdict(int)
    models = defaultdict(int)

    for a in agents:
        teams[a['team']].append(a['name'])
        categories[a['category']].append(a['name'])
        source_dirs[a['source_dir']] += 1
        if a['model']:
            models[a['model']] += 1

    # 写入索引
    index = {
        '_meta': {
            'total_agents': len(agents),
            'total_teams': len(teams),
            'total_categories': len(categories),
            'total_errors': len(errors),
        },
        'agents': sorted(agents, key=lambda x: x['name']),
        'by_team': {k: sorted(v) for k, v in sorted(teams.items())},
        'by_category': {k: sorted(v) for k, v in sorted(categories.items())},
        'by_source': dict(sorted(source_dirs.items())),
        'by_model': dict(sorted(models.items())),
    }

    output = ROOT / '_agents_index.json'
    with open(output, 'w', encoding='utf-8') as f:
        json.dump(index, f, ensure_ascii=False, indent=2)

    # 打印报告
    print(f"\n✅ 索引已生成: {output}")
    print(f"   总计 Agent: {len(agents)}")
    print(f"   总计团队: {len(teams)}")
    print(f"   总计分类: {len(categories)}")
    print(f"\n📊 按来源目录:")
    for d, c in sorted(source_dirs.items(), key=lambda x: -x[1]):
        print(f"   {d:40s} {c:4d}")
    print(f"\n📊 按模型:")
    for m, c in sorted(models.items(), key=lambda x: -x[1]):
        bar = '█' * min(c, 50)
        print(f"   {m:20s} {c:4d} {bar}")
    print(f"\n📊 按团队 (Top 10):")
    for t, members in sorted(teams.items(), key=lambda x: -len(x[1]))[:10]:
        print(f"   {t:35s} {len(members):4d} 个 Agent")
    print(f"\n📊 按分类:")
    for c, members in sorted(categories.items(), key=lambda x: -len(x[1])):
        print(f"   {c:35s} {len(members):4d}")

    if errors:
        print(f"\n⚠️  错误: {len(errors)}")
        for e in errors[:10]:
            print(f"   {e}")


if __name__ == '__main__':
    main()
