#!/usr/bin/env python3
"""
AYNC 全量编码基线生成脚本
功能: 读取所有索引，为每个实体分配 AYNC 编码，生成统一注册基线
使用: python3 generate_aync_registry.py
"""

import json
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent

# 分类码映射
CATEGORY_CODES = {
    'development-code': 'DE', 'document-processing': 'DP', 'business-productivity': 'BS',
    'email': 'EM', 'design': 'DS', 'deployment': 'DP2', 'research': 'RE',
    'content': 'CT', 'communication': 'CM', 'database': 'DB', 'ai-ml': 'AI',
    'security': 'SE', 'testing': 'TE', 'automation': 'AU', 'devops': 'DC',
    'cloud-infrastructure': 'CI', 'game-development': 'GA', 'mobile': 'MB',
    'marketing': 'MK', 'data-analysis': 'DA', 'analytics': 'DA', 'finance': 'FN',
    'ecommerce': 'EC', 'storage-docs': 'SD', 'crm': 'CR', 'customer-support': 'CS',
    'project-management': 'PM', 'social-media': 'SM', 'productivity': 'PD',
    'creative-collaboration': 'CC', 'tencent': 'TC', 'framework': 'FW',
    'observability': 'OB', 'infrastructure-cloud': 'IC', 'quality-security': 'QS',
    'workflow-orchestration': 'WO', 'game-development': 'GD', 'Education': 'ED',
    'frontend': 'FT', 'full-stack': 'FS', 'tech': 'TC', 'medical': 'MD',
    'travel': 'TR', 'graphics': 'GR', 'others': 'OT',
}

# 实体类型编码
TYPE_CODES = {'agent': 'A', 'skill': 'Y', 'mcp': 'N', 'plugin': 'C', 'tool': 'T'}


def load_json(path):
    try:
        with open(path) as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return None


def get_aync_id(type_key, category, registry):
    """生成或获取 AYNC 编码"""
    type_code = TYPE_CODES.get(type_key, 'X')
    cat_code = CATEGORY_CODES.get(category, 'OT')
    # 去重 key
    key = f"AYNC-{type_code}-{cat_code}"
    count = registry.get(key, 0) + 1
    registry[key] = count
    return f"{key}-{count:04d}"


def main():
    print("=" * 60)
    print("  AYNC 全量编码基线生成")
    print("=" * 60)

    # 加载所有索引
    categories = load_json(ROOT / '_categories.json')
    agents = load_json(ROOT / '_agents_index.json')
    mcps = load_json(ROOT / '_mcps_index.json')
    tools = load_json(ROOT / '_tools_index.json')
    metadata = load_json(ROOT / 'metadata_report.json')

    seq_registry = defaultdict(int)
    all_entities = []

    # 1. Skill 实体
    skill_count = 0
    if categories and 'all_skills' in categories:
        for s in categories['all_skills']:
            cat = s.get('category', 'other')
            aync = get_aync_id('skill', cat, seq_registry)
            all_entities.append({
                'aync_id': aync,
                'name': s['name'],
                'type': 'skill',
                'category': cat,
                'source_path': s.get('path', ''),
                'source_dir': s.get('source', ''),
                'version': s.get('version', ''),
                'description': s.get('description', ''),
                'has_plugin_json': s.get('has_plugin_json', False),
            })
            skill_count += 1

    # 2. Agent 实体
    agent_count = 0
    if agents and 'agents' in agents:
        for a in agents['agents']:
            cat = a.get('category', 'other')
            aync = get_aync_id('agent', cat, seq_registry)
            all_entities.append({
                'aync_id': aync,
                'name': a['name'],
                'type': 'agent',
                'category': cat,
                'source_path': a.get('source_path', ''),
                'source_dir': a.get('source_dir', ''),
                'team': a.get('team', ''),
                'model': a.get('model', ''),
                'tools': a.get('tools', []),
                'description': a.get('description', ''),
            })
            agent_count += 1

    # 3. MCP 实体
    mcp_count = 0
    if mcps and 'all_servers' in mcps:
        for m in mcps['all_servers']:
            cat = m.get('category', 'other')
            aync = get_aync_id('mcp', cat, seq_registry)
            all_entities.append({
                'aync_id': aync,
                'name': m['name'],
                'type': 'mcp',
                'category': cat if cat else 'other',
                'deploy_type': m.get('deploy_type', ''),
                'command': m.get('command', ''),
                'description': m.get('description', ''),
            })
            mcp_count += 1

    # 4. Tool 实体
    tool_count = 0
    if tools and 'tool_registry' in tools:
        for t in tools['tool_registry']:
            cat = 'development-code'
            aync = get_aync_id('tool', cat, seq_registry)
            all_entities.append({
                'aync_id': aync,
                'name': t['name'],
                'type': 'tool',
                'category': cat,
                'impl_count': t.get('impl_count', 0),
                'agent_ref_count': t.get('agent_ref_count', 0),
                'is_rust_builtin': t.get('is_rust_builtin', False),
            })
            tool_count += 1

    # 聚合统计
    type_stats = defaultdict(int)
    cat_stats = defaultdict(int)
    for e in all_entities:
        type_stats[e['type']] += 1
        cat_stats[e['category']] += 1

    # 写入基线
    baseline = {
        '_meta': {
            'version': '1.0.0',
            'generated_at': '2026-07-24',
            'total_entities': len(all_entities),
            'by_type': dict(type_stats),
            'by_category': dict(sorted(cat_stats.items(), key=lambda x: -x[1])),
        },
        'aync_codes_used': dict(sorted(seq_registry.items())),
        'entities': sorted(all_entities, key=lambda x: (x['type'], x['aync_id'])),
    }

    output = ROOT / 'aync_registry.json'
    with open(output, 'w', encoding='utf-8') as f:
        json.dump(baseline, f, ensure_ascii=False, indent=2)

    # 打印报告
    print(f"\n✅ 基线已生成: {output}")
    print(f"\n📊 各实体类型:")

    # 定义显示顺序
    type_order = ['skill', 'agent', 'mcp', 'tool']
    name_map = {'skill': 'Skills 技能', 'agent': 'Agents 代理', 'mcp': 'MCP Servers', 'tool': 'Tools 工具'}
    for t in type_order:
        c = type_stats.get(t, 0)
        bar = '█' * min(c // 10, 60)
        print(f"   {name_map.get(t, t):25s} {c:5d} {bar}")

    print(f"\n   {'总计':25s} {len(all_entities):5d}")
    print(f"\n📊 Top 15 分类分布:")
    for cat, c in sorted(cat_stats.items(), key=lambda x: -x[1])[:15]:
        bar = '█' * min(c // 5, 60)
        print(f"   {cat:35s} {c:5d} {bar}")


if __name__ == '__main__':
    main()
