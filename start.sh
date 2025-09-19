#!/bin/bash
# start.sh
# 功能：从 urls.txt 下载视频，后台执行，下载完成上传到远程 WebDAV，上传后删除本地文件
# 上传报错不影响下载
# urls.txt 支持两种格式：
# 1) 只有 URL（自动用模板命名）
# 2) URL 文件名（空格分隔，自定义文件名要写扩展名 mp4）
CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="$CURRENT_DIR/downloads"
LOG="$CURRENT_DIR/downloader.log"
YT="$HOME/.local/bin/yt-dlp"
# server酱 key
SENDKEY=""

# server酱 推送 url
PUSH_URL="https://sctapi.ftqq.com/$SENDKEY.send"
ARCHIVE_FILE="$CURRENT_DIR/downloaded.txt"
URL_FILE="$CURRENT_DIR/urls.txt"


# webDav url 例如：http://ip:port/path/
REMOTEURL=""
# webDav用户名
USER=""
# webDav密码
PASS=""

MAX_CONCURRENT=2

mkdir -p "$OUTDIR"
cd "$OUTDIR" || exit 1

echo "===== $(date --iso-8601=seconds) START =====" >> "$LOG"

# 后台执行函数
download_and_upload() {
    local url="$1"
    local filename="$2"

    if [ -n "$filename" ]; then
        # 自定义文件名
        $YT -f "bestvideo+bestaudio/best" \
            --merge-output-format mp4 \
            --restrict-filenames \
            --no-part \
            --download-archive "$ARCHIVE_FILE" \
            --retries 3 \
            --sleep-interval 2 \
            --max-sleep-interval 6 \
            --output "$filename" \
            "$url" >> "$LOG" 2>&1
    else
        # 自动模板命名
        $YT -f "bestvideo+bestaudio/best" \
            --merge-output-format mp4 \
            --restrict-filenames \
            --no-part \
            --download-archive "$ARCHIVE_FILE" \
            --retries 3 \
            --sleep-interval 2 \
            --max-sleep-interval 6 \
            --output "%(upload_date)s_%(title).120s.%(ext)s" \
            "$url" >> "$LOG" 2>&1
        filename=$(ls -t "$OUTDIR" | head -n1) # 获取最新下载文件
    fi

    if [ $? -eq 0 ]; then
        echo "$(date --iso-8601=seconds) DONE: $url" >> "$LOG"
        # 删除 urls.txt 中已处理的行
        sed -i "\|$url|d" "$URL_FILE"
        # 上传到远程，不影响下载流程
        {
            echo "上传 $filename ..." >> "$LOG"
            curl -s -T "$OUTDIR/$filename" -u "$USER:$PASS" "$REMOTEURL$filename" >> "$LOG" 2>&1
            if [ $? -eq 0 ]; then
                echo "$(date --iso-8601=seconds) UPLOAD DONE: $filename" >> "$LOG"
                rm -f "$OUTDIR/$filename"
            else
                echo "$(date --iso-8601=seconds) UPLOAD FAIL: $filename" >> "$LOG"
                # 上传失败，不删除本地文件，下一次可以重试
            fi
        } &
    else
        echo "$(date --iso-8601=seconds) FAIL: $url" >> "$LOG"
    fi
}

# 读取 URL 文件并并行下载
while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    url=$(echo "$line" | awk '{print $1}')
    filename=$(echo "$line" | cut -d' ' -f2-)

    download_and_upload "$url" "$filename" &

    # 控制并发数
    while [ "$(jobs -rp | wc -l)" -ge "$MAX_CONCURRENT" ]; do
        sleep 1
    done
done < "$URL_FILE"

wait

echo "===== $(date --iso-8601=seconds) END =====" >> "$LOG"

# 微信通知
curl -s "$PUSH_URL" \
    -d "title=视频下载完成" \
    -d "desp=所有下载已完成" >/dev/null 2>&1

truncate -s 0 "$CURRENT_DIR/downloader.log"