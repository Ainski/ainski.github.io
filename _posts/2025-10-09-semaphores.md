---
layout: post
title: "semaphores 信号量机制"
date:   2025-10-09
tags: [教程,操作系统]
comments: true
author: Ainski
---
<!-- more -->
`本文来源于操作系统第四版57页内容`
### 提出
dijistra哲学家问题
### 信号量的物理结构
#### 1. 整形信号量
```c
typedef struct{
    int value;
    struct process_control_block *list;

}semaphores;
wait(semaphores *S){
    S->value--;
    if (S->value<0) block(S->list);
}
signal(semaphore *S){
    S->value++;
    if(S->value<=0) wakeup(S->list);
}