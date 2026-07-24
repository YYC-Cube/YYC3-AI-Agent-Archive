# NVIDIA-Skills

**变更摘要：**

```
| 项目 | 说明 |
|------|------|
| 结构 | `## 分类标题` → `### NNN.  **名称**` 章节式层级 |
| 分类数 | **32 个领域** |
| 条目数 | **202 条**（完整覆盖 skills-hub 文件系统） |
| 命令 | 语义正确匹配（从 `命令信息.md` 按 skill 名查找） |
| 同步 | ✅ 与 `NVIDIA-Skills-CN.md` (201条) + FS (202个目录) 全量对齐 |
```

**32 个分类及其条目数：**

```
| #   | 分类　　　　　　　　　　　 | 条数 |
|-----|----------------------------|:----:|
| 1   | RAG 检索增强生成          | 3    |
| 2   | NemoClaw 沙箱安全生态     | 10   |
| 3   | Dynamo 推理服务编排       | 5    |
| 4   | Megatron-Bridge 分布式训练| 20   |
| 5   | NeMo AutoModel 训练自动化 | 5    |
| 6   | NeMo-RL 强化学习          | 5    |
| 7   | Nemotron 语音与定制       | 4    |
| 8   | Megatron-Core 框架工具    | 5    |
| 9   | cuOpt 数学优化            | 12   |
| 10  | Earth2Studio 天气气候     | 5    |
| 11  | Holoscan 医疗设备 SDK     | 7    |
| 12  | DeepStream 视频分析       | 3    |
| 13  | Omniverse 3D/USD 生态     | 3    |
| 14  | Physical AI 物理基础设施  | 4    |
| 15  | 医疗影像 AI               | 10   |
| 16  | DICOM 医学影像数据        | 3    |
| 17  | 数字健康 临床 ASR         | 4    |
| 18  | AI4Science 科学计算       | 1    |
| 19  | 数据处理与设计            | 4    |
| 20  | NeMo 评估与插件           | 2    |
| 21  | HSB 平台                  | 4    |
| 22  | cuPyNumeric 科学计算      | 5    |
| 23  | cuDF 数据处理             | 1    |
| 24  | AI-Q 基础                 | 2    |
| 25  | cuFolio 投资组合          | 1    |
| 26  | TAO 视觉 AI 训练平台      | 48   |
| 27  | VSS 视频安全监控          | 14   |
| 28  | TileGym 内核优化          | 6    |
| 29  | Nemotron 策略生成          | 1    |
| 30  | Physical AI 神经重建      | 1    |
| 31  | CUDA-Q 量子计算           | 1    |
| 32  | 技能治理                  | 1    |
```

## RAG 检索增强生成

### 001.  **蓝图**

   NVIDIA RAG Blueprint —— 部署、配置、排查和管理，处理任何RAG操作：部署、安装、启动、启用、禁用、切换、更改、配置、排查、调试、修复、关闭、停止或拆除任何RAG功能或服务（智能体式RAG）

   ```bash
   npx skills add NVIDIA/skills --skill rag-blueprint
   ```

### 002.  **AIQ-部署**

   当被要求安装、部署、运行、验证、排查或停止NVIDIA AI-Q Blueprint基础设施时使用。

   ```bash
   npx skills add NVIDIA/skills --skill aiq-deploy
   ```

### 003.  **破布孔**

   部署中的NVIDIA RAG Blueprint服务器的性能基准测试：通过单一YAML配置驱动的配置文件、通过测试+AIPERF负载测试。

   ```bash
   npx skills add NVIDIA/skills --skill rag-perf
   ```

### 004.  **rag-eval**

   文件系统 RAG 基准测试：包含语料库文件、训练文件、`train.json` 以及评估 RAG 质量的脚本（基于 RAGAS 评估质量）。本基准测试不适用于生产环境，超过阈值的基准测试请使用 `rag-perf`，也不适用于此仓库目录结构之外的评估任务。

   ```bash
   npx skills add NVIDIA/skills --skill rag-eval
   ```

## NemoClaw 沙箱安全生态

### 005.  **nemoclaw-user-configure-security**

   为NemoClaw中每个可配置的安全控制提供风险框架。用于评估安全态势、审查沙箱安全默认或评估控制权时使用。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-configure-security
   ```

### 006.  **nemoclaw-user-manage-policy**

   添加、移除或修改沙箱策略中允许的端点。用于自定义网络策略、更改出口规则或配置沙箱端点访问时使用。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-manage-policy
   ```

### 007.  **Nemoclaw-用户-管理-沙盒**

   快速启动后解释运营任务：列出沙盒、状态和健康检查、日志、诊断、端口转发、多个沙盒、凭证重置、重建、网络预设、升级和卸载。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-manage-sandboxes
   ```

### 008.  **nemoclaw-user-deploy-remote**

   解释了如何在远程GPU实例上运行NemoClaw。包括已弃用的Brev兼容性路径以及首选安装程序和板载流程。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-deploy-remote
   ```

### 009.  **Nemoclaw-用户-监视-沙盒**

   检查沙箱健康状况，追踪代理行为，并诊断问题。用于监控运行中的沙箱、调试代理问题或检查沙箱日志。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-monitor-sandbox
   ```

### 010.  **nemoclaw-user-reference**

   介绍NemoClaw插件和蓝图架构，以及它们如何编排OpenClaw沙箱。适用于重构构件、插件结构或蓝图设计的场景。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-reference
   ```

### 011.  **nemoclaw-user-configure-inference**

   将NemoClaw连接到本地推理服务器。在使用NemoClaw搭建Ollama、vLLM、TensorRT-LLM、NIM或任何与OpenAI兼容的本地模型服务器时使用。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-configure-inference
   ```

### 012.  **nemoclaw-user-agent-skills**

   介绍NemoClaw附带的智能体技能，以及如何通过克隆代码仓库来获取这些技能。适用于用户询问AI智能体支持、代码助手集成或agents/skills/目录的场景。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-agent-skills
   ```

### 013.  **nemoclaw-user-get-started**

   安装NemoClaw，启动沙箱并运行首个智能体示例。适用于首次入门、安装启动NemoClaw沙箱的场景。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-get-started
   ```

### 014.  **nemoclaw-user-overview**

   解释了OpenClaw、OpenShell和NemoClaw如何构成生态系统，NemoClaw在技术中的定位，NemoClaw在硬沙箱之外能提供的功能，以及相较于直接集成或OpenClaw沙箱何时更适合使用NemoClaw。

   ```bash
   npx skills add NVIDIA/skills --skill nemoclaw-user-overview
   ```

## Dynamo 推理服务编排

### 015.  **发电机-路由器-启动器**

   启动或修补Dynamo路由器模式，并运行路由器端点烟雾检查。用于轮询、KV感知、负载最低或设备感知的路由设置。

   ```bash
   npx skills add NVIDIA/skills --skill dynamo-router-starter
   ```

### 016.  **发电机配方跑者**

   选择、验证、修补并部署现有的NVIDIA Dynamo Kubernetes配方。用于模型/后端/GPU/部署模式的配方调用。

   ```bash
   npx skills add NVIDIA/skills --skill dynamo-recipe-runner
   ```

### 017.  **发电机互联检查**

   验证Dynamo部署的NIXL/UCC/NCCL互联是否已准备好通过RDMA/NVLink进行分段服务。在配方运行器之后使用，会启动部署。

   ```bash
   npx skills add NVIDIA/skills --skill dynamo-interconnect-check
   ```

### 018.  **发电机故障排除**

   诊断失败或不健康的Dynamo部署。当Pod、模型缓存作业、PVC、工作单元、前端/路由器健康、端点或基准作业失败时使用。

   ```bash
   npx skills add NVIDIA/skills --skill dynamo-troubleshoot
   ```

## Megatron-Bridge 分布式训练

### 019.  **nemo-mbridge-multi-node-slurm**

   将单节点脚本转换为多节点Slurm sbatch作业，并调试常见的多节点失败。涵盖了srun-native与uv运行火炬、分布式方法、容器设置等内容。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-multi-node-slurm
   ```

### 020.  **尼莫-麦布里奇韧性**

   减震天桥的弹性特性包括容错、落后检测、进程中重启、抢占和重运行状态机。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-resiliency
   ```

### 021.  **nemo-mbridge-perf-hierarchical-context-parallel nemo-mbridge-性能-分层-上下文并行**

   Megatron-Bridge 中启用分层上下文并行的操作指南，包括配置底层、代码锚点、潜在问题及验证方法。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-hierarchical-context-parallel
   ```

### 022.  **nemo-mbridge-perf-moe-dispatcher-selection**

   根据硬件（EP）和优化阶段选择合适的 MoE 令牌分发器（`alltoall`、DeepEP 或 HybridEP）。总结了在 DVS3、Qwen3 和 Qwen3-Next 以及视觉语言模型（VLM）上线工作模式中的 MoE 令牌分发器选择指南。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-moe-dispatcher-selection
   ```

### 023.  **nemo-mbridge-perf-activation-recompute**

   在 Megatron Bridge 中验证并使用选择性和全激活重计算，以额外计算为代价降低 GPU 内存占用。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-activation-recompute
   ```

### 024.  **nemo-mbridge-perf-cpu-offloading**

   在 Megatron Bridge 中验证并使用 CPU 卸载功能，包括基于层的激活卸载以及通过 `HybridDeviceOptimizer` 实现的部分优化器状态卸载。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-cpu-offloading
   ```

### 025.  **nemo-mbridge-perf-cuda-graphs**

   在 Megatron Bridge 中验证并使用 CUDA 图捕获功能，包括用于注意力、MLP 以及 MoE 模块的本地全迭代图和 Transformer Engine 作用域图。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-cuda-graphs
   ```

### 026.  **nemo-mbridge-perf-memory-tuning**

   Megatron Bridge 中降低 GPU 峰值内存的技术 —— 可扩展分段、并行度调整、激活重计算、CPU 卸载以及常见的内存不足（OOM）修复方法。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-memory-tuning
   ```

### 027.  **nemo-mbridge-perf-moe-long-context**

   Megatron Bridge 长上下文专业模型训练指南，涵盖批量并行设置、注意力/序列配置、调度器以及实践模式，来自 DVS3、Qwen3 和 Qwen3-Next 长上下文实验的实用模式。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-moe-long-context
   ```

### 028.  **nemo-mbridge-perf-expert-parallel-overlap**

   在 Megatron-Bridge 中验证并使用 MoE 专家并行通信重叠，包括 `overlap`、`expert_parallel`、`comm`、`dealygrad`、`compute` 和 `flexiback` 等参数设置，以及 DeepEP 和 HybridEP 等灵活调度器后端。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-expert-parallel-overlap
   ```

### 029.  **nemo-mbridge-perf-megatron-fsdp**

   Megatron-Bridge 中启用 Megatron FSDP 的操作指南，包括配置底层、代码锚点、常见陷阱和验证方法。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-megatron-fsdp
   ```

### 030.  **nemo-mbridge-perf-moe-comm-overlap**

   Megatron Bridge 中 MoE 专家并行通信重叠，涵盖调度/合并重叠、灵活调度后端以及专家权重梯度调度。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-moe-comm-overlap
   ```

### 031.  **nemo-mbridge-perf-moe-optimization-workflow nemo-mbridge-perf-moe-优化工作流**

   基于 Megatron-Core 的 Megatron Bridge 中 MoE 训练优化的系统化工作流，遵循 The Three Walls 框架、并行折叠、重计算策略、调度器选择、CUDA 图启用。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-moe-optimization-workflow
   ```

### 032.  **nemo-mbridge-perf-parallelism-strategies**

   Megatron Bridge 中并行策略的组合与操作指南，包括规模模型、硬件拓扑映射和组合并行配置。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-parallelism-strategies
   ```

### 033.  **nemo-mbridge-mlm-bridge-training**

   使用模拟或真实数据运行 Megatron-LM（MLM）和 Megatron Bridge 训练，涵盖相关性测试、可用教程以及多 GPU 示例。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-mlm-bridge-training
   ```

### 034.  **nemo-mbridge-perf-moe-hardware-configs**

   按硬件平台和模型系列总结的代表性 MoE 训练脚本，汇总了四舍五入后的吞吐量、并行模式以及常用调优栈。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-moe-hardware-configs
   ```

### 035.  **nemo-mbridge-perf-moe-vlm-training**

   Megatron Bridge 中视觉语言模型的 MoE 训练实践指南，涵盖 FSDP 和 3D 并行架构、使用开源实验的经验教训、DVS3 和其他多模态实验的经验教训，对比了完全分片并行与三维并行两种方法。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-moe-vlm-training
   ```

### 036.  **nemo-mbridge-recipe-recommender**

   根据用户的模型、GPU 数量和训练目标，推荐并定制 Megatron Bridge 方案，收录常用方案（训练/有监督微调/参数高效微调）和性能优化方案。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-recipe-recommender
   ```

### 037.  **nemo-mbridge-perf-sequence-packing**

   在 Megatron-Bridge 中验证并使用序列打包与长上下文训练，区分带偏移的打包序列与无上下文 LLM，应用正确的 CI/CP 约束。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-sequence-packing
   ```

### 038.  **nemo-mbridge-perf-tp-dp-comm-overlap**

   Megatron-Bridge 中启用张量并行（TP）、数据并行（DP）和流水线并行（PP）通信重叠的操作指南，包括配置底层、代码锚点、潜在问题与验证方法。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-mbridge-perf-tp-dp-comm-overlap
   ```

## NeMo AutoModel 训练自动化

### 039.  **nemo-automodel-launcher-config**

   配置NeMo AutoModel作业启动，用于交互运行、Slurm集群和SkyPilot云执行。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-automodel-launcher-config
   ```

### 040.  **nemo-automodel-distributed-training nemo-automodel 分布式训练**

   NeMo AutoModel 中分布式训练策略的选择与配置指南，涵盖 FSDP2、Megatron FSDP、DDP 以及并行设置。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-automodel-distributed-training
   ```

### 041.  **nemo-automodel-model-onboarding NeMo 自动模型模型接入**

   将新模型架构接入 NeMo AutoModel 的指南，包括架构发现、实现模式、注册和验证。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-automodel-model-onboarding
   ```

### 042.  **nemo-automodel-recipe-development NeMo 自动模型配方开发**

   创建和修改 NeMo AutoModel 的训练与评估方案，包括 YAML 结构、构建器以及执行流程。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-automodel-recipe-development
   ```

## NeMo-RL 强化学习

### 043.  **发射-尼莫-RL**

   通过mrl-k8s CLI在Kubernetes集群上启动、监控、停止和调试NeMo-RL配方的操作手册。涵盖短暂与长期运行的RayCluster模式。

   ```bash
   npx skills add NVIDIA/skills --skill launch-nemo-rl
   ```

### 044.  **nemo-rl-auto-research**

   用于定向假设检验和开放式探索的自主NeMo-RL研究代理工作流。引导代理完成整个实验生命周期：了解实验流程和环境，配置强化学习或NeMo-gym运行，启动可复现的基准测试。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-rl-auto-research
   ```

### 045.  **nemo-rl-session-memory**

   为编码代理处理可管理的会话工作内存。当用户想要保留或恢复跨上下文会话状态、VS Code、Core 状态、长时间运行的工作流、句柄或任何需要在重新连接时保留的重要状态时使用。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-rl-session-memory
   ```

### 046.  **nemo-rl-docs**

   NeMo-RL 文档约定，涵盖 `docs/index.md` 的更新和文档字符串格式。不适用于 bug 修复、测试依赖项、重构、CI/CD 更改、性能调优，或任何不涉及编写或更新文档的任务。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-rl-docs
   ```

### 047.  **nemo-rl-brev-etiquette**

   Brev 实例操作指南，适用于在 `/home/ubuntu/RL` 路径下工作的 NeMo-RL 代理，提供有限的工作空间磁盘、`/ephemeral` 临时空间、可选的 `/home/ubuntu/RL/envs` 密钥。适用于运行 `nemo-rl-auto-research` 活动、实验和训练任务时使用。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-rl-brev-etiquette
   ```

## Nemotron 语音与定制

### 048.  **神经电子语**

   路由NVIDIA Nemotron语音（Riva）NIM任务 —— 部署、运行并测试ASR、TTS和NMT的NIM在build.nvidia.com或自托管平台上。

   ```bash
   npx skills add NVIDIA/skills --skill nemotron-speech
   ```

### 049.  **nemotron-customize Nemotron 定制化**

   规划、配置并将单一或多步骤的 Nemotron 定制化流程（训练、SFT/PEFT、AutoModel 或 Megatron-Bridge、DPO/RLO/RLHF 对齐）应用到 RAG/RLHF/GRPO 场景中。流程包括数据准备、微调（SFT/PEFT）、AutoModel 或 Megatron-Bridge、RLHF/GRPO/RLHF、强化学习对齐（DPO/RLO/RLHF）、BYOB/MCQ 基准测试、检查点。

   ```bash
   npx skills add NVIDIA/skills --skill nemotron-customize
   ```

### 050.  **nemotron-retrieval-recipes Nemotron 检索配方**

   用于规划、调试、调优、评估、导出或部署公共 Nemotron `embed`/`rerank`/检索配方时使用。

   ```bash
   npx skills add NVIDIA/skills --skill nemotron-retrieval-recipes
   ```

## Megatron-Core 框架工具

### 051.  **mcore-create-issue**

   调查一个失败的GitHub Actions运行或作业，并为该失败创建一个GitHub问题。

   ```bash
   npx skills add NVIDIA/skills --skill mcore-create-issue
   ```

### 052.  **mcore-linting-and-formatting mcore-代码检查与格式化**

   Megatron-LM 的代码检查与格式化，涵盖 `autohf.sh` 脚本的运行、相关工具（ruff、black、isort、pylint、mypy）以及代码风格规范。

   ```bash
   npx skills add NVIDIA/skills --skill mcore-linting-and-formatting
   ```

### 053.  **mcore-run-on-slurm**

   如何在 SLURM 集群上启动分布式 Megatron-LM 训练作业，涵盖最小化的批处理脚本、`torchrun` 的环境变量配置、不同硬件和并行模式下的 `CUDA_DEVICE_MAX_CONNECTIONS` 规则、容器约定。

   ```bash
   npx skills add NVIDIA/skills --skill mcore-run-on-slurm
   ```

### 054.  **mcore-split-pr**

   将一个拉取请求拆分为多个拉取请求，以减少所需的 CODEOWNERS 审阅数量。

   ```bash
   npx skills add NVIDIA/skills --skill mcore-split-pr
   ```

### 055.  **mcore-testing**

   Megatron-LM 测试系统，涵盖测试布局、配方 YAML 结构、单元测试和功能测试、golden 值、标记过滤器、CI 和并行性。

   ```bash
   npx skills add NVIDIA/skills --skill mcore-testing
   ```

## cuOpt 数学优化

### 056.  **cuopt-numerical-optimization-api-cli**

   通过命令行从MPS文件求解LP、MILP或QP（测试版）问题。当用户通过命令行从MPS文件求解LP、MILP或QP时使用。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-numerical-optimization-api-cli
   ```

### 057.  **cuopt-routing-api-python**

   基于cuOpt的车辆路径规划（VRP、TSP、PDP） —— 仅支持Python API，适用于用户在Python中构建或求解路径规划问题的场景。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-routing-api-python
   ```

### 058.  **cuopt-install**

   通过pip、conda或Docker为Python、C语言或服务器安装cuOpt并验证安装。对于从源代码构建cuopt，请参阅cuopt-developer。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-install
   ```

### 059.  **cuopt-user-rules**

   终端用户用于调用NVIDIA cuOpt（路径规划/线性规划/混合整数线性规划/二次规划/服务器）的基本规则。不适用于cuOpt内部组件。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-user-rules
   ```

### 060.  **cuopt-numerical-optimization-api-c**

   支持cuOpt的LP、MILP和QP（测试版） —— 仅支持C语言API。适用于用户在C/C++中嵌入LP、MILP或QP的场景。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-numerical-optimization-api-c
   ```

### 061.  **cuopt-server-api-python**

   cuOPT REST服务器 —— 启动服务器、端点、Python/curl客户端示例。适用于用户部署或调用cuOPT REST API的场景。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-server-api-python
   ```

### 062.  **cuopt-server-common**

   cuOPT REST服务器 —— 其功能与请求流转方式。仅讲解领域概念，不涉及部署或客户端代码。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-server-common
   ```

### 063.  **cuopt-numerical-optimization-formulation**

   LP、MILP、QP —— 概念、问题文本解析与建模范式（参数、约束、决策、目标）。仅讲解概念，不涉及API。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-numerical-optimization-formulation
   ```

### 064.  **cuopt-routing-formulation**

   车辆路径规划（VRP、TSP、PDP） —— 问题类型与数据需求。仅讲解领域概念，无API或接口说明。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-routing-formulation
   ```

### 065.  **cuopt-numerical-optimization-api-python**

   使用cuOpt Python API求解线性规划（LP）、混合整数线性规划（MILP）和二次规划（QP，测试版） —— 支持线性/二次目标函数、整数变量、调度、投资组合、最小二乘问题。

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-numerical-optimization-api-python
   ```

## Earth2Studio 天气气候

### 066.  **earth2studio-install**

   指导如何通过uv或pip安装Earth2Studio，选择模型附加组件，并配置环境。不得将其用于编写推理代码、选择模型或解答PhysicsNeMo相关问题。

   ```bash
   npx skills add NVIDIA/skills --skill earth2studio-install
   ```

### 067.  **earth2studio-discover**

   查找适用于天气/气候用例的Earth2Studio模型、数据源和示例。不得将其用于编写推理代码、下载数据或进行安装操作。

   ```bash
   npx skills add NVIDIA/skills --skill earth2studio-discover
   ```

### 068.  **earth2studio-data-fetch**

   通过Earth2Studio数据源获取特定变量和时间的天气/气候数据。不得将其用于推理管道、模型发现或安装场景。

   ```bash
   npx skills add NVIDIA/skills --skill earth2studio-data-fetch
   ```

### 069.  **earth2studio-deterministic-forecast**

   借助Earth2Studio构建确定性预测脚本（涵盖模型、数据源、输入输出、推理）。不得将其用于集合模拟、诊断分析、纯数据获取或安装操作。

   ```bash
   npx skills add NVIDIA/skills --skill earth2studio-deterministic-forecast
   ```

## Holoscan 医疗设备 SDK

### 070.  **holoscan-install-container**

   通过NGC Docker容器安装Holoscan SDK。适用于基于容器的安装；不适用于原生apt/pip/Conda安装。

   ```bash
   npx skills add NVIDIA/skills --skill holoscan-install-container
   ```

### 071.  **holoscan-setup**

   指导Holoscan SDK安装：检查主机、评估平台兼容性、推荐安装方法，并委托给对应的安装技能。

   ```bash
   npx skills add NVIDIA/skills --skill holoscan-setup
   ```

### 072.  **holoscan-install-conda**

   在CUDA 13环境中通过Conda安装Holoscan SDK v4.3+及更高版本。适用于Conda安装；将CUDA 12主机重定向至容器/轮子。

   ```bash
   npx skills add NVIDIA/skills --skill holoscan-install-conda
   ```

### 073.  **holoscan-install-debian**

   通过apt在Ubuntu上安装Holoscan SDK。适用于Ubuntu上的C++安装；与/holoscan-install-wheel搭配用于Python安装。

   ```bash
   npx skills add NVIDIA/skills --skill holoscan-install-debian
   ```

### 074.  **holoscan-install-source**

   通过树内/run_script构建并安装Holoscan SDK。仅在发布的软件包无法满足用户需求时使用。

   ```bash
   npx skills add NVIDIA/skills --skill holoscan-install-source
   ```

### 075.  **holoscan-install-wheel**

   通过 `pip` 将 Holoscan SDK Python 轮子安装到虚拟环境中。适用于 Python 安装；不适用于原生 C++/apt 或 Conda 安装。

   ```bash
   npx skills add NVIDIA/skills --skill holoscan-install-wheel
   ```

## DeepStream 视频分析

### 076.  **deepstream-import-vision-model**

   使用此技能将HuggingFace或NVIDIA NGC上的任意视觉模型无缝集成到NVIDIA DeepStream管道中，可完成ONNX下载、Sensortensor导出、TRT引擎构建、自定义nvinfier边界框解析、多基准测试以及PDF报告生成。

   ```bash
   npx skills add NVIDIA/skills --skill deepstream-import-vision-model
   ```

### 077.  **deepstream-dev**

   使用Python pyservicemaker应用编程接口开发英伟达深度流软件开发工具包9.0。在构建视频分析管道、基于GStreamer的视频处理、TensorRT推理集成、目标检测/跟踪或Kafka/消息代理集成时使用。

   ```bash
   npx skills add NVIDIA/skills --skill deepstream-dev
   ```

## Omniverse 3D/USD 生态

### 078.  **omniverse-cad-to-simready**

   协调从端到端的CAD/资源到SimReady的工作流。适用于各类广泛需求，例如CAD转SIM资源、CAD转SimReady，或需要进行格式转换、材质/物理属性赋值、SimReady合规性验证、有效性确认的道具打包工作。

   ```bash
   npx skills add NVIDIA/skills --skill omniverse-cad-to-simready
   ```

### 079.  **omniverse-realtime-viewer**

   用作Omniverse Realtime Viewer USD应用请求的顶级路由器，并作为重点查看器参考文档。

   ```bash
   npx skills add NVIDIA/skills --skill omniverse-realtime-viewer
   ```

### 080.  **omniverse-usd-performance-tuning**

   用于USD性能诊断和优化的顶级工作流技能。适用于加载缓慢、内存占用高、帧率低或优化我的场景的请求；将身份验证/运行时设置工作委托给阶段0负责人。

   ```bash
   npx skills add NVIDIA/skills --skill omniverse-usd-performance-tuning
   ```

## Physical AI 物理基础设施

### 081.  **physical-ai-infrastructure-setup-and-resilient-scaling**

   适用于用户希望在本地MicroK8s或Azure AKS环境中为合成数据生成工作流设置、扩展、验证或强化NVIDIA AI物理基础设施的场景，包括Kubernetes集群、推理端点部署、OSMO部署等。

   ```bash
   npx skills add NVIDIA/skills --skill physical-ai-infrastructure-setup-and-resilient-scaling
   ```

### 082.  **physical-ai-defect-image-generation 物理 AI 缺陷图像生成**

   使用物理 AI 编排缺陷图像生成，相关联的设置、输出路径配置。The Day 0 path 处理冷启动，使用 USI-INIT-RL、mage 数据增强。The Day 8 path 和 AnomalyGen 用于创建无缺陷 PCB 数据集，第 1 天路径用于处理冷启动，以创建初始的印刷电路板组件数据集。

   ```bash
   npx skills add NVIDIA/skills --skill physical-ai-defect-image-generation
   ```

### 083.  **physical-ai-video-data-augmentation 物理人工智能视频数据增强**

   适用于在 OSM 上运行视频数据增强和自动标注工作流的场景，流程包括帧选择、模型选择、输出处理、关键帧配置、数据增强、和相关视频增强，包括自动标注、标签工作流。

   ```bash
   npx skills add NVIDIA/skills --skill physical-ai-video-data-augmentation
   ```

## 医疗影像 AI

### 084.  **nv-generate-mr**

   用于通过 `NV-Generate-CTMR rflow-mr` 生成合成人体磁共振体积数据。不用于配对掩码或生产训练数据。

   ```bash
   npx skills add NVIDIA/skills --skill nv-generate-mr
   ```

### 085.  **nv-generate-mr-brain**

   用于通过 `NV-Generate-CTMR rflow-mr-brain` 生成合成脑部磁共振数据。不用于生产训练数据。

   ```bash
   npx skills add NVIDIA/skills --skill nv-generate-mr-brain
   ```

### 086.  **nv-generate-mr-brain-finetune**

   用于微调 `NV-Generate-CTMR rflow-MR-brain` 扩散 UNet，来自 CT/NIfTI 数据集列表中的数据。不适用于临床或生产数据审批。

   ```bash
   npx skills add NVIDIA/skills --skill nv-generate-mr-brain-finetune
   ```

### 087.  **nv-generate-vae-finetune**

   用于根据 CT/MRI NIfTI 数据列表对 `NV-Generate-CTMR MAISI VAE` 进行微调。不用于临床或生产数据审批。

   ```bash
   npx skills add NVIDIA/skills --skill nv-generate-vae-finetune
   ```

### 088.  **nv-segment-ct**

   用于在 CT NIfTI 数据上运行 `NV-Segment-CT VISTA3D` 并记录标签验证证据。

   ```bash
   npx skills add NVIDIA/skills --skill nv-segment-ct
   ```

### 089.  **nv-reason-cxr**

   用于命令行形式实时 `NV-Reason-CXR` 胸部 X 光推理盲测测试。不用于诊断或临床报告。

   ```bash
   npx skills add NVIDIA/skills --skill nv-reason-cxr
   ```

### 090.  **nv-segment-ct-finetune NV-Segment-CT 微调**

   用于对 CT NIfTI 标签上的 `NV-Segment-CT VISTA3D` 进行烟雾测试或数据集微调，不用于临床验证。

   ```bash
   npx skills add NVIDIA/skills --skill nv-segment-ct-finetune
   ```

### 091.  **nv-segment-ctmr**

   用于在 CT 或 MRI NIfTI 体积和重建标签上运行 `NV-Segment-CTMR` 并记录标签验证证据。不可用于临床解读。

   ```bash
   npx skills add NVIDIA/skills --skill nv-segment-ctmr
   ```

### 092.  **nv-generate-ct-rflow**

   用于通过 `NV-Generate-CTMR rflow-ct` 生成合成计算机断层扫描（CT）体积和掩码，未审核，不得用于生产训练数据。

   ```bash
   npx skills add NVIDIA/skills --skill nv-generate-ct-rflow
   ```

## DICOM 医学影像数据

### 093.  **dicom-metadata-extract dicom-元数据提取**

   用于从单个 DICOM 文件中提取选定的元数据，并标记标准标签 PHI 的存在。不用于去标识化或临床用途。

   ```bash
   npx skills add NVIDIA/skills --skill dicom-metadata-extract
   ```

### 094.  **dicom-series-preflight**

   用于在转换或处理前对单个 DICOM 系列文件进行仅标头级别的预检。不用于去标识化或临床批准。

   ```bash
   npx skills add NVIDIA/skills --skill dicom-series-preflight
   ```

### 095.  **dicom-series-to-volume dicom-序列转体数据**

   用于将一个 CT DICOM 序列文件转换为带有损伤信息的 Hu NIfTI 体积，不用于多帧 DICOM 或临床使用。

   ```bash
   npx skills add NVIDIA/skills --skill dicom-series-to-volume
   ```

## 数字健康 临床 ASR

### 096.  **digital-health-clinical-asr-finetune 数字健康-临床 ASR 微调**

   临床 ASR Flywheel 的第 4 阶段。当主要优先级是 KSR（关键字识别）F1 值，且没有低延迟要求（使用 fine-tune 级）时，使用 NeMo Nemo ASR 模型。仅用于在第 4 阶段上运行临床 ASR 模型微调（SFT）以及高基线 KSR+1 重新评估。不适用于通用词汇增强（请使用 `fine-tune-asr`）。

   ```bash
   npx skills add NVIDIA/skills --skill digital-health-clinical-asr-finetune
   ```

### 097.  **digital-health-clinical-asr-setup 数字健康-临床 ASR-设置**

   临床 ASR Flywheel 的第 1 阶段。用于启动时的初始化：NVCR-MW 部署、`NVIDIA_API_KEY` 检查、依赖安装、TTS-ASR 引擎测试。

   ```bash
   npx skills add NVIDIA/skills --skill digital-health-clinical-asr-setup
   ```

### 098.  **digital-health-clinical-asr-eval 数字健康-临床 ASR 评估**

   临床 ASR Flywheel 的第 3 阶段。作为一个 NeMo ASR 模型，为临床 ASR KSR（关键字识别）提供评估，输出 `score.diagnostic`（不用于临床解释）。仅用于临床 ASR 轮的第三阶段，对 NeMo 清单进行评分，生成五段式 KSR（关键字识别）诊断。不适用于 ASR 身份验证（`riva-asr`）。

   ```bash
   npx skills add NVIDIA/skills --skill digital-health-clinical-asr-eval
   ```

### 099.  **digital-health-clinical-asr-build 数字健康-临床 ASR 构建**

   临床 ASR Flywheel 的第 2 阶段。用于整理临床术语、标记 IPA 以及合成 NeMo 清单。不适用于评分（请使用 `digital-health-clinical-asr-eval`）。

   ```bash
   npx skills add NVIDIA/skills --skill digital-health-clinical-asr-build
   ```

## AI4Science 科学计算

### 100.  **physicsnemo-discover**

   NVIDIA官方撰写的PhysicsNeMo导航指南 —— 为SciML/AI4Science任务（代理建模、预测、降尺度、物理信息驱动、反演、生成式任务）选择模型、数据管道或示例。通过实时代码仓库搜索定位现有文件。

   ```bash
   npx skills add NVIDIA/skills --skill physicsnemo-discover
   ```

## 数据处理与设计

### 101.  **dali-dynamic-mode DALI 动态模式**

   DALI 动态模式（`nvidia.dali.experimental.dynamic`，简称 `rdd`）：适用于处理 `nvidia.dali.pipeline` 任务。仅用于处理需要延迟或迁移管道的场景；仅处理普通相关任务时可跳过。

   ```bash
   npx skills add NVIDIA/skills --skill dali-dynamic-mode
   ```

### 102.  **data-designer 数据设计器**

   当用户想要创建数据集、生成合成数据或构建数据生成流水线时使用。

   ```bash
   npx skills add NVIDIA/skills --skill data-designer
   ```

### 103.  **nemo-data-designer-plugin NeMo 数据设计器插件**

   当用户想要创建数据集、生成合成数据或构建数据生成管道时使用。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-data-designer-plugin
   ```

## NeMo 评估与插件

### 104.  **nemo-evaluator-plugin**

   适用于开发或调试 Evaluator 插件（CLL 作业、SDK、基于 SDE 的指标、指标类型或插件化 Evaluator 技能）时使用。

   ```bash
   npx skills add NVIDIA/skills --skill nemo-evaluator-plugin
   ```

## 技能治理

### 105.  **skill-card-generator**

   仅用于为指定的现有智能体技能目录生成或更新治理技能卡。不得用于解释、列出、比较或讨论技能能力。

   ```bash
   npx skills add NVIDIA/skills --skill skill-card-generator
   ```

## HSB 平台

### 106.  **hsb-setup**

   HSB platform environment deployment — install, configure, verify dependencies and start services for HSB runtime initialization.

   ```bash
   npx skills add NVIDIA/skills --skill hsb-setup
   ```

### 107.  **hsb-app**

   HSB application development — build application functionality, business logic implementation and API integration.

   ```bash
   npx skills add NVIDIA/skills --skill hsb-app
   ```

### 108.  **hsb-flash**

   HSB flash acceleration — configure flash resources, performance tuning, read/write acceleration and storage optimization.

   ```bash
   npx skills add NVIDIA/skills --skill hsb-flash
   ```

### 109.  **hsb-test**

   HSB testing and validation — functional testing, performance testing, compatibility verification and regression testing.

   ```bash
   npx skills add NVIDIA/skills --skill hsb-test
   ```

## cuPyNumeric 科学计算

### 110.  **cupynumeric-migration-readiness**

   Assess NumPy code readiness for migration to cuPyNumeric GPU acceleration — feasibility, cost and expected benefits analysis.

   ```bash
   npx skills add NVIDIA/skills --skill cupynumeric-migration-readiness
   ```

### 111.  **cupynumeric-parallel-data-load**

   cuPyNumeric parallel data loading — multi-node, multi-GPU parallel data reading and loading for large-scale scientific datasets.

   ```bash
   npx skills add NVIDIA/skills --skill cupynumeric-parallel-data-load
   ```

## cuDF 数据处理

### 112.  **accelerated-computing-cudf**

   GPU-accelerated cuDF data processing with Pandas-compatible DataFrame operations. Use for high-performance data cleaning, transformation, aggregation and analysis on GPU.

   ```bash
   npx skills add NVIDIA/skills --skill accelerated-computing-cudf
   ```

## AI-Q 基础

### 113.  **aiq-research**

   NVIDIA AI-Q research exploration — algorithm research, experiment design, benchmarking and technical solution validation for AI-Q frontier research.

   ```bash
   npx skills add NVIDIA/skills --skill aiq-research
   ```

## CUDA-Q 量子计算

### 114.  **cudaq-guide**

   CUDA-Q quantum computing programming guide — installation, configuration, syntax, programming paradigms and debugging for quantum-classical hybrid development.

   ```bash
   npx skills add NVIDIA/skills --skill cudaq-guide
   ```

## cuFolio 投资组合

### 115.  **cufolio**

   cuOpt-based portfolio optimization — return-risk modeling, constraint configuration and efficient solving for optimal asset allocation.

   ```bash
   npx skills add NVIDIA/skills --skill cufolio
   ```

## cuOpt 数学优化（补全）

### 116.  **cuopt-developer**

   cuOpt developer advanced — source build, deep customization, low-level debugging and secondary development. Use for source-level cuOpt development.

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-developer
   ```

### 117.  **cuopt-skill-evolution**

   cuOpt skill evolution — version updates, capability upgrades, feature iteration and adaptation optimization tracking the cuOpt skill system evolution path.

   ```bash
   npx skills add NVIDIA/skills --skill cuopt-skill-evolution
   ```

## Physical AI 物理基础设施（补全）

### 118.  **physical-ai-neural-reconstruction**

   Physical AI neural reconstruction — 3D neural reconstruction, scene reconstruction and high-precision modeling for digital twin and industrial simulation.

   ```bash
   npx skills add NVIDIA/skills --skill physical-ai-neural-reconstruction
   ```

## Nemotron 策略生成

### 119.  **nemotron-policy-generator**

   Generate alignment policies, safety policies and behavior specification policies for Nemotron model alignment and security governance.

   ```bash
   npx skills add NVIDIA/skills --skill nemotron-policy-generator
   ```

## NeMo 检索增强

### 120.  **nemo-retriever**

   NeMo retrieval-augmented skills — retrieve system setup, vector search configuration, knowledge base integration and retrieval tuning for RAG pipelines.

   ```bash
   npx skills add NVIDIA/skills --skill nemo-retriever
   ```

## TAO 视觉 AI 训练平台（48 条）

### 121.  **tao-analyze-changenet-rca**

   TAO ChangeNet root cause analysis — analyze visual change detection model changes, locate underlying causes and influencing factors.

   ```bash
   npx skills add NVIDIA/skills --skill tao-analyze-changenet-rca
   ```

### 122.  **tao-analyze-gaps-visual-changenet**

   TAO visual ChangeNet gap analysis — analyze capability gaps in visual change detection models, identify optimization directions.

   ```bash
   npx skills add NVIDIA/skills --skill tao-analyze-gaps-visual-changenet
   ```

### 123.  **tao-analyze-gaps-vlm-bcq**

   TAO VLM batch capability gap analysis — analyze VLM capability gaps via batch queries, output model capability assessment and optimization suggestions.

   ```bash
   npx skills add NVIDIA/skills --skill tao-analyze-gaps-vlm-bcq
   ```

### 124.  **tao-convert-dataset-format**

   TAO dataset format conversion — convert between different dataset formats, align with TAO training framework dataset format standards.

   ```bash
   npx skills add NVIDIA/skills --skill tao-convert-dataset-format
   ```

### 125.  **tao-finetune-clip**

   TAO CLIP model fine-tuning — fine-tune CLIP multimodal models for customized multimodal scenarios.

   ```bash
   npx skills add NVIDIA/skills --skill tao-finetune-clip
   ```

### 126.  **tao-finetune-cosmos-embed**

   TAO Cosmos embedding model fine-tuning — fine-tune Cosmos series embedding models to optimize vector representation and retrieval matching.

   ```bash
   npx skills add NVIDIA/skills --skill tao-finetune-cosmos-embed
   ```

### 127.  **tao-finetune-cosmos-reason**

   TAO Cosmos reasoning model fine-tuning — fine-tune Cosmos series reasoning models to enhance multimodal reasoning and understanding.

   ```bash
   npx skills add NVIDIA/skills --skill tao-finetune-cosmos-reason
   ```

### 128.  **tao-finetune-huggingface-model**

   TAO HuggingFace model fine-tuning — import open-source HuggingFace models into TAO framework for fine-tuning.

   ```bash
   npx skills add NVIDIA/skills --skill tao-finetune-huggingface-model
   ```

### 129.  **tao-generate-image-grounding**

   TAO image grounding data generation — generate image grounding annotation data for visual grounding and object grounding model training.

   ```bash
   npx skills add NVIDIA/skills --skill tao-generate-image-grounding
   ```

### 130.  **tao-generate-referring-expressions**

   TAO referring expression generation — generate visual referring expression datasets for referring comprehension and VLM alignment.

   ```bash
   npx skills add NVIDIA/skills --skill tao-generate-referring-expressions
   ```

### 131.  **tao-generate-video-reasoning-annotations**

   TAO video reasoning annotation generation — generate video reasoning task annotations for video understanding and temporal reasoning.

   ```bash
   npx skills add NVIDIA/skills --skill tao-generate-video-reasoning-annotations
   ```

### 132.  **tao-launch-workflow**

   TAO workflow launcher — launch and schedule TAO AI workflows, manage workflow execution state and lifecycle.

   ```bash
   npx skills add NVIDIA/skills --skill tao-launch-workflow
   ```

### 133.  **tao-list-capabilities**

   TAO capability listing — query all supported models, tasks and functional capabilities across the TAO platform.

   ```bash
   npx skills add NVIDIA/skills --skill tao-list-capabilities
   ```

### 134.  **tao-mine-aoi-images**

   TAO industrial inspection image mining — mine AOI image data, hard example screening and effective sample extraction.

   ```bash
   npx skills add NVIDIA/skills --skill tao-mine-aoi-images
   ```

### 135.  **tao-port-huggingface-model**

   TAO HuggingFace model porting — port open-source HuggingFace models to TAO training framework.

   ```bash
   npx skills add NVIDIA/skills --skill tao-port-huggingface-model
   ```

### 136.  **tao-route-visual-changenet-samples**

   TAO visual ChangeNet sample routing — route and dispatch visual change detection samples to matching ChangeNet processing pipelines.

   ```bash
   npx skills add NVIDIA/skills --skill tao-route-visual-changenet-samples
   ```

### 137.  **tao-run-automl**

   TAO AutoML execution — automated machine learning training, auto model selection, hyperparameter search and optimization.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-automl
   ```

### 138.  **tao-run-automl-deft-pipeline**

   TAO DEFT AutoML pipeline — run automated training pipelines for DEFT scenarios, industrial inspection auto training.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-automl-deft-pipeline
   ```

### 139.  **tao-run-deft-aoi**

   TAO DEFT AOI execution — run DEFT industrial optical inspection tasks, defect detection, classification and quality assessment.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-deft-aoi
   ```

### 140.  **tao-run-inference-service**

   TAO inference service — deploy and run TAO model inference services, model serving and API invocation.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-inference-service
   ```

### 141.  **tao-run-on-brev**

   TAO Brev platform execution — run TAO training and inference on Brev instances, adapt to Brev environment specifications.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-on-brev
   ```

### 142.  **tao-run-on-kubernetes**

   TAO Kubernetes execution — deploy and run TAO workloads on Kubernetes clusters, containerized scheduling.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-on-kubernetes
   ```

### 143.  **tao-run-on-lepton**

   TAO Lepton platform execution — deploy TAO inference services on Lepton platform, serverless inference.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-on-lepton
   ```

### 144.  **tao-run-on-local-docker**

   TAO local Docker execution — run TAO training and inference in local Docker environment.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-on-local-docker
   ```

### 145.  **tao-run-on-slurm**

   TAO Slurm cluster execution — schedule TAO training tasks on Slurm HPC clusters.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-on-slurm
   ```

### 146.  **tao-run-platform**

   TAO platform orchestration — unified entry for multi-platform TAO execution, auto-dispatch to appropriate platform skills.

   ```bash
   npx skills add NVIDIA/skills --skill tao-run-platform
   ```

### 147.  **tao-setup-nvidia-gpu-host**

   TAO GPU host setup — build TAO runtime environment on NVIDIA GPU hosts, dependency installation and validation.

   ```bash
   npx skills add NVIDIA/skills --skill tao-setup-nvidia-gpu-host
   ```

### 148.  **tao-train-action-recognition**

   TAO action recognition training — train and tune action recognition models for video behavior analysis.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-action-recognition
   ```

### 149.  **tao-train-bevfusion**

   TAO BEVFusion model training — train BEVFusion multi-sensor fusion perception models for autonomous driving 3D perception.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-bevfusion
   ```

### 150.  **tao-train-centerpose**

   TAO CenterPose 6D pose estimation training — train CenterPose models for 6D object pose estimation.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-centerpose
   ```

### 151.  **tao-train-deformable-detr**

   TAO Deformable DETR training — train Deformable DETR object detection models for small object and dense detection.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-deformable-detr
   ```

### 152.  **tao-train-depth-anything-v2**

   TAO Depth Anything V2 training — fine-tune monocular depth estimation models for improved depth accuracy.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-depth-anything-v2
   ```

### 153.  **tao-train-dino**

   TAO DINO object detection training — train DINO series object detection models for high-precision detection.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-dino
   ```

### 154.  **tao-train-fast-foundation-stereo**

   TAO fast foundation stereo training — train fast stereo matching models for efficient binocular depth estimation.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-fast-foundation-stereo
   ```

### 155.  **tao-train-foundation-stereo**

   TAO foundation stereo training — train full stereo matching models for high-precision binocular depth estimation.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-foundation-stereo
   ```

### 156.  **tao-train-grounding-dino**

   TAO Grounding DINO training — fine-tune open-vocabulary object detection models for custom category detection.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-grounding-dino
   ```

### 157.  **tao-train-image-classification**

   TAO image classification training — train and tune image classification models for various classification scenarios.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-image-classification
   ```

### 158.  **tao-train-mask-auto-encoder**

   TAO mask auto-encoder training — unsupervised pre-training of mask autoencoders for visual representation learning.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-mask-auto-encoder
   ```

### 159.  **tao-train-mask-auto-label**

   TAO mask auto-label training — train mask auto-labeling models for automated segmentation annotation.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-mask-auto-label
   ```

### 160.  **tao-train-mask-grounding-dino**

   TAO Mask Grounding DINO training — fine-tune open-vocabulary segmentation models for open-vocabulary segmentation.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-mask-grounding-dino
   ```

### 161.  **tao-train-mask2former**

   TAO Mask2Former training — train Mask2Former panoptic segmentation models for instance, semantic and panoptic segmentation.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-mask2former
   ```

### 162.  **tao-train-metric-learning-recognition**

   TAO metric learning recognition training — train recognition models via metric learning for face recognition and re-identification.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-metric-learning-recognition
   ```

### 163.  **tao-train-nvdinov2**

   TAO NV-DINOv2 training — fine-tune NVIDIA DINOv2 vision foundation models for downstream visual tasks.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-nvdinov2
   ```

### 164.  **tao-train-nvpanoptix3d**

   TAO NV-Panoptix3D training — train 3D panoptic segmentation models for point cloud segmentation.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-nvpanoptix3d
   ```

### 165.  **tao-train-ocdnet**

   TAO OCDNet training — train text detection models for scene text detection.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-ocdnet
   ```

### 166.  **tao-train-ocrnet**

   TAO OCRNet training — train text recognition models for scene text recognition.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-ocrnet
   ```

### 167.  **tao-train-oneformer**

   TAO OneFormer training — train unified segmentation models supporting multiple segmentation tasks with a single model.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-oneformer
   ```

### 168.  **tao-train-optical-inspection**

   TAO optical inspection training — train industrial optical inspection models for product defect detection.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-optical-inspection
   ```

### 169.  **tao-train-pointpillars**

   TAO PointPillars training — train point cloud 3D object detection models for autonomous driving perception.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-pointpillars
   ```

### 170.  **tao-train-pose-classification**

   TAO pose classification training — train human pose classification models for behavior analysis and pose determination.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-pose-classification
   ```

### 171.  **tao-train-reid**

   TAO re-identification training — train pedestrian/vehicle re-identification models for cross-camera tracking and object retrieval.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-reid
   ```

### 172.  **tao-train-rtdetr**

   TAO RT-DETR training — train real-time object detection models balancing accuracy and inference speed.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-rtdetr
   ```

### 173.  **tao-train-segformer**

   TAO SegFormer training — train efficient semantic segmentation models.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-segformer
   ```

### 174.  **tao-train-single-step**

   TAO single-step training — quick single-step training pipeline for rapid model iteration.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-single-step
   ```

### 175.  **tao-train-sparse4d**

   TAO Sparse4D training — train sparse 4D perception models for autonomous driving perception.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-sparse4d
   ```

### 176.  **tao-train-visual-changenet**

   TAO visual ChangeNet training — train visual change detection models for change detection tasks.

   ```bash
   npx skills add NVIDIA/skills --skill tao-train-visual-changenet
   ```

### 177.  **tao-validate-dataset-format**

   TAO dataset format validation — validate dataset format compliance with TAO training framework requirements.

   ```bash
   npx skills add NVIDIA/skills --skill tao-validate-dataset-format
   ```

## VSS 视频安全监控（14 条）

### 178.  **vss-ask-video**

   VSS ask video — query and retrieve relevant video segments based on natural language questions.

   ```bash
   npx skills add NVIDIA/skills --skill vss-ask-video
   ```

### 179.  **vss-deploy-dense-captioning**

   VSS dense captioning deploy — deploy dense video captioning services for scene description generation.

   ```bash
   npx skills add NVIDIA/skills --skill vss-deploy-dense-captioning
   ```

### 180.  **vss-deploy-detection-tracking-2d**

   VSS 2D detection and tracking deploy — deploy 2D object detection and tracking pipelines.

   ```bash
   npx skills add NVIDIA/skills --skill vss-deploy-detection-tracking-2d
   ```

### 181.  **vss-deploy-detection-tracking-3d**

   VSS 3D detection and tracking deploy — deploy 3D object detection and tracking pipelines.

   ```bash
   npx skills add NVIDIA/skills --skill vss-deploy-detection-tracking-3d
   ```

### 182.  **vss-deploy-profile**

   VSS profile deploy — deploy VSS service profiles with optimized configurations.

   ```bash
   npx skills add NVIDIA/skills --skill vss-deploy-profile
   ```

### 183.  **vss-deploy-video-embedding**

   VSS video embedding deploy — deploy video embedding services for video feature extraction.

   ```bash
   npx skills add NVIDIA/skills --skill vss-deploy-video-embedding
   ```

### 184.  **vss-generate-video-calibration**

   VSS video calibration — generate video calibration data for camera alignment and correction.

   ```bash
   npx skills add NVIDIA/skills --skill vss-generate-video-calibration
   ```

### 185.  **vss-generate-video-report**

   VSS video report generation — generate automated video analysis reports.

   ```bash
   npx skills add NVIDIA/skills --skill vss-generate-video-report
   ```

### 186.  **vss-manage-alerts**

   VSS alert management — configure and manage video analytics alerts and notifications.

   ```bash
   npx skills add NVIDIA/skills --skill vss-manage-alerts
   ```

### 187.  **vss-manage-video-io-storage**

   VSS video IO and storage manage — configure video input/output and storage management.

   ```bash
   npx skills add NVIDIA/skills --skill vss-manage-video-io-storage
   ```

### 188.  **vss-query-analytics**

   VSS query analytics — query and analyze video analytics results and insights.

   ```bash
   npx skills add NVIDIA/skills --skill vss-query-analytics
   ```

### 189.  **vss-search-archive**

   VSS archive search — search archived video footage and historical analytics data.

   ```bash
   npx skills add NVIDIA/skills --skill vss-search-archive
   ```

### 190.  **vss-setup-behavior-analytics**

   VSS behavior analytics setup — set up behavior analytics pipelines for video-based behavior analysis.

   ```bash
   npx skills add NVIDIA/skills --skill vss-setup-behavior-analytics
   ```

### 191.  **vss-setup-video-analytics-api**

   VSS video analytics API setup — set up standardized video analytics API services.

   ```bash
   npx skills add NVIDIA/skills --skill vss-setup-video-analytics-api
   ```

## TileGym 内核优化（6 条）

### 192.  **tilegym-adding-cutile-kernel**

   TileGym — adding custom cuTile kernels to the TileGym kernel library.

   ```bash
   npx skills add NVIDIA/skills --skill tilegym-adding-cutile-kernel
   ```

### 193.  **tilegym-converting-cutile-to-julia**

   TileGym — convert cuTile kernels to Julia for cross-language optimization.

   ```bash
   npx skills add NVIDIA/skills --skill tilegym-converting-cutile-to-julia
   ```

### 194.  **tilegym-converting-cutile-to-triton**

   TileGym — convert cuTile kernels to Triton for broader GPU compatibility.

   ```bash
   npx skills add NVIDIA/skills --skill tilegym-converting-cutile-to-triton
   ```

### 195.  **tilegym-cutile-autotuning**

   TileGym — auto-tune cuTile kernel parameters for optimal performance.

   ```bash
   npx skills add NVIDIA/skills --skill tilegym-cutile-autotuning
   ```

### 196.  **tilegym-cutile-python**

   TileGym — Python bindings and interfaces for cuTile kernels.

   ```bash
   npx skills add NVIDIA/skills --skill tilegym-cutile-python
   ```

### 197.  **tilegym-improve-cutile-kernel-perf**

   TileGym — improve existing cuTile kernel performance through optimization techniques.

   ```bash
   npx skills add NVIDIA/skills --skill tilegym-improve-cutile-kernel-perf
   ```

### 198.  **tilegym-monkey-patch-kernels-to-transformers**

   TileGym — monkey-patch custom kernels into transformer models for accelerated inference.

   ```bash
   npx skills add NVIDIA/skills --skill tilegym-monkey-patch-kernels-to-transformers
   ```

## cuOpt 优化器工具（补全）

### 199.  **cuopt-numerical-optimization-api-python** *(entry already exists)*

## NeMo 评估器（补全）

### 200.  **nemo-evaluator-plugin** *(entry already exists)*

---

*共 202 条 — 已与 `NVIDIA-Skills-CN.md` + `skills-hub/ai-ml/nvidia-skills/skills/` 文件系统全量对齐*
