---
title: VSCode Markdown Snippet插件的使用问题备注
top: false
cover: false
toc: true
mathjax: true
date: 2022-02-26 17:22:13
password:
summary:
tags:
categories:
---



# VSCode Markdown Snippet插件的使用问题备注

## 官方给出的使用帮助

https://code.visualstudio.com/docs/editor/userdefinedsnippets



## 一个简短的示例

https://www.jianshu.com/p/a87e9ca2d208



记得在配置文件中添加相应的配置，不仅仅是相关语言的配置哦，setting中也记得

https://blog.csdn.net/serryuer/article/details/89393760





## 代码备注

```json
"hexo title": {
		"prefix": "hexo",
		"body": [
			"---",
			"title: $CLIPBOARD",
			"date: ${3:$CURRENT_YEAR}-${4:$CURRENT_MONTH}-${5:$CURRENT_DATE} ${6:$CURRENT_HOUR}:${7:$CURRENT_MINUTE}:${8:$CURRENT_SECOND}",
			// "categories: ${9|咨询, 编程开发, 网络空间, 学习笔记, 科普|}",
			// "tags: [${10:tags}]",
			"---",
			"$11"
		],
		"description": "Front-Matter"
	}
```

效果如下所示：

```yml
---
title: 大家好，我是明说网络的小明同学
date: 2022-02-26 17:20:22
---
```

