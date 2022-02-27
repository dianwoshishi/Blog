---
title: 每天感染1000台设备，这款恶意软件专为挖矿而来、超过9000个XMR币被开采出来
date: 2022-02-26 14:10:07
---

# 每天感染1000台设备，这款恶意软件专为挖矿而来、超过9000个XMR币被开采出来

![img](https://www.cybersafe.news/wp-content/uploads/2021/06/monero-800x400.png)

## 摘要

一款在攻击过程中利用Windows安全模式的加密货币挖矿恶意软件被发现，每天约有1,000台设备被攻击，全球已有超过22.2万台机器被感染。该恶意软件至少从2018年6月就开始蔓延，最新版本于2020年11月发布。研究人员表示，只要人们还下载破解的软件，恶意软件就会一直蔓延下去

## 名为Crackonosh的恶意软件

一款在攻击过程中滥用Windows安全模式的加密货币挖矿恶意软件被发现，它通过盗版和破解软件传播，并经常出现在torrents, forums, 和 "warez "网站中。

Avast的研究人员将这种恶意软件称为Crackonosh。研究人员指出，该恶意软件至少从2018年6月就开始蔓延，第一个受害者是运行伪装成合法软件的破解版软件而被攻击。

每天约有1,000台设备被攻击，全球已有超过22.2万台机器被感染。

主要利用系统算力和资源来挖掘[门罗币](https://www.xmr-zh.com/)（XMR）（一种加密货币）。Crackonosh总共产生了至少200万美元的门罗币，有超过9000个XMR币被开采出来。

![查看源图像](https://img.jinse.com/281169_image3.png)

![查看源图像](https://www.getmonero.us/upload/attach/202009/1_UB57RFD5QRG5WYD.jpg)

到目前为止，该恶意软件的30个变种已被确认，最新版本于2020年11月发布。





## 感染流程

### 启动

感染链从一个安装程序和一个修改Windows注册表的脚本开始，允许主要的恶意软件可执行文件在安全模式下运行。被感染的系统被设置为在下次启动时以安全模式启动。

### 抗杀软

研究人员说，当Windows系统处于安全模式时，杀毒软件就不会工作。这使得恶意的Serviceinstaller.exe能够轻易地禁用和删除Windows Defender。它还使用WQL查询所有安装的杀毒软件` SELECT * FROM AntiVirusProduct`.

Crackonosh将检查防病毒程序的存在，如Avast、Kaspersky、McAfee的扫描器、Norton和Bitdefender - 并尝试禁用或删除它们。然后擦除日志系统文件以掩盖其痕迹。

### 阻止Windows更新

Crackonosh还将试图停止Windows更新，并将用一个假的绿色勾选托盘图标取代Windows安全。

### 挖矿

最后，部署了一个XMRig，这是一个加密货币矿工，利用系统算力和资源来挖掘[门罗币](https://www.xmr-zh.com/)（XMR）（一种加密货币）。



Avast研究人员表示，只要人们还下载破解的软件，恶意软件就会一直蔓延下去



