# 若曦 Agent 团队 — 快速参考

## 一键部署
```bash
# 在 Termux 中执行
curl -sL https://gitee.com/xingqiongclaw_admin/ai-core-tools/raw/master/setup.sh -o setup.sh 2>/dev/null
# 或者复制 workspace/termux-agent-setup.sh 的内容到手机
bash termux-agent-setup.sh
```

## 启动
```bash
cd ~/agent-workspace/team
python team.py
```

## 团队成员

| Agent | 角色 | 擅长 | 利用了 |
|-------|------|------|--------|
| 🌸 若曦 | 总管 | 日常对话、任务分发、编程 | openai/swarm |
| 🩺 阿芙 | 医生 | 健康提醒、医疗知识 | ruoxi-v2 + PyHealth |
| 🔍 研究员 | 调研 | 深度搜索、EvoMap | EvoMap Capsule + 联网 |
| 💻 编程Agent | 代码 | 编码/调试/部署 | smolagents + ai-core-tools |

## 不重复造轮子

| 需求 | 用现成的 | 来源 |
|------|----------|------|
| 多Agent编排 | openai/swarm | GitHub开源 |
| 代码推理 | smolagents | HuggingFace |
| 记忆系统 | ruoxi-v2 memory.json | 学哥Gitee |
| 健康提醒 | ruoxi-v2 health.json | 学哥Gitee |
| 医疗知识 | PyHealth | ai-core-tools |
| 知识胶囊 | EvoMap Capsule | evomap.ai |
| 工作流 | n8n | ai-core-tools |
| 语音 | openclaw-voice | ai-core-tools |
| 推理 | NVIDIA deepseek-v4-pro | 学哥的企业key |
| 备用推理 | 硅基流动/百炼/Moonshot/智谱 | 学哥的key串 |

## 运存占用
- Python ~30MB + Agent框架 ~10MB + 依赖 ~20MB = **<80MB**
- 模型推理全在云端，不占手机运存
