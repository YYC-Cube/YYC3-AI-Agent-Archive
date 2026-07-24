#!/usr/bin/env python3
"""
MCP Server 全量扫描编目脚本 mcp_indexer.py
功能: 扫描仓库中所有 MCP Server 配置定义，生成统一索引
使用: python3 mcp_indexer.py
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).parent
SKIP_DIRS = {'node_modules', 'target', '.git', 'dist', 'build', '__pycache__', '.next'}

# MCP 配置文件匹配模式
MCP_PATTERNS = [
    '**/.ai-family-plugin/mcp.json',
    '**/mcp*.json',
    '**/.cursor/mcp.json',
    '**/.claude/mcp*.json',
]


def scan_mcp_configs():
    """扫描所有 MCP 配置文件"""
    configs = []
    seen_files = set()

    for pattern in MCP_PATTERNS:
        for fpath in sorted(ROOT.glob(pattern)):
            fpath_str = str(fpath)
            parts = Path(fpath_str).parts
            if any(s in parts for s in SKIP_DIRS):
                continue
            if fpath_str in seen_files:
                continue
            seen_files.add(fpath_str)

            rel_path = os.path.relpath(fpath_str, ROOT)
            try:
                with open(fpath_str, 'r', encoding='utf-8') as f:
                    data = json.load(f)
            except (json.JSONDecodeError, Exception) as e:
                configs.append({
                    'source': rel_path,
                    '_error': f'JSON parse error: {e}',
                    'mcp_count': 0,
                })
                continue

            mcp_servers = {}
            # 兼容两种格式: { "mcpServers": {...} } 或直接 { "server-name": {...} }
            if 'mcpServers' in data:
                mcp_servers = data['mcpServers']
            elif 'servers' in data:
                mcp_servers = data['servers']
            else:
                # 尝试检测是否直接是 server 定义
                for k, v in data.items():
                    if isinstance(v, dict) and 'command' in v:
                        mcp_servers = data
                        break

            servers = []
            for name, cfg in mcp_servers.items():
                if not isinstance(cfg, dict):
                    continue
                command = cfg.get('command', '')
                args = cfg.get('args', [])
                env = cfg.get('env', {})
                metadata = cfg.get('_metadata', {})

                # 分类类型
                if 'docker' in command:
                    deploy_type = 'docker'
                elif args and any('npx' in str(a) for a in args):
                    deploy_type = 'npx'
                elif 'node' in command or str(Path(command).suffix) in ('.js', '.ts', '.mjs'):
                    deploy_type = 'node'
                elif 'python' in command or str(Path(command).suffix) == '.py':
                    deploy_type = 'python'
                elif 'uvx' in command:
                    deploy_type = 'uvx'
                else:
                    deploy_type = 'other'

                server = {
                    'name': name,
                    'description': cfg.get('description', metadata.get('description', '')),
                    'command': command,
                    'args_count': len(args),
                    'deploy_type': deploy_type,
                    'has_env': len(env) > 0 if isinstance(env, dict) else False,
                    'category': metadata.get('category', ''),
                    'display_name': metadata.get('displayName', name),
                    'vendor': metadata.get('vendor', ''),
                }
                # 从 args 提取关键参数
                if deploy_type == 'docker' and args:
                    server['docker_image'] = args[-1] if len(args) > 2 else ''
                servers.append(server)

            configs.append({
                'source': rel_path,
                'format': 'mcpServers' if 'mcpServers' in data else 'direct',
                'mcp_count': len(servers),
                'servers': servers,
            })

    return configs


def main():
    print("=" * 60)
    print("  MCP Server 全量扫描编目")
    print("=" * 60)

    configs = scan_mcp_configs()

    # 聚合统计
    all_servers = []
    deploy_types = defaultdict(int)
    categories = defaultdict(int)
    vendors = defaultdict(int)
    sources = defaultdict(int)

    for cfg in configs:
        sources[cfg['source']] += cfg['mcp_count']
        for srv in cfg.get('servers', []):
            all_servers.append(srv)
            deploy_types[srv['deploy_type']] += 1
            if srv['category']:
                categories[srv['category']] += 1
            if srv['vendor']:
                vendors[srv['vendor']] += 1

    index = {
        '_meta': {
            'total_configs': len(configs),
            'total_mcp_servers': len(all_servers),
            'deploy_types': dict(deploy_types),
        },
        'configs': sorted(configs, key=lambda x: x['source']),
        'all_servers': sorted(all_servers, key=lambda x: x['name']),
        'by_deploy_type': dict(sorted(deploy_types.items())),
        'by_category': dict(sorted(categories.items())),
        'by_vendor': dict(sorted(vendors.items())),
    }

    output = ROOT / '_mcps_index.json'
    with open(output, 'w', encoding='utf-8') as f:
        json.dump(index, f, ensure_ascii=False, indent=2)

    print(f"\n✅ 索引已生成: {output}")
    print(f"   总计 MCP 配置文件: {len(configs)}")
    print(f"   总计 MCP Server 定义: {len(all_servers)}")
    print(f"\n📊 部署方式分布:")
    for dt, c in sorted(deploy_types.items(), key=lambda x: -x[1]):
        bar = '█' * min(c, 50)
        print(f"   {dt:15s} {c:4d} {bar}")
    print(f"\n📊 Top 10 配置文件来源:")
    for src, c in sorted(sources.items(), key=lambda x: -x[1])[:10]:
        print(f"   {src:50s} {c:4d}")

    # 打印错误
    errors = [c for c in configs if '_error' in c]
    if errors:
        print(f"\n⚠️  解析错误: {len(errors)}")
        for e in errors[:5]:
            print(f"   {e['source']}: {e['_error']}")


if __name__ == '__main__':
    main()
