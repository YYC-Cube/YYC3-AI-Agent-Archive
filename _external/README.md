# _external/ 外部代码治理说明

> 生成时间：2026-08-18 ｜ 盘点工具：`du -sh` + `git ls-files`

## 一、现状盘点

| 目录 | 磁盘体积 | git 追踪文件数 | 性质 | 建议处置 |
|------|:-------:|:------------:|------|---------|
| `ClickHouse/` | **398 MB** | ~35,000+ | ClickHouse 数据库完整源码副本（C++），仅为参考引入 | **移出仓库**（方案 A/B） |
| `autocomplete-specs/` | **101 MB** | ~4,000 | Argparse/Click 等 CLI 自动补全规范集（728 工具） | 保留索引、移出全量（方案 B） |
| `agents/` | 28 MB | ~1,500 | CowAgent 等外部 Agent 项目副本 | 按需保留 |
| `SuperPowers/` | 1.2 MB | 少量 | SuperPowers 插件集 | 保留 |
| **合计** | **529 MB** | **40,750** | — | — |

**核心影响**：克隆本仓库需拉取 529MB 外部代码，其中 ClickHouse 与本仓库的构建、测试、运行**零依赖关系**，纯粹是参考性引入。

## 二、处置方案（需维护者决策后执行）

### 方案 A：Git Submodule 化（推荐用于 ClickHouse）

```bash
# 1. 从索引移除（磁盘文件保留，可先备份）
git rm -r --cached _external/ClickHouse

# 2. 记录上游地址后删除本地副本
#    上游：https://github.com/ClickHouse/ClickHouse
rm -rf _external/ClickHouse

# 3. 以 submodule 方式按需拉取
git submodule add --depth 1 https://github.com/ClickHouse/ClickHouse.git _external/ClickHouse
```

### 方案 B：移出仓库 + 索引文档化（推荐用于 autocomplete-specs）

```bash
# 1. 生成索引清单（保留工具名目录列表）
find _external/autocomplete-specs -maxdepth 2 -type d > docs/autocomplete-specs-INDEX.txt

# 2. 移除 git 追踪并删除
git rm -r _external/autocomplete-specs
```

### 方案 C：维持现状

若本仓库定位为"离线归档"（无需远程克隆效率），可维持现状，但需接受：

- GitHub 仓库体积持续膨胀（当前已接近推送上限风险）
- 每次克隆/CI 检出耗时显著增加
- Dependabot 曾对 `_external` 内 8 个目录发起依赖更新（已合入），存在持续维护噪音

## 三、执行状态

- [x] 体积盘点完成（2026-08-18）
- [x] 治理文档建立
- [x] **ClickHouse 移出（2026-08-18 执行：`git rm -r --cached`，本地文件保留）**
- [x] **autocomplete-specs 移出（2026-08-18 执行：索引见 `docs/autocomplete-specs-INDEX.txt`，本地文件保留）**

## 四、已执行的处置与恢复方式（2026-08-18）

**执行内容**：ClickHouse 与 autocomplete-specs 已通过 `git rm -r --cached` 移出 git 追踪
（下次提交起，新克隆不再包含这 499MB），并加入 `.gitignore` 防止误重新追踪。
**本地磁盘文件全部保留**（398MB + 101MB），可继续离线参考。

**如需恢复为 git 追踪**：

```bash
git checkout HEAD~1 -- _external/ClickHouse _external/autocomplete-specs  # 从历史提交恢复追踪
# 并从 .gitignore 移除对应两行
```

**如需在另一台机器获取参考副本**（不进 git）：

```bash
# ClickHouse（浅克隆）
git clone --depth 1 https://github.com/ClickHouse/ClickHouse.git _external/ClickHouse

# autocomplete-specs
git clone https://github.com/withfig/autocomplete.git _external/autocomplete-specs
# 索引清单：docs/autocomplete-specs-INDEX.txt（1,476 个规范）
```

**保留追踪的目录**：`agents/`（28MB，CowAgent 被 packages/mcp-runtime 的
CowAgentMCPBridge 引用）、`SuperPowers/`（1.2MB）。
