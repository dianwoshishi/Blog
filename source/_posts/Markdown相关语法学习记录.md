---
title: Markdown相关语法学习记录
date: 2022-02-27 12:15:30
tags:
  - markdown
  - 流程图
categories:
  - 编程语言
  - 笔记记录
---







# markdown 中流程图详解

https://blog.csdn.net/suoxd123/article/details/84992282

```mermaid
graph TB
A[Apple]-->B{Boy}
A---C(Cat)
B.->D((Dog))
C==喵==>D
style A fill:#2ff,fill-opacity:0.1,stroke:#faa,stroke-width:4px
style D stroke:#000,stroke-width:8px;
```

```mermaid

    sequenceDiagram
    participant 张 as 张三
    participant 李 as 李四
    participant 王 as  王五   
    张 ->> +李: 你好！李四, 最近怎么样?
    李-->> 王: 你最近怎么样，王五？
    李--x -张: 我很好，谢谢!
    activate 王
    李-x 王: 我很好，谢谢!   
    Note over 李,王: 李四想了很长时间, 文字太长了<br/>不适合放在一行.
    deactivate 王
    loop 李四再想想
    李-->>王: 我还要想想
    王-->>李: 想想吧
    end
    李-->>张: 打量着王五...
    张->>王: 很好... 王五, 你怎么样?

```



实测，在本博客系统中不支持流程图特性，不过typora支持，这。。。反正不影响。先这么用着吧
