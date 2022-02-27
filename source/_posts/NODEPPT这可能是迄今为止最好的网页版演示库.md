---
title: 在你的hexo博客中使用nodeppt，一款迄今为止最好的网页版演示库
---

大家好，我是明说网络的小明同学。

今天我和大家分享一个非常酷的网页PPT工具，NODEPPT

# NODEPPT这可能是迄今为止最好的网页版演示库

一开始看到这个库的时候，我就喜欢上了。因为他效果非常的棒，而且能够非常好的和hexo结合。这样我们能够一次生成，到哪都可以演示PPT，还能配上相应的技术文档，是不是很酷啊！

## NODEPPT Demo

项目的演示网址在这：https://nodeppt.js.org/#slide=1

![image-20220226172518524](NODEPPT这可能是迄今为止最好的网页版演示库/image-20220226172518524.png)

主要说明了这个库包含什么样的功能

## NODE PPT Github

官网地址：https://github.com/ksky521/nodeppt

# Hexo中使用PPT Demo

以下是我使用官网的[demo](https://raw.githubusercontent.com/ksky521/nodeppt/master/site/index.md)制作的一个PPT，注意它是嵌入在我这个网页中的，以下网页你可以左右滑动。

<iframe src="../nodeppt/slides.html" width="100%" height="500" name="topFrame" scrolling="yes" noresize="noresize" frameborder="0" id="topFrame"></iframe>



如果你觉得这个功能很酷，想要添加到你的站点里面去，那么就和我一起往下走吧。

## 如何在Hexo中添加Nodeppt

前提，确保你的noteppt能够正常使用。这是前提，至于怎么熟练的玩好nodeppt，额…… 还是去官网吧，这里不误导人了。

整体的思路是，两步走：

- 第一步先使用nodeppt在相应的public目录生成相应的文件,如html,js,img等等
- 在post中引用相应的文件

### 首先熟悉nodeppt的build方法

输入`nodeppt build --help`

```
Usage: nodeppt build [options] [entry]

build html file

Options:
  -m, --map         Release sourcemap
  -d, --dest <dir>  output directory
  -h, --help        output usage information
  Examples:

    nodeppt build slide.md
```

我们需要使用的就是这个`-d`参数。目的是将生成的文件放入网站的public目录下

### 源文件目录说明

存放源文件的目录结构如下所示

```
root/public
		├──nodeppt
root/source
├── slideshare
│   ├── another.md
│   ├── build.sh
│   ├── buildlist.txt
│   ├── makefile
│   └── slides.md
```

- buildlist.txt 代表等待生成的ppt文件列表

```
slides.md
another.md%
```

- build.sh 

  在slideshare目录下运行本文件，作用是使用nodeppt按上面文件内容的顺序构建，输出目录为`public/nodeppt`

```shell
NODEPPT=/usr/local/Cellar/node/17.5.0/bin/nodeppt
Destination=../../public/nodeppt/
build_files=$(cat buildlist.txt | xargs)
for file in $build_files
do
    # echo $file
    $NODEPPT build ./$file -d $Destination
done
```

- makefile 本文件主要用于使用一个脚本完成所有的工作

```makefile
all:
        bash build.sh
```

至此，你使用在当前目录`make`就能将生成好的PPT网页放入public目录的noteppt目录中。

### 那么怎么使用呢？

在上一步中，我们生成了ppt文件，放在了`public/nodeppt/`中，假设文件名为`slides.html`

那么我们可以在hexo的post中简单的使用如下命令，就可以引用我们的PPT

```html
<iframe src="../nodeppt/slides.html" width="100%" height="500" name="topFrame" scrolling="yes" noresize="noresize" frameborder="0" id="topFrame"></iframe>
```

需要修改的部分就是iframe中的src部分。

最后放下一个一键上线部署的脚本

```makefile
all:
	make nodeppt
	hexo g 
	hexo d 

nodeppt:
	$(MAKE) -C source/slideshare/

test:
	make nodeppt
	hexo g
	hexo s

deploy:
	make nodeppt
	hexo g 
	hexo d
	
```

## 最后附上本次示例的PPT

试试看左右滑动

<iframe src="../nodeppt/use-nodeppt-in-hexo-demo.html" width="100%" height="500" name="topFrame" scrolling="yes" noresize="noresize" frameborder="0" id="topFrame"></iframe>

# 参考资料

## 静态压缩

https://hasaik.com/posts/495d0b23.html

使用Hexo-Neat成功https://github.com/rozbo/hexo-neat

Hexo静态资源压缩https://www.jianshu.com/p/5e48e532ae58



https://rye-catcher.github.io/2019/10/21/Nodeppt-%E5%85%A5%E5%9D%91%E6%8C%87%E5%8D%97/

给博客文章嵌入 PPT 演示https://hexo.fluid-dev.com/posts/hexo-nodeppt/

### 添加自定义网页

https://www.jianshu.com/p/524b073f9b37