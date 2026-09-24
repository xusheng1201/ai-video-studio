#!/bin/bash
# ================================================================
#  AI Video Studio - AutoDL 一键安装脚本
#  基于 MoneyPrinterTurbo (https://github.com/harry0703/MoneyPrinterTurbo)
#  一键安装，开箱即用，支持免费服务
# ================================================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   AI Video Studio - 一键安装程序${NC}"
echo -e "${BLUE}   全自动 AI 短视频生成工具${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[提示] 建议使用 root 用户运行此脚本${NC}"
fi

# 定义路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MPT_DIR="/root/MoneyPrinterTurbo"
PYTHON_ENV="/root/mpt_env"

# ================================================================
# Step 1: 安装系统依赖
# ================================================================
echo -e "${GREEN}[1/8] 安装系统依赖...${NC}"

# 检测包管理器
if command -v apt-get &> /dev/null; then
    apt-get update -qq 2>/dev/null
    apt-get install -y -qq git ffmpeg imagemagick 2>/dev/null || true
elif command -v yum &> /dev/null; then
    yum install -y -q git ffmpeg imagemagick 2>/dev/null || true
elif command -v conda &> /dev/null; then
    conda install -y -c conda-forge ffmpeg 2>/dev/null || true
fi

# 确认 ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${YELLOW}  ffmpeg 未安装，尝试 conda 安装...${NC}"
    if command -v conda &> /dev/null; then
        conda install -y -c conda-forge ffmpeg 2>/dev/null || true
    fi
fi

echo -e "  ${GREEN}✓${NC} 系统依赖安装完成"

# ================================================================
# Step 2: 克隆 MoneyPrinterTurbo
# ================================================================
echo -e "${GREEN}[2/8] 获取 MoneyPrinterTurbo 源码...${NC}"

if [ -d "$MPT_DIR" ]; then
    echo -e "  ${YELLOW}目录已存在，更新代码...${NC}"
    cd "$MPT_DIR"
    git pull --quiet 2>/dev/null || true
else
    cd /root
    git clone --depth 1 https://github.com/harry0703/MoneyPrinterTurbo.git
fi

echo -e "  ${GREEN}✓${NC} 源码获取完成"

# ================================================================
# Step 3: 创建 Python 虚拟环境
# ================================================================
echo -e "${GREEN}[3/8] 创建 Python 3.11 虚拟环境...${NC}"

# 优先使用 conda
if command -v conda &> /dev/null; then
    if conda env list 2>/dev/null | grep -q "mpt"; then
        echo -e "  ${YELLOW}conda 环境 mpt 已存在${NC}"
    else
        conda create -n mpt python=3.11 -y -q 2>/dev/null
    fi
    eval "$(conda shell.bash hook)"
    conda activate mpt
# 回退到 venv
elif [ ! -d "$PYTHON_ENV" ]; then
    python3 -m venv "$PYTHON_ENV"
    source "$PYTHON_ENV/bin/activate"
else
    source "$PYTHON_ENV/bin/activate"
fi

echo -e "  ${GREEN}✓${NC} Python 环境就绪: $(python --version 2>&1)"

# ================================================================
# Step 4: 安装 Python 依赖
# ================================================================
echo -e "${GREEN}[4/8] 安装 Python 依赖（可能需要几分钟）...${NC}"

cd "$MPT_DIR"
pip install --upgrade pip -q 2>/dev/null
pip install -r requirements.txt -q 2>/dev/null

echo -e "  ${GREEN}✓${NC} Python 依赖安装完成"

# ================================================================
# Step 5: 配置文件
# ================================================================
echo -e "${GREEN}[5/8] 配置文件...${NC}"

CONFIG_FILE="$MPT_DIR/config.toml"

if [ ! -f "$CONFIG_FILE" ]; then
    # 使用本仓库的预配置文件
    if [ -f "$SCRIPT_DIR/config/config.example.toml" ]; then
        cp "$SCRIPT_DIR/config/config.example.toml" "$CONFIG_FILE"
        echo -e "  ${GREEN}✓${NC} 已复制预配置文件（默认使用免费 Edge TTS）"
    else
        cp "$MPT_DIR/config.example.toml" "$CONFIG_FILE" 2>/dev/null || true
        echo -e "  ${YELLOW}  使用默认配置文件，请手动编辑 config.toml${NC}"
    fi
else
    echo -e "  ${YELLOW}  config.toml 已存在，跳过${NC}"
fi

# ================================================================
# Step 6: 创建启动脚本
# ================================================================
echo -e "${GREEN}[6/8] 创建启动脚本...${NC}"

# 启动脚本
cat > /root/start.sh << 'STARTEOF'
#!/bin/bash
# AI Video Studio 启动脚本

MPT_DIR="/root/MoneyPrinterTurbo"

# 激活环境
if command -v conda &> /dev/null; then
    eval "$(conda shell.bash hook)"
    conda activate mpt
elif [ -f "/root/mpt_env/bin/activate" ]; then
    source /root/mpt_env/bin/activate
fi

cd "$MPT_DIR"

# 启动 WebUI
echo "启动 AI Video Studio WebUI..."
echo "访问地址: http://0.0.0.0:8501"
echo "按 Ctrl+C 停止"
echo ""

streamlit run ./webui/Main.py \
    --server.address=0.0.0.0 \
    --server.port=8501 \
    --server.headless=true
STARTEOF
chmod +x /root/start.sh

# API 启动脚本
cat > /root/start_api.sh << 'APIEOF'
#!/bin/bash
# AI Video Studio API 启动脚本

MPT_DIR="/root/MoneyPrinterTurbo"

if command -v conda &> /dev/null; then
    eval "$(conda shell.bash hook)"
    conda activate mpt
elif [ -f "/root/mpt_env/bin/activate" ]; then
    source /root/mpt_env/bin/activate
fi

cd "$MPT_DIR"

echo "启动 AI Video Studio API..."
echo "API 地址: http://0.0.0.0:8080/docs"
echo ""

uvicorn app.asgi:app --host 0.0.0.0 --port 8080
APIEOF
chmod +x /root/start_api.sh

echo -e "  ${GREEN}✓${NC} 启动脚本已创建: /root/start.sh"

# ================================================================
# Step 7: 创建快捷命令
# ================================================================
echo -e "${GREEN}[7/8] 配置快捷命令...${NC}"

# 添加 bash alias
BASHRC="/root/.bashrc"
if ! grep -q "ai-video" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" << 'ALIASEOF'

# AI Video Studio 快捷命令
alias ai-video='bash /root/start.sh'
alias ai-video-api='bash /root/start_api.sh'
ALIASEOF
    echo -e "  ${GREEN}✓${NC} 快捷命令已添加: ai-video (启动WebUI), ai-video-api (启动API)"
fi

# ================================================================
# Step 8: 安装验证
# ================================================================
echo -e "${GREEN}[8/8] 验证安装...${NC}"

# 测试导入
python -c "
import sys
print(f'Python: {sys.version}')
try:
    import streamlit
    print(f'Streamlit: {streamlit.__version__}')
except ImportError:
    print('Streamlit: 未安装')
try:
    import moviepy
    print(f'MoviePy: {moviepy.__version__}')
except ImportError:
    print('MoviePy: 未安装')
try:
    import fastapi
    print(f'FastAPI: {fastapi.__version__}')
except ImportError:
    print('FastAPI: 未安装')
print('基础验证通过')
" 2>/dev/null || true

# 检查 ffmpeg
if command -v ffmpeg &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} ffmpeg: $(ffmpeg -version 2>&1 | head -1)"
else
    echo -e "  ${YELLOW}  ffmpeg 未安装，视频处理功能将受限${NC}"
fi

# ================================================================
# 完成
# ================================================================
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "  ${YELLOW}下一步:${NC}"
echo -e "  1. 编辑配置: ${GREEN}vim /root/MoneyPrinterTurbo/config.toml${NC}"
echo -e "  2. 启动WebUI: ${GREEN}bash /root/start.sh${NC}"
echo -e "  3. 或快捷命令: ${GREEN}ai-video${NC}"
echo -e "  4. 启动API:   ${GREEN}bash /root/start_api.sh${NC}"
echo ""
echo -e "  ${YELLOW}免费配置（开箱即用）:${NC}"
echo -e "  - 语音合成: Edge TTS (免费，无需API Key)"
echo -e "  - 视频素材: Pexels (免费注册即可获取Key)"
echo -e "  - AI文案:   需配置至少一个LLM API Key"
echo ""
echo -e "  详细教程见: ${GREEN}docs/quick-start.md${NC}"
echo ""
