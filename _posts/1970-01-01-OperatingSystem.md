---
layout: post
title: "操操操作系统"
date:   1970-01-01
tags: [学校课程复习,操作系统]
comments: true
toc: true
author: Ainski
---
任课老师：Fang
---

# 中断
## 外设控制器
发出中断请求信号的外设控制器是中断源。系统为每一个可以发出中断请求的外设分配一个唯一的标识符，称此标识符为中断号。
## CPU对某个中断请求作出相应后会获得
- 相应的中断处理程序的入口地址
- 中断处理时处理机的状态字
## 中断的硬件机构
2块级联的8259A芯片

## 中断的一般处理流程
- 硬件中断响应
- 保存运行现场
- 中断处理函数
- 恢复现场
- 中断返回
## 中断优先级与中断嵌套
- 每一个中断源有一个中断优先级
- 多个中断有限响应高优先级中断
- 关中断下不响应任何中断
- 开中断下可以被高优先级的中断打断

# 异常
## 类型
- 程序出错
    包括：算术溢出，除数为0，试图执行非法指令，访问到不允许访问的位置，访问存储在磁盘上的指令和数据（可以通过虚拟存储器解决）
- 硬件故障
    奇偶校验错或者掉电等等
- Debug

# 进程
## UnixV6++ 进程类图
```mermaid
classDiagram
class ProcessManager{
    Process porcess[NRPOC] 进程基本控制数组
    Text test[NTEXT] 代码控制块数组
    int CurPri 先运行占用CPU时优先数
    int RunRun 强迫调度标志
    int RunIn 进程中无合适进程可以调出到磁盘交换区
    int RunOut 磁盘交换区无进程可以调入内存
    int ExeCnt 同时进行图像改换的进程数
    int SwtchNum 系统中进程切换次数
}
class Process{
    short p_uid 用户ID
    int p_pid 进程ID
    int p_ppid 父进程ID
    unsigned long p_addr ppda区在物理内存中的起始地址
    unsigned int p_size 进程图像的长度以字节为单位
    Text* p_textp 指向该进程代码段的段描述符
    ProcessState p_state 进程状态
    int p_flag 进程标志
    int p_pri 进程优先级
    int p_cpu CPU值
    int p_nice 进程优先级偏置值
    int p_time 进程在磁盘交换区或者内存上的驻留时间
    unsigned long p_wchan 进程睡眠原因
    int p_sig 进程接收到的信号
    TTy* p_ttyp 进程tty结构地址
    void Nice() 用户设置计算进程优先数偏置值
    void SetPri() 根据占用CPU时间计算进程优先数
    void SetRun() 设置进程为运行态
    bool IsSleepOn(unsigned long chan) 判断进程睡眠原因是否为chan
    void Sleep(unsigned long chan, int pri) 进程睡眠
    void Expand(unsigned int  newSize) 改变进程占用的内存大小
    void Exit() Exit系统调用处理过程
    void Clone(Process& proc) 除了p_pid，子进程拷贝父进程Process结构
    void SBreak() brk系统调用处理过程
    void Psig(struct pt_context* pContext) 对当前进程接收到的信号进行处理
    void PSignal(int signal) 向当前进程发送信号。signal是要发送到俄信号书
    void Ssig() 设置用户自定西的信号处理方式的系统调用处理函数
    int IsSig() 检查是否有信号到达当前进程
}
class User{
    short u_uid 有效用户ID
    short u_gid 有效组
    short u_ruid 真实用户ID
    short u_rgid 真实组ID
    int u_time 进程用户态时间
    int u_stime 进程核心态时间
    int u_cutime 进程用户态时间总和
    int u_cstime 进程核心态时间总和
    
    unsigned long u_rsav[2] 用于保护esp与ebp指针
    unsigned long u_ssav[2] 用户二次保护esp与ebp指针

    Process* u_procp 指向当前进程的指针
    MemoryDescriptor* u_MemoryDescriptor 进程图像的内存信息
    static const int EAX = 0 访问线程保护区中的EAX寄存器的偏移量
    unsigned int * u_ar0 指向核心栈现场保护区EAX寄存区存放的栈单元
    int u_arg[5] 存放当前系统调用参数
    char* u_dirp 系统调用参数（pathname）的指针
    ...

}
class Text {
    int x_daddr 代码段在磁盘交换区上的地址
    unsigned long x_caddr 代码段在物理内存中的起始地址
    unsigned int x_size 代码段的长度
    Inode* x_ipdr 内存inode地址
    unsigned int x_count 共享该代码段的进程数
    unsigned short x_ccount 共享该代码段且图像在内存的进程数
}
class Inode{
}

class MemoryDescriptor{
}
class DirectoryEntry{
}
class IOParameter{
}
class OpenFiles{
}
Process *-- ProcessManager
Text *-- ProcessManager
Process -- User
User -- MemoryDescriptor
User -- DirectoryEntry
User -- IOParameter
User -- OpenFiles
Text -- Inode
```
    # 5 进程管理
## 5.1 进程的调度状态和状态转换
### swtch 函数
#### 就绪状态进程的特点
 - p_stat = SRUN
 - p_flag 包含 SLOAD标志
 - p_wchan = 0
当前运行的进程除了有就绪进程的特点以外，还有
 - cpu是当前进程的用户现场
 - cr3 寄存器登记这该进程的地址映射方式 即0x201号页框中的1023号页表项指向了这个进程的ppda区，同时0x202和0x203等记者该用户页表。
 - p_pri >= 100

#### 高优先级睡眠和低优先级睡眠的区别
|高优先级|低优先级|
|-------|---------|
|-100<=p_pri<0|0<=p_pri<100|
|等待快速设备的系统中断|等待低速设备的系统中断（鼠标）|
|SSLEEP|SWAIT|


- 睡眠状态会有
    - p_stat = SSLEEP/SWAIT
    - p_flags  拥有sload 标志位，表示进程在内存当中
    - p_wchan 记录了一个变量的地址
    - p_pri<0

    - 核心栈帧
        |栈帧|
        |--|
        |swait|
        |sleep|
        |外设栈帧|
        |Trap|
        |一次中断响应的栈帧|
- 唤醒之后会有
    - p_stat = SRUN
    - p_wchan = 0
    这个过程由WakeUpAll完成
#### 核心态就绪和用户态就绪

|核心态就绪|用户态就绪|
|-------|---------|
|p_pri<=100|p_pri>=100|
|用于等待io中断，是非抢占调度的结果|由于cpu占用时间过程，是抢占式调度的结果|

因此p_pri重算的过程中，不会重算核心态就绪的p_pri值，因为他们是人工设置得来的。而用户态就绪的是计算而来的。

- 由于系统调用睡眠的进程，它最近一次上台的机会是什么？
 
 当前cpu上的运行进程最近的一次例行调度。

### schedule 函数
#### 如果内存不足以容纳所有的进程？
更换优先级：
低睡>高睡>就绪

低谁和高睡在换出之后不会再换回来，只有到了就绪的状态才会回来。

### newProc 函数
新进程的 p_pri = 0
