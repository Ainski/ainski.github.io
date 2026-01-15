---
layout: post
title: "应用层协议"
date:   2026-01-12
tags: [计算机网络]
comments: true
toc: true
author: Ainski
---

# 应用层协议

## 1 http/https

[借鉴]([HTTP 的发展 - HTTP | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Guides/Evolution_of_HTTP))

### 1.1 协议历程

http 协议是一种面向于client-server的协议，用于web浏览器来完成。满足了客户端与服务器，服务器与服务器之间的通信。

http在http2之前是人类可读的。例如

```http
GET / HTTP/1.1
Host: developer.mozilla.org
Accept-Language: zh
```

请求由以下元素组成：

| 字段 | 取值意义             |
| ---- | -------------------- |
| 方法 | Get/Post/Options     |
| url  | 不包括协议，域名端口 |

早期，http协议仅仅支持单行协议。由于其高可扩展性，被迅速广泛使用。

狭义的  [RFC1945](https://datatracker.ietf.org/doc/html/rfc1945)  被发表，但是仍然不是官方标准。

随后，http 1.1 补充了更多的内容

- 连接可以复用，节省了多次打开 TCP 连接加载网页文档资源的时间。
- 增加管线化技术，允许在第一个应答被完全发送之前就发送第二个请求，以降低通信延迟。
- 支持响应分块。
- 引入额外的缓存控制机制。
- 引入内容协商机制，包括语言、编码、类型等。并允许客户端和服务器之间约定以最合适的内容进行交换。
- 凭借 [`Host`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Reference/Headers/Host) 标头，能够使不同域名配置在同一个 IP 地址的服务器上。



更以后 http 2 http 3以此发表，建立了更贱健全的机制保证数据安全箱。最终，http1.1以其简洁性和https以其安全性得以保存。

### 1.2 如何发送一个请求

如果想要获取`http://42.192.3.159:5173` 的主界面，那么需要发布如下的内容。

```http
GET / HTTP/1.1
Host: 42.192.3.159
Accept-Language: fr #Franch
```

标头当中没有content-length 数据块为空，否则，要补充数据块。补充数据块和前面的标头用空行分隔。

> 我感觉大不如json格式的请求。

如果请求当中包含了数据块内容，就要加入正确地数据格式来完成发送。

```http
POST / HTTP/1.1
Host:
```

