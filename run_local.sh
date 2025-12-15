#!/bin/bash

# Ainski's Blog 本地运行脚本 (Linux 版)
# 确保已安装 Ruby 和 Jekyll

echo "正在启动 Ainski's Blog 本地服务器..."
echo "请确保已安装 Ruby 和 Jekyll"

# 检查 Ruby 是否安装
if ! command -v ruby &> /dev/null; then
    echo "错误: 未找到 Ruby，请先安装 Ruby"
    exit 1
fi

# 检查 Jekyll 是否安装
if ! command -v jekyll &> /dev/null; then
    echo "未找到 Jekyll，正在安装..."
    gem install jekyll bundler
fi

# 安装依赖（如果有 Gemfile）
if [ -f "Gemfile" ]; then
    echo "正在安装依赖..."
    bundle install
fi

# 启动 Jekyll 服务器
echo "正在启动本地服务器..."
echo
echo "本地服务器已启动！"
echo "请在浏览器中访问: http://localhost:4000 或 http://$(hostname -I | awk '{print $1}'):4000"
echo
jekyll serve --watch --incremental --host=0.0.0.0