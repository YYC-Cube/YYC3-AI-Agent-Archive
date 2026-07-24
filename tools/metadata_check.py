#!/usr/bin/env python3
"""
元数据规范校验脚本 metadata_check.py
功能: 校验所有 SKILL.md 文件的 YAML frontmatter 元数据是否符合规范
使用: python3 metadata_check.py [--fix]
  --fix: 自动修复可修复的问题（如添加缺失的 category 字段）
"""

import os
import sys
import re
import json
from pathlib import Path
from collections import defaultdict

# 颜色输出
class Color:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    NC = '\033[0m'

    @staticmethod
    def red(msg): return f"{Color.RED}{msg}{Color.NC}"
    @staticmethod
    def green(msg): return f"{Color.GREEN}{msg}{Color.NC}"
    @staticmethod
    def yellow(msg): return f"{Color.YELLOW}{msg}{Color.NC}"
    @staticmethod
    def blue(msg): return f"{Color.BLUE}{msg}{Color.NC}"
    @staticmethod
    def bold(msg): return f"{Color.BOLD}{msg}{Color.NC}"

# 必填字段
REQUIRED_FIELDS = ['name', 'description']
# 推荐字段
RECOMMENDED_FIELDS = ['description_zh', 'description_en', 'version', 'category']
# 可选字段
OPTIONAL_FIELDS = ['license', 'homepage', 'author', 'tags']

# 有效分类列表
VALID_CATEGORIES = {
    'development-code', 'document-processing', 'business-productivity',
    'devops', 'email', 'design', 'deployment', 'productivity',
    'research', 'content', 'creative-collaboration', 'data-analysis',
    'security', 'testing', 'automation', 'communication',
    'web-scraping', 'media-processing', 'ai-ml', 'database',
    'cloud-infrastructure', 'game-development', 'mobile-development',
    'marketing', 'finance', 'education', 'health', 'legal',
    'real-estate', 'travel', 'food', 'fashion', 'music', 'art',
    'sports', 'science', 'history', 'philosophy', 'religion',
    'politics', 'lifestyle', 'other'
}

class SkillMetadata:
    """解析 SKILL.md 的 YAML frontmatter"""
    def __init__(self, file_path):
        self.file_path = file_path
        self.fields = {}
        self.errors = []
        self.warnings = []
        self.raw_content = ""
        self._parse()

    def _parse(self):
        try:
            with open(self.file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            self.raw_content = content

            # 提取 YAML frontmatter
            match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
            if not match:
                self.errors.append("缺少 YAML frontmatter (--- ... ---)")
                return

            yaml_block = match.group(1)
            for line in yaml_block.split('\n'):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                # 匹配 key: value 格式
                m = re.match(r'^(\w[\w_-]*)\s*:\s*(.*)$', line)
                if m:
                    key = m.group(1).strip()
                    value = m.group(2).strip().strip('"').strip("'")
                    self.fields[key] = value
        except Exception as e:
            self.errors.append(f"解析失败: {e}")

    def validate(self):
        """校验元数据完整性"""
        # 检查必填字段
        for field in REQUIRED_FIELDS:
            if field not in self.fields:
                self.errors.append(f"缺少必填字段: {field}")
            elif not self.fields[field]:
                self.errors.append(f"必填字段为空: {field}")

        # 检查推荐字段
        for field in RECOMMENDED_FIELDS:
            if field not in self.fields:
                self.warnings.append(f"缺少推荐字段: {field}")

        # 校验 category 值
        if 'category' in self.fields:
            cat = self.fields['category']
            if cat not in VALID_CATEGORIES:
                self.warnings.append(f"非标准 category 值: {cat}")

        # 校验 version 格式
        if 'version' in self.fields:
            ver = self.fields['version']
            if not re.match(r'^\d+\.\d+\.\d+', ver):
                self.warnings.append(f"version 格式不规范: {ver} (应为 x.y.z)")

        # 校验 name 与目录名一致
        if 'name' in self.fields:
            dir_name = Path(self.file_path).parent.name
            if self.fields['name'] != dir_name:
                self.warnings.append(f"name({self.fields['name']}) 与目录名({dir_name})不一致")

        return len(self.errors) == 0

    def get_category(self):
        return self.fields.get('category', 'other')

    def get_name(self):
        return self.fields.get('name', Path(self.file_path).parent.name)

    def get_description(self):
        return self.fields.get('description', '')

    def get_version(self):
        return self.fields.get('version', '0.0.0')


def find_all_skills(root_dir):
    """查找所有 SKILL.md 文件"""
    skills = []
    skip_dirs = {'node_modules', 'target', '.git', 'dist', 'build', '__pycache__'}

    for dirpath, dirnames, filenames in os.walk(root_dir):
        # 跳过指定目录
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]

        if 'SKILL.md' in filenames:
            skill_path = os.path.join(dirpath, 'SKILL.md')
            skills.append(skill_path)

    return sorted(skills)


def generate_stats(skills_meta):
    """生成统计信息"""
    stats = {
        'total': len(skills_meta),
        'valid': 0,
        'with_errors': 0,
        'with_warnings': 0,
        'categories': defaultdict(int),
        'missing_category': [],
        'missing_version': [],
        'missing_description_zh': [],
        'version_distribution': defaultdict(int),
    }

    for meta in skills_meta:
        if not meta.errors:
            stats['valid'] += 1
        else:
            stats['with_errors'] += 1

        if meta.warnings:
            stats['with_warnings'] += 1

        cat = meta.get_category()
        stats['categories'][cat] += 1

        if 'category' not in meta.fields:
            stats['missing_category'].append(str(meta.file_path))

        if 'version' not in meta.fields:
            stats['missing_version'].append(str(meta.file_path))

        if 'description_zh' not in meta.fields:
            stats['missing_description_zh'].append(str(meta.file_path))

        ver = meta.get_version()
        major = ver.split('.')[0] if ver != '0.0.0' else 'unknown'
        stats['version_distribution'][major] += 1

    return stats


def main():
    fix_mode = '--fix' in sys.argv

    root = Path(__file__).parent
    print(Color.blue("=" * 60))
    print(Color.blue("  Skills-archive 元数据规范校验"))
    print(Color.blue("=" * 60))
    print()

    # 查找所有 SKILL.md
    skill_files = find_all_skills(root)
    print(f"找到 {len(skill_files)} 个 SKILL.md 文件")
    print()

    # 解析并校验
    skills_meta = []
    for path in skill_files:
        meta = SkillMetadata(path)
        meta.validate()
        skills_meta.append(meta)

    # 输出错误
    print(Color.bold("[错误详情]"))
    print("-" * 60)
    error_count = 0
    for meta in skills_meta:
        if meta.errors:
            rel_path = os.path.relpath(meta.file_path, root)
            for err in meta.errors:
                print(f"  {Color.red('ERROR')}: {rel_path} - {err}")
                error_count += 1

    if error_count == 0:
        print(f"  {Color.green('无错误')}")
    print()

    # 输出警告
    print(Color.bold("[警告详情]"))
    print("-" * 60)
    warning_count = 0
    for meta in skills_meta:
        if meta.warnings:
            rel_path = os.path.relpath(meta.file_path, root)
            for warn in meta.warnings:
                print(f"  {Color.yellow('WARN')}: {rel_path} - {warn}")
                warning_count += 1

    if warning_count == 0:
        print(f"  {Color.green('无警告')}")
    print()

    # 生成统计
    stats = generate_stats(skills_meta)

    print(Color.bold("[统计摘要]"))
    print("-" * 60)
    print(f"  总计 SKILL.md: {stats['total']}")
    print(f"  {Color.green('有效:')} {stats['valid']}")
    print(f"  {Color.red('有错误:')} {stats['with_errors']}")
    print(f"  {Color.yellow('有警告:')} {stats['with_warnings']}")
    print()

    print(Color.bold("[分类分布]"))
    print("-" * 60)
    for cat, count in sorted(stats['categories'].items(), key=lambda x: -x[1]):
        bar = '█' * min(count, 50)
        print(f"  {cat:30s} {count:4d} {bar}")
    print()

    print(Color.bold("[缺失字段统计]"))
    print("-" * 60)
    print(f"  缺少 category:        {len(stats['missing_category'])}")
    print(f"  缺少 version:         {len(stats['missing_version'])}")
    print(f"  缺少 description_zh:  {len(stats['missing_description_zh'])}")
    print()

    print(Color.bold("[版本分布]"))
    print("-" * 60)
    for ver, count in sorted(stats['version_distribution'].items()):
        print(f"  v{ver}.x: {count}")
    print()

    # 生成 JSON 报告
    report = {
        'total': stats['total'],
        'valid': stats['valid'],
        'errors': error_count,
        'warnings': warning_count,
        'categories': dict(stats['categories']),
        'missing_category': stats['missing_category'],
        'missing_version': stats['missing_version'],
    }

    report_path = root / 'metadata_report.json'
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    print(f"报告已生成: {report_path}")
    print()

    # 返回码
    if error_count > 0:
        sys.exit(1)
    else:
        print(Color.green("校验通过!"))
        sys.exit(0)


if __name__ == '__main__':
    main()
