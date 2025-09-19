#!/bin/bash
LOCALDIR="$(cd "$(dirname "$0")" && pwd)"
# webDav url 例如：http://ip:port/path/
REMOTEURL=""
# webDav用户名
USER=""
# webDav密码
PASS=""

for f in "$LOCALDIR"/*; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    echo "上传 $fname ..."
    curl -T "$f" -u "$USER:$PASS" "$REMOTEURL$fname"
done