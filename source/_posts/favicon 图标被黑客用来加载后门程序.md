---
title: favicon 图标被黑客用来加载后门程序
date: 2022-02-26 14:11:22
---

# favicon 图标被黑客用来加载后门程序

![img](https://www.cybersafe.news/wp-content/uploads/2021/05/magecart-640x400.jpg)

网络犯罪分子正在分发伪装成favicon的恶意PHP web shells，以实现对被攻击服务器的远程访问，并将JavaScript skimmers注入在线购物平台，目的是窃取用户的财务信息。

Malwarebytes Jérôme Segura表示，这些被称为Smilodon或Megalodon的Web shells被用来通过服务器端请求动态加载JavaScript skimming代码到在线商店。这种技术很有趣，因为大多数客户端的安全工具将无法检测或阻挡盗取者。

## 原理

Magecart，针对在线购物网站的黑客组织使用在电子商务网站上注入网络盗取器(web skimmers)的技术来窃取信用卡的详细信息。盗取器(skimmers )也被称为形式劫持攻击，盗取器采取JavaScript代码的形式，操作者秘密插入电子商务网站，通常是在支付页面，目的是实时捕捉客户的银行卡信息，并将其传输到远程服务器。

注入式盗刷器的工作原理是，当客户访问网店时，向托管在攻击者控制的域名上的外部JavaScript资源发出客户端请求。然而，最新的攻击有点不同，因为盗取代码是在服务器端动态引入商家网站的。

基于PHP的网络外壳恶意软件伪装成favicon（"Magento.png"），通过篡改HTML代码中的快捷图标标签指向假的PNG图像文件，将恶意软件插入到被攻击的网站。这个网络shell又被配置为从外部主机-获取下一阶段的有效载荷:一个信用卡盗刷器。

## 恶意活动关联

基于TTPs( tactics, techniques, and procedures)的重叠，最新的活动被归结为Magecart Group 12。Malwarebytes补充说，他们发现的最新域名（zolo[.]pw）恰好与recaptcha-in[.]pw和google-statik[.]pw托管在同一个IP地址（217.12.204[.]185），这两个域名之前与Magecart Group 12有关。

在过去的几个月里，Magecart的行为者使用了几种攻击技术来避免被发现和渗出数据。