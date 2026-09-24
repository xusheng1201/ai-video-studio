# AI Video Studio - 全自动 AI 短视频生成工具

> 基于 [MoneyPrinterTurbo](https://github.com/harry0703/MoneyPrinterTurbo) 构建

## 简介

输入一个主题，自动生成完整短视频（AI文案 + 高清素材 + 中文配音 + 字幕 + 背景音乐）。

## 安装

```bash
cd /root
git clone https://github.com/你的用户名/ai-video-studio.git
cd ai-video-studio
bash setup.sh
```

安装完成后配置 2 个免费 API Key：

```bash
vim /root/MoneyPrinterTurbo/config.toml
```

| 服务 | 注册地址 | 费用 | 配置项 |
|------|---------|------|--------|
| Pexels | https://www.pexels.com/api/ | 免费 | `video_source.pexels.api_keys` |
| Moonshot | https://platform.moonshot.cn/ | 新用户免费 | `llm.moonshot.api_key` |

> Edge TTS 语音合成已默认配置，无需 Key。

## 启动

```bash
bash /root/start.sh        # WebUI
bash /root/start_api.sh    # API
```

WebUI 访问 `http://localhost:8501`，API 文档 `http://localhost:8080/docs`。

## 使用

1. 打开 WebUI
2. 输入视频主题（如"如何高效学习编程"）
3. 选择时长和分辨率
4. 点击生成，等待 3-8 分钟
5. 视频输出在 `/root/MoneyPrinterTurbo/storage/`

## 配置说明

完整配置见 `config/config.example.toml`，主要配置项：

- **LLM**: 支持 Moonshot/DeepSeek/OpenAI/Gemini/通义千问/Ollama 等
- **TTS**: 默认 Edge TTS（免费），可选 Azure Speech
- **素材源**: 默认 Pexels（免费），可选 Pixabay/Coverr
- **分辨率**: 默认 1080x1920 竖版，可改横版

## 验证安装

```bash
bash scripts/check_env.sh
python scripts/test_install.py
```

## 技术栈

Streamlit (WebUI) / FastAPI (API) / MoviePy+FFmpeg (视频) / Edge-TTS (语音) / Python 3.11+

## 致谢

基于 [MoneyPrinterTurbo](https://github.com/harry0703/MoneyPrinterTurbo) (MIT License)
