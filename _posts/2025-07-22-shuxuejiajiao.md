---
layout: post
title: "数学家教"
date:   2025-06-29
tags: [杂项]
comments: false
toc: true
author: Ainski
---

# 数学家教

## 阿基米德多面体

这里提供13个阿基米德多面体的图像以供感知。[Archimedean](https://cn.mathigon.org/step/polyhedra/archimedean)  
![13个阿基米德多面体](../images/2025-07-22-ArchimedeanSolids_1000.svg)
### 定义
由两种或多种不同类型的非相交正凸多边形以相同的方式围绕每个顶点排列，且所有边都具有相同的长度


### 性质
- 阿基米德立体都能够被正四面体外接，使得它们的四个面位于该四面体的面上。  
    - 尝试证明`cuboctahedron`满足如此性质

- 阿基米德立体满足  
    $$(2\pi-\sigma)\times V = 4\pi$$ 
  其中$\sigma$为顶点处面角的总和，$V$为顶点数。
    - 尝试证明`icosidodecahedron`满足如此性质

- 设 $r_d$ 为对偶多面体的内半径（对应于内切球，内切球与对偶立体的面相切），$\rho=\rho_d$ 为多面体及其对偶的中间半径（对应于中切球，中切球与多面体及其对偶的边都相切），$R$ 为阿基米德立体的外接球半径（对应于立体的外接球，外接球与立体的顶点相切），$a$ 为立体的边长。由于外接球和内切球彼此对偶，它们遵循以下关系
    $$
    R \times r_d = \rho^2
    $$
    此外，仍有性质：
    - $$ R = \frac{1}{2}(r_d + \sqrt{r_d^2+a^2} ) = \sqrt{\rho^2+\frac{1}{4}a^2} $$
    - $$ r_d = \frac{\rho^2}{\sqrt{\rho^2+\frac{1}{4}a^2}}=\frac{R^2-\frac{1}{4}a^2}{R} $$
    - $$ \rho = \frac{\sqrt{2}}{2}\sqrt{r_d^2+r_d\sqrt{r_d^2+a^2}}=\sqrt{R^2-\frac{1}{4}a^2}$$
    - 尝试证明`truncated tetrahedron`满足如此性质