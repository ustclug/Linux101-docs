# 拓展阅读 {#supplement}

## 查看容器镜像的工具：Dive {#dive}

在调试容器时，我们可能想看一下使用的容器镜像里有哪些文件。[Dive](https://github.com/wagoodman/dive) 是一个很方便的小工具。

对于 Debian/Ubuntu 用户，由于其不在官方软件源中，需要手动下载 deb 包安装：

```shell
$ wget https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.deb
$ sudo apt install ./dive_0.9.2_linux_amd64.deb
```

之后直接使用即可：

```shell
$ dive ubuntu:20.04  # 查看 Ubuntu 20.04 镜像中的内容
```

## Docker 以外的容器工具 {#other-container-tools}

Docker 目前已几乎是容器的代名词了，但是实际上，用户还可以选择其他的程序来运行容器。其中一些代表性的方案有 Podman、LXC 等。

### Podman {#podman}

Podman 是由 Red Hat 编写的容器工具。相比于 Docker，Podman 是无守护进程的（daemonless），不需要像 Docker 一样运行系统服务。并且，Podman 的 CLI 工具与 Docker 的语法兼容（甚至可以设置 `alias docker=podman`），方便用户迁移到 Podman。

### LXC {#lxc}

相比于 Docker 专注应用容器化而言，LXC（Linux Containers）更加注重完整 Linux 系统的容器虚拟化，用户可以使用 LXC 启动一个近似完整的 Linux 系统。Canonical 公司基于 LXC 编写的 LXD 工具则为管理员提供了一个方便的管理接口。

### systemd-nspawn {#systemd-nspawn}

systemd-nspawn 是非常轻量级的容器，但「麻雀虽小，五脏俱全」。类似于 Unix 环境中历史悠久的 chroot，它能够很方便地从已有的系统文件启动，并且执行需要的系统管理命令。

### 自制简单的容器运行时 {#write-a-simple-container-runtime}

Linux 下的容器本身的运行原理并不复杂。在了解相关概念后，甚至可以自己写一个简单的容器实现。科大 OS(H) 课程 2020 年曾有过编写容器运行时的实验，详情可参考 [OSH 2020 Lab 4](https://osh-2020.github.io/lab-4/)。
