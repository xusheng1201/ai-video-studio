#!/bin/bash
# ================================================================
#  AI Video Studio - 停止服务脚本
# ================================================================

echo "停止 AI Video Studio 服务..."

# 停止 Streamlit WebUI
pkill -f "streamlit run" 2>/dev/null && echo "WebUI 已停止" || echo "WebUI 未运行"

# 停止 API 服务
pkill -f "uvicorn app.asgi" 2>/dev/null && echo "API 已停止" || echo "API 未运行"

# 停止 Ollama（如运行）
pkill -f "ollama serve" 2>/dev/null && echo "Ollama 已停止" || true

echo "完成"
