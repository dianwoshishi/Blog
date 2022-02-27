---
title: Linux下从汇编手撕c++-值传递和引用传递e
date: 2020-08-15 18:49:36
tags:
  - C语言回头看
  - 汇编
categories:
  - 开发
  - 编程
---
# Linux下从汇编手撕c++-值传递和引用传递

## 示例程序

`main.c`

主要分为两个部分，每个部分使用一个display函数，函数内使得传入的参数自加1，然后打印到标准输出上。不同的地方在于，display1使用了值传递，display2使用了引用传递

```c++
#include <stdio.h>

void display1(int num){ //int num，属于值传递
	num++;
	printf("display1: %d\n", num);
}

void display2(int & num){ //int & num ，属于引用传递
	num++;
	printf("display2: %d\n", num);
}

int main(){
	int num1 = 0, num2 = 0;
	display1(num1);
	printf("num1:%d\n", num1);
	printf("--------------------\n");
	display2(num2);
	printf("num2:%d\n", num2);
	return 0;
}
```

`makefile`

```c++
OBJ=reference

$(OBJ):
	g++ main.c -o $@

clean:
	-rm -rf $(OBJ)
```

在ubuntu中使用`make`命令进行编译并运行，结果如下图所示。

![image-20210724002053895](Linux下手撕c++-值传递和引用传递/image-20210724002053895.png)

通过上述结果我们可以看出，虽然仅仅一个`&`符号的差异，但通过参数传递和通过值传递获得的**结果不一样**。

- 值传递中的num虽然进行了自加操作(输出display:1可以看出)，但是**并没有影响**到main函数中的num1（num1:0可以看出)

- 但是引用传递中的num进行了自加1(输出display:1可以看出)，并且**影响到**了main函数中的num2(num2:1可以看出).

## 提出问题

是什么原因造成了仅仅一个`&`符号的差异，导致函数内值传递和引用传递的差别呢？

## 实验

`objdump -d ./reference > objdump.txt`

```asm

./reference:     file format elf64-x86-64

00000000004005d6 <_Z8display1i>:
  4005d6:	55                   	push   %rbp
  4005d7:	48 89 e5             	mov    %rsp,%rbp
  4005da:	48 83 ec 10          	sub    $0x10,%rsp
  4005de:	89 7d fc             	mov    %edi,-0x4(%rbp) #将值取出到%rbp-0x4
  4005e1:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)	# +1运算
  4005e5:	8b 45 fc             	mov    -0x4(%rbp),%eax	#写回%rbp-0x4, 仍然是局部变量，生命周期在函数内
  4005e8:	89 c6                	mov    %eax,%esi
  4005ea:	bf 44 07 40 00       	mov    $0x400744,%edi
  4005ef:	b8 00 00 00 00       	mov    $0x0,%eax
  4005f4:	e8 b7 fe ff ff       	callq  4004b0 <printf@plt>
  4005f9:	90                   	nop
  4005fa:	c9                   	leaveq 
  4005fb:	c3                   	retq   

00000000004005fc <_Z8display2Ri>:
  4005fc:	55                   	push   %rbp
  4005fd:	48 89 e5             	mov    %rsp,%rbp
  400600:	48 83 ec 10          	sub    $0x10,%rsp
  400604:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)#将值取出到%rbp-0x8， 注意此时%rdi为地址
  400608:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  40060c:	8b 00                	mov    (%rax),%eax
  40060e:	8d 50 01             	lea    0x1(%rax),%edx  #加一
  400611:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  400615:	89 10                	mov    %edx,(%rax) # 将结果放入原地址所指的内存当中，
  400617:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  40061b:	8b 00                	mov    (%rax),%eax
  40061d:	89 c6                	mov    %eax,%esi
  40061f:	bf 52 07 40 00       	mov    $0x400752,%edi
  400624:	b8 00 00 00 00       	mov    $0x0,%eax
  400629:	e8 82 fe ff ff       	callq  4004b0 <printf@plt>
  40062e:	90                   	nop
  40062f:	c9                   	leaveq 
  400630:	c3                   	retq   

0000000000400631 <main>:
  400631:	55                   	push   %rbp
  400632:	48 89 e5             	mov    %rsp,%rbp
  400635:	48 83 ec 10          	sub    $0x10,%rsp
  400639:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
  400640:	00 00 
  400642:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  400646:	31 c0                	xor    %eax,%eax
  400648:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  40064f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)
  400656:	8b 45 f4             	mov    -0xc(%rbp),%eax # 将%rbp-0xc的值放入%eax，相当于复制了一份
  400659:	89 c7                	mov    %eax,%edi
  40065b:	e8 76 ff ff ff       	callq  4005d6 <_Z8display1i>
  400660:	8b 45 f4             	mov    -0xc(%rbp),%eax
  400663:	89 c6                	mov    %eax,%esi
  400665:	bf 60 07 40 00       	mov    $0x400760,%edi
  40066a:	b8 00 00 00 00       	mov    $0x0,%eax
  40066f:	e8 3c fe ff ff       	callq  4004b0 <printf@plt>
  400674:	bf 69 07 40 00       	mov    $0x400769,%edi
  400679:	e8 12 fe ff ff       	callq  400490 <puts@plt>
  40067e:	48 8d 45 f0          	lea    -0x10(%rbp),%rax # 将%rbp-0xc的地址放入%eax，想到与对原地址进行操作
  400682:	48 89 c7             	mov    %rax,%rdi
  400685:	e8 72 ff ff ff       	callq  4005fc <_Z8display2Ri>
  40068a:	8b 45 f0             	mov    -0x10(%rbp),%eax
  40068d:	89 c6                	mov    %eax,%esi
  40068f:	bf 7e 07 40 00       	mov    $0x40077e,%edi
  400694:	b8 00 00 00 00       	mov    $0x0,%eax
  400699:	e8 12 fe ff ff       	callq  4004b0 <printf@plt>
  40069e:	b8 00 00 00 00       	mov    $0x0,%eax
  4006a3:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  4006a7:	64 48 33 14 25 28 00 	xor    %fs:0x28,%rdx
  4006ae:	00 00 
  4006b0:	74 05                	je     4006b7 <main+0x86>
  4006b2:	e8 e9 fd ff ff       	callq  4004a0 <__stack_chk_fail@plt>
  4006b7:	c9                   	leaveq 
  4006b8:	c3                   	retq   
  4006b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
```



通过上述汇编代码（相关关键步骤已经使用注释进行了说明）。

```c++
display1(num1);
display2(num2);
```

```asm
  400656:	8b 45 f4             	mov    -0xc(%rbp),%eax # 注意mov操作！！将%rbp-0xc的值（也就是局部变量num1）放入%eax，相当于复制了一份
  400659:	89 c7                	mov    %eax,%edi
  40065b:	e8 76 ff ff ff       	callq  4005d6 <_Z8display1i>  

  40067e:	48 8d 45 f0          	lea    -0x10(%rbp),%rax # 注意lea 操作！！将%rbp-0xc（也就是局部变量num2）的地址放入%eax，想当于对原地址进行操作
  400682:	48 89 c7             	mov    %rax,%rdi
  400685:	e8 72 ff ff ff       	callq  4005fc <_Z8display2Ri>
```

可以看出：

- 对于值传递，使用`mov`指令，相当于**复制**了一份；

- 对于引用，使用`lea`指令，得到了地址，随后的操作都在**地址上**进行，相当于直接对该地址的数进行操作。

因此，我们知道，虽然传递的都是传递的一个变量名，但display1使用的值传递，display2使用的是引用传递：

```c++
	display1(num1);//虽然进行了自加1，但是是对num1的副本进行的操作，作用范围在display函数内
	display2(num2);//使用引用传递，相当于指针操作，作用范围在main函数当中。
```

- 当使用值传递时，在函数内对参数的操作，参数作用范围只在函数内，跳出函数后该是啥还是啥，在原函数(这里是main)里就是进入函数前的状态。因为值传递方式，在函数中只改变的是值的副本。

- 在使用引用传递时，引用的本质使用的是指针。因此在函数中的操作，都会直接作用于该地址的值。

## 总结

通过对值传递和引用传递的汇编代码的分析，我们清晰的看出值传递本是上是传递了一个原值的副本，其变化并不影响调用函数的值；引用传递的本质是指针，其变化，直接作用于调用函数的值。

