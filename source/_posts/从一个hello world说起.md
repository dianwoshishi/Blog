---
title: 从一个hello world说起
date: 2022-02-26 14:14:18
---

# 从一个hello world说起

大家好，我是明说网络的小明同学。今天我们从C语言的Hello World说起，和大家一起温习一下C语言中一个Hello World怎么运行起来的，以及C语言如何组织栈缓冲区等。本文不适用于C语言初学者，需要具备有一定的汇编基础。好了下面，我们开始吧。

## 工具

本文的工具为：

```txt
操作系统：Ubuntu16.04， 4.15.0-142-generic

编译器：gcc version 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.12)

make工具GNU Make 4.1

反汇编查看器：objdump

elf文件查看器：readelf

gdb，pwngdb
```



## C语言介绍

C 语言是一种通用的高级语言，最初是由丹尼斯·里奇在贝尔实验室为开发 UNIX 操作系统而设计的。UNIX 操作系统，C编译器，和几乎所有的 UNIX 应用程序都是用 C 语言编写的。由于各种原因，C 语言现在已经成为一种广泛使用的专业语言。

同时，C语言是一门大学期间基本上都会开设的课程。作为一门入门编程课程，C语言有着独特的魅力和不可替代的作用。虽然当前python火热，C语言好像显得不那么重要了，“python难道不香吗”的疑问开始出现。但是我的观点是：每种语言有每种语言的优势，python永远也取代不了C语言。像我独爱指针，能够带来自由的感觉。

下面就开始我们的探索之旅吧。

## 第一个程序helloworld

### 编写程序

首先我们有如下程序：`main.c`

```c
//main.c
#include <stdio.h>
int display(char *name){
	
	printf("hello world! %s\n", name);
}

int 
main(){
	char name[256] = "I'm a string";
	display(name);
	return 0;
}
```

上述程序实现的功能很简单，就是输出一句话`hello world! I'm a string`，为了便于说明，其中故意使用了一个函数调用`int display(char *)`。

函数的逻辑为，main函数--> display()函数(一个参数)-->printf函数(两个参数)。

是不是很简单！

### 程序编译makefile

为了便于说明，我们使用makefile文件进行编译。创建文件名为`makefile`的文件，内容如下：

```makefile
# makefile
OBJ=printf.main

$(OBJ):
	gcc main.c -o $@

clean:
	-rm $(OBJ)
```

我们生成的文件名为`printf.main`，这里你可以改为你喜欢的任意名称。

使用`make`命令进行编译，会生成最终文件。运行后就可以看见`hello world! I'm a string`

### 小结

到这里我们就完成了一个helloworld程序的编写和编译，并且运行。是不是很简单。对于初学者，其实到这里就完了，姑且可以认为main函数就是一个程序的开始和结束（我曾经就一直这么认为）。但是对于有过一定经验的人来说，就知道：main函数并不是一个程序的开始，也不是一个程序的结束。

咦，这么神奇的吗？就让我们来看看吧。

## Hello world 的背后

首先让我们来认识一下我们生成的`printf.main。`

```shell
file ./printf.main 
./printf.main: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=5c389a402866aaa012b8b8ab992fed778eb989b0, not stripped
```



ELF是执行和链接格式（Execurable and Linking Format）的缩略词。它是UNIX系统的几种可执行文件格式中的一种。

使用命令`readelf -h ./printf.main > elf_head.txt`

```txt
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x4004a0 //注意这一行
  Start of program headers:          64 (bytes into file)
  Start of section headers:          6712 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         9
  Size of section headers:           64 (bytes)
  Number of section headers:         31
  Section header string table index: 28
```

这里面，我们注意第11行，`Entry point address:               0x4004a0`,显示，入口点地址为address，说明操作系统在运行这个`printf.main`程序时，首先从这个地址开始运行。那么我们看看这个地址到底是什么吧

### 汇编

使用命令`objdump -d printf.main > objdump.txt`将程序的汇编代码提取出来（删除了一些当前没有必要说明的内容），如下所示：

```asm

printf.main:     file format elf64-x86-64


Disassembly of section .init:

0000000000400428 <_init>:
  400428:	48 83 ec 08          	sub    $0x8,%rsp
  40042c:	48 8b 05 c5 0b 20 00 	mov    0x200bc5(%rip),%rax        # 600ff8 <_DYNAMIC+0x1d0>
  400433:	48 85 c0             	test   %rax,%rax
  400436:	74 05                	je     40043d <_init+0x15>
  400438:	e8 53 00 00 00       	callq  400490 <__libc_start_main@plt+0x10>
  40043d:	48 83 c4 08          	add    $0x8,%rsp
  400441:	c3                   	retq   

Disassembly of section .plt:


0000000000400470 <printf@plt>:
  400470:	ff 25 aa 0b 20 00    	jmpq   *0x200baa(%rip)        # 601020 <_GLOBAL_OFFSET_TABLE_+0x20>
  400476:	68 01 00 00 00       	pushq  $0x1
  40047b:	e9 d0 ff ff ff       	jmpq   400450 <_init+0x28>

0000000000400480 <__libc_start_main@plt>:
  400480:	ff 25 a2 0b 20 00    	jmpq   *0x200ba2(%rip)        # 601028 <_GLOBAL_OFFSET_TABLE_+0x28>
  400486:	68 02 00 00 00       	pushq  $0x2
  40048b:	e9 c0 ff ff ff       	jmpq   400450 <_init+0x28>

Disassembly of section .plt.got:

0000000000400490 <.plt.got>:
  400490:	ff 25 62 0b 20 00    	jmpq   *0x200b62(%rip)        # 600ff8 <_DYNAMIC+0x1d0>
  400496:	66 90                	xchg   %ax,%ax

Disassembly of section .text:

00000000004004a0 <_start>:
  4004a0:	31 ed                	xor    %ebp,%ebp
  4004a2:	49 89 d1             	mov    %rdx,%r9
  4004a5:	5e                   	pop    %rsi
  4004a6:	48 89 e2             	mov    %rsp,%rdx
  4004a9:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
  4004ad:	50                   	push   %rax
  4004ae:	54                   	push   %rsp
  4004af:	49 c7 c0 b0 06 40 00 	mov    $0x4006b0,%r8 //00000000004006b0 <__libc_csu_fini>:
  4004b6:	48 c7 c1 40 06 40 00 	mov    $0x400640,%rcx //0000000000400640 <__libc_csu_init>:
  4004bd:	48 c7 c7 bb 05 40 00 	mov    $0x4005bb,%rdi //00000000004005bb <main>:
  4004c4:	e8 b7 ff ff ff       	callq  400480 <__libc_start_main@plt>
  4004c9:	f4                   	hlt    
  4004ca:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

0000000000400596 <display>:
  400596:	55                   	push   %rbp
  400597:	48 89 e5             	mov    %rsp,%rbp
  40059a:	48 83 ec 10          	sub    $0x10,%rsp
  40059e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  4005a2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  4005a6:	48 89 c6             	mov    %rax,%rsi
  4005a9:	bf c4 06 40 00       	mov    $0x4006c4,%edi
  4005ae:	b8 00 00 00 00       	mov    $0x0,%eax
  4005b3:	e8 b8 fe ff ff       	callq  400470 <printf@plt>
  4005b8:	90                   	nop
  4005b9:	c9                   	leaveq 
  4005ba:	c3                   	retq   

00000000004005bb <main>:
  4005bb:	55                   	push   %rbp
  4005bc:	48 89 e5             	mov    %rsp,%rbp
  4005bf:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  4005c6:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
  4005cd:	00 00 
  4005cf:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  4005d3:	31 c0                	xor    %eax,%eax
  4005d5:	48 b8 49 27 6d 20 61 	movabs $0x74732061206d2749,%rax
  4005dc:	20 73 74 
  4005df:	48 89 85 f0 fe ff ff 	mov    %rax,-0x110(%rbp)
  4005e6:	48 c7 85 f8 fe ff ff 	movq   $0x676e6972,-0x108(%rbp)
  4005ed:	72 69 6e 67 
  4005f1:	48 8d 95 00 ff ff ff 	lea    -0x100(%rbp),%rdx
  4005f8:	b8 00 00 00 00       	mov    $0x0,%eax
  4005fd:	b9 1e 00 00 00       	mov    $0x1e,%ecx
  400602:	48 89 d7             	mov    %rdx,%rdi
  400605:	f3 48 ab             	rep stos %rax,%es:(%rdi)
  400608:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  40060f:	48 89 c7             	mov    %rax,%rdi
  400612:	e8 7f ff ff ff       	callq  400596 <display>
  400617:	b8 00 00 00 00       	mov    $0x0,%eax
  40061c:	48 8b 75 f8          	mov    -0x8(%rbp),%rsi
  400620:	64 48 33 34 25 28 00 	xor    %fs:0x28,%rsi
  400627:	00 00 
  400629:	74 05                	je     400630 <main+0x75>
  40062b:	e8 30 fe ff ff       	callq  400460 <__stack_chk_fail@plt>
  400630:	c9                   	leaveq 
  400631:	c3                   	retq   
  400632:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  400639:	00 00 00 
  40063c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000400640 <__libc_csu_init>:
  400640:	41 57                	push   %r15
  400642:	41 56                	push   %r14
  400644:	41 89 ff             	mov    %edi,%r15d
  400647:	41 55                	push   %r13
  400649:	41 54                	push   %r12
  40064b:	4c 8d 25 be 07 20 00 	lea    0x2007be(%rip),%r12        # 600e10 <__frame_dummy_init_array_entry>
  400652:	55                   	push   %rbp
  400653:	48 8d 2d be 07 20 00 	lea    0x2007be(%rip),%rbp        # 600e18 <__init_array_end>
  40065a:	53                   	push   %rbx
  40065b:	49 89 f6             	mov    %rsi,%r14
  40065e:	49 89 d5             	mov    %rdx,%r13
  400661:	4c 29 e5             	sub    %r12,%rbp
  400664:	48 83 ec 08          	sub    $0x8,%rsp
  400668:	48 c1 fd 03          	sar    $0x3,%rbp
  40066c:	e8 b7 fd ff ff       	callq  400428 <_init>
  400671:	48 85 ed             	test   %rbp,%rbp
  400674:	74 20                	je     400696 <__libc_csu_init+0x56>
  400676:	31 db                	xor    %ebx,%ebx
  400678:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  40067f:	00 
  400680:	4c 89 ea             	mov    %r13,%rdx
  400683:	4c 89 f6             	mov    %r14,%rsi
  400686:	44 89 ff             	mov    %r15d,%edi
  400689:	41 ff 14 dc          	callq  *(%r12,%rbx,8)
  40068d:	48 83 c3 01          	add    $0x1,%rbx
  400691:	48 39 eb             	cmp    %rbp,%rbx
  400694:	75 ea                	jne    400680 <__libc_csu_init+0x40>
  400696:	48 83 c4 08          	add    $0x8,%rsp
  40069a:	5b                   	pop    %rbx
  40069b:	5d                   	pop    %rbp
  40069c:	41 5c                	pop    %r12
  40069e:	41 5d                	pop    %r13
  4006a0:	41 5e                	pop    %r14
  4006a2:	41 5f                	pop    %r15
  4006a4:	c3                   	retq   
  4006a5:	90                   	nop
  4006a6:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  4006ad:	00 00 00 

00000000004006b0 <__libc_csu_fini>:
  4006b0:	f3 c3                	repz retq 

Disassembly of section .fini:

00000000004006b4 <_fini>:
  4006b4:	48 83 ec 08          	sub    $0x8,%rsp
  4006b8:	48 83 c4 08          	add    $0x8,%rsp
  4006bc:	c3                   	retq   
```



这里我们注意第45，46，47，48行，注意其中

```asm
  4004af:	49 c7 c0 b0 06 40 00 	mov    $0x4006b0,%r8 //00000000004006b0 <__libc_csu_fini>:
  4004b6:	48 c7 c1 40 06 40 00 	mov    $0x400640,%rcx //0000000000400640 <__libc_csu_init>:
  4004bd:	48 c7 c7 bb 05 40 00 	mov    $0x4005bb,%rdi //00000000004005bb <main>:
  4004c4:	e8 b7 ff ff ff       	callq  400480 <__libc_start_main@plt>
```

`__libc_start_main@plt`包含了三个参数，`__libc_csu_fini`,`__libc_csu_init`,`main`显然，从名称上就可以看出这四个函数的作用。

__libc_start_main是libc.so.6中的一个函数。它的原型是这样的：

```
extern int BP_SYM (__libc_start_main) (int (*main) (int, char **, char **),
		int argc,
		char *__unbounded *__unbounded ubp_av,
		void (*init) (void),
		void (*fini) (void),
		void (*rtld_fini) (void),
		void *__unbounded stack_end)
__attribute__ ((noreturn));
```

这个函数需要做的是建立/初始化一些数据结构/环境然后调用我们的main()。

程序启动的过程应该：`_start -> __libc_start_main -> __libc_csu_init -> _init -> main -> _fini`.

这篇文章有详细的说明：[linux编程之main()函数启动过程](https://blog.csdn.net/gary_ygl/article/details/8506007)

### 栈缓冲区及结构

> ### 汇编基础
>
> x86_64有16个64位寄存器，分别是：
>
> %rax，%rbx，%rcx，%rdx，%esi，%edi，%rbp，%rsp，%r8，%r9，%r10，%r11，%r12，%r13，%r14，%r15。
>
> 其中：
>
> %rax 作为函数返回值使用。
> %rsp 栈指针寄存器，指向栈顶
> %rdi，%rsi，%rdx，%rcx，%r8，%r9 用作函数参数，依次对应第1参数，第2参数
> %rbx，%rbp，%r12，%r13，%14，%15 用作数据存储，遵循被调用者使用规则，简单说就是随便用，调用子函数之前要备份它，以防他被修改
> %r10，%r11 用作数据存储，遵循调用者使用规则，简单说就是使用之前要先保存原值
>
> 64位与32位的不同在于64位不用压栈来存储下一个函数参数，而是放在了%rdi，%rsi，%rdx，%rcx，%r8，%r9六个寄存器中，超出部分再压栈。
>
> ![preview](https://pic1.zhimg.com/v2-8c6f52a7fabfb4f31464e51c3aa0e8a4_r.jpg)
>
> ![preview](https://pic2.zhimg.com/v2-03edf3d060b91b58698db2a58bfb3be5_r.jpg)
>
> ![img](https://pic4.zhimg.com/80/v2-0cbd2ee34a6a173804028b19fe0a9167_720w.jpg)



首先，我们将`main.c`文件进行汇编，使用命令`gcc -S main.c`，在当前目录下回生成`main.s`的汇编文件，内容如下：

```asm
	.file	"main.c"
	.section	.rodata
.LC0:
	.string	"hello world! %s\n"
	.text
	.globl	display
	.type	display, @function
display:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rsi
	movl	$.LC0, %edi
	movl	$0, %eax
	call	printf
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	display, .-display
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$272, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movabsq	$8391086132249306953, %rax //0x74732061206d2749 ("I'm a st")
	movq	%rax, -272(%rbp)
	movq	$1735289202, -264(%rbp)
	leaq	-256(%rbp), %rdx
	movl	$0, %eax
	movl	$30, %ecx
	movq	%rdx, %rdi
	rep stosq
	leaq	-272(%rbp), %rax
	movq	%rax, %rdi //使用%rdi寄存器压入参数
	call	display //调用函数
	movl	$0, %eax
	movq	-8(%rbp), %rsi
	xorq	%fs:40, %rsi
	je	.L4
	call	__stack_chk_fail
.L4:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
```

#### main函数

在53，54行，使用`rdi`压入了一个参数，参数的地址在`-272(%rbp)（即rdi）`, 可以看出正好是字符串"I'm a string"的地址。如下所示：![image-20210719112214862](从一个hello world说起/image-20210719112214862.png)

其中，函数调用栈缓冲区`backtrace`显示当前栈缓冲区为main，再上一层为__libc_start_main，再次印证了上一节的说法。

#### display函数

下面我们进入display函数，可以看出printf的两个参数分别放在`rdi,rsi`两个寄存器当中。

![image-20210719112513484](从一个hello world说起/image-20210719112513484.png)其中，函数调用栈缓冲区`backtrace`显示当前栈缓冲区为display，再上一层为main，__libc_start_main，再次印证了上一节的说法。

### 小结

通过对main函数中display函数的参数，display函数中的printf函数的参数进行实验，说明了C语言在函数调用时的栈缓冲区的组织。

## 结语

对于一个普普通通的C语言程序，其实其背后是一堆复杂的操作系统预备好的操作，执行完毕之后，就开始执行我们的main函数。main函数并不是程序执行的第一个函数，当然也不是最后一个。我们编写的程序的main函数，仅仅是操作系统在加载elf文件时候调用的函数而已，仅仅是函数而已。

栈缓冲区的组织，一定要动手自己调一调，理解栈缓冲区，有助于理解pwn题中的栈缓冲的利用。

这就是我喜欢C语言的原因，因为他能让我更加清晰的看到程序运行的背后，而像python这类语言，我也使用，因为真的方便，但是对于理解计算机、理解背后的故事非常的不利。



关注我，学习更多系统的知识！