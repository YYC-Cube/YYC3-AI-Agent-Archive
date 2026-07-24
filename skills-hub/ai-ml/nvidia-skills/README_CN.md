<!-- SPDX-License-Identifier: Apache-2.0 AND CC-BY-4.0 -->
<!-- Copyright (c) 2026 NVIDIA Corporation. All rights reserved. -->
<!-- 中文本地化版本 YYC³ -->
<!-- 基于 skills/README.md (英文原版) 对齐翻译 -->

# NVIDIA 智能体技能库

**NVIDIA 官方验证的 AI 智能体技能集合。**

[![NVIDIA](https://img.shields.io/badge/NVIDIA-Verified-76B900?style=flat&logo=nvidia&logoColor=white)](https://nvidia.com)
[![Agent Skills Spec](https://img.shields.io/badge/智能体%20Skills-规范-blue)](https://agentskills.io)
[![License](https://img.shields.io/badge/许可证-Apache%202.0%20%2B%20CC--BY--4.0-green.svg)](LICENSE)

> 📖 **文档:** [docs.nvidia.com/skills](https://docs.nvidia.com/skills) &nbsp;·&nbsp;
> 📺 **直播回放:** [从有漏洞到已验证](https://www.youtube.com/watch?v=sVpKonYJ4D4&list=PL5B692fm6--vEL0FwctKghCpyEnBGAQJA&index=1) &nbsp;·&nbsp;
> 📝 **博客:** [NVIDIA 验证智能体技能：AI 智能体的能力治理](https://developer.nvidia.com/blog/nvidia-verified-agent-skills-provide-capability-governance-for-ai-agents/)

---

技能是可移植的指令集，教导 AI 智能体如何最优地使用 NVIDIA 软件，包括 CUDA-X 库、AI Blueprint 和平台工具。本仓库是技能目录：技能在各产品仓库维护，通过自动化同步流水线每日镜像至此。技能持续添加中，请定期查看更新。我们正在开放构建此基础设施，欢迎贡献。参见[路线图](#路线图)了解后续计划。

---

## 快速开始

使用默认的 [`skills` CLI](https://github.com/vercel-labs/skills) 流程安装 NVIDIA 技能：

```bash
npx skills add nvidia/skills
```

CLI 通过 `npx` 运行，提示选择技能和安装位置。无需克隆本仓库或手动复制技能文件夹。

下次智能体加载技能并遇到相关任务时即可使用。例如，让智能体"用 cuOpt 求解线性规划问题"，技能会引导其使用 cuOpt Python API。

### 无提示安装单个技能

已知技能名称并希望跳过提示时使用。

```bash
npx skills add nvidia/skills --skill cuopt-numerical-optimization-api-python --yes
```

将 `cuopt-numerical-optimization-api-python` 替换为[技能目录](#技能目录)中的任一技能名称。

### 为特定智能体安装

使用 `--agent` 指定目标 AI 编码智能体。初期支持常用客户端，后续扩展。完整列表请参见 [`skills` CLI 支持智能体表](https://github.com/vercel-labs/skills#supported-agents)。

**Claude Code**

```bash
npx skills add nvidia/skills --skill cuopt-numerical-optimization-api-python --agent claude-code
```

**Codex**

```bash
npx skills add nvidia/skills --skill cuopt-numerical-optimization-api-python --agent codex
```

**Cursor**

```bash
npx skills add nvidia/skills --skill cuopt-numerical-optimization-api-python --agent cursor
```

**Kiro**

```bash
npx skills add nvidia/skills --skill cuopt-numerical-optimization-api-python --agent kiro-cli
```

多次使用 `--agent` 可将同一技能安装到多个智能体：

```bash
npx skills add nvidia/skills \
  --skill cuopt-numerical-optimization-api-python \
  --agent claude-code \
  --agent codex \
  --agent cursor \
  --agent kiro-cli
```

### 浏览目录

查看可用 NVIDIA 技能列表（不安装）：

```bash
npx skills add nvidia/skills --list
```

非交互式安装、全局安装、指定智能体安装、更新、移除及手动复制回退方案，参见[高级安装](docs/advanced-install.mdx)。

---

## 技能目录

<!-- skills-table-start -->
| 产品 | 描述 | 技能 |
|------|------|------|
| **AIQ** | NVIDIA AI-Q Blueprint — 以智能体技能形式部署本地 AI-Q 服务，执行浅层或深层研究工作流。 | [`aiq-research`](skills/aiq-research), [`aiq-deploy`](skills/aiq-deploy) |
| **CUDA-Q** | CUDA Quantum — 安装指南、测试程序、GPU 仿真、QPU 硬件及量子应用的入门指引。 | [`cudaq-guide`](skills/cudaq-guide) |
| **cuDF** | NVIDIA cuDF GPU DataFrame 官方指南 — pandas 加速、dask-cuDF、ETL、连接、分组、CSV/Parquet I/O、空值语义及多 GPU DataFrame 工作负载。 | [`accelerated-computing-cudf`](skills/accelerated-computing-cudf) |
| **cuFOLIO** | 基于 NVIDIA cuOpt 的 GPU 加速均值-CVaR 投资组合优化 — CVaR 优化、有效前沿、情景生成、回测与再平衡。 | [`cufolio`](skills/cufolio) |
| **cuOpt** | GPU 加速优化 — 车辆路径规划、线性规划、二次规划、安装部署、服务端部署及开发者工具。 | [`cuopt-developer`](skills/cuopt-developer), [`cuopt-install`](skills/cuopt-install), [`cuopt-numerical-optimization-api-c`](skills/cuopt-numerical-optimization-api-c), [`cuopt-numerical-optimization-api-cli`](skills/cuopt-numerical-optimization-api-cli), [`cuopt-numerical-optimization-api-python`](skills/cuopt-numerical-optimization-api-python), [`cuopt-numerical-optimization-formulation`](skills/cuopt-numerical-optimization-formulation), [`cuopt-routing-api-python`](skills/cuopt-routing-api-python), [`cuopt-routing-formulation`](skills/cuopt-routing-formulation), [`cuopt-server-api-python`](skills/cuopt-server-api-python), [`cuopt-server-common`](skills/cuopt-server-common), [`cuopt-skill-evolution`](skills/cuopt-skill-evolution), [`cuopt-user-rules`](skills/cuopt-user-rules) |
| **cuPyNumeric** | 多节点多 GPU 系统上的 NumPy 和 SciPy — cuPyNumeric 安装、现有 NumPy 代码迁移及并行 I/O 相关技能。 | [`cupynumeric-hdf5`](skills/cupynumeric-hdf5), [`cupynumeric-install`](skills/cupynumeric-install), [`cupynumeric-migration-readiness`](skills/cupynumeric-migration-readiness), [`cupynumeric-parallel-data-load`](skills/cupynumeric-parallel-data-load) |
| **DALI** | 基于 NVIDIA DALI 的 GPU 加速数据加载与处理。 | [`dali-dynamic-mode`](skills/dali-dynamic-mode) |
| **Data Designer** | 使用 NeMo Data Designer 构建声明式合成数据集生成流水线。 | [`data-designer`](skills/data-designer) |
| **DeepStream** | DeepStream 开发的智能体技能指导。 | [`deepstream-dev`](skills/deepstream-dev), [`deepstream-import-vision-model`](skills/deepstream-import-vision-model) |
| **数字健康** | 临床 ASR 评估飞轮的智能体技能 — 术语整理、合成临床语音基准生成、关键词错误率评分及微调指导。 | [`digital-health-clinical-asr-setup`](skills/digital-health-clinical-asr-setup), [`digital-health-clinical-asr-build`](skills/digital-health-clinical-asr-build), [`digital-health-clinical-asr-eval`](skills/digital-health-clinical-asr-eval), [`digital-health-clinical-asr-finetune`](skills/digital-health-clinical-asr-finetune) |
| **Dynamo** | NVIDIA Dynamo 在 Kubernetes 上的部署启动 — 选择并部署配方、启动路由器模式、验证拆分 NIXL/UCX/NCCL 互联、排障运维期故障。 | [`dynamo-interconnect-check`](skills/dynamo-interconnect-check), [`dynamo-recipe-runner`](skills/dynamo-recipe-runner), [`dynamo-router-starter`](skills/dynamo-router-starter), [`dynamo-troubleshoot`](skills/dynamo-troubleshoot) |
| **Earth2Studio** | 用于探索、构建和部署 AI 天气/气候工作流的开源深度学习框架。 | [`earth2studio-data-fetch`](skills/earth2studio-data-fetch), [`earth2studio-deterministic-forecast`](skills/earth2studio-deterministic-forecast), [`earth2studio-discover`](skills/earth2studio-discover), [`earth2studio-install`](skills/earth2studio-install) |
| **Holoscan SDK** | 在任何平台上安装和配置 Holoscan SDK（容器、Debian、Python、Conda 或源码）。 | [`holoscan-install-debian`](skills/holoscan-install-debian), [`holoscan-install-source`](skills/holoscan-install-source), [`holoscan-install-wheel`](skills/holoscan-install-wheel), [`holoscan-install-conda`](skills/holoscan-install-conda), [`holoscan-install-container`](skills/holoscan-install-container), [`holoscan-setup`](skills/holoscan-setup) |
| **Holoscan 传感器桥** | Holoscan Sensor Bridge 开发套件的智能体技能，覆盖演示环境搭建、Lattice 和 VB1940 硬件 FPGA 烧录、示例应用执行及 QA 测试自动化。 | [`hsb-setup`](skills/hsb-setup), [`hsb-flash`](skills/hsb-flash), [`hsb-app`](skills/hsb-app), [`hsb-test`](skills/hsb-test) |
| **医疗 AI 技能** | 基于 MONAI 的智能体医疗 AI 技能 — DICOM 处理、NVIDIA 托管医疗影像模型工作流、分割、合成及循证评估。 | [`dicom-metadata-extract`](skills/dicom-metadata-extract), [`dicom-series-preflight`](skills/dicom-series-preflight), [`dicom-series-to-volume`](skills/dicom-series-to-volume), [`nv-generate-ct-rflow`](skills/nv-generate-ct-rflow), [`nv-generate-mr`](skills/nv-generate-mr), [`nv-generate-mr-brain`](skills/nv-generate-mr-brain), [`nv-generate-mr-brain-finetune`](skills/nv-generate-mr-brain-finetune), [`nv-generate-vae-finetune`](skills/nv-generate-vae-finetune), [`nv-reason-cxr`](skills/nv-reason-cxr), [`nv-segment-ct`](skills/nv-segment-ct), [`nv-segment-ct-finetune`](skills/nv-segment-ct-finetune), [`nv-segment-ctmr`](skills/nv-segment-ctmr) |
| **Megatron-Core** | 大规模分布式训练 — 模型并行、流水线并行及混合精度。 | [`mcore-create-issue`](skills/mcore-create-issue), [`mcore-linting-and-formatting`](skills/mcore-linting-and-formatting), [`mcore-run-on-slurm`](skills/mcore-run-on-slurm), [`mcore-split-pr`](skills/mcore-split-pr), [`mcore-testing`](skills/mcore-testing) |
| **NeMo AutoModel** | NeMo AutoModel — 面向 LLM/VLM 的 PyTorch 原生分布式训练，支持 Hugging Face、配方、启动器及验证工作流。 | [`nemo-automodel-distributed-training`](skills/nemo-automodel-distributed-training), [`nemo-automodel-launcher-config`](skills/nemo-automodel-launcher-config), [`nemo-automodel-model-onboarding`](skills/nemo-automodel-model-onboarding), [`nemo-automodel-recipe-development`](skills/nemo-automodel-recipe-development) |
| **NeMo MBridge** | NeMo MBridge — Hugging Face 与 Megatron-Core 之间的 PyTorch 原生桥梁，支持检查点转换、训练配方及 NVIDIA GPU 性能工作流。 | [`nemo-mbridge-mlm-bridge-training`](skills/nemo-mbridge-mlm-bridge-training), [`nemo-mbridge-multi-node-slurm`](skills/nemo-mbridge-multi-node-slurm), [`nemo-mbridge-perf-activation-recompute`](skills/nemo-mbridge-perf-activation-recompute), [`nemo-mbridge-perf-cpu-offloading`](skills/nemo-mbridge-perf-cpu-offloading), [`nemo-mbridge-perf-cuda-graphs`](skills/nemo-mbridge-perf-cuda-graphs), [`nemo-mbridge-perf-expert-parallel-overlap`](skills/nemo-mbridge-perf-expert-parallel-overlap), [`nemo-mbridge-perf-hierarchical-context-parallel`](skills/nemo-mbridge-perf-hierarchical-context-parallel), [`nemo-mbridge-perf-megatron-fsdp`](skills/nemo-mbridge-perf-megatron-fsdp), [`nemo-mbridge-perf-memory-tuning`](skills/nemo-mbridge-perf-memory-tuning), [`nemo-mbridge-perf-moe-comm-overlap`](skills/nemo-mbridge-perf-moe-comm-overlap), [`nemo-mbridge-perf-moe-dispatcher-selection`](skills/nemo-mbridge-perf-moe-dispatcher-selection), [`nemo-mbridge-perf-moe-hardware-configs`](skills/nemo-mbridge-perf-moe-hardware-configs), [`nemo-mbridge-perf-moe-long-context`](skills/nemo-mbridge-perf-moe-long-context), [`nemo-mbridge-perf-moe-optimization-workflow`](skills/nemo-mbridge-perf-moe-optimization-workflow), [`nemo-mbridge-perf-moe-vlm-training`](skills/nemo-mbridge-perf-moe-vlm-training), [`nemo-mbridge-perf-parallelism-strategies`](skills/nemo-mbridge-perf-parallelism-strategies), [`nemo-mbridge-perf-sequence-packing`](skills/nemo-mbridge-perf-sequence-packing), [`nemo-mbridge-perf-tp-dp-comm-overlap`](skills/nemo-mbridge-perf-tp-dp-comm-overlap), [`nemo-mbridge-recipe-recommender`](skills/nemo-mbridge-recipe-recommender), [`nemo-mbridge-resiliency`](skills/nemo-mbridge-resiliency) |
| **NeMo 平台** | NeMo 平台将 NVIDIA NeMo 库统一到单个 CLI、Python SDK 和 Web UI 中。 | [`nemo-evaluator-plugin`](skills/nemo-evaluator-plugin), [`nemo-data-designer-plugin`](skills/nemo-data-designer-plugin) |
| **NeMo Retriever** | NeMo Retriever — 本地部署 NeMo Retriever Library，从语料库提取信息并回答问题。 | [`nemo-retriever`](skills/nemo-retriever) |
| **NeMo-RL** | 基于 Ray 的 RLHF 训练 — 面向 LLM 和 VLM 的 GRPO、DPO 和 SFT，支持 FSDP2 和 Megatron-Core。 | [`launch-nemo-rl`](skills/launch-nemo-rl), [`nemo-rl-auto-research`](skills/nemo-rl-auto-research), [`nemo-rl-brev-etiquette`](skills/nemo-rl-brev-etiquette), [`nemo-rl-docs`](skills/nemo-rl-docs), [`nemo-rl-session-memory`](skills/nemo-rl-session-memory) |
| **NemoClaw** | 安全智能体沙箱 — 在 NVIDIA OpenShell 中运行 OpenClaw，支持推理管理、策略管理、远程部署及沙箱监控。 | [`nemoclaw-user-agent-skills`](skills/nemoclaw-user-agent-skills), [`nemoclaw-user-configure-inference`](skills/nemoclaw-user-configure-inference), [`nemoclaw-user-configure-security`](skills/nemoclaw-user-configure-security), [`nemoclaw-user-deploy-remote`](skills/nemoclaw-user-deploy-remote), [`nemoclaw-user-get-started`](skills/nemoclaw-user-get-started), [`nemoclaw-user-manage-policy`](skills/nemoclaw-user-manage-policy), [`nemoclaw-user-manage-sandboxes`](skills/nemoclaw-user-manage-sandboxes), [`nemoclaw-user-monitor-sandbox`](skills/nemoclaw-user-monitor-sandbox), [`nemoclaw-user-overview`](skills/nemoclaw-user-overview), [`nemoclaw-user-reference`](skills/nemoclaw-user-reference) |
| **Nemotron** | 使用 NVIDIA AI 栈编排端到端模型开发、定制、评估和部署流水线。 | [`nemotron-customize`](skills/nemotron-customize), [`nemotron-retrieval-recipes`](skills/nemotron-retrieval-recipes), [`nemotron-policy-generator`](skills/nemotron-policy-generator) |
| **Nemotron 语音** | 部署和运行 NVIDIA Nemotron Speech (Riva) NIM — ASR、TTS 和 NMT，可通过 build.nvidia.com 云托管或在自有 GPU 上自托管。 | [`nemotron-speech`](skills/nemotron-speech) |
| **Physical AI** | Physical AI 技能 — 仿真、合成数据生成、训练、验证和部署等。 | [`omniverse-cad-to-simready`](skills/omniverse-cad-to-simready), [`omniverse-realtime-viewer`](skills/omniverse-realtime-viewer), [`omniverse-usd-performance-tuning`](skills/omniverse-usd-performance-tuning), [`physical-ai-infrastructure-setup-and-resilient-scaling`](skills/physical-ai-infrastructure-setup-and-resilient-scaling), [`physical-ai-neural-reconstruction`](skills/physical-ai-neural-reconstruction), [`physical-ai-defect-image-generation`](skills/physical-ai-defect-image-generation), [`physical-ai-video-data-augmentation`](skills/physical-ai-video-data-augmentation) |
| **PhysicsNeMo** | NVIDIA PhysicsNeMo — 用于构建、训练和微调深度学习模型的开源框架，采用最先进的 Physics-ML 方法。 | [`physicsnemo-discover`](skills/physicsnemo-discover) |
| **RAG Blueprint** | RAG 流水线 — 使用 Docker Compose 或 Helm 部署、配置、排障和管理检索增强生成。 | [`rag-blueprint`](skills/rag-blueprint), [`rag-eval`](skills/rag-eval), [`rag-perf`](skills/rag-perf) |
| **技能卡生成器** | 读取智能体技能源文件，生成技能卡及审核表。技能目录已存在且需要生成或更新治理卡时使用。 | [`skill-card-generator`](skills/skill-card-generator) |
| **TAO 工具包** | NVIDIA TAO 工具包 — 使用低代码微服务，基于自有数据微调和优化 100+ 预训练视觉 AI 模型，导出面向边缘或云的生产级模型。 | [`tao-analyze-changenet-rca`](skills/tao-analyze-changenet-rca), [`tao-finetune-huggingface-model`](skills/tao-finetune-huggingface-model), [`tao-port-huggingface-model`](skills/tao-port-huggingface-model), [`tao-run-automl`](skills/tao-run-automl), [`tao-run-automl-deft-pipeline`](skills/tao-run-automl-deft-pipeline), [`tao-run-deft-aoi`](skills/tao-run-deft-aoi), [`tao-run-inference-service`](skills/tao-run-inference-service), [`tao-train-single-step`](skills/tao-train-single-step), [`tao-analyze-gaps-visual-changenet`](skills/tao-analyze-gaps-visual-changenet), [`tao-analyze-gaps-vlm-bcq`](skills/tao-analyze-gaps-vlm-bcq), [`tao-convert-dataset-format`](skills/tao-convert-dataset-format), [`tao-generate-image-grounding`](skills/tao-generate-image-grounding), [`tao-generate-referring-expressions`](skills/tao-generate-referring-expressions), [`tao-generate-video-reasoning-annotations`](skills/tao-generate-video-reasoning-annotations), [`tao-mine-aoi-images`](skills/tao-mine-aoi-images), [`tao-route-visual-changenet-samples`](skills/tao-route-visual-changenet-samples), [`tao-validate-dataset-format`](skills/tao-validate-dataset-format), [`tao-finetune-clip`](skills/tao-finetune-clip), [`tao-finetune-cosmos-embed`](skills/tao-finetune-cosmos-embed), [`tao-finetune-cosmos-reason`](skills/tao-finetune-cosmos-reason), [`tao-train-action-recognition`](skills/tao-train-action-recognition), [`tao-train-bevfusion`](skills/tao-train-bevfusion), [`tao-train-centerpose`](skills/tao-train-centerpose), [`tao-train-deformable-detr`](skills/tao-train-deformable-detr), [`tao-train-depth-anything-v2`](skills/tao-train-depth-anything-v2), [`tao-train-dino`](skills/tao-train-dino), [`tao-train-fast-foundation-stereo`](skills/tao-train-fast-foundation-stereo), [`tao-train-foundation-stereo`](skills/tao-train-foundation-stereo), [`tao-train-grounding-dino`](skills/tao-train-grounding-dino), [`tao-train-image-classification`](skills/tao-train-image-classification), [`tao-train-mask-auto-encoder`](skills/tao-train-mask-auto-encoder), [`tao-train-mask-auto-label`](skills/tao-train-mask-auto-label), [`tao-train-mask-grounding-dino`](skills/tao-train-mask-grounding-dino), [`tao-train-mask2former`](skills/tao-train-mask2former), [`tao-train-metric-learning-recognition`](skills/tao-train-metric-learning-recognition), [`tao-train-nvdinov2`](skills/tao-train-nvdinov2), [`tao-train-nvpanoptix3d`](skills/tao-train-nvpanoptix3d), [`tao-train-ocdnet`](skills/tao-train-ocdnet), [`tao-train-ocrnet`](skills/tao-train-ocrnet), [`tao-train-oneformer`](skills/tao-train-oneformer), [`tao-train-optical-inspection`](skills/tao-train-optical-inspection), [`tao-train-pointpillars`](skills/tao-train-pointpillars), [`tao-train-pose-classification`](skills/tao-train-pose-classification), [`tao-train-reid`](skills/tao-train-reid), [`tao-train-rtdetr`](skills/tao-train-rtdetr), [`tao-train-segformer`](skills/tao-train-segformer), [`tao-train-sparse4d`](skills/tao-train-sparse4d), [`tao-train-visual-changenet`](skills/tao-train-visual-changenet), [`tao-validate-dataset-format`](skills/tao-validate-dataset-format), [`tao-list-capabilities`](skills/tao-list-capabilities), [`tao-setup-nvidia-gpu-host`](skills/tao-setup-nvidia-gpu-host), [`tao-run-on-brev`](skills/tao-run-on-brev), [`tao-run-on-kubernetes`](skills/tao-run-on-kubernetes), [`tao-run-on-lepton`](skills/tao-run-on-lepton), [`tao-run-on-local-docker`](skills/tao-run-on-local-docker), [`tao-run-on-slurm`](skills/tao-run-on-slurm), [`tao-run-platform`](skills/tao-run-platform) |
| **TileGym** | 基于块的 GPU 编程 — 添加新内核、跨框架转换及性能优化。 | [`tilegym-adding-cutile-kernel`](skills/tilegym-adding-cutile-kernel), [`tilegym-converting-cutile-to-julia`](skills/tilegym-converting-cutile-to-julia), [`tilegym-converting-cutile-to-triton`](skills/tilegym-converting-cutile-to-triton), [`tilegym-cutile-autotuning`](skills/tilegym-cutile-autotuning), [`tilegym-cutile-python`](skills/tilegym-cutile-python), [`tilegym-improve-cutile-kernel-perf`](skills/tilegym-improve-cutile-kernel-perf), [`tilegym-monkey-patch-kernels-to-transformers`](skills/tilegym-monkey-patch-kernels-to-transformers) |
| **视频搜索与摘要** | VSS Blueprint — 部署配置、搜索和摘要视频、生成分析报告、管理告警和事件、查询 VIOS 传感器、使用 RTVI VLM 微服务。 | [`vss-ask-video`](skills/vss-ask-video), [`vss-deploy-dense-captioning`](skills/vss-deploy-dense-captioning), [`vss-deploy-detection-tracking-2d`](skills/vss-deploy-detection-tracking-2d), [`vss-deploy-detection-tracking-3d`](skills/vss-deploy-detection-tracking-3d), [`vss-deploy-profile`](skills/vss-deploy-profile), [`vss-deploy-video-embedding`](skills/vss-deploy-video-embedding), [`vss-generate-video-calibration`](skills/vss-generate-video-calibration), [`vss-generate-video-report`](skills/vss-generate-video-report), [`vss-manage-alerts`](skills/vss-manage-alerts), [`vss-manage-video-io-storage`](skills/vss-manage-video-io-storage), [`vss-query-analytics`](skills/vss-query-analytics), [`vss-search-archive`](skills/vss-search-archive), [`vss-setup-behavior-analytics`](skills/vss-setup-behavior-analytics), [`vss-setup-video-analytics-api`](skills/vss-setup-video-analytics-api), [`vss-summarize-video`](skills/vss-summarize-video) |
<!-- skills-table-end -->

---

## 签名验证

所有技能均携带 `.sig` 签名文件，可使用仓库根目录的 `nv-agent-root-cert.pem` 进行验证：

```bash
git clone https://github.com/NVIDIA/skills.git
cd skills

# 安装 model_signing CLI
pip install model_signing

# 验证单个技能目录
model_signing verify certificate SKILL_DIR \
  --signature SKILL_DIR/skill.oms.sig \
  --certificate_chain nv-agent-root-cert.pem \
  --ignore_unsigned_files
```

验证成功确认技能内容自 NVIDIA 签名后未被修改。

参见[验证签名的智能体技能](docs/signing-agent-skills.mdx)了解签名布局、信任流水线及策略选项。

---

## 路线图

- ✅ 公开技能目录，包含跨产品的 NVIDIA 验证技能
- ✅ 自动化同步流水线，每日从产品仓库镜像技能
- ✅ 所有发布技能的安全扫描，覆盖指令安全与供应链完整性
- ✅ 技能签名，每个发布技能携带可验证的 NVIDIA 签名
- ✅ 技能通用评估标准及任务专用标准
- ✅ 技能卡，包含机器可读元数据（身份、来源、质量、行为边界）
- ✅ 同步时合规门控 — 签名漂移检测及缺失工件强制校验
- ✅ 向外部市场分发 — Skills.sh、Codex 插件、Claude Code 插件、ClawHub、Hermes Hub
- 🔲 向更多 MCP 中心及合作伙伴渠道分发

---

## 仓库结构

```
NVIDIA/skills/
├── skills/                      # NVIDIA 验证技能（持续增长）
│   │                              从上游产品仓库同步
│   ├── README.md                 # 面向浏览器的安装指南
│   ├── <product-prefix>-*/       # 扁平布局 — 每个技能一个目录，以产品名称为前缀
│   │                              例如 aiq-*, cuopt-*, cupynumeric-*, dali-*,
│   │                              deepstream-*, digital-health-*, dynamo-*,
│   │                              earth2studio-*, launch-nemo-rl, mcore-*,
│   │                              nemo-automodel-*, nemo-data-designer-plugin,
│   │                              nemo-evaluator-plugin, nemo-mbridge-* (20),
│   │                              nemo-retriever, nemo-rl-* (4),
│   │                              nemoclaw-user-* (10), nemotron-*,
│   │                              physicsnemo-*, rag-*, skill-card-generator,
│   │                              tilegym-*, vss-* (15),
│   │                              accelerated-computing-cudf, cudaq-guide
│   ├── omniverse-*/              # Physical AI — 手动暂存
│   └── physical-ai-*/            # Physical AI — 手动暂存
├── components.d/                # 产品注册表 — 每个产品一个文件，团队在此入站
│   ├── README.md                 # 模式说明及入站指导
│   └── <product>.yml             # 每个已注册产品一个文件
├── plugins/                     # 打包的插件分发
│   └── nvidia-skills/            # NVIDIA 技能精选包（Claude Code、Codex）
├── plugins.d/                   # 插件构建注册表 — `build-plugins.py` 配置
│   ├── README.md
│   ├── _defaults.yml
│   └── nvidia-skills.yml
├── .ai-family-plugin/              # Claude Code 市场元数据
│   └── marketplace.json
├── .agents/plugins/             # 智能体市场元数据（其他客户端）
│   └── marketplace.json
├── docs/                        # 长篇文档（通过 Fern 发布）
│   ├── README.md                 # 本地构建文档说明
│   ├── index.mdx
│   ├── advanced-install.mdx
│   ├── agent-skill-trust-pipeline.mdx
│   ├── release-checklist.mdx
│   ├── scanning-agent-skills.mdx
│   ├── signing-agent-skills.mdx
│   └── skill-cards.mdx
├── fern/                        # Fern 文档站点配置
├── .github/
│   ├── workflows/                # 同步流水线、插件验证、DCO 检查、作者验证
│   └── scripts/                  # regenerate-readme.sh, build-plugins.py,
│                                 # manual-components.yml, marketplace/metadata.json
├── nv-agent-root-cert.pem       # OMS 签名验证的信任锚点
├── skills.sh.json               # Skills.sh 市场分组配置
├── CHANGELOG.md
├── CONTRIBUTING.md              # 贡献指南
├── SECURITY.md                  # 安全报告策略
├── CODE_OF_CONDUCT.md           # 社区行为准则
└── LICENSE                      # Apache 2.0 / CC BY 4.0
```

技能在各产品仓库维护（参见[技能目录](#技能目录)中的**来源**列），每日同步至本仓库。同步流水线确认每个技能携带以下内容后才会出现在 `skills/` 下：

- `skill.oms.sig` — 独立的 OMS 格式签名（可对照 `nv-agent-root-cert.pem` 验证）
- `skill-card.md` — 技能身份与治理卡
- Tier-3 评估数据集 — 接受于 `evals/evals.json`、`evals/*.json`、`eval/*.json` 或 `benchmark/evals.json`

评估运行产生 `BENCHMARK.md` 时，会随技能一同发布，以便消费者查看可验证的性能提升数据。

---

## 标准与兼容性

本仓库遵循[智能体技能规范](https://agentskills.io/specification)：

- 技能是根目录包含 `SKILL.md` 文件的可移植目录。
- 元数据使用 YAML 前置元数据，包含必需的 `name` 和 `description` 字段。
- 技能采用渐进式披露模型 — 启动时加载轻量元数据，激活时加载完整指令。
- 使用 [`skills-ref`](https://github.com/agentskills/agentskills/tree/main/skills-ref) 参考库验证技能。

---

## 许可证

本项目采用双许可证：[Apache License 2.0](LICENSE) 和 [Creative Commons Attribution 4.0 International (CC BY 4.0)](LICENSE)。
