---
title: 一个用Go编程语言编写的新木马被用于勒索攻击
date: 2022-02-26 14:09:59
---

# 一个用Go编程语言编写的新木马被用于勒索攻击

![img](https://cystory-images.s3.amazonaws.com/GoLang_Malware.png)




被称为ChaChi的恶意软件，在2020年上半年被发现，远程访问木马（RAT）的原始变体已经与针对法国地方政府当局的网络攻击有关，但现在，一个更为复杂的变体已经出现。现有的最新样本已与针对美国大型学校和教育机构发起的攻击有关。

## Go语言开发的恶意软件



ChaChi是用GoLang（Go）编写的，这种编程语言由于其通用性和跨平台代码编译的便利性，现在被攻击者使用。 

![img](https://www.cybersafe.news/wp-content/uploads/2021/06/Golang-800x400.png)

据Intezer称，在过去几年中，基于Go的恶意软件样本大约增加了2000%。据黑莓威胁研究和情报部门的研究团队称，由于这是一个新现象，许多核心分析工具仍在开发。这可能使分析Go的恶意软件更具挑战性。

![img](https://unit42.paloaltonetworks.com/wp-content/uploads/2019/07/golang-hacker.jpg)

## 命名

ChaChi之所以这样命名，是因为Chashell和Chisel是恶意软件在攻击过程中使用的两个现成的工具。Chashell是一个通过DNS提供的反向外壳，而Chisel是一个端口转发系统。

## 能力

与ChaChi的第一个变种相比，该恶意软件具有较差的混淆和低级别的攻击能力，现在能够执行典型的RAT活动，包括创建后门和数据渗透，以及通过Windows本地安全授权子系统服务（LSASS）进行证书转储、网络枚举、DNS隧道、SOCKS代理功能、服务创建和跨网络横向移动。该恶意软件使用一个可开源的GoLang工具gobfuscate进行混淆。



## 黑客组织PYSA

黑莓研究人员认为，该木马是PYSA/Mespinoza的作品，该威胁组织以发起勒索软件活动和使用扩展名而闻名。当受害者的文件被加密时，PYSA代表 "保护你的系统Amigo"。

通常PYSA专注于 "猎杀大型游戏"( “big game hunting” )，并挑选那些能够支付大笔赎金的目标。这些攻击是有针对性的，由人类操作员控制，而不是自动化执行。