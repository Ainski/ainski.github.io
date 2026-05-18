---
layout: post
title: "ll1算法"
date:   2026-04-03
tags: [编译原理,学校课程复习]
comments: true
author: Ainski
---

# LL(1) 算法简述
LL(1) 是一种**自顶向下、无回溯**的语法分析算法，用于判断给定输入串是否符合某上下文无关文法（CFG）。

- 第一个 **L**：从左到右扫描输入串
- 第二个 **L**：最左推导（Leftmost derivation）
- **(1)**：**向前看 1 个终结符**就决定选用哪条产生式

## 核心条件
文法是 LL(1) 的充要条件：
对任意产生式 $A \to \alpha \mid \beta$：

1. $FIRST(\alpha) \cap FIRST(\beta) = \emptyset$
2. 若 $\beta \Rightarrow \varepsilon$，则 $FIRST(\alpha) \cap FOLLOW(A) = \emptyset$

也就是说，FOLLOW集的使用仅仅在当前 变量  可以匹配 $\varepsilon$的时候才能起作用。

## 关键步骤
1. 对每个非终结符求 **FIRST 集**（推导开头能出现的终结符）
2. 求 **FOLLOW 集**（可能跟在该符号后面的终结符）
3. 构造 **LL(1) 分析表** $M[A,a]$
4. 使用**分析栈**，查表进行匹配/推导，直到栈空且输入结束



# LL(\*) allstar 算法

能够处理任何文法包括 二义性文法， 除了间接左递归
