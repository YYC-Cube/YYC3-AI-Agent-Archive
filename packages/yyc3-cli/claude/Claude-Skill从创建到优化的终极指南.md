---
@file: Claude-Skill从创建到优化的终极指南.md
@description: YYC³-CLI Claude-Skill从创建到优化的终极指南.md
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

# Claude Skill 到底是什么？从创建到优化的终极指南

本文讨论了Claude Skill的相关内容，包括其定义、创建方法、加载与测试、优化原则以及一个Word文档处理的Skill示例，旨在将Claude Code打造成深度融入工作流的编码工具。关键要点包括：
1. Skill定义：Skill是自定义指令，可增强Claude在特定任务或领域的能力，能编码机构知识、标准化输出和处理复杂工作流。
2. 创建方式：可使用官方模板或手动编写，创建时要明确核心需求、合理命名、撰写有效描述和结构化指令。
3. 加载与测试：在项目根目录创建skills文件夹，添加SKILL.md文件，安装插件后Claude Code会自动加载。测试要涵盖常规、边界和超出范围三种场景。
4. 优化原则：从真实痛点出发创建，明确“好”的标准，善用“Skill - Creator”工具，了解Skill局限，避免信息堆砌。
5. Word文档处理Skill示例：目标是让Claude Code成为Word文档操作专家，核心结构清晰，有YAML头部信息、工作流决策树，任务模块化。
6. 关键设计优点：有强制性指令确保信息完整加载，模块化引用节省上下文窗口，用正反示例教学，能预判和规避错误。
7. 最终目标：将Claude Code从通用AI助手打造成深度融入工作流的编码工具。

什么是 Skill？ 
Skill 是一种自定义指令，用于增强 Claude 在特定任务或领域的能力。通过 SKILL.md 文件创建 Skill，实际上是在教 Claude Code 如何更高效地处理某些场景。Skill 的优势在于它能帮助你将机构知识进行编码、标准化输出，并处理复杂的多步骤工作流。过去，这些工作流往往需要反复说明或者需要为每个场景开发定制化的 Agent。
如果你想将 Claude Code 从一个通用助手变为专门适应你工作流的专家，你可以通过两种方式创建 Skill：使用官方提供的技能创建模板（Skill Creator Template）或者手动编写。

小建议：
如果想省时省力，可以先用模板搭建 SKILL.md 的基本框架，然后根据实际需求进行调整优化。

如何创建可以稳定触发的 Skill？
1. 明确核心需求
在动手创建 Skill 之前，先要搞清楚它要解决什么具体问题。优秀的 Skill 应该针对具体的需求，并且能给出可量化的结果。例如，“从 PDF 中提取财务数据并格式化为 CSV”要比“处理财务相关事务”更明确，因为清晰地定义了输入格式、执行动作和输出期望。
如何梳理需求？可以考虑以下问题：
- Skill 要完成哪些具体任务？
- 触发 Skill 的条件是什么？
- 成功的判定标准是什么？
- Skill 的边界和局限在哪里？
2. 如何命名 Skill 
每个 Skill 必须包含三个核心组件：名称（清晰标识）、描述（触发场景）、指令（执行步骤）。这里重点关注名称和描述，因为它们决定了 Skill 的触发逻辑 —— 也就是说，决定了Claude 能否在合适的时机调用该 Skill 执行相关工作。
命名规则：
- 使用简洁的名称，并采用小写字母和连字符（如：pdf-editor 或 brand-guidelines）。
- 避免冗长描述，确保名称直观、易于理解。
3. 如何撰写描述字段
描述字段决定了 Skill 何时被触发。你需要从 Claude Code 的角度来编写，重点说明触发条件、能力范围和适用场景。
高效描述的关键：
- 能力：具体描述 Skill 能做什么。
- 触发条件：明确什么情况下会调用 Skill。
- 上下文：说明在什么情况下，Claude Code 会使用此 Skill。
- 边界：明确指出不适用的场景。
通过一个例子，就可以直观地理解什么样的描述更为有效：
低效描述示例：
“该 Skill 可处理 PDF 和文档相关事务。”
高效描述示例：
“全面的 PDF 处理工具，支持文本/表格提取、创建新 PDF、合并/拆分文档及表单填写。当 Claude Code 需要批量处理或分析 PDF 文档时触发，适用于文档工作流及批量操作场景。不支持简单查看或基础格式转换。”
4.  如何编写核心指令
指令部分需要结构化、易于理解，并可以直接执行。你可以通过 Markdown 格式来提升可读性，多使用标题层级、项目符号和代码块。
推荐结构：
- 概述：简要介绍 Skill 的核心功能。
- 前置条件：使用 Skill 前需要满足的条件。
- 执行步骤：详细说明每个步骤的输入输出。
- 示例：提供具体使用场景和操作示例。
- 错误处理：列出常见错误及其解决方法。
- 局限说明：明确 Skill 无法实现的功能。
此外，SKILL.md还可以附加相关参考文件或资源，帮助 Claude Code 更准确地执行任务。
5. 如何在 Claude Code 中加载你的 Skill
1. 创建 Skill 文件夹
在你的项目根目录下创建一个 skills/ 文件夹。
2. 添加 SKILL.md 文件
在 skills/ 文件夹中，创建一个新的文件夹（比如命名为 my-skill），并在该文件夹下添加 SKILL.md 文件。该文件应包含你编写的 Skill 描述和指令。
3. 安装插件并加载
安装相关插件后，Claude Code 会自动识别并加载你添加的 Skill。
示例目录结构：
my-project/
├── skills/
│   └── my-skill/
│       └── SKILL.md

6. 测试与验证
在部署之前，必须在真实场景中对 Skill 进行全面测试，确保它能在不同情况下稳定运行。通过系统性验证，可以提前发现指令漏洞、描述不清或使用时可能遇到的边界问题。
建议按以下三种场景开始测试：
1. 常规操作场景
测试 Skill 是否能处理典型请求，验证其在标准场景下的表现。例如，财务分析类 Skill 可以测试“分析微软最新财报”或“为这份 10-K 文件生成数据包”，通过这些测试确认 Skill 是否按预期执行。
2. 边界场景
测试 Skill 如何处理不完整或异常输入。比如数据缺失、文件格式不符，或者用户指令不清晰时，Skill 应该能够给出简化的可用结果，或明确提示用户需要补充的信息。
3. 超出范围的场景
测试一些看似相关但实际上不应触发该 Skill 的请求。例如，NDA 审核类 Skill 可以测试“审核这份雇佣协议”或“分析这份租赁合同”，此时 Skill 应该保持休眠状态，由其他 Skill 来处理。
7. 基于反馈进行迭代优化
就像优化提示词一样，优质的 Skill 需要通过不断的实际应用反馈来迭代和优化，发现问题并解决问题，才能确保它更贴合实际需求。
- 如果触发不稳定，可以优化描述字段。
- 如果输出结果异常，需要进一步调整指令的细节。

想让你的 Skill 真正好用？记住这几个黄金法则
别让你辛辛苦苦创建的 Skill 只是躺在那里，看起来很酷，却解决不了实际问题。下面这些原则，能帮你打造出维护起来不费劲、能反复使用、并且真正成为你左膀右臂的实用工具。
1. 从真实的痛点出发，而不是凭空想象
不要为了创造而创造。最强大、最实用的 Skill，都诞生于你工作中那些反复出现、让你感到繁琐的真实场景。
在动手之前，不妨先诚实地问自己两个问题：
- 这个任务我已经做过至少 5 次了吗？
- 未来还会再做至少 10 次吗？
只有当这两个问题的答案都是肯定的，你投入时间去创建一个 Skill 才具有真正的价值。
2. 把“好”的标准，明明白白地写进去
不要让 Claude Code 去猜你心目中的“优质输出”到底是什么样子。你需要像一位严格的项目经理，为成功设定清晰、可衡量的标准，并把这些标准直接写进 Skill 的指令里。
举个例子，如果你要创建一个生成财务报告的 Skill，你就必须明确要求：
- 结构标准：报告必须包含“摘要”、“关键财务指标”、“风险分析”和“未来展望”这四个章节。
- 格式规范：所有数字必须使用千分位分隔符，百分比保留两位小数，表格使用特定的 Markdown 格式。
- 验证规则：所有数据必须与原始数据源进行交叉验证，差异不得超过 0.1%。
- 质量阈值：报告的结论必须基于至少三个独立的数据点来支撑。
当你把这些标准都变成了指令的一部分，Claude Code 就拥有了自我校验的能力，它交出的答卷才会更接近你的预期。
3. 善用 “Skill-Creator” 这个工具
Skill-Creator 是帮助你构建结构化 Skill 的工具，它就像你的私人教练和陪练。
它会：
- 主动提问，引导你把模糊的需求变得清晰、具体。
- 给出建议，帮你优化描述的字段，让指令更精准。
- 规范格式，协助你搭建一个结构合理、易于维护的 Skill。
你可以在 GitHub 的 Skills 仓库里找到它。尤其是在你创建最初的几个 Skill 时，能少走很多弯路，帮你快速上手。
4. 理解 Skill 的“脾气”：它的局限与注意事项
了解 Skill 的工作原理和它的能力边界，能帮你设计出更高效的工具，同时也能让你对它建立一个合理的预期。
Skill 是如何被“唤醒”的？
Claude Code 并不是通过简单的关键词匹配来决定是否启动某个 Skill 的。它更像是在通过语义理解，判断你的请求和哪个 Skill 的描述最相关。
但这套理解系统并非完美，以下几点需要你特别注意：
- 拒绝模糊的描述：如果你的请求描述得不清不楚，Claude Code 很可能找不到对应的 Skill，或者找错了。
- 避免“一呼百应”：在处理复杂任务时，你的一个请求可能会同时激活多个 Skill，因为它们可能都沾点边，都觉得自己能处理。
- 避免“叫天天不应”：如果你在 Skill 的描述里遗漏了某些关键用例，那么当这些场景出现时，Claude Code 可能会完全无动于衷，导致无法触发 Skill。
所以，给你的 Skill 起一个精准的名字，写一段清晰的简介，至关重要。
别让 Skill 变得“臃肿”
创建 Skill 时，要避免把所有信息都堆砌在主文件里，这会占用宝贵的“上下文窗口”（可以理解为 Claude Code 的即时记忆空间）。
你需要时刻思考：“这条信息，是每次对话都必须加载的吗？还是只在特定条件下才需要？”
这里推荐一种“菜单式思路”：
如果你的 Skill 包含多个独立的功能或流程（比如，既能生成报告，又能分析数据，还能制作图表），那么你的主 SKILL.md 文件就应该像一份餐厅的菜单，它只需要：
1. 简要概述自己能提供哪些“菜品”（功能）。
2. 为每道“菜品”提供一个指向详细“菜谱”的链接（即相对路径引用其他独立文件）。
这样做的好处是，当用户点了“宫保鸡丁”（某个具体任务）时，Claude Code 只会加载“宫保鸡丁”的详细菜谱（对应的独立文件），而不会把整本厚厚的菜谱书都读一遍。这极大地提升了效率，也确保了输出的精准性。
这些独立的“菜谱”文件之间并不冲突，核心原则就是将内容拆分为合理的模块，让 Claude Code 能够根据用户的具体任务，自主选择并加载它真正需要的那些资源。

真实场景 Skill 示例：一个全能的 Word 文档处理“专家”
想象一下，你有一个专门的助手，它精通 Word 文档的一切操作——从创建、编辑、分析，到处理复杂的修订追踪和批注。这个 docx Skill 就是你的这位“专家”。

#---
name: docx
description: "Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction. When Claude needs to work with professional documents (.docx files) for: (1) Creating new documents, (2) Modifying or editing content, (3) Working with tracked changes, (4) Adding comments, or any other document tasks"
license: Proprietary. LICENSE.txt has complete terms
---
# DOCX creation, editing, and analysis
## Overview

A user may ask you to create, edit, or analyze the contents of a .docx file. A .docx file is essentially a ZIP archive containing XML files and other resources that you can read or edit. You have different tools and workflows available for different tasks.

## Workflow Decision Tree
### Reading/Analyzing Content
Use "Text extraction" or "Raw XML access" sections below

### Creating New Document
Use "Creating a new Word document" workflow

### Editing Existing Document
- **Your own document + simple changes**
  Use "Basic OOXML editing" workflow

- **Someone else's document**
  Use **"Redlining workflow"** (recommended default)
- **Legal, academic, business, or government docs**
  Use **"Redlining workflow"** (required)
## Reading and analyzing content
### Text extraction
If you just need to read the text contents of a document, you should convert the document to markdown using pandoc. Pandoc provides excellent support for preserving document structure and can show tracked changes:

```bash
# Convert document to markdown with tracked changes
pandoc --track-changes=all path-to-file.docx -o output.md
# Options: --track-changes=accept/reject/all
```
### Raw XML access
You need raw XML access for: comments, complex formatting, document structure, embedded media, and metadata. For any of these features, you'll need to unpack a document and read its raw XML contents.

#### Unpacking a file
`python ooxml/scripts/unpack.py <office_file> <output_directory>`
#### Key file structures
* `word/document.xml` - Main document contents
* `word/comments.xml` - Comments referenced in document.xml
* `word/media/` - Embedded images and media files
* Tracked changes use `<w:ins>` (insertions) and `<w:del>` (deletions) tags
## Creating a new Word document
When creating a new Word document from scratch, use **docx-js**, which allows you to create Word documents using JavaScript/TypeScript.
### Workflow
1. **MANDATORY - READ ENTIRE FILE**: Read [`docx-js.md`](docx-js.md) (~500 lines) completely from start to finish. **NEVER set any range limits when reading this file.** Read the full file content for detailed syntax, critical formatting rules, and best practices before proceeding with document creation.
2. Create a JavaScript/TypeScript file using Document, Paragraph, TextRun components (You can assume all dependencies are installed, but if not, refer to the dependencies section below)
3. Export as .docx using Packer.toBuffer()
## Editing an existing Word document
When editing an existing Word document, use the **Document library** (a Python library for OOXML manipulation). The library automatically handles infrastructure setup and provides methods for document manipulation. For complex scenarios, you can access the underlying DOM directly through the library.
### Workflow
1. **MANDATORY - READ ENTIRE FILE**: Read [`ooxml.md`](ooxml.md) (~600 lines) completely from start to finish. **NEVER set any range limits when reading this file.** Read the full file content for the Document library API and XML patterns for directly editing document files.
2. Unpack the document: `python ooxml/scripts/unpack.py <office_file> <output_directory>`
3. Create and run a Python script using the Document library (see "Document Library" section in ooxml.md)
4. Pack the final document: `python ooxml/scripts/pack.py <input_directory> <office_file>`

The Document library provides both high-level methods for common operations and direct DOM access for complex scenarios.

## Redlining workflow for document review
This workflow allows you to plan comprehensive tracked changes using markdown before implementing them in OOXML. **CRITICAL**: For complete tracked changes, you must implement ALL changes systematically.
**Batching Strategy**: Group related changes into batches of 3-10 changes. This makes debugging manageable while maintaining efficiency. Test each batch before moving to the next.
**Principle: Minimal, Precise Edits**
When implementing tracked changes, only mark text that actually changes. Repeating unchanged text makes edits harder to review and appears unprofessional. Break replacements into: [unchanged text] + [deletion] + [insertion] + [unchanged text]. Preserve the original run's RSID for unchanged text by extracting the `<w:r>` element from the original and reusing it.

Example - Changing "30 days" to "60 days" in a sentence:
```python
# BAD - Replaces entire sentence
'<w:del><w:r><w:delText>The term is 30 days.</w:delText></w:r></w:del><w:ins><w:r><w:t>The term is 60 days.</w:t></w:r></w:ins>'

# GOOD - Only marks what changed, preserves original <w:r> for unchanged text
'<w:r w:rsidR="00AB12CD"><w:t>The term is </w:t></w:r><w:del><w:r><w:delText>30</w:delText></w:r></w:del><w:ins><w:r><w:t>60</w:t></w:r></w:ins><w:r w:rsidR="00AB12CD"><w:t> days.</w:t></w:r>'
```
### Tracked changes workflow
1. **Get markdown representation**: Convert document to markdown with tracked changes preserved:
   ```bash
   pandoc --track-changes=all path-to-file.docx -o current.md
   ```
2. **Identify and group changes**: Review the document and identify ALL changes needed, organizing them into logical batches:
   **Location methods** (for finding changes in XML):
   - Section/heading numbers (e.g., "Section 3.2", "Article IV")
   - Paragraph identifiers if numbered
   - Grep patterns with unique surrounding text
   - Document structure (e.g., "first paragraph", "signature block")
   - **DO NOT use markdown line numbers** - they don't map to XML structure
   **Batch organization** (group 3-10 related changes per batch):
   - By section: "Batch 1: Section 2 amendments", "Batch 2: Section 5 updates"
   - By type: "Batch 1: Date corrections", "Batch 2: Party name changes"
   - By complexity: Start with simple text replacements, then tackle complex structural changes
   - Sequential: "Batch 1: Pages 1-3", "Batch 2: Pages 4-6"
3. **Read documentation and unpack**:
   - **MANDATORY - READ ENTIRE FILE**: Read [`ooxml.md`](ooxml.md) (~600 lines) completely from start to finish. **NEVER set any range limits when reading this file.** Pay special attention to the "Document Library" and "Tracked Change Patterns" sections.
   - **Unpack the document**: `python ooxml/scripts/unpack.py <file.docx> <dir>`
   - **Note the suggested RSID**: The unpack script will suggest an RSID to use for your tracked changes. Copy this RSID for use in step 4b.
4. **Implement changes in batches**: Group changes logically (by section, by type, or by proximity) and implement them together in a single script. This approach:
   - Makes debugging easier (smaller batch = easier to isolate errors)
   - Allows incremental progress
   - Maintains efficiency (batch size of 3-10 changes works well)
   **Suggested batch groupings:**
   - By document section (e.g., "Section 3 changes", "Definitions", "Termination clause")
   - By change type (e.g., "Date changes", "Party name updates", "Legal term replacements")
   - By proximity (e.g., "Changes on pages 1-3", "Changes in first half of document")

   For each batch of related changes:

   **a. Map text to XML**: Grep for text in `word/document.xml` to verify how text is split across `<w:r>` elements.
   **b. Create and run script**: Use `get_node` to find nodes, implement changes, then `doc.save()`. See **"Document Library"** section in ooxml.md for patterns.
   **Note**: Always grep `word/document.xml` immediately before writing a script to get current line numbers and verify text content. Line numbers change after each script run.
5. **Pack the document**: After all batches are complete, convert the unpacked directory back to .docx:
   ```bash
   python ooxml/scripts/pack.py unpacked reviewed-document.docx
   ```
6. **Final verification**: Do a comprehensive check of the complete document:
   - Convert final document to markdown:
     ```bash
     pandoc --track-changes=all reviewed-document.docx -o verification.md
     ```
   - Verify ALL changes were applied correctly:
     ```bash
     grep "original phrase" verification.md  # Should NOT find it
     grep "replacement phrase" verification.md  # Should find it
     ```
   - Check that no unintended changes were introduced

## Converting Documents to Images

To visually analyze Word documents, convert them to images using a two-step process:

1. **Convert DOCX to PDF**:
   ```bash
   soffice --headless --convert-to pdf document.docx
   ```
2. **Convert PDF pages to JPEG images**:
   ```bash
   pdftoppm -jpeg -r 150 document.pdf page
   ```
   This creates files like `page-1.jpg`, `page-2.jpg`, etc.

Options:
- `-r 150`: Sets resolution to 150 DPI (adjust for quality/size balance)
- `-jpeg`: Output JPEG format (use `-png` for PNG if preferred)
- `-f N`: First page to convert (e.g., `-f 2` starts from page 2)
- `-l N`: Last page to convert (e.g., `-l 5` stops at page 5)
- `page`: Prefix for output files

Example for specific range:
```bash
pdftoppm -jpeg -r 150 -f 2 -l 5 document.pdf page  # Converts only pages 2-5
```
## Code Style Guidelines
**IMPORTANT**: When generating code for DOCX operations:
- Write concise code
- Avoid verbose variable names and redundant operations
- Avoid unnecessary print statements
## Dependencies

Required dependencies (install if not available):

- **pandoc**: `sudo apt-get install pandoc` (for text extraction)
- **docx**: `npm install -g docx` (for creating new documents)
- **LibreOffice**: `sudo apt-get install libreoffice` (for PDF conversion)
- **Poppler**: `sudo apt-get install poppler-utils` (for pdftoppm to convert PDF to images)
- **defusedxml**: `pip install defusedxml` (for secure XML parsing)

让我们来深入分析一下这个 docx Skill 文件。
1. 目标明确
这个 Skill 的目标非常明确：让 Claude Code 成为一个精通 Word 文档底层操作的专业工程师，而不仅仅是一个会用自然语言描述文档内容的助手。它没有试图用模糊的语言去“教” Claude Code，而是提供了一套精确、可执行、包含决策逻辑和边界条件的完整工作流。
2. 核心结构清晰、分层明确
这个文件完美地解决了“信息过载”和“决策模糊”两大难题。
1. YAML 头部信息：
  - name: docx: 简洁明了，便于内部调用。
  - description: 这是整个 Skill 的“触发器”。它没有用空泛的词，而是列举了 4 个具体的、高频的使用场景（创建、修改、处理修订、添加评论）。这大大增加了 Claude Code 在用户提出相关请求时，准确匹配并激活此 Skill 的概率。
2. 工作流决策树：Skill 的“大脑”
它没有一上来就堆砌技术细节，而是首先建立一个决策框架。它通过一系列简单的判断（是读取还是创建？是自己的文档还是别人的？），将复杂的需求分流到不同的、最优的处理路径上。避免了 Claude Code 面对一个复杂任务时“无从下手”或“选错工具”的窘境，极大地提升了执行的准确性和效率。
3. 任务模块化
文件主体按照任务类型（读取、创建、编辑、修订）划分成独立模块。每个模块都像一个独立的“工具说明书”。
3. 关键设计与优点
1. 强制性指令：杜绝“想当然”
  - MANDATORY - READ ENTIRE FILE 和 NEVER set any range limits 是非常强硬的指令。
  - 这背后是对 AI 行为模式的深刻理解：AI 倾向于“偷懒”和“总结”，可能会忽略长文档中的关键细节。通过这种强制命令，确保了 Claude Code 在执行任何操作前，必须完整地加载所有必要的知识，从而避免了因信息不全导致的错误。
2. 模块化引用：保持主文件的“清爽”
  - 它没有把 docx-js.md 和 ooxml.md 的几百行内容全部塞进主文件。而是通过引用的方式，让 Claude Code 在需要时再去加载。
  - 这完美实践了之前提到的“菜单式思路”。主文件是菜单，告诉 Claude Code 有什么“菜”；引用的文件是“菜谱”，告诉 Claude Code 具体怎么做。这极大地节省了宝贵的上下文窗口，也让主文件更易于阅读和维护。
3. 用正反示例进行直观的“教学”
  - 在工作流中，关于如何精确标记修订，它给出了 BAD 和 GOOD 的代码对比。
  - 这比任何抽象的描述都有效。它让 Claude Code 直观地理解了“最小化、精准化编辑”这一抽象原则的具体含义，学会了如何写出专业的修订标记。
4. 错误预判与规避
  - 批处理策略：建议将 3-10 个改动打包处理，这是为了降低调试难度，防止一次性改动太多导致问题难以定位。
  - 定位方法警告：明确警告 DO NOT use markdown line numbers，因为行号和 XML 结构不对应，这是一个新手极易犯的错误。
  - 代码风格指南：要求代码简洁，避免冗余，这是为了保证生成的脚本清晰、高效。
这个 docx Skill 文件不仅仅是在“告诉” Claude Code 该做什么，更是在构建一个完整的决策和执行框架。

总结
回顾我们一路的探讨，从理解 Skill 的本质，到掌握创建它的最佳实践，我们最终的目标始终如一：将 Claude Code 从一个通用的 AI 助手，打造为深度融入你工作流的编码工具。
上述详细拆解的 Skill 示例恰恰体现了这一理念的精髓。它展示了一个理想的 Skill，不再只是一个简单的问答系统，而是一个具备清晰决策树、严格操作规程、并能避免常见陷阱的“虚拟工程师”。它的价值不仅体现在代码的实现上，更在于对业务逻辑的深入理解，以及对 AI 行为的精准掌控。
