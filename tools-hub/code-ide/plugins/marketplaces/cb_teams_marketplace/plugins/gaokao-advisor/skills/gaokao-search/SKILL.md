---
name: gaokao-search
description: >
category: development-code
version: 1.0.0
  高考知识库可信检索能力。用于检索高考真题、作文素材、高校介绍、专业信息、
  招生政策、志愿填报规则等需要知识库证据的问题。分数线、一分一段和位次换算
  应优先交给专门分数技能，本技能只在需要文档证据时使用。
---

# 高考知识库可信检索

本技能检索高考知识库，返回文档片段、标题、相关性分数、资源标识和下载能力。

## 认证

认证由 WorkBuddy 的 `connect_cloud_service` 提供，执行规则如下：

1. **每次**调用 `gaokao-search.py` 前，都必须先调用 `connect_cloud_service`，不得跳过。
2. `connect_cloud_service` 返回中可能包含 `tempToken` 和 `token` 两个字段。
3. **优先使用 `tempToken`**：如果 `tempToken` 存在且非空，将它通过 `--token` 参数传入脚本。
4. 如果 `tempToken` 不存在或为空，才使用 `token` 字段作为 `--token` 参数。
5. 不向用户展示、记录、复述或解释 Token 内容。
6. **禁止缓存或复用 Token**：即使同一轮对话连续多次检索，也必须每次重新调用 `connect_cloud_service`。
7. 脚本不会从环境变量读取 AgentTool Token；`--token` 必须是本次调用刚获取的凭证。
8. 除本次 `--token` 外，脚本不依赖任何环境变量；新安装环境使用内置默认端点、默认超时和默认返回条数即可运行。

## 配额节省规则

高考知识库检索存在每日限额，成功或失败搜索都会消耗配额。调用方必须按以下方式节省次数：

1. 默认使用 `--limit 20`，一次尽量取满结果。
2. 先构造覆盖面大的 query，再调用脚本；不要为了覆盖多个科目、多个相近关键词、同一学校的多个资料类型而逐条搜索。
3. 真题/试卷资料优先把年份、卷别、地区和科目集合合并到一个 query，例如“2024 全国一卷 真题 语文 数学 英语 物理 化学 生物 政治 历史 地理”。
4. 院校/专业资料优先把学校、专业、年份、省份、招生章程、录取线、选科要求等关键词合并到一个 query。
5. 先充分整理当前返回结果；只有明确缺少关键证据时，才补充搜索一次，并把缺口合并为一个 query。
6. 如果返回 `DAILY_LIMIT_EXCEEDED` 或上游提示 `daily search limit exceeded`，停止继续检索，基于本轮已返回结果回答，并说明哪些信息还缺证据。

## 使用边界

- 适用：高考真题、作文题目/素材/范文、高校介绍、专业介绍、高校录取线/投档线、招生章程、志愿填报政策、官方文档片段检索。
- 不优先适用：地区批次分数线、一分一段、分数换位次、位次换分数。这些问题应使用包内两个专门分数技能。
- 单纯查询高校信息、专业信息、招生章程或政策内容时，只整理命中文档支持的信息和来源；不得主动延伸为报考建议、学校/专业优劣评价、地域倾向或志愿方案。
- 检索为空或失败时，必须明确告知没有可用证据，不得基于常识补写答案。
- 检索有命中但标题、摘要、正文与用户问题明显不相关时，必须当作“无可用证据”，不得为了回答而牵强引用。
- 当前知识库或包内技能无法提供足够相关证据时，不得自行改用其他网络来源继续检索；只建议用户到省级招生考试机构官网、高校本科招生网、官方招生章程、阳光高考等官方可信渠道核验。
- 住宿条件、食堂、校园环境、交通便利度、生活便利度、宿舍新旧、校园氛围、就业口碑等只有在命中文档片段明确提供信息时才能回答；否则必须说“当前知识库没有可核验的信息”，不得凭印象、常识或外部网络补写。
- 院校录取线/投档线等数字信息必须逐字遵循命中文档片段和字段。若同一学校、年份、生源省份、科类/选科、批次/专业组下出现多个不一致结果，只列出差异并提示官方核验，不得自行择一、平均或沿用历史回答。

## 调用方式

```bash
python ./scripts/gaokao-search.py "2024 全国一卷 真题 语文 数学 英语 物理 化学 生物 政治 历史 地理" --limit 20 --token "<fresh-token-from-connect_cloud_service>"
```

```bash
python ./scripts/gaokao-search.py "中山大学 2025 广东 招生章程 录取线 投档线 专业 选科要求" --limit 20 --download-id "dl_xxxxxxxxxxxxxxxx" --download-dir "/workspace" --token "<fresh-token-from-connect_cloud_service>"
```

Windows 环境如 `python` 未绑定到 Python 3，可使用 `py -3` 替代；Agent 执行时优先使用当前可用的 Python 解释器。

可选参数：

| 参数 | 说明 |
|------|------|
| `--limit` | 返回条数，1-20，默认 20；除非用户问题非常窄，否则保持 20 |
| `--endpoint` | 检索端点，默认使用正式 AgentTool 域名；一般不要改 |
| `--token` | 本次调用通过 `connect_cloud_service` 新获取的 Bearer token |
| `--resolve` | 可选 DNS 覆盖，格式同 curl `--resolve`；一般不要使用 |
| `--download` | 可选下载命中文档，取值 `first` / `all`；只有显式传入 `--download` 才会下载，单独传 `--download` 且不带值时等同 `all` |
| `--download-id` | 可选下载指定稳定资料标识，可传多次；优先用于用户确认某条资料后下载，避免结果重排导致下错文件 |
| `--download-index` | 可选下载指定 1-based 结果序号，可传多次；仅用于同一次检索结果刚返回、尚未换 query 时的兼容方式 |
| `--download-dir` | 下载保存目录；使用 `--download`、`--download-id` 或 `--download-index` 时必填。Agent 应自行判断：有 `/workspace` 时下载到 `/workspace`；没有 `/workspace` 时可选择当前工作目录 |
| `--download-timeout` | 文件下载超时秒数，默认 60 |

## 链接展示与下载规则

- `gaokao-search` 用户侧不展示任何文档链接，不让用户复制链接到浏览器打开。用户侧只展示标题、摘要、命中片段、相关性分数、`download_id` 和 `download_index`。
- 用户明确要某份资料文件时，先检索并核对标题/摘要；若有唯一或明显匹配项，优先使用对应 `--download-id ID` 下载。只有在同一次检索结果刚返回且未更换 query 时，才可使用 `--download-index N`。只有在调用方已经确认第一条就是目标资料时，才使用 `--download first`。
- 用户目标不明确或检索到多个相似资料时，先展示当前结果列表并询问是否/哪一个是他要的；用户确认后优先用对应 `download_id` 下载，不要在换 query 后沿用旧 `download_index`。
- 执行下载命令时必须显式传入 `--download-dir`；脚本不会默认选择下载位置。Agent 应根据自身环境判断保存目录：有 `/workspace` 时下载到 `/workspace`；没有 `/workspace` 时可选择当前工作目录。
- 下载完成后，脚本会在 `attachment_paths` 中返回所有 `downloads[].ok=true`、`bytes_downloaded > 0` 且本地文件存在的可交付文件路径；Agent 必须调用 `deliver_attachments` 工具交付 `attachment_paths` 中的每一个文件。
- 如果 `attachment_paths` 包含 1 个路径，就把这 1 个路径传给 `deliver_attachments` 工具；如果包含多个路径，应优先一次性把全部路径传给 `deliver_attachments` 工具；如果工具一次只能处理单个文件，应逐个调用，直到每个路径都交付完成。
- 调用 `deliver_attachments` 完成文件交付后，回复用户“资料已下载并交付”，同步给出脚本返回的对应本地路径，并询问用户是否需要帮忙打开文件所在文件夹；不要承诺可在对话中直接打开预览。
- 打开文件所在位置是可选动作，不得在下载完成后自动执行。只有用户确认需要打开文件夹时，才执行打开命令；macOS 使用 Finder；Windows 使用 `os.startfile(<folder>)` 打开文件夹；其他系统可使用可用的系统文件夹打开命令。
- 如果 `deliver_attachments` 通过 ToolSearch 按名称没有搜到，仍应按宿主环境提供的同名交付工具直接调用；只有工具实际不可调用时，才说明文件已保存但无法作为正式附件交付。
- 用户只是查询内容时，不主动下载，只整理命中文档支持的信息。

## 输出格式

成功：

```json
{
  "ok": true,
  "query": "...",
  "total": 1,
  "retrieval_status": "hit",
  "chunks": [
    {
      "title": "文档标题.pdf",
      "abstract": "文档摘要",
      "url": "",
      "content": "命中文档片段",
      "score": 26.625,
      "resource_id": "...",
      "chunk_id": "...",
      "download_available": true,
      "download_id": "dl_xxxxxxxxxxxxxxxx",
      "download_index": 1
    }
  ],
  "downloads": [
    {
      "ok": true,
      "download_id": "dl_xxxxxxxxxxxxxxxx",
      "download_index": 1,
      "file": "/path/to/root/document.pdf",
      "local_path": "/path/to/root/document.pdf",
      "bytes_downloaded": 102400,
      "folder_opened": false,
      "open_location": null,
      "message": "资料已下载，文件路径：/path/to/root/document.pdf"
    }
  ],
  "attachment_paths": [
    "/path/to/root/document.pdf"
  ],
  "download_root": "/path/to/root",
  "action_required": {
    "tool": "deliver_attachments",
    "tool_input_paths": [
      "/path/to/root/document.pdf"
    ],
    "tool_call_scope": "Call the deliver_attachments tool with every path in tool_input_paths; one path means one attachment, multiple paths means all attachments.",
    "tool_call_strategy": "Pass all paths in one tool call if supported; otherwise call the tool once per path until every path is delivered.",
    "user_message": "After delivery, list the delivered local path(s). Ask whether the user wants the containing folder opened.",
    "open_folder": "Do not open automatically. Open only after the user confirms."
  },
  "source_note": "All chunks are extracted from the search API response."
}
```

失败：

```json
{
  "ok": false,
  "error": "SEARCH_FAILED",
  "message": "检索服务 HTTP 500。"
}
```

## 严谨性要求

1. 回答只能引用 `chunks` 中实际存在的内容、标题、分数、资源标识和下载序号。
2. 不得把模型常识、外部记忆或推测包装成检索结论。
3. 每条关键结论都要能回到具体来源：至少包含标题；文档 URL 不得提供给用户。
4. 资料文件需要用户获取时，应直接下载或先确认资料后下载，不要让用户打开链接；下载时优先使用 `download_id`，只在同一次检索结果内兼容使用 `download_index`；下载完成且确认文件有实际内容后，必须调用 `deliver_attachments` 正式交付 `attachment_paths` 中的全部文件，再列出所有文件路径，并询问用户是否需要帮忙打开文件所在文件夹。只有用户确认后才执行打开命令。
5. 对志愿填报、录取可能性、政策解释等高影响问题，必须附“仅供参考，以省级招生考试机构和高校官方发布为准”的边界说明。
6. 对明显不相关的命中结果，不得引用；应说明“当前知识库未返回与问题匹配的高考证据”。
7. 对高校信息、专业信息等资料检索需求，回答到信息摘要和来源为止，不添加倾向性建议或价值排序。
8. 对当前数据源无法覆盖的信息，禁止自行外扩检索、猜测或补写；只说明证据不足并建议用户自行核验官方可信资料。
9. 面向用户的文字不得使用“优先级、P0/P1/P2、阻断、闸门”等内部术语，也不得使用“985 基本盘”“守门员”等评价性标签。
