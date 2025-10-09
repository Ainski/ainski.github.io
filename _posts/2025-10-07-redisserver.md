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
    redis-cli shutdown -a [pwd]
    ```



# 超详细Redis入门教程——Redis的安装与配置
## 一、Redis的安装（Linux系统）
### 1. 克隆并配置主机
- 修改主机名：通过编辑`/etc/hostname`文件实现。
- 修改网络配置：编辑`/etc/sysconfig/network-scripts/ifcfg-ens33`文件进行配置。

### 2. 安装前的准备工作
#### （1）安装gcc
Redis由C/C++编写，官网下载的安装包需编译后才能安装，因此需安装编译器gcc与gcc-c++（CentOS7默认未安装）。
执行命令：`[root@redis0s ~]# yum -y install gcc gcc-c++`
其中，GCC（GNU Compiler Collection）是GNU编译器集合。

#### （2）下载Redis
Redis官网为http://redis.io，进入官网可直接下载。文中以稳定版本Redis 7.0.3为例，该版本包含多个新的用户功能、显著的性能优化及其他改进，也存在可能与旧版本不兼容的变更，下载文件为`redis-7.0.3.tar.gz`。

#### （3）上传到Linux
将下载好的`redis-7.0.3.tar.gz`压缩包上传至Linux的`/opt/tools`目录。

### 3. 安装Redis
#### （1）解压Redis
- 执行命令`[root@redis0S tools]# tar -zxvf redis-7.0.3.tar.gz -C /opt/apps/`，将Redis解压到`/opt/apps`目录。
- 进入`/opt/apps`目录，执行`[root@redis0S apps]# mv redis-7.0.3/ redis`，将解压包目录更名为`redis`（不更名也可）。

#### （2）编译
进入`/opt/apps/redis`解压目录，执行`[root@redis0S redis]# make`命令进行编译。当出现“INSTALL redis-check-rdb INSTALL redis-check-aof Hint: It's a good idea to run 'make test' ;) make[1]:离开目录"/opt/apps/redis/src"”提示时，表明编译成功。编译依据解压包中自带的Makefile文件进行。

#### （3）安装
在Linux系统中，对编译过的安装包执行`make install`命令安装。
执行命令：`[root@redis0S redis]# make install`
安装完成后，会生成三个组件：redis服务器（`redis-server`）、客户端（`redis-cli`）以及性能测试工具benchmark（`redis-benchmark`）。

#### （4）查看bin目录
安装完成后，`/usr/local/bin`目录会新增多个文件，执行`[root@redis0S redis]# ll /usr/local/bin/`可查看，主要包括`redis-benchmark`、`redis-cli`、`redis-server`等，且部分文件为软链接（如`redis-check-aof -> redis-server`、`redis-check-rdb -> redis-server`、`redis-sentinel -> redis-server`）。
执行`[root@redis0S redis]# echo $PATH`，可发现`/usr/local/bin`目录在系统变量中，因此这些命令可在任意目录执行。

### 4. Redis启动与停止
#### （1）前台启动
在任意目录执行`redis-server`命令即可启动Redis，此启动方式会占用当前命令行窗口。
启动后，新开启一个会话窗口，执行`[root@redis0s ~]# ps aux| grep redis`，可查看当前Redis进程，默认端口号为6379。
通过`Ctrl + C`命令可停止Redis。

#### （2）命令式后台启动
使用`nohup`命令并在末尾加`&`符，可使Redis以守护进程方式在后台运行，且会在当前目录创建`nohup.out`文件记录操作日志。
执行命令：`[root@redis0S redis]# nohup redis-server &`，执行后会出现“[1]6996 root@redis0S redis]# nohup:忽略输入并把输出追加到"nohup.out"”提示。

#### （3）Redis的停止
执行`[root@redis0s redis]# redis-cli shutdown`命令，可停止Redis，执行后会显示“[1]+完成 nohup redis-server”。

#### （4）配置式后台启动
- 修改配置文件：编辑Redis安装目录根下的`redis.conf`文件，将`daemonize`属性值由`no`改为`yes`，使Redis以守护进程方式运行（修改后文件中相关内容为“309 daemonize yes”）。
- 启动Redis：修改配置后，启动时无需再输入`nohup`与`&`符，但需指定配置文件，执行命令`[root@redis0s redis]# redis-server redis.conf`。
原因：`nohup redis-server &`命令启动时，Redis按默认参数启动；而修改配置文件后，需指定加载该配置文件，使配置文件中的参数覆盖默认值。Redis安装目录根下的`redis.conf`为配置文件模板。


## 二、连接前的配置
要使远程主机客户端能连接并访问Redis服务端，需进行以下配置：

### 1. 绑定客户端IP
Redis可通过修改配置文件限定可访问的客户端IP。默认配置`bind 127.0.0.1 -::1`仅允许当前主机访问，若要允许所有客户端访问，将该行注释掉即可（注释后为“# bind 127.0.0.1 -::1”）。

### 2. 关闭保护模式
默认保护模式开启，仅允许本机客户端访问，生产环境中需关闭以确保其他客户端可连接。
修改`redis.conf`文件，将`protected-mode`设置为`no`，即“111 protected-mode no”。

### 3. 设置访问密码
设置访问密码可对读写Redis的用户进行身份验证，无密码用户可登录但无法访问。
#### （1）密码设置
在`redis.conf`配置文件中设置，默认该配置被注释，无密码。取消注释并设置密码，如“1036 requirepass 111”（密码设为111）。无密码登录时，执行`set`、`get`等操作会提示“(error) NOAUTH Authentication required.”。

#### （2）使用密码
- 登录时未使用密码：登录后执行`127.0.0.1:6379> auth 111`，验证通过后即可正常操作（如`set name sh`、`get name`）。
- 登录时使用密码：执行`[root@redis0S redis]# redis-cli -a 111`，会出现“Warning: Using a password with '-a'or'-u' option t be safe.”提示，登录后可直接操作。
- 退出时使用密码：执行`[root@redis0S redis]# redis-cli -a 111 shutdown`，同样会有上述安全提示。

#### （3）注意
为方便后续介绍，可将密码配置注释掉（即“1036 # requirepass 111”），此时无需密码即可访问。

### 4. 禁止/重命名命令
`flushall`与`flushdb`命令危险，可删除整个Redis数据库，可通过修改`redis.conf`文件禁止或重命名这些命令。例如，添加“# rename-command flushall "=" # rename-command flushdb "="”可禁用这两个命令（学习过程中可暂时不禁用）。

### 5. 启动Redis
完成上述配置后，执行`[root@redis0S redis]# redis-server redis.conf`命令启动Redis，确保客户端可连接。


## 三、Redis客户端分类
Redis客户端与MySQL客户端类似，主要分为以下三类：

### 1. 命令行客户端
Redis提供基本的命令行客户端，打开命令的命令为`redis-cli`。
- 指定IP和端口连接：执行`[root@redis0S redis]# redis-cli -h 127.0.0.1 -p 6379`，其中`-h`指定Redis服务器IP，`-p`指定端口号。
- 简化连接：若连接本机Redis且端口为默认的6379，可省略`-h`与`-p`选项，直接执行`redis-cli`。

### 2. 图形界面客户端
#### （1）Redis Desktop Manager
较知名的图形界面客户端，原本免费，从0.8.8版本后变为商业化收费软件，官网为https://resp.app/。

#### （2）RedisPlus
开源免费的桌面客户端软件，支持Windows、Linux、Mac三大系统平台，具有高效、便捷的使用体验和现代化的用户界面风格，官网地址为https://gitee.com/MaxBill/RedisPlus。

### 3. Java代码客户端
Java代码客户端是操作Redis的API，类似JDBC，实质是提供操作接口的一个或多个Jar包。
常用的API有jdbc-redis、jredis等，其中最常用且知名的是Jedis。


## 四、Redis配置文件详解
Redis核心配置文件`redis.conf`位于安装根目录，默认含2000多行内容，按功能分为多个部分，以下介绍重要部分：

### 1. 基础说明
- 启动配置文件：启动Redis需指定配置文件路径，命令格式为`./redis-server /path/to/redis.conf`。
- 容量单位：配置文件中容量单位表示及含义如下：
  - `1k`=1000字节，`1kb`=1024字节；
  - `1m`=1000000字节，`1mb`=1024×1024字节；
  - `1g`=1000000000字节，`1gb`=1024×1024×1024字节。
- 单位大小写：容量单位不区分大小写，如`1GB`、`1Gb`、`1gB`含义相同。

### 2. includes
该部分用于指定在当前配置文件中包含的其他配置文件，便于配置信息管理，可将不同场景配置单独定义，再在核心配置文件中根据场景选择包含。
示例配置：
```
include /path/to/local.conf
include /path/to/other.conf
include /path/to/fragments/*.conf
```
注意：`include`选项不会被`CONFIG REWRITE`命令重写；为避免运行时覆盖配置更改，建议将`include`放在文件开头；若需用`include`覆盖配置选项，可将其放在文件末尾。此外，包含路径可含通配符，匹配的文件会按字母顺序包含，若路径含通配符但启动时无匹配文件，`include`语句会被忽略且不报错。

### 3. modules
通过该部分在启动时加载第三方模块，以增强、扩展Redis功能。若服务器无法加载模块，会终止启动，可使用多个`loadmodule`指令加载多个模块。
示例配置（需取消注释并指定模块路径）：
```
# loadmodule /path/to/my_module.so
# loadmodule /path/to/other_module.so
```

### 4. network（网络相关配置）
#### （1）bind
指定可访问Redis服务的客户端IP，默认`bind 127.0.0.1 -::1`，仅允许本地访问。若要允许所有客户端访问，需将该行注释。若取消注释且不限制客户端，需确保设置密码或禁用保护模式。

#### （2）protected-mode
默认开启保护模式，仅允许本机客户端访问。若确定要让其他主机客户端连接（即使未配置认证），需将其设为`no`（`protected-mode no`），生产环境通常需关闭。

#### （3）port
Redis监听的连接端口号，默认6379（IANA #815344）。若指定端口为0，Redis将不监听TCP套接字。

#### （4）tcp-backlog
TCP连接队列，用于解决高并发场景下客户端慢连接问题，配置值为队列长度，与TCP三次握手相关。
- 不同Linux内核队列差异：
  - Linux内核2.2版本前：队列存放已完成第一次握手的客户端连接，含未完成（SYN_RECEIVED状态）和已完成（ESTABLISHED状态）三次握手的连接，仅ESTABLISHED状态连接会被Redis处理。
  - Linux内核2.2版本后：维护SYN_RECEIVED队列（存未完成三次握手连接）和ESTABLISHED队列（存已完成三次握手连接），此时`tcp-backlog`对应ESTABLISHED队列。
- 查看Linux内核版本：执行`[root@redis ~]# uname -a`或`[root@redis ~]# cat /proc/version`。
- 与内核参数关系：Linux中TCP的`backlog`队列长度由内核参数`somaxconn`决定，Redis中该队列长度取配置文件设置与`somaxconn`的最小值。
- 查看与修改`somaxconn`：
  - 查看：执行`[root@redis ~]# cat /proc/sys/net/core/somaxconn`，默认值通常为128。
  - 修改：编辑`/etc/sysctl.conf`文件，在末尾添加`net.core.somaxconn=2048`，执行`[root@redis ~]# sysctl -p`使修改生效，生产高并发场景建议增大该值。

#### （5）timeout
客户端与Redis的空闲超时时间，单位为秒。当空闲时间超过该值，连接自动断开，默认值为0，表示永远不超时。

#### （6）tcp-keepalive
用于设置Redis检测与其连接的所有客户端存活性的时间间隔，单位为秒，默认300秒（Redis 3.2.1及以后版本默认值），一般在`timeout`设为0时配置。

### 5. general
#### （1）daemonize
控制Redis启动是否采用守护进程方式（后台启动），默认`no`，设为`yes`则以后台方式启动（`daemonize yes`）。当Redis由upstart或systemd管理时，该参数无效，且以守护进程方式启动时，Redis会在`/var/run/redis.pid`写入pid文件。

#### （2）pidfile
指定Redis运行时pid写入的文件，无论是否以守护进程方式启动，pid都会写入该文件。示例配置为`pidfile /var/run/redis_6379.pid`（现代Linux系统建议用`/run/redis.pid`）。
若未配置pid文件：
- 以守护进程方式启动（`daemonize=yes`）：pid文件为`/var/run/redis.pid`。
- 前台启动（`daemonize=no`）：不生成pid文件。

#### （3）loglevel
配置日志级别，Redis有四个级别（由低到高）：
- `debug`：输出大量信息，适用于开发和测试。
- `verbose`：输出较多不太有用的信息，信息量少于`debug`。
- `notice`：输出生产环境所需的适量信息，为默认级别。
- `warning`：仅记录非常重要/关键的信息。
配置示例：`loglevel notice`。

#### （4）logfile
指定日志文件，若设为空串，日志强制记录到标准输出设备（显示器）；若以守护进程方式启动且设为空串，日志会发送到`/dev/null`（空设备）。配置示例：`logfile ""`（默认空串）。

#### （5）databases
设置数据库数量，默认16个，默认使用0号数据库。可通过`select <dbid>`命令（`dbid`为0到`databases-1`的整数）在每个连接基础上选择不同数据库。配置示例：`databases 16`。

### 6. security
该部分用于用户ACL权限、Redis访问密码相关配置，最常用的是`requirepass`属性。
- 注意事项：Redis 6及以后版本中，`requirepass`是新ACL系统之上的兼容层，仅用于设置默认用户密码，客户端仍可通过`AUTH <password>`或`AUTH default <password>`认证。
- 兼容性：`requirepass`与`aclfile`选项和`ACL LOAD`命令不兼容，若使用后两者，`requirepass`会被忽略。
- 配置示例：`requirepass 111`（设置访问密码为111，注释后无密码）。

### 7. clients
仅含`maxclients`属性，用于设置Redis可并发处理的客户端连接数量，默认10000。若Redis无法将进程文件限制配置为指定值，最大允许连接数会设为当前文件限制减32（Redis预留部分文件描述符供内部使用）。当达到最大连接数，Redis会拒绝新连接并返回“max number of clients reached”错误。
- 限制：该值不能超过Linux系统支持的可打开文件描述符最大数量阈值，执行`[root@redis ~]# ulimit -n`可查看阈值（默认通常为1024），修改需编辑`/etc/security/limits.conf`文件（具体方法需自行查询）。
- 集群注意：使用Redis集群时，最大连接数还与集群总线共享，集群中每个节点使用两个连接（一个入站、一个出站），大型集群需相应调整该值。

### 8. memory management（内存管理）
#### （1）maxmemory
设置Redis可使用的最大内存字节数。当达到内存限制时，Redis会根据`maxmemory-policy`逐出策略尝试删除符合条件的key。若无法按策略移除key，写操作命令会返回错误，但只读命令不受影响。
- 副本建议：若有副本连接，建议降低`maxmemory`值，为副本输出缓冲区预留系统空闲内存（若策略为`noeviction`则无需此操作）。
- 配置示例：`maxmemory <bytes>`（需替换`<bytes>`为具体数值，如`maxmemory 1gb`）。

#### （2）maxmemory-policy
当达到`maxmemory`时，Redis选择删除内容的策略，若无符合策略的内容可删，写操作会返回错误。支持8种策略：
|策略|说明|
| ---- | ---- |
|volatile-lru|使用近似LRU（最近最少使用）算法移除，仅适用于设置了过期时间的key|
|allkeys-lru|使用近似LRU算法移除，适用于所有类型的key|
|volatile-lfu|使用近似LFU（最不经常使用）算法移除，仅适用于设置了过期时间的key|
|allkeys-lfu|使用近似LFU算法移除，适用于所有类型的key|
|volatile-random|随机移除，仅适用于设置了过期时间的key|
|allkeys-random|随机移除，适用于所有类型的key|
|volatile-ttl|移除距离过期时间最近（TTL最小）的key|
|noeviction|不移除任何内容，写操作返回错误，为默认值|
注：LRU、LFU和volatile-ttl均通过近似随机算法实现；需内存的写操作（如SET、INCR、HSET等）会受影响，只读操作不受影响。

#### （3）maxmemory-samples
指定挑选要删除key的样本数量，样本选择采用LRU算法（不可修改），从样本中选择移除的key采用`maxmemory-policy`指定的策略。
- 取值影响：默认值5可产生较好效果；10接近真实LRU但占用更多CPU；3速度快但准确性低。
- 配置示例：`maxmemory-samples 5`。

#### （4）maxmemory-eviction-tenacity
设置移除容忍度，数值越小，容忍度越低，需移除数据的移除延迟越小；数值越大，容忍度越高，移除延迟越大。取值范围为0-100，0表示最小延迟，10为默认值，100表示不考虑延迟处理。
- 场景调整：若写流量异常大，需增大该值；若需降低延迟，可减小该值（需承担移除处理效果下降的风险）。
- 配置示例：`maxmemory-eviction-tenacity 10`。

### 9. threaded I/O（多线程IO配置）
Redis主要为单线程，但部分操作（如UNLINK、慢IO访问等）支持多线程，该部分配置多线程IO模型支持。

#### （1）io-threads
指定启用多线程IO模型时使用的线程数量，默认禁用多线程。
- 启用建议：仅在至少4核CPU的机器上启用，且预留至少1个空闲核心；超过8个线程通常无明显帮助；仅当Redis实例CPU占用率高、存在性能问题时启用，否则无需使用。
- 线程数选择：4核机器建议用2-3个IO线程，8核机器建议用6个线程。
- 查看CPU数量：执行`[root@redis ~]# lscpu`命令。
- 配置示例：`io-threads <num>`（需替换`<num>`为具体线程数，如`io-threads 4`）。

#### （2）io-threads-do-reads
启用多线程IO模型中多线程处理读请求的能力，默认`no`（不启用）。
- 说明：`io-threads`设为1时，仍使用主线程；启用IO线程时，默认仅用线程处理写操作（线程化write(2)系统调用，将客户端缓冲区传输到套接字）；设为`yes`可启用多线程处理读请求和协议解析，但通常多线程处理读请求帮助不大。
- 配置示例：`io-threads-do-reads no`。