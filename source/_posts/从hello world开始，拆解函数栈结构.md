---
title: 从hello world开始，拆解函数栈结构
author: dianwoshishi 
date: 2022-02-27 11:25:34 
tags:
  - C语言
  - Linux
  - 汇编
catogories:
  - 编程开发
---
# 从hello world开始，拆解函数栈结构

## 第一个程序helloworld

### 编写程序

首先我们有如下程序：`main.c`

```c
//main.c
#include<stdio.h>
int test_stack(){
	char name[25] = {0};
	scanf("%s", name);
	puts(name);
	return 0;
}
int main(){
	test_stack();
	return 0;
}
```

上述程序实现的功能很简单，就是从`scanf`输入一个字符串，赋值到`name`，并且通过`puts`打印。

是不是很简单！

### 程序编译makefile

为了便于说明，我们使用makefile文件进行编译。创建文件名为`makefile`的文件，内容如下：

```makefile
# makefile
OBJ=stack

$(OBJ):
	gcc main.c -o $@

clean:
	-rm -rf $(OBJ)
```

我们生成的文件名为`stack`，这里你可以改为你喜欢的任意名称。

使用`make`命令进行编译，会生成最终文件。运行后就可以看见输出。

## 提出问题

C语言中函数栈是如何组织的呢？都有哪些元素呢？

## 分析问题

首先，我们通过汇编代码，理解上述C语言代码，我们能更加清晰的看出一个`test_stack`函数到底干了什么。相关内容我们在其后直接进行了注释。

```asm
# objdump -d ./stack
./stack:     file format elf64-x86-64

00000000004005f6 <test_stack>:
  4005f6:	55                   	push   %rbp
  4005f7:	48 89 e5             	mov    %rsp,%rbp
  4005fa:	48 83 ec 30          	sub    $0x30,%rsp #栈上开辟了0x30=48的空间，注意我们的局部变量只需要25的空间
  4005fe:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax # 从%fs:0x28取了一个值，放在了栈底之上，这就是canary，一种栈溢出的保护措施
  400605:	00 00 
  400607:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  40060b:	31 c0                	xor    %eax,%eax
  40060d:	48 c7 45 d0 00 00 00 	movq   $0x0,-0x30(%rbp) #char name[25] = {0};
  400614:	00 
  400615:	48 c7 45 d8 00 00 00 	movq   $0x0,-0x28(%rbp)
  40061c:	00 
  40061d:	48 c7 45 e0 00 00 00 	movq   $0x0,-0x20(%rbp)
  400624:	00 
  400625:	c6 45 e8 00          	movb   $0x0,-0x18(%rbp)
  400629:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  40062d:	48 89 c6             	mov    %rax,%rsi
  400630:	bf 04 07 40 00       	mov    $0x400704,%edi #’%s'
  400635:	b8 00 00 00 00       	mov    $0x0,%eax
  40063a:	e8 a1 fe ff ff       	callq  4004e0 <__isoc99_scanf@plt>
  40063f:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  400643:	48 89 c7             	mov    %rax,%rdi
  400646:	e8 65 fe ff ff       	callq  4004b0 <puts@plt>
  40064b:	b8 00 00 00 00       	mov    $0x0,%eax
  400650:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  400654:	64 48 33 14 25 28 00 	xor    %fs:0x28,%rdx #检查canary
  40065b:	00 00 
  40065d:	74 05                	je     400664 <test_stack+0x6e>
  40065f:	e8 5c fe ff ff       	callq  4004c0 <__stack_chk_fail@plt>
  400664:	c9                   	leaveq 
  400665:	c3                   	retq   

0000000000400666 <main>:
  400666:	55                   	push   %rbp
  400667:	48 89 e5             	mov    %rsp,%rbp
  40066a:	b8 00 00 00 00       	mov    $0x0,%eax
  40066f:	e8 82 ff ff ff       	callq  4005f6 <test_stack>
  400674:	b8 00 00 00 00       	mov    $0x0,%eax
  400679:	5d                   	pop    %rbp
  40067a:	c3                   	retq   
  40067b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
```

主要进行了以下操作：

- **callq操作。**我们需要注意一个隐含操作，就是上述第40行`callq  4005f6 <test_stack>`,这个操作隐含将下一条指令地址压栈，即0x400674
- **开辟栈空间。**开辟了大小为48的栈空间，这里注意，我们的局部变量name只需要25大小的空间
- **canary值。**从%fs:0x28取了一个值，放在了栈底之上，这就是canary，一种栈溢出的保护措施，最后对其检查
- **初试化操作。**使用3个`movq`和1个`movb`对name变量进行了初始化。name变量的起始地址为`$rbp-0x30$`即`$rsp$`栈顶
- **赋值。**使用`scanf`函数，对name变量进行了赋值

其中，初始化，赋值通过汇编代码都很容易看出。下面我们通过gdb主要来看看栈结构吧。

## 实验

使用gdb+pwngdb插件进行解释，如不清楚，可私信我或加我公众号。

### callq操作

![image-20210721000901757](从hello world开始，拆解函数栈结构/image-20210721000901757.png)

在进行callq操作之前，rbp和rsp为同一地址，说明栈空间大小为0.

![image-20210721001254187](从hello world开始，拆解函数栈结构/image-20210721001254187.png)

注意箭头部分，当我们进入`test_stack`函数时，callq操作，进行了隐含操作，callq的下一条指令地址压栈，在这里我们可以看出，其内容为`0x400674`，与我们静态分析汇编代码一致。验证了callq操作对栈的影响。

### 开辟栈空间

此操作中，注意rsp和rbp的变化。

- push指令，将栈底压栈。

![image-20210721001715969](从hello world开始，拆解函数栈结构/image-20210721001715969.png)

- 将栈底和栈顶地址设为相同（可通过栈底的上一条内容01：0008，恢复上一个栈底）。

![image-20210721001827503](从hello world开始，拆解函数栈结构/image-20210721001827503.png)

- 开辟栈空间，大小为0x30=48。

![image-20210721002102212](从hello world开始，拆解函数栈结构/image-20210721002102212.png)

红框中`[00:0000-06:0030)`之间，为当前`test_stack`栈帧中的结构，大小为0x30=48字节。中间的数据为一些初始化函数执行过程中残留的栈数据，暂时不用管它。(s + buffer + canary)

rbp为test_stack函数的第一个push rbp的操作压入的栈底（saved ebp)

07:0038为test_stack函数执行完毕后的返回地址。(return address)

示意图如下：

![See the source image](https://manybutfinite.com/img/stack/bufferCanary.png)

### canary值

如下图，我们继续执行两步，该函数在`fs:[0x28]`处取了一个值，然后放入了rbp-8的位置，即图中画线的位置，值为：0x92cb97cb6f51ae00，这个数就是我们所谓的canary，金丝雀。主要用来检测栈溢出。

![image-20210721003510355](从hello world开始，拆解函数栈结构/image-20210721003510355.png)

然后我们查看栈顶开始的48个字节，即栈的内容

![image-20210721004153415](从hello world开始，拆解函数栈结构/image-20210721004153415.png)

s: 0x7fffffffddd0:	（0x00000000	0x00000000	0x00000000	0x00000000
0x7fffffffdde0:	0x00000000	0x00000000	0x00）s表示我们局部变量填充的空间         

buffer: (000000	0x00000000
0x7fffffffddf0:	0x00400680	0x00000000)buffer	代表补齐8字节所占用的空间

canary: (0x6f51ae00	0x92cb97cb)canary 代表栈溢出检测指标。



![See the source image](https://manybutfinite.com/img/stack/bufferCanary.png)

通过IDA pro验证我们的想法：

![image-20210721010044515](从hello world开始，拆解函数栈结构/image-20210721010044515.png)



## 缓冲区溢出分析

实际上我们花了大量的篇幅去讲栈的结构，其实目的就是这么一张图

![See the source image](https://manybutfinite.com/img/stack/bufferCanary.png)

栈溢出其实就是使得字符串长度达到return address的位置，使得在函数执行完毕retn时，return address的地址弹出给rip寄存器，从而使得CPU按照rip寄存的内容执行下一条指令。这里面要非常清楚的就是栈的结构，栈空间的计算真正要做到”一字不差“！

当然了，这里的canary对栈进行了保护，是一个随机生成的数。当然还有很多办法来绕过甚至是猜出canary，实现栈溢出，这不在本篇文章的范畴之内，留给下一次机会吧。

## 总结

对通过一个最简单的程序对栈的结构进行了静态和动态的分析，得出了一张刻画栈帧空间的图。对于栈的计算要十分的仔细，这样在pwn题中才能做到心中有数，一招制敌。