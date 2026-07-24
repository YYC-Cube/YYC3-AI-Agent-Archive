#!/usr/bin/env python3
"""
Tool 全量扫描编目脚本 tool_indexer.py
功能: 扫描仓库中所有 Tool 定义，生成统一索引
使用: python3 tool_indexer.py
"""

import os
import json
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent
SKIP_DIRS = {'node_modules', 'target', '.git', 'dist', 'build', '__pycache__', '.next', '.loki'}

# Tool 定义来源
TOOL_SOURCES = [
    # 1. agent/tools/ — Rust 内置 Tool 实现
    ('agent/tools/', 'rust-builtin'),
    # 2. Agent 文件 — tools 字段引用
    ('agent/**/*.md', 'agent-file'),
    # 3. 各 skills 下的 tools/ 目录
    ('skills/*/tools/', 'skill-tools'),
    # 4. chatAgentTools
    ('chatAgentTools/', 'chat-agent'),
    # 5. 各插件下的 scripts/tools/
    ('external_plugins/*/scripts/tools/', 'plugin-tools'),
    ('buildwithclaude/plugins/*/scripts/tools/', 'plugin-tools'),
    # 6. MCP Server 中也暴露工具
    ('**/tools/', 'generic'),
]


def scan_tool_dirs():
    """扫描工具目录中的工具实现文件"""
    tools = []
    seen = set()

    # 扫描工具目录
    tool_dirs = sorted(ROOT.glob('**/tools/'))
    for td in tool_dirs:
        td_str = str(td)
        parts = Path(td_str).parts
        if any(s in parts for s in SKIP_DIRS):
            continue

        rel_dir = os.path.relpath(td_str, ROOT)
        # 收集工具文件
        impls = []
        for ext in ('*.rs', '*.py', '*.js', '*.ts', '*.sh', '*.mjs', '*.cjs'):
            for f in sorted(td.glob(ext)):
                fname = f.name
                tool_name = fname.rsplit('.', 1)[0]
                if tool_name.startswith('mod') or tool_name.startswith('_'):
                    continue
                # 从文件名推断语言
                lang_map = {
                    '.rs': 'rust', '.py': 'python', '.js': 'javascript',
                    '.ts': 'typescript', '.sh': 'shell', '.mjs': 'javascript',
                    '.cjs': 'javascript',
                }
                impls.append({
                    'name': tool_name,
                    'file': fname,
                    'language': lang_map.get(f.suffix, f.suffix),
                    'size': f.stat().st_size,
                })
                seen.add(tool_name)

        if impls:
            tools.append({
                'source_dir': rel_dir,
                'impl_count': len(impls),
                'implementations': sorted(impls, key=lambda x: x['name']),
            })

    return tools, seen


def scan_agent_tool_refs():
    """从 Agent 定义文件扫描 tools 字段引用的工具名"""
    from agent_indexer import is_agent_file, parse_agent_md
    tool_refs = defaultdict(set)

    for pattern in ('**/agents/*.md', '**/agents/**/*.md', '**/AGENTS.md'):
        for fpath in sorted(ROOT.glob(pattern)):
            fpath_str = str(fpath)
            parts = Path(fpath_str).parts
            if any(s in parts for s in SKIP_DIRS):
                continue
            if not is_agent_file(fpath_str):
                continue
            fields = parse_agent_md(fpath_str)
            tools = fields.get('tools', [])
            if isinstance(tools, str):
                tools = [t.strip() for t in tools.replace(',', ' ').split() if t.strip()]
            for t in tools:
                tool_refs[t].add(os.path.relpath(fpath_str, ROOT))
    return tool_refs


def main():
    print("=" * 60)
    print("  Tool 全量扫描编目")
    print("=" * 60)

    # 1. 扫描工具实现目录
    tool_dirs, seen_tool_names = scan_tool_dirs()
    print(f"\n📁 工具实现目录: {len(tool_dirs)}")
    print(f"🔧 发现工具名: {len(seen_tool_names)}")

    # 列出所有发现的工具名
    all_tool_names = sorted(seen_tool_names)

    # 2. 扫描 Agent 引用
    try:
        agent_refs = scan_agent_tool_refs()
        print(f"📎 Agent 引用工具数: {len(agent_refs)}")
    except ImportError:
        print("⚠️  无法导入 agent_indexer，跳过 Agent 引用分析")
        agent_refs = {}

    # 3. 扫描 Rust 内置工具
    rust_tools = []
    rust_dir = ROOT / 'agent' / 'tools'
    if rust_dir.exists():
        for f in sorted(rust_dir.glob('*.rs')):
            if f.name == 'mod.rs':
                continue
            tool_name = f.stem
            rust_tools.append({
                'name': tool_name,
                'file': f.name,
                'size': f.stat().st_size,
                'language': 'rust',
            })

    # 4. 构建工具注册表
    # 聚合每个工具名被哪些目录实现
    tool_impl_map = defaultdict(list)
    for td in tool_dirs:
        for impl in td['implementations']:
            tool_impl_map[impl['name']].append({
                'source_dir': td['source_dir'],
                'file': impl['file'],
                'language': impl['language'],
                'size': impl['size'],
            })

    # 与 Agent 引用关联
    tool_registry = []
    for name in sorted(set(list(tool_impl_map.keys()) + [t['name'] for t in rust_tools] + list(agent_refs.keys()))):
        entry = {
            'name': name,
            'implementations': tool_impl_map.get(name, []),
            'is_rust_builtin': any(t['name'] == name for t in rust_tools),
            'agent_refs': list(agent_refs.get(name, [])),
            'impl_count': len(tool_impl_map.get(name, [])),
            'agent_ref_count': len(agent_refs.get(name, [])),
        }
        tool_registry.append(entry)

    # 统计
    has_impl = sum(1 for t in tool_registry if t['impl_count'] > 0)
    agent_only = sum(1 for t in tool_registry if t['impl_count'] == 0 and t['agent_ref_count'] > 0)
    duplicated_impl = sum(1 for t in tool_registry if t['impl_count'] > 1)

    index = {
        '_meta': {
            'total_tool_names': len(tool_registry),
            'has_implementation': has_impl,
            'agent_ref_only': agent_only,
            'duplicated_implementations': duplicated_impl,
            'rust_builtin_count': len(rust_tools),
        },
        'rust_builtins': sorted(rust_tools, key=lambda x: x['name']),
        'tool_registry': tool_registry,
        'tool_dirs': tool_dirs,
    }

    output = ROOT / '_tools_index.json'
    with open(output, 'w', encoding='utf-8') as f:
        json.dump(index, f, ensure_ascii=False, indent=2)

    print(f"\n✅ 索引已生成: {output}")
    print(f"   总计工具名: {len(tool_registry)}")
    print(f"   有实现文件: {has_impl}")
    print(f"   仅被Agent引用: {agent_only}")
    print(f"   多实现重复: {duplicated_impl}")
    print(f"   Rust内置工具: {len(rust_tools)}")
    if duplicated_impl > 0:
        print(f"\n⚠️  多实现工具 (需关注):")
        for t in tool_registry:
            if t['impl_count'] > 1:
                sources = [f['source_dir'] for f in t['implementations']]
                print(f"   {t['name']:30s} {t['impl_count']}处: {sources}")


if __name__ == '__main__':
    main()
