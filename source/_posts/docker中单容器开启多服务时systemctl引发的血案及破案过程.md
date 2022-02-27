---
title: docker中单容器开启多服务时systemctl引发的血案及破案过程
date: 2022-02-27 19:09:52
tags:
    - docker
    - systemd
    - systemctl
categories:
    - 编程开发
    - 运维管理
---

# docker中单容器开启多服务时systemctl引发的血案及破案过程

问题的起源来源于，想要将一个运行在centos7上的项目，移植到docker上，实现快速部署。原项目，我们暂且称之为`Myproject`， 提供了install_centos7.sh和Vagrant的构建文件。Vagrant 文件工作的很好，但是笔者是在虚拟机中完成的vagrant构建的验证，也遇见了不少问题，例如嵌套虚拟化的问题

但，虚拟机里面搞总感觉不得劲，又加上vagrant比较小众，我就盯上了Docker。本来想着这不是很简单吗，pull一个centos7的image，然后run一个container，bash install一下就完了呗。

没想到这就开始了，痛苦的采坑之旅。

## docker安装Myproject出现的的问题

由于docker的设计原则是一个container只运行一个服务，所以像Myproject这样的需要多个服务的(redis, httpd, psql, mongo, rabbitmq等)，想要在一个容器中使用，存在很多限制。

问题包括，但不限于[docker中执行systemctl命令问题记录和解决_WELTest的专栏-CSDN博客_docker systemctl](https://blog.csdn.net/henni_719/article/details/99689411)

[Not able to use systemd on ubuntu docker container - Stack Overflow](https://stackoverflow.com/questions/39169403/not-able-to-use-systemd-on-ubuntu-docker-container)

### 问题有：Failed to get D-Bus connection: Operation not permitted

解决这个问题的一个方法是使用`--privileged`和`/usr/sbin/init`

- privileged的作用是使得docker的环境以管理员角色运行

- /usr/sbin/init是

> /usr/sbin/init 启动容器之后可以使用systemctl方法  
> -privileged=true 获取宿主机root权限（特殊权限-）
> 
> [docker -privileged和/usr/sbin/init - lvph - 博客园](https://www.cnblogs.com/lph970417/p/14754072.html)

但是这个方法使用后出现了以下问题：

```shell
 ~  docker run -itd --privileged --name centos7 centos:7 /usr/sbin/init
a2f71d42e0f4c5c13b06a607da719df40e428305188c1a3154889a1bc4991f6d
 ~  docker exec -it centos7 ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.4  0.1  42716  3888 ?        Ss   10:44   0:00 /usr/sbin/init
root         8  0.0  0.1  51748  3400 pts/1    Rs+  10:44   0:00 ps aux
 ~  docker exec -it centos7 /bin/bash
[root@a2f71d42e0f4 /]# systemctl
Failed to get D-Bus connection: No such file or directory
```

还有一种方法是：run docker image with `docker run --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro <image>` and `systemctl` works fine

经过试验，也解决不了我的问题

```shell
 ~  docker run --privileged -itd  -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name centos7 centos:7 /usr/sbin/init
7ff1b85e7c9fecf17c889e0c2a25ab73203131ecdcb629180798fa1c07b4ee22
 ~  docker exec -it centos7 ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  1.0  0.1  42716  3944 ?        Ss   10:49   0:00 /usr/sbin/init
root         8  0.0  0.1  51748  3456 pts/1    Rs+  10:49   0:00 ps aux
 ~  docker exec -it centos7 /bin/bash
[root@7ff1b85e7c9f /]# systemctl
Failed to get D-Bus connection: No such file or directory


 ~  docker run -it \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --rm centos:7 /bin/bash
[root@9c3b2edf75ff /]# systemctl
Failed to get D-Bus connection: Operation not permitted
[root@9c3b2edf75ff /]#
```

### Failed to connect to bus: No such file or directory

在搜索资料的过程中发现了这篇文章， 对这个问题的解释比较到位：[如何在Docker里面使用systemctl - Ehds](https://ehds.github.io/2021/01/21/docker_systemctl/)

**容器里面是没有systemd进程的，而很多进程管理工具都需要和systemd通信，这里面就有我们这里的主角systemctl。docker只是提供了进程隔离，不是操作系统的虚拟。**

> That’s because “systemctl” talks to the systemd daemon by using the d-bus. In a container there is no systemd-daemon. Asking for a start will probably not quite do what you expect - the dev-mapping need to be a bit longer. 
> This is by design. Docker should be running a process in the foreground in your container and it will be spawned as PID 1 within the container’s pid namespace. Docker is designed for process isolation, not for OS virtualization, so there are no other OS processes and daemons running inside the container (like systemd, cron, syslog, etc), only your entrypoint or command you run.  
> If they included systemd commands, you’d find a lot of things not working since your entrypoint replaces init. Systemd also makes use to cgroups which docker restricts inside of containers since the ability to change cgroups could allow a process to escape the container’s isolation. Without systemd running as init inside your container, there’s no daemon to process your start and stop commands.

给出解决方案，确实能work

>   解决方案
> 
> 1. 我们可以在启动容器的时候将在启动参数加上 /sbin/init 来让其生效。  
>    以centos为例：  
>    `docker run -d -v /sys/fs/cgroup/:/sys/fs/cgroup:ro --cap-add SYS_ADMIN --name systemd_websrv centos /sbin/init`  
>    就可以正常使用systemd了  
>    但是如果容器重启，那么就可能导致失效。
> 
> 2. 替换systemctl  
>    使用 [docker-systemctl-replacement](https://github.com/gdraheim/docker-systemctl-replacement)替换容器中的systemctl。  
>    以ubuntu镜像为例：  
>    1). 安装python2  
>    `sudo apt install python`  
>    2). 替换systemcl (注意路径，可以使用`whereis systemctl`查看当前默认路径)  
>    `wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py -O /bin/systemctl`  
>    3). 给定权限  
>    `sudo chmod a+x /bin/systemctl`  
>    这样接可以使用非systemd的systemctl，但是因为是非官方的systemcl所以可能存在一些未知问题。
> 
> 最好还是建议将docker作为进程隔离环境，`single app single container`， 但是遇到非常特殊的情况下，可以上述两个解决方案，如果有更好的方案，欢迎提出。

上面这些在单容器单服务下都工作的很好，但是在笔者的场景下呢？情况不是太好

### 事情还没有完

当我们想要像在虚拟机上一样，在一个容器中运行多个container，比如一般网站的配置，redis，httpd，mongo，rabbitmq等等，这该怎么搞？不要问我为什么不把容器拆分，要问就是配置起来太麻烦了。

笔者遇到一个问题就是，按照上述copy的方法对container中所有服务安装完毕之后，一切非常正常，但问题发生在，重启container，systemctl就再也启动不起来某些服务，例如httpd，psql等。

经过一番周折，以及和systemctl.py的作者进行沟通，最后发现：其实这个问题的根源还是在`systemctl`上.

在centos系统中，systemctl需要使用d-bus来与systemd通信，完成服务的启动。但是在docker的容器中并没有systemd-daemon的守护进程，所以上述通信是不会完成的。这就导致了前面所说的两个问题:D-Bus connection: Operation not permitted以及No such file or directory的问题

下面举个例子

一般我们启动容器的过程一般使用`docker run -t -i centos:7 /bin/bash`, 那么容器中一号进程就是`/bin/bash`, 而不是我们熟悉的systemd。

```shell
 ~  docker pull centos:7
7: Pulling from library/centos
2d473b07cdd5: Downloading
7: Pulling from library/centos
2d473b07cdd5: Pull complete
Digest: sha256:c73f515d06b0fa07bb18d8202035e739a494ce760aa73129f60f4bf2bd22b407
Status: Downloaded newer image for centos:7
docker.io/library/centos:7
 ~  docker run -itd --name centos7 centos:7
c625bedacd894f9db6ca065839e413bb02e46cf6b602822f26baebfab745982a
 ~  docker exec -it centos7 ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.4  0.1  11844  2944 pts/0    Ss+  10:41   0:00 /bin/bash
root        14  0.0  0.1  51748  3448 pts/1    Rs+  10:41   0:00 ps aux
```

对象都没有了，所以暴d-bus的错误，就很容易解释了。

上述描述是对这个问题的通俗解释，想要了解关于这个问题的根本原因可以看下面两个链接，进一步了解，基本都是在解释一号进程的问题

[linux - how to solve Docker issue Failed to connect to bus: No such file or directory - Stack Overflow](https://stackoverflow.com/questions/49285658/how-to-solve-docker-issue-failed-to-connect-to-bus-no-such-file-or-directory)

[Not able to use systemd on ubuntu docker container - Stack Overflow](https://stackoverflow.com/questions/39169403/not-able-to-use-systemd-on-ubuntu-docker-container)

## 解决方案

问题的根源找到了，解决这个问题的思路就非常的清晰了，就是使服务的管理不依赖于systemd。

> Do not rely on systemd as a process manager but have the docker container run your desired application in the foreground.

有一款工具，就能够实现执行systemctl而不依赖于systemd，他就是[GitHub - gdraheim/docker-systemctl-replacement: docker systemctl replacement - allows to deploy to systemd-controlled containers without starting an actual systemd daemon (e.g. centos7, ubuntu16)](https://github.com/gdraheim/docker-systemctl-replacement)， 这个github仓库专门在处理这个问题。同时，如果你不想写一些dockerfile来实现上述过程，你也可以使用该作者的另一个仓库，[docker-systemctl-images/centos-httpd.dockerfile at master · gdraheim/docker-systemctl-images · GitHub](https://github.com/gdraheim/docker-systemctl-images/blob/master/centos-httpd.dockerfile)

在这里，作者给出了很多版本的可以使用systemctl的镜像，非常的有用。

### 在使用systemctl的过程中，其实也踩了很多坑

**第一个问题是，什么时候拷贝的问题？**

最最朴素的想法是，拷贝一次就行了呗，当初我也是这样想的，结果，水很深。

> Most os packages with a systemd service have declared a dependency on systemd. When you install an os package it updates systemd which overwrites /usr/bin/systemctl which in turn kills the replacement functionality. The next "systemctl" is again executed by systemd which does not work in a container easily as you know. So after a os package install it helps to just drop-in the replacement script again.
> 
> [can not start the service when reboot? · Issue #137 · gdraheim/docker-systemctl-replacement · GitHub](https://github.com/gdraheim/docker-systemctl-replacement/issues/137#issuecomment-1052164317)

这是与作者沟通时候，作者的解释，很容易懂，大致就是，安装软件时会更新systemctl，那么我们之前一次的拷贝不就失效了嘛。所以安装了软件之后，就拷贝一下吧！！！

时机：

> After "yum install" and before the next "systemctl" execution.
> 
> [can not start the service when reboot? · Issue #137 · gdraheim/docker-systemctl-replacement · GitHub](https://github.com/gdraheim/docker-systemctl-replacement/issues/137#issuecomment-1052200067)

**第二个问题是，启动点设为systemctl还是/bin/bash/还是/usr/sbin/init.**

首先给出答案，需要设置成systemctl，因为它负责移除对systemd的依赖，所以要让它成为一号进程。

这个可以看看作者给出的dockerfile

```dockerfile
FROM centos:7.7.1908

LABEL __copyright__="(C) Guido Draheim, licensed under the EUPL" \
      __version__="1.4.4147"
EXPOSE 80

COPY files/docker/systemctl.py /usr/bin/systemctl
RUN yum install -y httpd httpd-tools
COPY files/docker/systemctl.py /usr/bin/systemctl

RUN echo TEST_OK > /var/www/html/index.html

RUN systemctl enable httpd
CMD /usr/bin/systemctl
```

## 总结

- **问题的根源在`systemctl`,它需要像docker容器中的systemd通信，但是却没有对象
- 解决问题的方法在于，解除systemctl与systemd的依赖关系，这里我们用到了一个systemctl.py的工具
- 使用systemctl.py需要注意拷贝的时机，以及设置systemctl作为容器一号进程

## 参考资料及备注

### 一号进程有什么作用？

Docker 的 stop 和 kill 命令都是用来向容器发送信号的。注意，只有容器中的 1 号进程能够收到信号，这一点非常关键！究竟谁是 1 号进程则主要由 EntryPoint, CMD, RUN 等指令的写法决定，所以这些指令的使用是很有讲究的。[在 docker 容器中捕获信号 - sparkdev - 博客园](https://www.cnblogs.com/sparkdev/p/7598590.html)

CMD 和 ENTRYPOINT 指令都支持 exec 模式和 shell 模式的写法，所以要理解 CMD 和 ENTRYPOINT 指令的用法，就得先区分 exec 模式和 shell 模式。这两种模式主要用来指定容器中的不同进程为 1 号进程。

使用 exec 模式时，容器中的任务进程就是容器内的 1 号进程，exec 模式是建议的使用模式

使用 shell 模式时，docker 会以 /bin/sh -c "task command" 的方式执行任务命令。也就是说容器中的 1 号进程不是任务进程而是 bash 进程

CMD 指令的目的是：为容器提供默认的执行命令。  
CMD 指令有三种使用方式，其中的一种是为 ENTRYPOINT 提供默认的参数：  
**CMD ["param1","param2"]**  
另外两种使用方式分别是 exec 模式和 shell 模式：  
**CMD ["executable","param1","param2"]**    // 这是 exec 模式的写法，注意需要使用双引号。  
**CMD command param1 param2**                  // 这是 shell 模式的写法。

注意命令行参数可以覆盖 CMD 指令的设置，但是只能是重写，却不能给 CMD 中的命令通过命令行传递参数。

ENTRYPOINT 指令的目的也是为容器指定默认执行的任务。  
ENTRYPOINT 指令有两种使用方式，就是我们前面介绍的 exec 模式和 shell 模式：  
**ENTRYPOINT ["executable", "param1", "param2"]**   // 这是 exec 模式的写法，注意需要使用双引号。  
**ENTRYPOINT command param1 param2**                   // 这是 shell 模式的写法。

**指定 ENTRYPOINT  指令为 exec 模式时，命令行上指定的参数会作为参数添加到 ENTRYPOINT 指定命令的参数列表中**

命令行参数被 ENTRYPOINT  指令的 shell 模式忽略了。

https://www.ctl.io/developers/blog/post/dockerfile-entrypoint-vs-cmd/

### 其他参考资料

[Not able to use systemd on ubuntu docker container - Stack Overflow](https://stackoverflow.com/questions/39169403/not-able-to-use-systemd-on-ubuntu-docker-container)
