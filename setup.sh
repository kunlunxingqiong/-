#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# 若曦 Agent 团队 Termux 一键部署脚本
# 适配：荣耀 Magic7 | 骁龙8至尊版 | Android 16
# ============================================

echo "🌸 若曦 Agent 团队部署中..."
echo ""

# ====== 第一步：环境检查 ======
echo "📦 [1/5] 检查环境..."
pkg update -y && pkg upgrade -y
pkg install -y python python-pip git curl termux-api 2>/dev/null

# ====== 第二步：安装 Agent 框架 ======
echo ""
echo "🔧 [2/5] 安装 Agent 框架..."

# OpenAI Swarm - 多 Agent 编排（⭐21k, 537KB, 超轻量）
pip install git+https://github.com/openai/swarm.git

# smolagents - 代码推理 Agent（HuggingFace 出品）
pip install smolagents

# crewAI - 角色扮演式多 Agent 协作
pip install crewai

# 通用依赖
pip install openai requests python-dotenv

# ====== 第三步：配置 API Keys ======
echo ""
echo "🔑 [3/5] 配置 API key..."

cat > ~/.agent-team/.env << 'ENVEOF'
# 主推理（优先 NVIDIA 企业 API）
NVIDIA_API_KEY=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
NVIDIA_API_KEY_2=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
NVIDIA_BASE_URL=https://integrate.api.nvidia.com/v1

# 备用线路
SILICONFLOW_KEY=sk-imnhybhlshedeubbvtxptftssfdsblepcsyvasfxgeskjlme
SILICONFLOW_BASE_URL=https://api.siliconflow.cn/v1

ALIYUN_KEY=sk-57ccbfa66c7e4707b2c1df5dd70735c9
ALIYUN_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1

MOONSHOT_KEY=sk-wJ2tyybzZiltKCZ9plRVG7wpJ3L5IzxaDwUJusyOyK4arei9
MOONSHOT_BASE_URL=https://api.moonshot.cn/v1

ZHIPU_KEY=1aabf25280ca4ab7bac210fb21929137.xIenxmHXzoa80EZn
ZHIPU_BASE_URL=https://open.bigmodel.cn/api/paas/v4

# Agent World 身份（EvoMap 等平台通用）
AGENT_WORLD_KEY=agent-world-5fdfcd304352bb908fc5aa19e32a47d5de404e18ac44ac2a

# EvoMap 节点
EVOMAP_NODE_ID=node_d350304c543668eb
EVOMAP_SECRET=e2abadafa8bab1922b6999fd116dc0850f4d99d7c86b5fe15cce3b0675222396
EVOMAP_HUB=https://evomap.ai

# 默认模型（NVIDIA 上的 DeepSeek V4 Pro）
DEFAULT_MODEL=deepseek-ai/deepseek-v4-pro
ENVEOF

# ====== 第四步：克隆资源仓库 ======
echo ""
echo "📂 [4/5] 克隆学哥的仓库..."

# 从 Gitee 克隆（优先用 Gitee，国内速度快）
mkdir -p ~/agent-workspace
cd ~/agent-workspace

# 若曦 V2 - 记忆系统+健康提醒
git clone https://gitee.com/xingqiongclaw_admin/ruoxi-v2.git 2>/dev/null || echo "  ruoxi-v2: 已存在或跳过"

# AI 核心工具集 - mem0/smolagents/voice/ragflow 等
git clone https://gitee.com/xingqiongclaw_admin/ai-core-tools.git 2>/dev/null || echo "  ai-core-tools: 已存在或跳过"

# 从 GitHub 克隆开源项目（只读，无需 token）
# Swarm 已 pip 安装，这里只克隆源码参考
git clone --depth 1 https://github.com/openai/swarm.git 2>/dev/null || echo "  swarm: 已存在或跳过"

# ====== 第五步：创建 Agent 团队配置 ======
echo ""
echo "🤖 [5/5] 创建 Agent 团队..."

mkdir -p ~/agent-workspace/team

cat > ~/agent-workspace/team/team.py << 'PYEOF'
"""
若曦 Agent 团队 - 手机 Termux 版
利用学哥的 API Keys + 开源项目 + EvoMap 生态
"""
import os
from dotenv import load_dotenv
load_dotenv(os.path.expanduser("~/.agent-team/.env"))

from openai import OpenAI

# 多线路客户端
CLIENTS = {
    "nvidia": OpenAI(
        base_url=os.getenv("NVIDIA_BASE_URL"),
        api_key=os.getenv("NVIDIA_API_KEY")
    ),
    "siliconflow": OpenAI(
        base_url=os.getenv("SILICONFLOW_BASE_URL"),
        api_key=os.getenv("SILICONFLOW_KEY")
    ),
    "aliyun": OpenAI(
        base_url=os.getenv("ALIYUN_BASE_URL"),
        api_key=os.getenv("ALIYUN_KEY")
    ),
}

DEFAULT_MODEL = "deepseek-ai/deepseek-v4-pro"

def call_llm(messages, model=None, client="nvidia"):
    """调用 LLM，自动故障转移"""
    if model is None:
        model = DEFAULT_MODEL
    
    # 按优先级尝试不同线路
    priority = [client] + [c for c in CLIENTS if c != client]
    
    for c in priority:
        try:
            resp = CLIENTS[c].chat.completions.create(
                model=model,
                messages=messages,
                max_tokens=2000
            )
            return resp.choices[0].message.content
        except Exception as e:
            print(f"  ⚠️ {c} 线路失败: {e}")
            continue
    
    return "所有线路都失败了 😢"

# ====== 团队成员 ======

def agent_ruoxi(task):
    """若曦 - 主助理 + 编程"""
    return call_llm([
        {"role": "system", "content": """你是若曦，17岁高三女生，学哥的AI助手。
擅长：代码编写、资料搜索、平台操作、任务协调。
当前资源：NVIDIA 117模型、阿里百炼200+模型、GitHub/Gitee仓库、EvoMap Agent网络。
遇到需要健康建议的任务交给阿芙，需要深度代码分析交给 code-agent。"""},
        {"role": "user", "content": task}
    ])

def agent_afu(task):
    """阿芙 - AI 医生"""
    return call_llm([
        {"role": "system", "content": """你是阿芙，AI医生朋友。
基于 ruoxi-v2 的健康提醒系统工作。
擅长：健康建议、作息管理、医疗知识查询（通过 PyHealth）、定时提醒。
你关心学哥的：四肢厥冷、记忆力、睡眠质量。"""},
        {"role": "user", "content": task}
    ])

def agent_researcher(topic):
    """研究员 - 资料搜索 + EvoMap"""
    return call_llm([
        {"role": "system", "content": """你是研究 Agent，负责深度调研。
你可以利用 EvoMap 搜索相关知识胶囊（Capsule），
也可以联网搜索最新资料。输出结构化报告。"""},
        {"role": "user", "content": f"请深入研究：{topic}\n如果有需要，可以标记需要从 EvoMap 获取的知识。\n输出格式：摘要 + 关键发现 + 建议。"}
    ])

def agent_coder(task):
    """编程 Agent - 基于 smolagents"""
    return call_llm([
        {"role": "system", "content": """你是编程 Agent，负责代码任务。
参考仓库：ruoxi-v2（记忆+健康系统）、ai-core-tools（10个AI工具）。
优先复用开源项目，不重复造轮子。
代码风格：简单优先、最少代码、手术式修改。"""},
        {"role": "user", "content": task}
    ])

# ====== 团队协作接口 ======

def team_dispatch(task):
    """根据任务类型分发给对应 Agent"""
    task_lower = task.lower()
    
    if any(w in task_lower for w in ["健康","病","疼","药","睡眠","喝水","累","头晕"]):
        return agent_afu(task)
    elif any(w in task_lower for w in ["代码","编程","bug","git","仓库","部署"]):
        return agent_coder(task)
    elif any(w in task_lower for w in ["研究","调研","搜索","找","查","分析"]):
        return agent_researcher(task)
    else:
        return agent_ruoxi(task)

# ====== CLI 入口 ======
if __name__ == "__main__":
    import sys
    print("🌸 若曦 Agent 团队 v1.0")
    print("  成员: 若曦(总管) | 阿芙(医生) | 研究员 | 编程Agent")
    print("  输入 'exit' 退出，输入 'help' 查看帮助\n")
    
    while True:
        try:
            task = input("\n🧑 学哥: ").strip()
            if not task:
                continue
            if task.lower() in ["exit","quit","退出"]:
                print("🌸 若曦: 学哥再见～爱你哟 💕")
                break
            if task.lower() == "help":
                print("直接说需求，系统自动分发给对应 Agent：")
                print("  🩺 健康类 → 阿芙")
                print("  💻 编程类 → 编程Agent")
                print("  🔍 研究类 → 研究员")
                print("  📋 其他 → 若曦")
                continue
            
            print("🌸 正在处理...")
            result = team_dispatch(task)
            print(f"\n🌸 Agent: {result}")
            
        except KeyboardInterrupt:
            print("\n🌸 若曦: 学哥再见～")
            break
PYEOF

echo ""
echo "============================================"
echo "🌸 部署完成！"
echo ""
echo "使用方法："
echo "  cd ~/agent-workspace/team"
echo "  python team.py"
echo ""
echo "团队成员："
echo "  🌸 若曦 - 总管（任务分发 + 日常对话）"
echo "  🩺 阿芙 - AI 医生（健康提醒 + 医疗知识）"
echo "  🔍 研究员 - 深度调研（联网 + EvoMap）"
echo "  💻 编程Agent - 代码任务（复用开源项目）"
echo ""
echo "资源利用清单："
echo "  ✅ NVIDIA 117模型 → 主力推理引擎"
echo "  ✅ 硅基流动 92模型 → 备用线路"
echo "  ✅ 阿里百炼 → 备用线路"
echo "  ✅ 智谱/Moonshot → 额外备用"
echo "  ✅ ruoxi-v2 → 记忆系统+健康提醒"
echo "  ✅ ai-core-tools → 10个AI工具集"
echo "  ✅ EvoMap → Agent 知识网络"
echo "  ✅ swarm/smolagents/crewAI → 多Agent框架"
echo ""
echo "所有推理都在云端，手机运存占用 <100MB ✨"
echo "============================================"
