---
layout: post
title: "redisserver配置"
date:   2025-10-07
tags: [教程,数据库]
comments: true
author: Ainski
---
<!-- more -->
## [教程参考于本网站](https://blog.csdn.net/qq_42146402/article/details/130204064)

## 服务器启动命令：
- redis-server
    1. 启动redis服务
    ```shell
    nohup redis-server &
    或者
    redis-server /path/to/redis.conf
    ```
    2. 停止redis服务
    ```shell
    redis-cli shutdown
    ```
