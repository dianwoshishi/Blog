---
title: 警报! 物联网恶意软件Mirai和其他十几个变种依然活跃
date: 2022-02-26 14:07:58
---

# 警报! 物联网恶意软件Mirai和其他十几个变种依然活跃

## 摘要

Mirai僵尸网络自2016年首次出现以来，已经有近五年的时间。自Mirai出现以来，一直是一个持续的物联网安全威胁。该恶意软件及其几个变种被认为是2021年第一季度引发对物联网（55%）和Linux（38%）系统攻击激增的原因。物联网设备制造商需要及时修补漏洞，并遵循适当的物联网安全标准。

![img](https://i.pcmag.com/imagery/articles/04radPg0HVCyUfpdTaKkJ63-2.1569487823.fit_lim.jpg)



Mirai僵尸网络自2016年首次出现以来，已经有近五年的时间。自Mirai出现以来，一直是一个持续的物联网安全威胁。在McAfee最近的一份报告中，该恶意软件及其几个变种被认为是2021年第一季度引发对物联网（55%）和Linux（38%）系统攻击激增的原因。 安全研究人员警告说，恶意软件一直在控制世界各地的路由器、网络摄像机和DVR，以创建一个能够扰乱互联网的巨大僵尸网络。

![Alert! Mirai Botnet is Active and So are its Dozen Other Variants](https://cyware-ent.s3.amazonaws.com/image_bank/90cf_shutterstock_530465965.jpg)

物联网恶意软件在互联网上扫描使用默认或薄弱用户名和密码的物联网设备。他们还寻求利用已知的，有时甚至是零日(0Day)漏洞来增加他们获得设备访问权限的机会。一旦触发漏洞，就会自动下载并执行恶意二进制文件，使物联网设备成为僵尸网络的一部分，然后可能被攻击者控制参与分布式拒绝服务（DDOS）攻击，导致被攻击目标服务中断。一些威胁者甚至将这些控制的僵尸网络作为一项服务（DDoS-for-Hire/ DDoS as a Service)出售。

## 变种继续增长



自从Mirai的作者发布源代码以来，威胁者一直在通过创建他们自己的物联网僵尸网络军队的来发动大量的攻击。
虽然各种Mirai变体不断增加新的功能和漏洞，但其结构和目标仍然是相同的。

![See the source image](https://tse4-mm.cn.bing.net/th/id/OIP-C.kDawNYcjW-OuXL0ZbHHzawHaFW?pid=ImgDet&rs=1)



## 评估Mirai的突出地位

Fortinet的研究人员在跟踪物联网僵尸网络活动的过程中遇到了许多有趣的方面。
一个用于此目的的新蜜罐(Honeypot)系统被发现每天收到约200次攻击，在短短三周内总和接近4700次攻击。
这些攻击中约有4000次与Mirai变体有关。根据这些攻击，使用最多的变种是Hajime, SYLVEON, Kyton, PEDO, DNXFCOW, SORA, Cult, BOTNET, OWARI, 和Ecchi。
除了蜜罐，研究人员还发现Mirai的一个变种MANGA正在积极更新其列表中的漏洞载体。其中一些漏洞是针对OptiLink ONT1GEW GPON、Cisco HyperFlex和Tenda路由器中发现的漏洞。



## 另一个Mirai变体Moobot的活动出现了高峰

根据AT&T外星人实验室(AT&T Alien Labs)的说法，另一个Mirai变体Moobot的活动出现了高峰。
事实证明，它是从一个新的网络地下恶意软件域推送出来的，该域被称为Cyberium，一直在锚定大量的Mirai变体活动。
研究人员观察到，Moobot正在积极扫描Tenda路由器中的一个远程代码执行漏洞。
Moobot的主要特征之一是在代码中多次使用硬编码字符串，如生成执行时使用的进程名称。

## 结论

随着智能设备的数量不断爆炸，物联网在未来仍将是恶意软件运作的温床。显然，Mirai变种在攻击和发展方面的活跃状态使其更加令人担忧。它也再次强调物联网设备制造商需要及时修补漏洞，并遵循适当的物联网安全标准。