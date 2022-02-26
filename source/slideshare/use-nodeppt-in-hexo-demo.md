title: another ppt
speaker: dianwoshishi
plugins:
    - echarts

<slide class="bg-black-blue aligncenter" image="https://source.unsplash.com/C1HhAQrbykQ/ .dark">

# How to use nodeppt in your hexo blog system {.text-landing.text-shadow}

By dianwoshishi {.text-intro}

[:fa-github: Github](https://github.com/dianwoshishi){.button.ghost}




<slide :class="size-50 aligncenter">
### 前言
---

确保你的noteppt能够正常使用

这是前提，至于怎么熟练的玩好nodeppt，额…… 还是去[官网](https://github.com/ksky521/nodeppt)吧，这里不误导人了。  {.text-content}

<slide :class="size-30 aligncenter">
整体的思路是，两步走： {.text-content}

- 第一步先使用nodeppt在相应的public目录生成相应的文件,如html,js,img等等

- 在post中引用相应的文件

<slide :class="size-30 aligncenter">

### `nodeppt build --help`
---

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
*我们需要使用的就是这个`-d`参数。目的是将生成的文件放入网站的public目录下*


<slide :class="size-30 aligncenter">
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


<slide :class="size-30 alignleft">
### 文件说明
---

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

<slide :class="size-30 aligncenter">
### 引用文件

---

在上一步中，我们生成了ppt文件，放在了`public/nodeppt/`中，假设文件名为`slides.html`

那么我们可以在hexo的post中简单的使用如下命令，就可以引用我们的PPT

```html
<iframe src="../nodeppt/slides.html" width="100%" height="500" name="topFrame" scrolling="yes" noresize="noresize" frameborder="0" id="topFrame"></iframe>
```
:::note
## 需要修改的部分就是iframe中的src部分。
:::


<slide  image="https://webslides.tv/static/images/iphone-hand.png .right-bottom">
## 总结
通过生成复制、引用两个步骤，完成了在hexo博客系统中引入nodeppt的功能，
撒花！{.animated.tada}

