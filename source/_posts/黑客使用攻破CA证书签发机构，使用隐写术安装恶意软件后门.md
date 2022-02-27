---
title: [咨询]黑客攻破CA证书签发机构，使用隐写术安装恶意软件后门
date: 2022-02-26 14:03:45
---

# 黑客攻破CA证书签发机构，使用隐写术安装恶意软件后门

## 摘要

黑客攻破了蒙古国主要证书颁发机构之一MonPass的网站，用Cobalt Strike对其恶意软将安装后门。

![Mongolian Certificate Authority](https://thehackernews.com/images/-Pjw0E6xjSCY/YN8IHupWLeI/AAAAAAAADEk/T46SGyPXt3YcMQdOj7vEE7zF4DcDpIC8QCLcBGAsYHQ/s728-e1000/lock.jpg)

在另一起软件供应链攻击事件中，不明身份的黑客攻破了蒙古国主要证书颁发机构之一MonPass的网站，用Cobalt Strike对其恶意软将安装后门。还值得注意的是，此次攻击使用隐写术将shellcode转移到受害者机器上。

## 正文

![See the source image](https://tse2-mm.cn.bing.net/th/id/OIP-C.64Hv6plXekpzjFXedCGjawHaFL?pid=ImgDet&rs=1)

捷克网络安全软件公司Avast在周四发表的一份报告中说，该木马客户端在2021年2月8日至2021年3月3日期间提供下载。

此外，MonPass托管的一个公共网络服务器可能被渗透了多达8次，研究人员在被入侵的服务器上发现了8个不同的网络shell和后门。MonPass于4月22日被告知这一事件，此后，该证书机构采取措施修复被破坏的服务器，并通知那些下载了安装后门程序的客户端的人。

![Mongolian Certificate Authority](https://thehackernews.com/images/-_ISo0pRAJY4/YN8DFbddbNI/AAAAAAAADEU/WZufypAcSw4L00_h_9-SF5o_ZLVOdxeJACLcBGAsYHQ/s728-e1000/software.jpg)

## 原理

Avast对这一事件的调查是在它在一个客户的系统上发现后门安装和植入程序后开始的。

研究人员说："恶意安装程序是一个未签署的[PE文件]，"。"它首先从MonPass官方网站下载合法版本的安装程序。这个合法版本被丢到'C:\Users\Public\'文件夹中，并在一个新的进程中执行。这保证了安装程序的行为符合合法，这意味着普通用户不太可能注意到任何可疑之处"。

还值得注意的是，该操作方式使用隐写术将shellcode转移到受害者机器上，安装程序从远程服务器下载一个位图图像（.BMP）文件，以提取和部署一个加密的Cobalt Strike信标有效载荷(payload)。



## 影响

该事件标志着第二次由证书颁发机构提供的软件破坏，使目标感染了恶意的后门。2020年12月，ESET披露了一个名为 "Operation SignSight "的活动，其中越南政府认证机构（VGCA）的数字签名工具包被篡改，包括能够收集系统信息和安装额外恶意软件的间谍软件。



这一发展也是在本周早些时候，Proofpoint透露，威胁行为者活动中滥用Cobalt Strike渗透测试工具的情况达到顶峰，从2019年到2020年同比猛增161%。

"Cobalt Strike作为初始访问有效载荷(payload)在威胁行为者中越来越受欢迎，而不仅仅是威胁行为者在实现访问后使用的第二阶段工具，犯罪威胁行为者在2020年的Cobalt Strike活动中占了大部分。"Proofpoint研究人员说。

