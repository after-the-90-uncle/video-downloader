#!/bin/bash

# 安装目录
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# 命令路径
YTDLP="$INSTALL_DIR/yt-dlp"

# 判断是否已安装
if command -v yt-dlp >/dev/null 2>&1; then
    echo "yt-dlp 已存在: $(command -v yt-dlp)"
else
    echo "yt-dlp 未找到，开始自动下载..."

    # 判断系统类型
    OS=$(uname -s)
    case "$OS" in
        Linux)
            URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux"
            ;;
        Darwin)
            URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos"
            ;;
        *)
            echo "暂不支持的系统: $OS"
            exit 1
            ;;
    esac

    # 下载 yt-dlp
    curl -L "$URL" -o "$YTDLP" || { echo "下载失败"; exit 1; }
    chmod +x "$YTDLP"

    # 提示 PATH 设置
    if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
        echo "⚠️  请把 $INSTALL_DIR 加入 PATH，例如："
        echo "    echo 'export PATH=\$PATH:$INSTALL_DIR' >> ~/.bashrc"
        echo "    source ~/.bashrc"
    fi

    echo "yt-dlp 已安装到 $YTDLP"
fi
