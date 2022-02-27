---
title: 从hello world开始，拆解函数栈结构
author: dianwoshishi 
---
# 从hello world开始，拆解字符串常量的存储位置

## 第一个程序helloworld

### 编写程序

首先我们有如下程序：`main.c`

```c
//main.c
#include <stdio.h>
int display(char *name){
	
	printf("hello world! %s\n", name);
}
char *g_pstr = "global_I'm a string\n";
int 
main(){
	char *pname = "III'm a stringI'm a stringII'm a stringI'm a stringII'm a stringI'm a stringII'm a stringI'm a stringII'm a stringI'm a stringII'm a stringI'm a stringII'm a stringI'm a stringII'm a stringI'm a stringII'm a stringI'm a stringII'm a stringI'm a stringI'm a stringI'm a string";
	puts(pname);
	puts(g_pstr);
	char name[256] = "local_string_I'm a string"; 
	display(name);
	return 0;
}
```

上述程序实现的功能很简单，就是输出三个字符串pname，g_pstr和name，为了便于说明，其中故意使用了一个函数调用`int display(char *)`。

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

使用`make`命令进行编译，会生成最终文件。运行后就可以看见输出。

## 提出问题

我们想要知道字符串常量在程序运行中存储的位置

## 分析问题

我们通过命令`objdump -d ./printf.main`, 查看相应的汇编代码。如下所示，定位到关键步骤，关键步骤已经使用‘#’注释

```asm

./printf.main:     file format elf64-x86-64

00000000004005d6 <display>:
  4005d6:	55                   	push   %rbp
  4005d7:	48 89 e5             	mov    %rsp,%rbp
  4005da:	48 83 ec 10          	sub    $0x10,%rsp
  4005de:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  4005e2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  4005e6:	48 89 c6             	mov    %rax,%rsi
  4005e9:	bf 48 07 40 00       	mov    $0x400748,%edi
  4005ee:	b8 00 00 00 00       	mov    $0x0,%eax
  4005f3:	e8 b8 fe ff ff       	callq  4004b0 <printf@plt>
  4005f8:	90                   	nop
  4005f9:	c9                   	leaveq 
  4005fa:	c3                   	retq   

00000000004005fb <main>:
  4005fb:	55                   	push   %rbp
  4005fc:	48 89 e5             	mov    %rsp,%rbp
  4005ff:	48 81 ec 20 01 00 00 	sub    $0x120,%rsp
  400606:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
  40060d:	00 00 
  40060f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  400613:	31 c0                	xor    %eax,%eax
  400615:	48 c7 85 e8 fe ff ff 	movq   $0x400770,-0x118(%rbp)			# 0x400770作为pname的地址
  40061c:	70 07 40 00 
  400620:	48 8b 85 e8 fe ff ff 	mov    -0x118(%rbp),%rax
  400627:	48 89 c7             	mov    %rax,%rdi
  40062a:	e8 61 fe ff ff       	callq  400490 <puts@plt>
  40062f:	48 8b 05 12 0a 20 00 	mov    0x200a12(%rip),%rax        # 601048 <g_pstr>
  400636:	48 89 c7             	mov    %rax,%rdi
  400639:	e8 52 fe ff ff       	callq  400490 <puts@plt>
  40063e:	48 b8 6c 6f 63 61 6c 	movabs $0x74735f6c61636f6c,%rax		#‘local_st’ "local_string_I'm a string"变量以常量整型的方式进行复制。
  400645:	5f 73 74 
  400648:	48 89 85 f0 fe ff ff 	mov    %rax,-0x110(%rbp)
  40064f:	48 b8 72 69 6e 67 5f 	movabs $0x6d27495f676e6972,%rax  # ‘ring_I'm’
  400656:	49 27 6d 
  400659:	48 89 85 f8 fe ff ff 	mov    %rax,-0x108(%rbp)
  400660:	48 b8 20 61 20 73 74 	movabs $0x6e69727473206120,%rax
  400667:	72 69 6e 
  40066a:	48 89 85 00 ff ff ff 	mov    %rax,-0x100(%rbp)
  400671:	48 c7 85 08 ff ff ff 	movq   $0x67,-0xf8(%rbp)
  400678:	67 00 00 00 
  40067c:	48 8d 95 10 ff ff ff 	lea    -0xf0(%rbp),%rdx
  400683:	b8 00 00 00 00       	mov    $0x0,%eax
  400688:	b9 1c 00 00 00       	mov    $0x1c,%ecx
  40068d:	48 89 d7             	mov    %rdx,%rdi
  400690:	f3 48 ab             	rep stos %rax,%es:(%rdi)
  400693:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  40069a:	48 89 c7             	mov    %rax,%rdi
  40069d:	e8 34 ff ff ff       	callq  4005d6 <display>
  4006a2:	b8 00 00 00 00       	mov    $0x0,%eax
  4006a7:	48 8b 75 f8          	mov    -0x8(%rbp),%rsi
  4006ab:	64 48 33 34 25 28 00 	xor    %fs:0x28,%rsi
  4006b2:	00 00 
  4006b4:	74 05                	je     4006bb <main+0xc0>
  4006b6:	e8 e5 fd ff ff       	callq  4004a0 <__stack_chk_fail@plt>
  4006bb:	c9                   	leaveq 
  4006bc:	c3                   	retq   
  4006bd:	0f 1f 00             	nopl   (%rax)

```



### 第一个pname参数

```asm
  400615:	48 c7 85 e8 fe ff ff 	movq   $0x400770,-0x118(%rbp)			# 0x400770作为pname的地址
  40061c:	70 07 40 00 
  400620:	48 8b 85 e8 fe ff ff 	mov    -0x118(%rbp),%rax
  400627:	48 89 c7             	mov    %rax,%rdi
  40062a:	e8 61 fe ff ff       	callq  400490 <puts@plt>
```



![image-20210720102416074](从hello world开始，复习C语言知识——字符串常亮/image-20210720102416074.png)

查看地址**0x400770**，得到字符串。

### 第二个参数g_pstr

```asm
  40062f:	48 8b 05 12 0a 20 00 	mov    0x200a12(%rip),%rax        # 601048 <g_pstr>
  400636:	48 89 c7             	mov    %rax,%rdi
  400639:	e8 52 fe ff ff       	callq  400490 <puts@plt>
```



![image-20210720102733348](从hello world开始，复习C语言知识——字符串常亮/image-20210720102733348.png)

查看地址**0x400759**，得到地址

### 第三个参数字符串常量

```asm
  40063e:	48 b8 6c 6f 63 61 6c 	movabs $0x74735f6c61636f6c,%rax		#‘local_st’ "local_string_I'm a string"变量以常量整型的方式进行复制。
  400645:	5f 73 74 
  400648:	48 89 85 f0 fe ff ff 	mov    %rax,-0x110(%rbp)
  40064f:	48 b8 72 69 6e 67 5f 	movabs $0x6d27495f676e6972,%rax  # ‘ring_I'm’
  400656:	49 27 6d 
  400659:	48 89 85 f8 fe ff ff 	mov    %rax,-0x108(%rbp)
  400660:	48 b8 20 61 20 73 74 	movabs $0x6e69727473206120,%rax
  400667:	72 69 6e 
  40066a:	48 89 85 00 ff ff ff 	mov    %rax,-0x100(%rbp)
  400671:	48 c7 85 08 ff ff ff 	movq   $0x67,-0xf8(%rbp)
  400678:	67 00 00 00 
  40067c:	48 8d 95 10 ff ff ff 	lea    -0xf0(%rbp),%rdx
  400683:	b8 00 00 00 00       	mov    $0x0,%eax
```



0x74735f6c61636f6c -> 为字符串”local_st“

0x6d27495f676e6972->为字符串”ring_I'm“

其他等等

得到字符串。

## 思考

#### 全局变量和只有引用的字符串常量，使用rodata数据区存储其值

全局变量g_pstr和pname所指向的地址，均为`.rodata`，意思是read only。从以下IDA pro的结果中我们也能看出来。



![image-20210720143206385](从hello world开始，复习C语言知识——字符串常亮/image-20210720143206385.png)

#### 能够实现赋值初始化的字符串常量，由编译器优化，使用整型常量的方式复制到栈上，不占用`rodata`空间

对于`char name[256] = "local_string_I'm a string"; `实现的赋值语句，其常量是以整型的方式存储，然后赋值到栈上的name变量中。实际上，这是编译器帮助我们实现了这个步骤。

为了确认这一事实，我们做如下实验：

使用`char name[256] = "llocal_string_I'm a stringlocal_string_I'm a stringlocal_string_I'm a stringlocal_string_I'm a stringocal_string_I'm a string";`进行试验，得到如下结果。

![image-20210720143749564](从hello world开始，复习C语言知识——字符串常亮/image-20210720143749564.png)

可以看出，确实是将字符串拆解为整型常量，然后赋值到栈空间上。



## 总结

其他的常量也可以依次类推。

一般我们的理解都是字符串常量都是放在`rodata`中，但是通过汇编代码，我们可以清晰的看出，当字符串常量初始化给一个数组时，字符串常量并不会放在`rodata`中，二是将字符串常量转化为多个整型常量，然后在运行时直接复制到栈上。