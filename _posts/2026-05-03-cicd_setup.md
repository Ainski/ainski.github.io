---
layout: post
title: "cicd部署"
date:   2026-05-03
tags: [教程]
comments: true
author: Ainski
---

# 0 给服务器启动学术代理

（你承认这是你的个人博客了？)

虽然可以在服务器上专门设置一个代理，但是好像容易被抓（？） 我还是采用了本地电脑代理远程服务器的方式。

本地电脑设置 clash verge启动服务模式，启动局域网模式，点不了服务模式的点一下小盾牌安装一下就好了。![image-20260503153708433](./images/image-20260503153708433.png)

随后，在你的电脑上创建bat脚本如下，可以直接写好放到自己的磁盘当中，下一次可以直接用。以后直接运行这个脚本就可以启动服务器代理了。这个脚本是你每次启动都需要运行的。关了这个命令行窗口，就不会再代理了。

```bat
@echo off
ssh -R 127.0.0.1:7890:127.0.0.1:7890 ^
    -R 127.0.0.1:1080:127.0.0.1:7890 ^
42.192.3.159 -N
```

42.192.3.159是我的服务器，使用时替换为你自己的即可， 如果你不想被自己服务器的密码卡住，还是了解一下ssh秘钥免密登录服务器的相关内容吧，我不过多赘述了。

![image-20260503154249446](./images/image-20260503154249446.png)

随后，在服务器上将以下内容写入你的.bashrc或者.zshrc  当然，你也可以选择自己喜欢的端口使用。**此外你看到那个端口在使用，就看看服务器或者本地的端口是否开放了。**

```bash
# proxy-setup
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export no_proxy=localhost,127.0.0.1
```

此时运行下面的指令，应该能看到类似的结果。

```
(base) ubuntu@VM-4-12-ubuntu:~$ curl -I https://www.google.com
HTTP/1.1 200 Connection established

HTTP/2 200 
content-type: text/html; charset=ISO-8859-1
content-security-policy-report-only: object-src 'none';base-uri 'self';script-src 'nonce-M6WZKUxe1R4wIQ0excjFWw' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
accept-ch: Sec-CH-Prefers-Color-Scheme
p3p: CP="This is not a P3P policy! See g.co/p3phelp for more info."
date: Sun, 03 May 2026 07:35:14 GMT
server: gws
x-xss-protection: 0
x-frame-options: SAMEORIGIN
expires: Sun, 03 May 2026 07:35:14 GMT
cache-control: private
set-cookie: AEC=AaJma5u2fvZSrK9slKJkCL6GtiPX6PBuy5yK_xqqNayx0uVMnQ74qTtdNw; expires=Fri, 30-Oct-2026 07:35:14 GMT; path=/; domain=.google.com; Secure; HttpOnly; SameSite=lax
set-cookie: NID=531=a5ngu9RA1WG4t1sYUqZfVuMSR7thWTZRkGg-KEglqeCiF_KdGZIpn2rS8WfzRCUGXzw2xJazcxAsULFS-GbyKN8rGQMktrFSsKp8pCQx6ez7rmZH7_R1tcFe3-Asd37l2sU1DV7BqTLx1IHR2ipoj9DFYvsOvGHVMrW7z5caqCh-g-5D_Y-VBwnVXd4Z-azUsLRPVKjrpBBVauwwfJxwTS_QlzZ9ZKE; expires=Mon, 02-Nov-2026 07:35:14 GMT; path=/; domain=.google.com; HttpOnly
set-cookie: __Secure-BUCKET=CNAD; expires=Fri, 30-Oct-2026 07:35:14 GMT; path=/; domain=.google.com; Secure; HttpOnly
alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000
```



# 1 gitlabrunner 配置 

如果你有钱，可以充所使用git服务网址的会员，用他所提供的gitlab-runner

也可以使用自己的服务器作为gitlab-runner

先运行以下脚本，完成gitlab-runner 的下载 或者应当参考这个网站看，完成下载 [Gitlab-Runner部署全过程教程（指定版本安装、注册、卸载、后续配置等）_gitlab runner-CSDN博客](https://blog.csdn.net/zzg11/article/details/142926555)

```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

sudo apt install gitlab-runner 
```

# 2 添加runner

在gitlab你的项目当中会有一个cicd settings 的内容

![image-20260503182928871](./images/image-20260503182928871.png)

按照其指引正确设置即可

最后，你应当运行

```bash
sudo systemctl start gitlab-runner
```

最后，你应该能看到一个

![image-20260503190820883](./images/image-20260503190820883.png)

# 3 配置gitlab 相关变量

![image-20260503190754411](./images/image-20260503190754411.png)

![image-20260503190845402](./images/image-20260503190845402.png)

上面的内容哪里不一样，你就照着配置就完事了，很多，你要仔仔细细看。

注意，下面的SERVER_IP 就是你的目标服务器的ip地址，

对于SSH_PRIVATE_KEY 

  1. 在本地生成SSH密钥对（如果还没有）：
     ```bash
     ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f gitlab_deploy_key
     ```
  2. 获取私钥内容：
     ```bash
     cat ~/.ssh/gitlab_deploy_key
     ```
  3. 复制完整的私钥内容（包括`-----BEGIN RSA PRIVATE KEY-----`和`-----END RSA PRIVATE KEY-----`之间的所有内容）

现在你的项目应该是可以正确访问你的服务器的。

# 4 gitlabrunner用户设置

```shell
# 1. 把 gitlab-runner 加入 root 组（最高权限组）
sudo usermod -aG root gitlab-runner

# 2. 把 gitlab-runner 加入 ubuntu 组（读写你的项目目录）
sudo usermod -aG ubuntu gitlab-runner

# 3. 给 gitlab-runner 免密 sudo 权限（任意命令都能执行）
echo "gitlab-runner ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/gitlab-runner
sudo chmod 0440 /etc/sudoers.d/gitlab-runner
```

