# Blog

Hexo搭建个人博客







nodejs 配置国内源

可以直接使用命令配置国内源:

```
npm config set registry http://registry.npm.taobao.org
```



第一步：新建文件夹



第二步：安装hexo基础框架

```nginx
//第一条   这是安装hexo的基础框架
npm install -g hexo

//第二条   这是初始化hexo框架 这个可能会比较慢
hexo init

//第三条 安装所需要的组件
npm install

//第四条 编译生成静态页面
hexo g
//如果实时编译 hexo g --watch


//第五条 启动本地服务
hexo s


hexo g
//安装一个扩展npm i hexo-deployer-git
```



第三步：使用Next主题

```
git clone https://github.com/theme-next/hexo-theme-next themes/next
```

然后设置站点配置文件_config.yml：

```
theme: next
```







#### 1. post_asset_folder

首先确认***_config.yml\***中有***post_asset_folder:true\***。

Hexo提供了一种更方便管理Asset的设定：***post_asset_folder\***
 当您设置***post_asset_folder\***为***true\***参数后，在建立文件时，Hexo
 会自动建立一个与文章同名的文件夹；以前的文章也可以自己手动创建同名文件夹。

#### 2. 安装 hexo-asset-image

在hexo的目录下执行



```cpp
npm install https://github.com/CodeFalling/hexo-asset-image --save
```





当文章全部写完后，使用Typora的替换功能（替换功能包含删除功能，当替换的内容什么都不输入时为全部删除）将所有图片地址前面多余的部分删除即可





# hexo设置 关于 标签 分类 归档

https://blog.csdn.net/ganzhilin520/article/details/79047249





## 添加RSS

https://blog.csdn.net/qq_19069509/article/details/105467052

先安装 hexo-generator-feed 插件
$ npm install hexo-generator-feed --save
1
打开 *主题配置文件* 找到follow_me，将RSS注释去掉即可:
注意: 新版本的next主题中同样也已经集成了RSS这个功能，默认是关闭的，注释掉就行

follow_me:
  RSS: /atom.xml || fa fa-rss
————————————————
版权声明：本文为CSDN博主「暮子凡」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/qq_19069509/article/details/105467052





阅读全文按钮

https://www.jianshu.com/p/6f77c96b7eff









win10系统无法加载脚本，使用管理员身份运行 PowerShell，
然后输入 set-executionpolicy remotesigned
输入Y即可





模仿知乎卡片链接

https://bestzuo.cn/posts/3858317073.html

https://lruihao.cn/posts/linkcard.html





### nodeppt

https://github.com/ksky521/nodeppt



## 参考资料

 Hexo博客优化之Next主题美化 https://blog.csdn.net/nightmare_dimple/article/details/86661502

官网 http://theme-next.iissnan.com/getting-started.html





欢迎关注我的微信公众号，扫描下方二维码，就可以找到我，我会持续为你分享 IT 技术和珠宝知识。

![欢迎关注我的微信公众号，扫描下方二维码，就可以找到我，我会持续为你分享 IT 技术和珠宝知识](https://pic1.zhimg.com/80/v2-8ff04a9934840c3c552ed41497bc4748_720w.jpg)

也可以关注我的个人博客

[点我试试的个人博客](https://dianwoshishi.github.io/)

