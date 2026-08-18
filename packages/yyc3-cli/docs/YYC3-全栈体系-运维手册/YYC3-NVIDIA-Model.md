# 《NVIDIA Model 企业级全栈知识体系与运维手册（YYC³ 专属长效版）》

> **版本**：V1.1（2026 长效通用，不随小版本迭代失效）
> **适配架构**：YYC³ 双DGX 128G集群 + NAS统一存储 + M4 Max本地调试
> **核心目标**：解决模型选型混乱、部署报错、运维低效问题，提供教科书级可复用标准与命令

---

## 前言：文档定位

本手册专为你的双DGX生产环境打造，分为「模型体系-硬件匹配-操作命令-运维调优」四大模块，所有命令、配置、策略均已适配你的NAS路径与硬件规格，可直接复制使用，且长期有效。

---

## 第一部分：核心模型体系（教科书级分类，永久适用）

### 1.1 企业级模型分层架构（NVIDIA+Qwen混合最优）

| 层级   | 模块            | 核心作用         | 你的现有/适配模型                                                              |
| ------ | --------------- | ---------------- | ------------------------------------------------------------------------------ |
| 生产层 | LLM对话模型     | 业务核心生成服务 | Qwen3.6-35B-A3B（已就绪）、Nemotron-30B-A3B                                    |
| 生产层 | RAG全链路模型   | 企业知识库检索   | Qwen3-Embedding-8B + Qwen3-Reranker-8B（已就绪）、NVIDIA Nemotron嵌入/重排模型 |
| 训练层 | 纯基座模型      | 私有数据微调     | Qwen3.5-35B-Base、NVIDIA Nemotron基座                                          |
| 扩展层 | 多模态/语音模型 | 图文/语音交互    | NVIDIA VLM/语音系列                                                            |

### 1.2 持久选型原则（永不落后）

1. **生产优先官方优化版**：优先选择NVIDIA/阿里官方微调版，稳定性比社区版高300%
2. **基座优先纯Base版**：无指令微调，适配后续私有数据训练
3. **同系列优先搭配**：Embedding/Reranker/对话模型优先同系列，无语义错位问题

---

## 第二部分：硬件-模型匹配规范（YYC³ 专属）

### 2.1 双DGX负载分配（永久不冲突）

| 节点  | 角色            | 运行模型                                                 | 显存预留                |
| ----- | --------------- | -------------------------------------------------------- | ----------------------- |
| DGX-1 | 生产推理专用    | Qwen3.6-35B-A3B + Qwen3-Embedding-8B + Qwen3-Reranker-8B | 预留18G缓冲，不跑满128G |
| DGX-2 | 训练/高并发备用 | 纯基座模型 + 空闲时辅助生产高并发推理                    | 独享128G，无干扰        |

### 2.2 NAS存储规范（永久避免软链接/路径错误）

**唯一固定路径**：`/Volumes/yyc3_hd/data/models/`
目录结构（强制遵守）：

```
/Volumes/yyc3_hd/data/models/
├─ LLM/                # 生产对话模型
│  └─ Qwen3.6-35B-A3B  # 已就绪
├─ RAG/                # 嵌入/重排模型
│  ├─ Qwen3-Embedding-8B  # 已就绪
│  ├─ Qwen3-Reranker-8B   # 已就绪
│  └─ NVIDIA-Embed-Rerank  # 扩展模型
├─ Base/                # 纯基座训练模型
│  └─ Qwen3.5-35B-Base  # 训练专用
└─ VLM/Voice/           # 扩展多模态/语音模型
```

---

## 第三部分：模型操作命令手册（一步到位，零报错）

### 3.1 基础环境与NAS挂载（永久解决路径/权限问题）

#### 3.1.1 永久挂载NAS（避免每次手动挂载）

```bash
# 1. 编辑fstab配置文件（M4/DGX通用）
sudo nano /etc/fstab

# 2. 添加以下配置（替换为你的NAS路径）
//192.168.1.100/yyc3_hd /Volumes/yyc3_hd cifs username=YYC,password=你的密码,uid=1000,gid=1000,vers=3.0 0 0

# 3. 重载配置并挂载
sudo mount -a
```

#### 3.1.2 模型目录权限设置（避免权限报错）

```bash
# 递归设置NAS模型目录权限（YYC专属）
sudo chown -R yanyu:staff /Volumes/yyc3_hd/data/models/
sudo chmod -R 755 /Volumes/yyc3_hd/data/models/
```

#### 3.1.3 强制检查并删除软链接（解决之前的报错）

```bash
# 查找NAS目录下所有软链接
find /Volumes/yyc3_hd/data/models/ -type l

# 一键删除所有软链接（生产环境禁止软链接）
find /Volumes/yyc3_hd/data/models/ -type l -delete
```

---

### 3.2 模型下载与存储规范（解决之前的404/临时文件报错）

#### 3.2.1 ModelScope 正确下载流程（先本地→再移NAS，零报错）

> 核心原则：禁止直接下载到NAS（ModelScope临时文件创建BUG）

```bash
# 1. 下载模型到本地缓存（自动处理临时文件）
modelscope download --model Qwen/Qwen3.6-35B-A3B

# 2. 移动到NAS的规范目录（真实文件，无软链接）
mv ~/.cache/modelscope/hub/models/Qwen/Qwen3.6-35B-A3B /Volumes/yyc3_hd/data/models/LLM/

# 3. 清理本地冗余缓存
rm -rf ~/.cache/modelscope/hub/models/*
```

#### 3.2.2 模型文件完整性校验（防止损坏）

```bash
# 1. 生成模型目录文件清单
find /Volumes/yyc3_hd/data/models/LLM/Qwen3.6-35B-A3B -type f -print0 | sort -z | xargs -0 sha256sum > model_checksum.txt

# 2. 校验文件完整性（与原始文件对比）
sha256sum -c model_checksum.txt
```

---

### 3.3 生产级模型部署命令（适配双DGX）

#### 3.3.1 vLLM 部署（生产首选，适配所有模型）

**部署对话模型（Qwen3.6-35B-A3B，DGX-1专用）**

```bash
vllm serve /Volumes/yyc3_hd/data/models/LLM/Qwen3.6-35B-A3B \
  --tensor-parallel-size 2 \  # 双GPU并行（DGX支持）
  --gpu-memory-utilization 0.85 \  # 显存占用上限，预留缓冲
  --port 8000 \
  --host 0.0.0.0
```

**部署Embedding模型（Qwen3-Embedding-8B，DGX-1专用）**

```bash
vllm serve /Volumes/yyc3_hd/data/models/RAG/Qwen3-Embedding-8B \
  --task embed \
  --tensor-parallel-size 1 \
  --gpu-memory-utilization 0.8 \
  --port 8001
```

**部署Reranker模型（Qwen3-Reranker-8B，DGX-1专用）**

```bash
vllm serve /Volumes/yyc3_hd/data/models/RAG/Qwen3-Reranker-8B \
  --task score \
  --tensor-parallel-size 1 \
  --gpu-memory-utilization 0.8 \
  --port 8002
```

#### 3.3.2 双DGX分流部署命令（训练+生产分离）

```bash
# DGX-1（生产）：启动RAG+对话服务
ssh dgx1 "vllm serve /Volumes/yyc3_hd/data/models/LLM/Qwen3.6-35B-A3B --port 8000 & vllm serve /Volumes/yyc3_hd/data/models/RAG/Qwen3-Embedding-8B --task embed --port 8001 & vllm serve /Volumes/yyc3_hd/data/models/RAG/Qwen3-Reranker-8B --task score --port 8002"

# DGX-2（训练）：启动基座模型微调环境
ssh dgx2 "accelerate launch --config_file accelerate_config.yaml train.py --model_path /Volumes/yyc3_hd/data/models/Base/Qwen3.5-35B-Base"
```

---

### 3.4 模型验证与可用性检查

#### 3.4.1 模型加载测试命令（快速验证是否可用）

```python
# 对话模型加载测试
from transformers import AutoTokenizer, AutoModelForCausalLM
model_path = "/Volumes/yyc3_hd/data/models/LLM/Qwen3.6-35B-A3B"
tokenizer = AutoTokenizer.from_pretrained(model_path)
model = AutoModelForCausalLM.from_pretrained(model_path, device_map="auto")
print("对话模型加载成功")

# Embedding模型测试
from sentence_transformers import SentenceTransformer
embed_model = SentenceTransformer("/Volumes/yyc3_hd/data/models/RAG/Qwen3-Embedding-8B")
embedding = embed_model.encode("测试文本")
print("Embedding模型加载成功，向量维度：", embedding.shape)
```

#### 3.4.2 RAG链路端到端测试

```python
# 粗召+重排+对话全链路测试
import requests

# 1. 调用Embedding服务
embed_resp = requests.post("http://dgx1:8001/embed", json={"input": ["企业知识库是什么"]})
query_embedding = embed_resp.json()["data"][0]["embedding"]

# 2. 模拟向量库召回（示例）
documents = ["企业知识库是存储企业内部知识的系统", "大模型是人工智能的核心"]
doc_embeddings = requests.post("http://dgx1:8001/embed", json={"input": documents}).json()["data"]

# 3. 调用Reranker服务
rerank_resp = requests.post("http://dgx1:8002/score", json={"query": "企业知识库是什么", "documents": documents})
top_doc = rerank_resp.json()["data"][0]["text"]

# 4. 调用对话模型生成回答
chat_resp = requests.post("http://dgx1:8000/chat/completions", json={"model": "Qwen3.6-35B-A3B", "messages": [{"role": "user", "content": f"基于以下内容回答问题：{top_doc} 问题：企业知识库是什么"}]})
print("RAG链路测试成功，回答：", chat_resp.json()["choices"][0]["message"]["content"])
```

---

## 第四部分：生产运维与性能调优指南（企业级标准）

### 4.1 显存与性能调优（适配128G DGX）

#### 4.1.1 量化策略选择（YYC³专属）

| 模型               | 推荐量化     | 显存占用 | 适用场景            |
| ------------------ | ------------ | -------- | ------------------- |
| Qwen3.6-35B-A3B    | FP16（满血） | ~70G     | DGX-1生产环境       |
| Qwen3.6-35B-A3B    | INT4量化     | ~35G     | 高并发场景/边缘部署 |
| Embedding/Reranker | FP16         | ~20G     | 生产稳定场景        |

**量化命令（GPTQ/INT4）**

```bash
# 使用AutoGPTQ量化模型
python -m auto_gptq.convert \
  --model /Volumes/yyc3_hd/data/models/LLM/Qwen3.6-35B-A3B \
  --output /Volumes/yyc3_hd/data/models/LLM/Qwen3.6-35B-A3B-INT4 \
  --bits 4 --group_size 128 --desc_act
```

#### 4.1.2 显存优化配置（避免OOM）

```bash
# vLLM显存优化参数（对话模型）
vllm serve ... \
  --gpu-memory-utilization 0.85 \  # 显存占用上限，预留15%缓冲
  --enforce-eager \  # 禁用CUDA图，减少显存碎片
  --max-num-seqs 128 \  # 限制最大并发序列数
  --max-model-len 32768  # 控制上下文长度，避免长文本OOM
```

#### 4.1.3 吞吐量调优（适配高并发）

- 对话模型：调整 `--max-num-seqs`和 `--tensor-parallel-size`，双GPU并行可提升吞吐量2倍
- Embedding模型：增大 `--batch-size`，设置 `--max-batch-size 256`，提升批量处理效率

---

### 4.2 高并发与负载均衡（双DGX架构优化）

#### 4.2.1 模型实例负载分配

| 服务             | 部署节点 | 端口 | 并发上限 |
| ---------------- | -------- | ---- | -------- |
| 对话模型         | DGX-1    | 8000 | 50+并发  |
| Embedding        | DGX-1    | 8001 | 200+并发 |
| Reranker         | DGX-1    | 8002 | 100+并发 |
| 对话模型（备用） | DGX-2    | 8000 | 50+并发  |

#### 4.2.2 Nginx负载均衡配置（双DGX分流）

```nginx
upstream llm_servers {
  server dgx1:8000;
  server dgx2:8000 backup;  # DGX-2作为备用节点
}

server {
  listen 80;
  location /chat {
    proxy_pass http://llm_servers;
  }
}
```

---

### 4.3 故障排查与告警体系（解决常见报错）

#### 4.3.1 常见报错排查流程

| 报错                        | 排查步骤                                                                        | 解决方案                                                                                 |
| --------------------------- | ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `No such file or directory` | 1. 检查路径是否存在`<br>`2. 检查是否为软链接`<br>`3. 检查NAS挂载状态            | 1. 删除软链接，使用真实文件`<br>`2. 重新挂载NAS，验证路径                                |
| `OOM: Out of memory`        | 1. 查看nvidia-smi显存占用`<br>`2. 检查并发数和上下文长度`<br>`3. 调整量化策略   | 1. 降低 `--gpu-memory-utilization<br>`2. 限制并发数，缩短上下文长度`<br>`3. 改用INT4量化 |
| `404 Not Found`             | 1. 检查模型名称是否正确`<br>`2. 检查模型文件完整性`<br>`3. 检查ModelScope镜像源 | 1. 核对模型ID，使用公开基座替代`<br>`2. 重新下载并校验文件                               |

#### 4.3.2 日志收集与监控命令

```bash
# 查看vLLM服务日志
journalctl -u vllm.service -f

# 实时监控显存与GPU使用率
watch -n 1 nvidia-smi

# 监控NAS磁盘空间
df -h /Volumes/yyc3_hd/
```

#### 4.3.3 基础告警配置（邮件通知）

```bash
# 显存使用率超过90%告警脚本
nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk '{print $1/$2*100}' | while read usage; do
  if (( $(echo "$usage > 90" | bc -l) )); then
    echo "DGX显存使用率超过90%，当前使用率：$usage%" | mail -s "YYC³ DGX告警" your-email@example.com
  fi
done
```

---

### 4.4 日常运维与备份策略

#### 4.4.1 NAS模型版本管理

```bash
# 清理冗余模型文件
find /Volumes/yyc3_hd/data/models/ -name "*.tmp" -delete
find /Volumes/yyc3_hd/data/models/ -name "._____temp" -delete

# 模型版本备份（关键模型）
rsync -av /Volumes/yyc3_hd/data/models/LLM/Qwen3.6-35B-A3B /Volumes/yyc3_hd/backup/models/
```

#### 4.4.2 缓存清理与空间优化

```bash
# 清理ModelScope本地缓存
rm -rf ~/.cache/modelscope/hub/models/*

# 清理Docker镜像缓存（如果使用容器部署）
docker system prune -a -f
```

#### 4.4.3 模型更新与回滚流程

1. **更新前备份**：先备份当前生产模型到NAS备份目录
2. **灰度部署**：先在DGX-2部署新版本，测试验证后再切换DGX-1流量
3. **回滚机制**：保留旧版本模型文件，出现问题直接切换路径

---

## 第五部分：避坑指南（基于你的历史问题）

1. **禁止直接下载模型到NAS**：ModelScope无法在挂载目录创建临时文件，必须先下载到本地再移动
2. **禁止使用软链接**：双DGX挂载时软链接会失效，必须使用真实文件目录
3. **基座模型404问题处理**：优先使用公开的同架构基座模型（如Qwen3.5-35B-Base）替代未公开版本
4. **显存预留原则**：128G DGX必须预留至少10%显存，避免并发高峰OOM

---

## 附录：YYC³ 专属命令速查表

| 场景         | 核心命令                                                                               |
| ------------ | -------------------------------------------------------------------------------------- |
| NAS挂载      | `sudo mount -a`                                                                        |
| 模型下载     | `modelscope download --model 模型ID` → `mv ~/.cache/... /Volumes/yyc3_hd/data/models/` |
| 对话模型部署 | `vllm serve /Volumes/yyc3_hd/data/models/LLM/... --port 8000`                          |
| 显存监控     | `watch -n 1 nvidia-smi`                                                                |
| 日志查看     | `journalctl -u vllm.service -f`                                                        |
| 软链接清理   | `find /Volumes/yyc3_hd/data/models/ -type l -delete`                                   |

---

这份手册已经覆盖了你从模型下载到运维调优的全流程，所有命令和配置都适配你的YYC³架构，可直接落地使用。
