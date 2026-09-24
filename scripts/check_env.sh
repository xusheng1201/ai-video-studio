#!/bin/bash
# ================================================================
#  AI Video Studio - 环境检测脚本
# ================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  AI Video Studio - 环境检测"
echo "========================================"
echo ""

PASS=0
FAIL=0
WARN=0

check() {
    local name=$1
    local cmd=$2
    local required=$3

    if eval "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}[✓]${NC} $name"
        PASS=$((PASS+1))
    else
        if [ "$required" = "required" ]; then
            echo -e "  ${RED}[✗]${NC} $name (必需)"
            FAIL=$((FAIL+1))
        else
            echo -e "  ${YELLOW}[!]${NC} $name (可选)"
            WARN=$((WARN+1))
        fi
    fi
}

# 系统依赖
echo "--- 系统依赖 ---"
check "Git" "command -v git" "required"
check "FFmpeg" "command -v ffmpeg" "required"
check "Python 3.11+" "python3 -c 'import sys; assert sys.version_info >= (3,11)'" "required"
check "pip" "command -v pip" "required"
check "Conda" "command -v conda" "optional"
check "GPU (CUDA)" "nvidia-smi" "optional"

echo ""

# Python 依赖
echo "--- Python 依赖 ---"

# 激活环境
if command -v conda &> /dev/null; then
    eval "$(conda shell.bash hook)" 2>/dev/null
    conda activate mpt 2>/dev/null || true
elif [ -f "/root/mpt_env/bin/activate" ]; then
    source /root/mpt_env/bin/activate
fi

check "Streamlit" "python -c 'import streamlit'" "required"
check "FastAPI" "python -c 'import fastapi'" "required"
check "MoviePy" "python -c 'import moviepy'" "required"
check "OpenAI SDK" "python -c 'import openai'" "required"
check "Edge-TTS" "python -c 'import edge_tts'" "required"
check "Faster-Whisper" "python -c 'import faster_whisper'" "optional"
check "Pillow" "python -c 'import PIL'" "required"

echo ""

# 项目文件
echo "--- 项目文件 ---"
check "MoneyPrinterTurbo 目录" "test -d /root/MoneyPrinterTurbo" "required"
check "config.toml" "test -f /root/MoneyPrinterTurbo/config.toml" "required"
check "启动脚本 start.sh" "test -f /root/start.sh" "required"
check "API 启动脚本" "test -f /root/start_api.sh" "optional"

echo ""

# 配置检查
echo "--- 配置检查 ---"
CONFIG="/root/MoneyPrinterTurbo/config.toml"
if [ -f "$CONFIG" ]; then
    # 检查 Edge TTS
    if grep -q 'provider = "edge"' "$CONFIG"; then
        echo -e "  ${GREEN}[✓]${NC} TTS: Edge TTS (免费)"
        PASS=$((PASS+1))
    else
        echo -e "  ${YELLOW}[!]${NC} TTS: 非默认配置"
        WARN=$((WARN+1))
    fi

    # 检查 LLM 配置
    if grep -q 'api_key = ""' "$CONFIG" | head -1; then
        echo -e "  ${YELLOW}[!]${NC} LLM: API Key 未配置"
        echo -e "      请编辑 config.toml 填写至少一个 LLM API Key"
        WARN=$((WARN+1))
    else
        echo -e "  ${GREEN}[✓]${NC} LLM: API Key 已配置"
        PASS=$((PASS+1))
    fi

    # 检查视频源
    if grep -q 'pexels_api_keys' "$CONFIG" && ! grep -q 'pexels_api_keys = ""' "$CONFIG"; then
        echo -e "  ${GREEN}[✓]${NC} 视频源: Pexels Key 已配置"
        PASS=$((PASS+1))
    else
        echo -e "  ${YELLOW}[!]${NC} 视频源: Pexels Key 未配置"
        WARN=$((WARN+1))
    fi
fi

echo ""
echo "========================================"
echo -e "  通过: ${GREEN}$PASS${NC}  警告: ${YELLOW}$WARN${NC}  失败: ${RED}$FAIL${NC}"
echo "========================================"

if [ $FAIL -gt 0 ]; then
    echo ""
    echo -e "${RED}存在必需组件缺失，请重新运行: bash setup.sh${NC}"
    exit 1
elif [ $WARN -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}存在可选组件未配置，不影响基本使用${NC}"
    echo -e "${YELLOW}请编辑配置文件: vim /root/MoneyPrinterTurbo/config.toml${NC}"
else
    echo ""
    echo -e "${GREEN}所有检测通过！可以开始使用了${NC}"
    echo -e "启动: ${GREEN}bash /root/start.sh${NC}"
fi
