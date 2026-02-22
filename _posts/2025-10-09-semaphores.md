---
layout: post
title: "semaphores 信号量机制"
date:   2025-10-09
tags: [教程,操作系统]
comments: true
author: Ainski
toc : true
---

<!-- more -->
`本文来源于操作系统第四版57页内容`
### 提出
dijistra哲学家问题
### 信号量的物理结构
#### 1. 整型信号量
``` c
wait(S){
    while(S<=0);
    S--;

}
Signal(S){
    S++;
}
```
S 表示某一种资源数目的总数
#### xxxxxxxxxx class Solution {public:    string intToRoman(int num) {        string input=to_string(num);        reverse(input.begin(),input.end());        while(input.size()<4) input.push_back('0');        reverse(input.begin(),input.end());        string res;​        char half[4]={'x','D','L','V'};        char full[4]={'M','C','X','I'};        for(int j=0;j<4;j++){            if(input[j]=='9'){                res+=full[j];                res+=full[j-1];            }            else if(input[j]>='5'){                res+=half[j];                for(char i='5';i<input[j];i++){                    res+=full[j];                }            }            else if(input[j]=='4'){                res+=full[j];                res+=half[j];            }            else {                for(char i='0';i<input[j];i++){                    res+=full[j];                }            }        }        return res;    }};c++
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
```
