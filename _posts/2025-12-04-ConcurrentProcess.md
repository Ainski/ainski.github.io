---
layout: post
title: "unix进程图像的交换"
date: 2025-12-04
tags: [学校课程复习,操作系统]
comments: true
author: Ainski
---

## swap函数

```c++
	enum BufFlag	/* b_flags中标志位 */
	{
		B_WRITE = 0x1,		/* 写操作。将缓存中的信息写到硬盘上去 */
		B_READ	= 0x2,		/* 读操作。从盘读取信息到缓存中 */
		B_DONE	= 0x4,		/* I/O操作结束 */
		B_ERROR	= 0x8,		/* I/O因出错而终止 */
		B_BUSY	= 0x10,		/* 相应缓存正在使用中 */
		B_WANTED = 0x20,	/* 有进程正在等待使用该buf管理的资源，清B_BUSY标志时，要唤醒这种进程 */
		B_ASYNC	= 0x40,		/* 异步I/O，不需要等待其结束 */
		B_DELWRI = 0x80		/* 延迟写，在相应缓存要移做他用时，再将其内容写到相应块设备上 */
	};
    bool Swap(int blkno, unsigned long addr, int count, enum Buf::BufFlag flag);
	/* Swap I/O 用于进程图像在内存和盘交换区之间传输
	 * blkno: 交换区中盘块号；addr:  进程图像(传送部分)内存起始地址；
     * count: 进行传输字节数，byte为单位；传输方向flag: 内存->交换区 or 交换区->内存。 */
bool BufferManager::Swap(int blkno, unsigned long addr, int count, enum Buf::BufFlag flag)
{
	User& u = Kernel::Instance().GetUser();

	X86Assembly::CLI();

	/* swbuf正在被其它进程使用，则睡眠等待 */
	while ( this->SwBuf.b_flags & Buf::B_BUSY )
	{
		this->SwBuf.b_flags |= Buf::B_WANTED;
		u.u_procp->Sleep((unsigned long)&SwBuf, ProcessManager::PSWP);
	}

	this->SwBuf.b_flags = Buf::B_BUSY | flag;
	this->SwBuf.b_dev = DeviceManager::ROOTDEV;
	this->SwBuf.b_wcount = count;
	this->SwBuf.b_blkno = blkno;
	/* b_addr指向要传输部分的内存首地址 */
	this->SwBuf.b_addr = (unsigned char *)addr;
	this->m_DeviceManager->GetBlockDevice(Utility::GetMajor(this->SwBuf.b_dev)).Strategy(&this->SwBuf);

	/* 关中断进行B_DONE标志的检查 */
	X86Assembly::CLI();
	/* 这里Sleep()等同于同步I/O中IOWait()的效果 */
	while ( (this->SwBuf.b_flags & Buf::B_DONE) == 0 )
	{
		u.u_procp->Sleep((unsigned long)&SwBuf, ProcessManager::PSWP);
	}

	/* 这里Wakeup()等同于Brelse()的效果 */
	if ( this->SwBuf.b_flags & Buf::B_WANTED )
	{
		Kernel::Instance().GetProcessManager().WakeUpAll((unsigned long)&SwBuf);
	}
	X86Assembly::STI();
	this->SwBuf.b_flags &= ~(Buf::B_BUSY | Buf::B_WANTED);

	if ( this->SwBuf.b_flags & Buf::B_ERROR )
	{
		return false;
	}
	return true;
}
```
- 一次和磁盘的交互都是512字节，因为一个盘块是512字节，因此count应当小于等于512字节
## 发生内存交换的情况
### 当内存空间不足以装下所有就绪进程

```c++
	/* 
	 * 进程图像内存和交换区之间的传送。如果有进程想要换入内存，而内存
	 * 中无法找到能够容纳该进程的连续内存区，则依次将低优先权睡眠状态(SWAIT)-->
	 * 暂停状态(SSTOP)-->高优先权睡眠状态(SSLEEP)-->就绪状态(SRUN)进程换出，
	 * 直到腾出足够内存空间将想要换入的进程调入内存
	 */
	void Sched();
    void ProcessManager::Sched()
{
	Process* pSelected;
	User& u = Kernel::Instance().GetUser();
	int seconds;
	unsigned int size;
	unsigned long desAddress;

	/* 
	 * 选择在交换区驻留时间最长，处于就绪状态的进程换入
	 */
	goto loop;

sloop:
	this->RunIn++;
	u.u_procp->Sleep((unsigned long)&RunIn, ProcessManager::PSWP);

loop:
	X86Assembly::CLI();
	seconds = -1;
	for ( int i = 0; i < ProcessManager::NPROC; i++ )
	{
		if ( this->process[i].p_stat == Process::SRUN 
        && (this->process[i].p_flag & Process::SLOAD) == 0 
        && this->process[i].p_time > seconds )
		{
			pSelected = &(this->process[i]);
			seconds = pSelected->p_time;
		}
	}

	/* 如果没有符合条件的进程，0#进程睡眠等待有需要换入的进程 */
	if ( -1 == seconds )
	{
		this->RunOut++;
		u.u_procp->Sleep((unsigned long)&RunOut, ProcessManager::PSWP);
		goto loop;
	}

	/* 如果有进程满足条件，需要换入，则检查是否有足够内存 */
	X86Assembly::STI();
	/* 计算进程换入需要的内存大小 */
	size = pSelected->p_size;
	/* 
	 * 如果存在共享正文段，但是没有进程图像在内存中，引用该正文段的进程，
	 * 即共享正文段不再内存中，换入时需要读入正文段在交换区中的副本
	 */
	if ( pSelected->p_textp != NULL && 0 == pSelected->p_textp->x_ccount )
	{
		size += pSelected->p_textp->x_size;
	}
	/* 如果内存分配成功，则进行实际换入操作 */
	desAddress = Kernel::Instance().GetUserPageManager().AllocMemory(size);
	if ( NULL != desAddress )
	{
		goto found2;
	}

	/*
	 * 分配内存失败情况下，换出内存中进程，腾出空间。
	 * 换出原则：从易到难；依次将低优先权睡眠状态(SWAIT)-->
	 * 暂停状态(SSTOP)-->高优先权睡眠状态(SSLEEP)-->就绪状态(SRUN)进程换出。
	 */
	X86Assembly::CLI();
	for ( int i = 0; i < ProcessManager::NPROC; i++ )
	{

		bool pFlagIsSLOAD = (this->process[i].p_flag & (int(Process::SSYS) | int(Process::SLOCK) | int(Process::SLOAD))) == int(Process::SLOAD);

		bool statIsSWAITOrSSTOP = (this->process[i].p_stat == Process::SWAIT || this->process[i].p_stat == Process::SSTOP);

		if (pFlagIsSLOAD && statIsSWAITOrSSTOP)
		{
			goto found1;
		}
	}

	/* 
	 * 在换出高优先权睡眠状态(SSLEEP)、就绪状态(SRUN)进程而腾出内存之前，
	 * 检查待换入进程在交换区驻留时间是否已达到3秒，低于则不予换入
	 */
	if ( seconds < 3 )
	{
		goto sloop;
	}

	seconds = -1;
	for ( int i = 0; i < ProcessManager::NPROC; i++ )
	{

		bool pFlagIsSLOAD = (this->process[i].p_flag & (int(Process::SSYS) | int(Process::SLOCK) | int(Process::SLOAD))) == int(Process::SLOAD);
		bool pStatIsSWAITOrSSTOP = this->process[i].p_stat == Process::SWAIT || this->process[i].p_stat == Process::SSTOP;

		if ( pFlagIsSLOAD && pStatIsSWAITOrSSTOP && pSelected->p_time > seconds ) {
			pSelected = &(this->process[i]);
			seconds = pSelected->p_time;
		}
	}

	/* 如果要换出SSLEEP、SRUN状态进程，先检查该进程驻留内存时间是否超过2秒，否则不予换出 */
	if ( seconds < 2 )
	{
		goto sloop;
	}

	/* 换出pSelected指向的被选中进程 */
found1:
	X86Assembly::STI();
	pSelected->p_flag &= ~Process::SLOAD;
	this->XSwap(pSelected, true, 0);
	/* 腾出内存空间后再次尝试换入进程 */
	goto loop;

	/* 已经分配好足够的内存，进行实际的换入操作 */
found2:
	BufferManager& bufMgr = Kernel::Instance().GetBufferManager();
	/* 
	* 如果存在共享正文段，但是没有进程图像在内存中，引用该正文段的进程，
	* 即共享正文段不再内存中，换入时需要读入正文段在交换区中的副本
	*/
	if ( pSelected->p_textp != NULL )
	{
		Text* pText = pSelected->p_textp;
		if ( pText->x_ccount == 0 )
		{
			/* 因为共享正文段，和进程ppda、数据段、堆栈段在交换区中是分开存放的，所以先换入共享正文段 */
			if ( bufMgr.Swap(pText->x_daddr, desAddress, pText->x_size, Buf::B_READ) == false )
			{
				goto err;
			}
			/* 共享正文段在内存中的起始地址 */
			pText->x_caddr = desAddress;
			desAddress += pText->x_size;
		}
		pText->x_ccount++;
	}
	/* 换入剩余部分图像：ppda、数据段、堆栈段 */
	if ( bufMgr.Swap(pSelected->p_addr /* blkno */, desAddress, pSelected->p_size, Buf::B_READ) == false )
	{
		goto err;
	}
	Kernel::Instance().GetSwapperManager().FreeSwap(pSelected->p_size, pSelected->p_addr /* blkno */);
	pSelected->p_addr = desAddress;
	pSelected->p_flag |= Process::SLOAD;
	pSelected->p_time = 0;
	goto loop;

err:
	Utility::Panic("Swap Error");
}
```
- 每次时钟中断，p_time 都会加一，这样sched会按照p_time从小到大的顺序一次把就绪进程移动到磁盘交换区上。
### 进程图像的换入
- 如果有代码段，判断代码段是否需要进入内存，如果需要进入内存，要调用swap函数，并把x_ccount++
- 随后释放磁盘上进程图像可交换部分所占的空间，把进程图像也搬到内存当中
- 修改换入进程的p_addr p_flag 加上SLOAD 并设置p_time =0  
- 结束之后，代码段的x_daddr会保留，x_caddr被正确赋值能够在内存上找到代码段。

0# 进程负责一个死循环去维护上面的进程保证他们能够不停的执行。只要0#进程在台上，就会一直去查找是否有就绪的进程可以换入，如果没有，那么去sleep(RunOut,-100)，等随后由于这个原因而唤醒。在setRun函数当中，一个进程发现自己的图像不再内存上，会唤醒0#进程来换入自己的进程。

### 换入进程发现没有多余的空间
原则：
- 无SSYS 和 SLOCK 标志位
- 先换出低睡进程 SWAIT
- 对于所有的高睡进程，以及就绪进程，把这两类进程中最久没有被调用的进程换出。 SLEEP\|SRUN

```c++
	/*
	 * 将进程从内存换出至磁盘交换区上
	 * pProcess: 指向要换出的进程
	 * bFreeMemory: 是否释放进程图像占据的内存
	 * size: 除共享正文段外，进程可交换部分图像长度；参数size为0时，直接使用p_size
	 */
	void XSwap(Process* pProcess, bool bFreeMemory, int size);
void ProcessManager::XSwap( Process* pProcess, bool bFreeMemory, int size )
{
	if ( 0 == size)
	{
		size = pProcess->p_size;
	}

	/* blkno记录分配到的交换区起始扇区号 */
	int blkno = Kernel::Instance().GetSwapperManager().AllocSwap(pProcess->p_size);
	if ( 0 == blkno )
	{
		Utility::Panic("Out of Swapper Space");
	}
	/* 递减进程图像在内存中，且引用该正文段的进程数 */
	if ( pProcess->p_textp != NULL )
	{
		pProcess->p_textp->XccDec();
	}
	/* 上锁，防止同一进程图像被重复换出 */
	pProcess->p_flag |= Process::SLOCK;
	if ( false == Kernel::Instance().GetBufferManager().Swap(blkno, pProcess->p_addr, size, Buf::B_WRITE) )
	{
		Utility::Panic("Swap I/O Error");
	}
	if ( bFreeMemory )
	{
		Kernel::Instance().GetUserPageManager().FreeMemory(size, pProcess->p_addr);
	}
	/* 把进程图像在交换区起始扇区号记录在p_addr中，SLOAD是0、进程是盘交换区上的进程了 */
	pProcess->p_addr = blkno;
	pProcess->p_flag &= ~(Process::SLOAD | Process::SLOCK);
	/* 最近一次被换入或换出以来，在内出或交换区驻留的时间长度清零 */
	pProcess->p_time = 0;

	if ( this->RunOut )
	{
		this->RunOut = 0;
		Kernel::Instance().GetProcessManager().WakeUpAll((unsigned long)&RunOut);
	}
}
```
- 减少x_ccount的值
- 上锁防止被重复换出
- 运行到发现没有进程可以调出，sleep(&runin,-100); 其他进程再sleep函数的时候，就要让0#进程试试能不能把这个进程去换出，这个时候要求换出的进程p_time值要大于2，换入的进程p_time值要大于3
### 内存空间不足以存放新进程

```c++
//这段代码来自于Newproc
	if ( desAddress == 0 ) /* 内存不够，需要swap */
	{
		current->p_stat = Process::SIDL;
		/* 子进程p_addr指向父进程图像，因为子进程换出至交换区需要以父进程图像为蓝本 */
		child->p_addr = current->p_addr;
		SaveU(u.u_ssav);
		this->XSwap(child, false, 0);
		child->p_flag |= Process::SSWAP;
		current->p_stat = Process::SRUN;
	}
```
- 父进程执行Xswap，二次保存的ssav的结果，栈顶是newproc指针的结果。于是子进程应该使用ssav的newproc栈帧回到自己的执行状态。
- 子进程有SSWAP标志位，要用ssav如替换rsav把无用的核心栈栈帧刷掉。
### 内存空间不足以扩展自己的图像
```c++
void Process::Expand(unsigned int newSize)
{
	UserPageManager& userPgMgr = Kernel::Instance().GetUserPageManager();
	ProcessManager& procMgr = Kernel::Instance().GetProcessManager();
	User& u = Kernel::Instance().GetUser();
	Process* pProcess = u.u_procp;

	unsigned int oldSize = pProcess->p_size;
	p_size = newSize;
	unsigned long oldAddress = pProcess->p_addr;
	unsigned long newAddress;

	/* 如果进程图像缩小，则释放多余的内存 */
	if ( oldSize >= newSize )
	{
		userPgMgr.FreeMemory(oldSize - newSize, oldAddress + newSize);
		return;
	}

	/* 进程图像扩大，需要寻找一块大小newSize的连续内存区 */
	SaveU(u.u_rsav);
	newAddress = userPgMgr.AllocMemory(newSize);
	/* 分配内存失败，将进程暂时换出到交换区上 */
	if ( NULL == newAddress )
	{
		SaveU(u.u_ssav);
		procMgr.XSwap(pProcess, true, oldSize);
		pProcess->p_flag |= Process::SSWAP;
		procMgr.Swtch();
		/* no return */
	}
	/* 分配内存成功，将进程图像拷贝到新内存区，然后跳转到新内存区继续运行 */
	pProcess->p_addr = newAddress;
	for ( unsigned int i = 0; i < oldSize; i++ )
	{
		Utility::CopySeg(oldAddress + i, newAddress + i);
	}

	/* 释放原来占用的内存区 */
	userPgMgr.FreeMemory(oldSize, oldAddress);
	
	X86Assembly::CLI();
	SwtchUStruct(pProcess);
	RetU();
	X86Assembly::STI();

	u.u_MemoryDescriptor.MapToPageTable();
}
```
发现图像空间不够的时候，给自己一个SSWAP标志位，把自己的整体和自己的扩展部分当成一个整体放在盘交换区上，像是一个刚刚创建的子进程一样归来。
## 神秘的0号进程
可以再睡眠中参与swtch函数的调度，梦游说是.
然而，中间这一棒只能由0号进程来完成，只有它能够自然醒。