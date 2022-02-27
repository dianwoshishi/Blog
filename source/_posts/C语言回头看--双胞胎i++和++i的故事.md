---
title: C语言回头看--诡异的i++和++i
author: dianwoshishi
tag:
  - C语言
categories:
  - 开发
  - C语言回头看
---
# C语言回头看--诡异的i++和++i

C语言中的`i++`和`++i`使用非常的方便，简单明了。但是很多人在学习C语言的过程中，对这两个语句还是存在恐惧，因为这两条语句会引起不必要的麻烦。例如：到底是先用再加，还是先加再用？ 同时在一些程序语句中也会出现一些令人意想不到的结果，例如`i=1,((++i)+(++i))=6`的情况，非常的诡异。

因此本文针对这个问题，深入到汇编层面，理解双胞胎i++和++i的故事。相信通过本文，你能够更加深刻的理解C语言中的自加自减等操作。

## 例子介绍

### 本文所用程序

C语言文件如下所示，逻辑为：分别输出`i++`和`++i`的结果。

```asm
#include <stdio.h>

int main(){
	int i = 0;
	printf("i = 0,++i = %d\n", ++i);
	i = 0;
	
	printf("i = 0,i++ = %d\n", i++);



	i = 1;
	printf("i = 1,(i++)+(++i) = %d\n", (i++)+(++i));


	i = 1;
	printf("i = 1,(++i)+(i++) = %d\n", (++i)+(i++));

	i = 1;
	printf("i = 1,(++i)+(++i) = %d\n", (++i)+(++i));

	return 0;
}
```

使用`make`进行构建，`makefile`如下所示

```makefile
OBJ=selfincre

$(OBJ):
	g++ -Wall main.c -o $@

clean:
	-rm -rf $(OBJ)
```
本机所用的环境如下所示：

```txt
Ubuntu 16.04 (64位，内核版本4.15.0-142-generic）
gcc version 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.12)
make：GNU Make 4.1，Built for x86_64-pc-linux-gnu
```

结果如下：

![image-20210726110945317](C语言回头看--双胞胎i++和++i的故事/image-20210726110945317.png)

##  汇编分析

在ubuntu中我们使用`objdump ~d ./selfincre > objdump.txt`，将程序进行反汇编，我们将不重要的信息剔除，只保留`main`函数，如下所示，在部分汇编语句中进行了注释，可以结合‘餐食’。

```asm

./selfincre:     file format elf64-x86-64

0000000000400526 <main>:
  400526:	55                   	push   %rbp
  400527:	48 89 e5             	mov    %rsp,%rbp
  40052a:	48 83 ec 10          	sub    $0x10,%rsp
  40052e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp) # -0x4(%rbp) 是局部变量i，本操作为赋值为0
  400535:	83 45 fc 01          	addl   $0x1,-0x4(%rbp) # i + 1
  400539:	8b 45 fc             	mov    -0x4(%rbp),%eax # 将i放入eax
  40053c:	89 c6                	mov    %eax,%esi				# 将eax复制给esi，作为printf的第一个参数
  40053e:	bf 04 06 40 00       	mov    $0x400604,%edi
  400543:	b8 00 00 00 00       	mov    $0x0,%eax
  400548:	e8 b3 fe ff ff       	callq  400400 <printf@plt>
  40054d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)	## -0x4(%rbp) 是局部变量i，本操作为赋值为0
  400554:	8b 45 fc             	mov    -0x4(%rbp),%eax	## i赋值给eax
  400557:	8d 50 01             	lea    0x1(%rax),%edx					## 取rax的值加一（注意：rax本身并没有+1)，并赋值给edx
  40055a:	89 55 fc             	mov    %edx,-0x4(%rbp)				## 将edx赋值给局部变量i
  40055d:	89 c6                	mov    %eax,%esi				## 注意这里的eax并没有进行+1操作，所以值自赋值为0后并未改变，作为printf的第一个参数
  40055f:	bf 0e 06 40 00       	mov    $0x40060e,%edi
  400564:	b8 00 00 00 00       	mov    $0x0,%eax
  400569:	e8 92 fe ff ff       	callq  400400 <printf@plt>
  40056e:	b8 00 00 00 00       	mov    $0x0,%eax
  400573:	c9                   	leaveq 
  400574:	c3                   	retq   
  400575:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  40057c:	00 00 00 
  40057f:	90                   	nop
```

### 分析++i

主要分析一下C代码

```C
++i;
```

汇编如下所示：

```asm
	40052e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp) # -0x4(%rbp) 是局部变量i，本操作为赋值为0
  400535:	83 45 fc 01          	addl   $0x1,-0x4(%rbp) # i + 1
  400539:	8b 45 fc             	mov    -0x4(%rbp),%eax # 将i放入eax
  40053c:	89 c6                	mov    %eax,%esi				# 将eax复制给esi，作为printf的第一个参数
  40053e:	bf 04 06 40 00       	mov    $0x400604,%edi
  400543:	b8 00 00 00 00       	mov    $0x0,%eax
  400548:	e8 b3 fe ff ff       	callq  400400 <printf@plt>
```

**++i正如字面的意思一样，先加后用！**

其加一汇编操作，均在`-0x4(%rbp)`进行，加一操作为`addl   $0x1,-0x4(%rbp)`，**因此++i直接造成的结果就是i的改变。**

### 分析i++

C代码如下

```c
i++;
```

汇编如下所示：


```asm
  40054d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)	## -0x4(%rbp) 是局部变量i，本操作为赋值为0
  400554:	8b 45 fc             	mov    -0x4(%rbp),%eax	## i赋值给eax
  400557:	8d 50 01             	lea    0x1(%rax),%edx					## 取rax的值加一（注意：rax本身并没有+1)，并赋值给edx
  40055a:	89 55 fc             	mov    %edx,-0x4(%rbp)				## 将edx赋值给局部变量i
  40055d:	89 c6                	mov    %eax,%esi				## 注意这里的eax并没有进行+1操作，所以值自赋值为0后并未改变，作为printf的第一个参数
  40055f:	bf 0e 06 40 00       	mov    $0x40060e,%edi
  400564:	b8 00 00 00 00       	mov    $0x0,%eax
  400569:	e8 92 fe ff ff       	callq  400400 <printf@plt>
```

**i++正如字面的意思一样，先用后加！**

其加一汇编操作，在寄存器`eax`的值的基础上进行，加一操作为`lea    0x1(%rax),%edx；mov    %edx,-0x4(%rbp)`。

我们可以如下理解i++， 拆分为两句：

```c
i++ 	--> 	i;i = i + 1
```

`i++`相当于：先使用`i`，在对`i`进行加一操作。

- 先使用i：操作为将i的值存储在eax以便在后面使用，`eax`代表了`i++`这条语句的结果

- 对i进行加一操作：`lea    0x1(%rax),%edx；mov    %edx,-0x4(%rbp)`，加一操作并不影响eax寄存器。 

  

因此`i++`的结果是`i`，使用的方法是`eax寄存器`。只不过在使用完`i`，会有一个加一的操作而已。

### 小结

**++i，先加后用！**

**i++，先用后加！**

出现`i++`，`++i`这样语句的目的可能在于减少语句操作吧。通过上述字面理解，其实是最快的。





## (i++)+(++i)=6？？？

### 示例代码

使用如下代码进行分析

```C
	i = 1;
	printf("i = 1,(i++)+(++i) = %d\n", (i++)+(++i));


	i = 1;
	printf("i = 1,(++i)+(++i) = %d\n", (++i)+(++i));
```

### 分析(i++)+(++i)

首先我们先进行一个简单一些的分析，`i = 1;(i++)+(++i)` 的结果是多少呢？

```asm
  # (i++)+(++i)
  # i = 1
  40056e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)		## -0x4(%rbp) 就是局部变量i，本操作为赋值为1,i = 1
  # i++
  400575:	8b 45 fc             	mov    -0x4(%rbp),%eax		## eax = i = 1
  400578:	8d 50 01             	lea    0x1(%rax),%edx			## 取rax的值加一，赋值给edx
  40057b:	89 55 fc             	mov    %edx,-0x4(%rbp)		## i = edx, 此时i = 2
  # ++i
  40057e:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)		## i+ 1 = i,此时i = 3
  # $1 + $2
  400582:	8b 55 fc             	mov    -0x4(%rbp),%edx		## i的值赋给edx，也就是3
  400585:	01 d0                	add    %edx,%eax					## 执行eax + edx = eax 也就是1 + 3 = 4
  400587:	89 c6                	mov    %eax,%esi					## eax赋给esi，作为printf的第一个参数，也就是4
  400589:	bf 74 06 40 00       	mov    $0x400674,%edi
  40058e:	b8 00 00 00 00       	mov    $0x0,%eax
  400593:	e8 68 fe ff ff       	callq  400400 <printf@plt>
  
```

通过第二节的分析，我们知道，其实`(i++)+(++i) `的可以看做`(i_1 + (++i_2))`（`i_1`是因为此时`i_1`的值是eax的值，`i_1` 不等同于`i_2`，并不随`i`的值变化）， ~~再由C语言中表达式的计算是由右到左，所以会先计算`++i`，然后是~~再相加。那么结果应该是1 + 2 = 3。

但是，实际结果却是4.为什么呢？

原因就是在进行`++i`的时候，虽然后续用的是`eax`的值，但是这句话（第5行）随后进行的操作改变了`-0x4(%rbp)`的值（第6、7行）。其本意是`-0x4(%rbp)+1`，但是此时`-0x4(%rbp)`的值已经被`i++`修改过了，为2，所以`++i`的结果就成为了3。最终两式一加，结果为4.



### 分析(++i)+(++i)

下面我们分析`(++i)+(++i) = 6？`

汇编代码如下所示：

```asm

  # (++i)+(++i)
  # i = 1
  400598:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)		# -0x4(%rbp) = i = 1
  #(++i)
  40059f:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)		# -0x4(%rbp) = i = 2
  #(++i)
  4005a3:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)		# -0x4(%rbp) = i = 3
  # $1 + $2
  4005a7:	8b 45 fc             	mov    -0x4(%rbp),%eax		# -0x4(%rbp)赋值给eax， eax = 3
  4005aa:	01 c0                	add    %eax,%eax					# eax + eax = 6
  4005ac:	89 c6                	mov    %eax,%esi
  4005ae:	bf 8c 06 40 00       	mov    $0x40068c,%edi
  4005b3:	b8 00 00 00 00       	mov    $0x0,%eax
  4005b8:	e8 43 fe ff ff       	callq  400400 <printf@plt>
```

经过上一小节的分析，其实这里已经非常简单了，因为两次`++i`不断的改变`-0x4(%rbp)`的值，使得`-0x4(%rbp)`在使用时变成了3，最终两式相加为6.

### 练手题目

```txt
	i = 1;
	printf("i = 1,(++i)+(i++) = %d\n", (++i)+(i++));
```



```asm
  400598:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  40059f:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  4005a3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  4005a6:	8d 50 01             	lea    0x1(%rax),%edx
  4005a9:	89 55 fc             	mov    %edx,-0x4(%rbp)
  4005ac:	8b 55 fc             	mov    -0x4(%rbp),%edx
  4005af:	01 d0                	add    %edx,%eax
  4005b1:	89 c6                	mov    %eax,%esi
  4005b3:	bf ac 06 40 00       	mov    $0x4006ac,%edi
  4005b8:	b8 00 00 00 00       	mov    $0x0,%eax
  4005bd:	e8 3e fe ff ff       	callq  400400 <printf@plt>
```

他的结果是5，通过上述分析，你算对了吗？

关键提示：

- ~~C语言中运行由右至左，所以先算`i++`，再算`++i`~~
- `i++`和`++i`的运算过程改变了`-0x4(%rbp)`的值，所以出现了非预期的结果。



## 未定义行为

虽然这有点复杂，感觉确定性非常的不高。但是不用担心，在C语言的编译过程中，会警告我们，这样的语句中i没有定义。如果你发现这样的问题后，就需要注意了。

![image-20210726111037526](C语言回头看--双胞胎i++和++i的故事/image-20210726111037526.png)

下面文章中对这个问题进行了解释，不再赘述。

> i＝1，为什么 (++i)+(++i)＝6？ - CWKSC的回答 - 知乎 https://www.zhihu.com/question/347864795/answer/836263029



## 总结

- 从汇编角度理解++i和i++，可以更好的得出一些奇奇怪怪的语句的结果，让我们更好的理解C语言，理解编译器。
- 一定不建议写这样的语句！一定不建议写这样的语句！一定不建议写这样的语句！请用`i += 1`这样代替。多写一个字符而已。如果一定要写i++或++i，请将其单独为一个语句，不要进行组合！不要进行组合！不要进行组合！这样，你好我好大家好，不然当某一天你维护的代码出现灵异事件时，就只有祷告了。





====



```c
#include <stdio.h>
int f(){
	int i = 1;
	return i++;
}

int g(){
	int i = 1;
	return i++;
}

int main(){

	int ret = f() + g();
	

	printf("%d\n", ret);

	printf("%d\n", f() + g());

	int a = 1, b = 2, c = 3, d = 4;
	d = a * b + c * 2;
	printf("%d\n", d);

	return 0;
}
```



```asm

0000000000400526 <_Z1fv>:
  400526:	55                   	push   %rbp
  400527:	48 89 e5             	mov    %rsp,%rbp
  40052a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  400531:	8b 45 fc             	mov    -0x4(%rbp),%eax
  400534:	8d 50 01             	lea    0x1(%rax),%edx
  400537:	89 55 fc             	mov    %edx,-0x4(%rbp)
  40053a:	5d                   	pop    %rbp
  40053b:	c3                   	retq   

000000000040053c <_Z1gv>:
  40053c:	55                   	push   %rbp
  40053d:	48 89 e5             	mov    %rsp,%rbp
  400540:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  400547:	8b 45 fc             	mov    -0x4(%rbp),%eax
  40054a:	8d 50 01             	lea    0x1(%rax),%edx
  40054d:	89 55 fc             	mov    %edx,-0x4(%rbp)
  400550:	5d                   	pop    %rbp
  400551:	c3                   	retq   

0000000000400552 <main>:
  400552:	55                   	push   %rbp
  400553:	48 89 e5             	mov    %rsp,%rbp
  400556:	53                   	push   %rbx
  400557:	48 83 ec 28          	sub    $0x28,%rsp
  40055b:	e8 c6 ff ff ff       	callq  400526 <_Z1fv>		#f()
  400560:	89 c3                	mov    %eax,%ebx
  400562:	e8 d5 ff ff ff       	callq  40053c <_Z1gv>		#g()
  400567:	01 d8                	add    %ebx,%eax
  400569:	89 45 dc             	mov    %eax,-0x24(%rbp)
  40056c:	8b 45 dc             	mov    -0x24(%rbp),%eax
  40056f:	89 c6                	mov    %eax,%esi
  400571:	bf 74 06 40 00       	mov    $0x400674,%edi
  400576:	b8 00 00 00 00       	mov    $0x0,%eax
  40057b:	e8 80 fe ff ff       	callq  400400 <printf@plt>
  400580:	e8 a1 ff ff ff       	callq  400526 <_Z1fv>		#f()
  400585:	89 c3                	mov    %eax,%ebx
  400587:	e8 b0 ff ff ff       	callq  40053c <_Z1gv>		#g()
  40058c:	01 d8                	add    %ebx,%eax
  40058e:	89 c6                	mov    %eax,%esi
  400590:	bf 74 06 40 00       	mov    $0x400674,%edi
  400595:	b8 00 00 00 00       	mov    $0x0,%eax
  40059a:	e8 61 fe ff ff       	callq  400400 <printf@plt>
  40059f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%rbp) #a
  4005a6:	c7 45 e4 02 00 00 00 	movl   $0x2,-0x1c(%rbp)	#b
  4005ad:	c7 45 e8 03 00 00 00 	movl   $0x3,-0x18(%rbp)	#c
  4005b4:	c7 45 ec 04 00 00 00 	movl   $0x4,-0x14(%rbp) #d
  4005bb:	8b 45 e0             	mov    -0x20(%rbp),%eax
  4005be:	0f af 45 e4          	imul   -0x1c(%rbp),%eax # a * b
  4005c2:	8b 55 e8             	mov    -0x18(%rbp),%edx 
  4005c5:	01 d2                	add    %edx,%edx				# c + c = c*2
  4005c7:	01 d0                	add    %edx,%eax				# 相加
  4005c9:	89 45 ec             	mov    %eax,-0x14(%rbp)
  4005cc:	8b 45 ec             	mov    -0x14(%rbp),%eax
  4005cf:	89 c6                	mov    %eax,%esi
  4005d1:	bf 74 06 40 00       	mov    $0x400674,%edi
  4005d6:	b8 00 00 00 00       	mov    $0x0,%eax
  4005db:	e8 20 fe ff ff       	callq  400400 <printf@plt>
  4005e0:	b8 00 00 00 00       	mov    $0x0,%eax
  4005e5:	48 83 c4 28          	add    $0x28,%rsp
  4005e9:	5b                   	pop    %rbx
  4005ea:	5d                   	pop    %rbp
  4005eb:	c3                   	retq   
  4005ec:	0f 1f 40 00          	nopl   0x0(%rax)

```

从汇编代码可以看出，实际上`f()+g()` 和`a * b + c *2`的顺序均为从左向右。

实际上，之前自己记忆中一直是以下这句：

- **复合赋值运算的优先级符合C语言运算符的优先级表，结合方向为从右到左。** C语言中可以进行连续赋值,如a=b=c=1,“=”运算符是从右至左结合
-  **函数参数：**主要是函数参数入栈的方式造成有，入栈从右向左，运算也就从右向左。 i=1; printf("%d%d",i,i++);//输出2 1
