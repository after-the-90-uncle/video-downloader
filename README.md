# 自动下载视频工具

## 安装 yt-dlp 工具
```
1. 无环境 install.sh 直接执行安装
2. 有环境 把start.sh YT 变量换成自己的目录
```
## 配置 urls.txt
```
可同时配置多个
https://www.xxx.com/aa.m3u8 测试.mp4
https://www.xxx.com/aa.m3u8 测试.mp4

默认下载完成会删除对应的行
```

## 启动
```
./start.sh &
默认下载完会自动推送到定义的webdav上 upload完成后 会自动删除 可自行修改
默认下载完成会自动清空日志
视频下载完成会自动 利用server酱 推送微信提示
```
## 输出
```
downloads 目录下
```

## 注意
```
upload.sh 目前没有用 如果上传失败 可以使用此脚本 手动执行上传
```