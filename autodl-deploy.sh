#!/bin/bash
# ================================================================
#  AI Video Studio - AutoDL 一键部署脚本
#  在 AutoDL 实例终端中直接运行此脚本
# ================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}  AI Video Studio - AutoDL 一键部署${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# 1. 安装系统依赖
echo -e "${GREEN}[1/6] 安装系统依赖...${NC}"
apt-get update -qq 2>/dev/null
apt-get install -y -qq git ffmpeg 2>/dev/null
echo -e "  ${GREEN}✓${NC} 系统依赖安装完成"

# 2. 克隆项目
echo -e "${GREEN}[2/6] 获取项目源码...${NC}"
cd /root
if [ -d "ai-video-studio" ]; then
    cd ai-video-studio
    git pull --quiet 2>/dev/null || true
else
    git clone --depth 1 https://github.com/xusheng1201/-..git ai-video-studio
    cd ai-video-studio
fi
echo -e "  ${GREEN}✓${NC} 源码获取完成"

# 3. 运行安装脚本
echo -e "${GREEN}[3/6] 安装 AI Video Studio...${NC}"
bash setup.sh
echo -e "  ${GREEN}✓${NC} 安装完成"

# 4. 安装中文字体（字幕需要）
echo -e "${GREEN}[4/6] 安装中文字体...${NC}"
apt-get install -y -qq fonts-noto-cjk 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} 字体安装完成"

# 5. 验证安装
echo -e "${GREEN}[5/6] 验证安装...${NC}"
bash scripts/check_env.sh || true
echo ""

# 6. 完成
echo -e "${GREEN}[6/6] 部署完成！${NC}"
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}  下一步操作:${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "  ${YELLOW}1. 配置 API Key:${NC}"
echo -e "     ${GREEN}vim /root/MoneyPrinterTurbo/config.toml${NC}"
echo -e "     填写 Pexels Key 和 Moonshot Key"
echo ""
echo -e "  ${YELLOW}2. 启动 WebUI:${NC}"
echo -e "     ${GREEN}bash /root/start.sh${NC}"
echo -e "     或快捷命令: ${GREEN}ai-video${NC}"
echo ""
echo -e "  ${YELLOW}3. 访问 WebUI:${NC}"
echo -e "     在 AutoDL JupyterLab 中打开 http://localhost:8501"
echo ""
echo -e "  ${YELLOW}4. 测试生成视频后，保存镜像:${NC}"
echo -e "     AutoDL 控制台 → 关机 → 更多 → 保存镜像"
echo ""
echo -e "  ${YELLOW}5. 发布镜像:${NC}"
echo -e "     访问 https://autodl.art/publish/image"
echo -e "     GitHub 仓库: https://github.com/xusheng1201/-"
echo -e "     镜像名称: ai-video-studio"
echo ""
