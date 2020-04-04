# 八：Docker

!!! Failure "本文目前尚未完稿，存在诸多未尽章节且未经审阅，不是正式版本。"

!!! abstract "导言"

    「容器」，是近年来非常热门的一个概念。它通过操作系统内核提供的隔离技术，实现轻量级的虚拟化环境。目前，它在软件的开发、部署等方面有着非常广泛的应用。

    而 Docker，是 Linux 容器技术中的代表性软件，它为用户提供了方便的接口来创建、使用 Linux 容器。下面，就让我们简单地入门一下 Docker。

## 为什么使用 Docker？ {#why-docker}

Docker 能够利用 Linux 内核的容器特性，隔离出一个轻便的环境来运行程序。这有什么意义呢？试想以下这些情况：

- 你运行的 Linux 发行版很老，而你需要运行一个给新版本的 Linux 发行版，或者完全不同的 Linux 发行版设计的程序。
- 你和朋友在设计一个大型的程序，而因为你们配置的环境不同，有时候在某个人的机器上正常运行的程序，在另一台机器上没法正常运行。
- 你希望在多台服务器上部署一个项目，但是项目需要非常复杂的配置，一个一个配置服务器的成本非常大。
- …………

Docker 就可以帮助解决这些问题。它可以快速配置不同的环境（比如说，通过 Docker，你可以在 Ubuntu 上使用 CentOS 的环境），部署应用。

## 安装 Docker {#install-docker}

Docker 可以在 Windows, Linux 和 macOS 上安装。下面我们讨论内容都基于 Docker 免费的社区版本。

### 在 Windows 或 macOS 上安装 {#install-on-windows-or-macos}

上面提到，Docker 使用了 Linux 内核的容器特性，它依赖于 Linux。所以在 Windows 和 macOS 上，Docker 不得不通过虚拟 Linux 内核的方式来完成任务。其提供了一套被称为 Docker Desktop 的软件来帮助在 Windows 和 macOS 上配置 Docker。直接从[官网下载](https://www.docker.com/products/docker-desktop)即可。

!!! info "Docker Desktop on Windows 的环境要求"

    Docker Desktop on Windows 要求系统为 64 位的 Windows 10 专业版，硬件支持 Hyper-V 虚拟化且 Hyper-V 已经开启。目前在 Hyper-V 开启的情况下，如 VirtuaBox 和 VMware Workstation 等虚拟机软件无法正常使用。如果环境要求无法达到，可以安装[老版本的 Docker Toolbox on Windows](https://docs.docker.com/toolbox/toolbox_install_windows/)。

!!! note "Windows 容器"

    你可能会搜索到，Docker 也支持「Windows 容器」。是的，在新版本（1607 之后）的 Windows 10 中，Windows 内核支持 Windows 容器。可以在这样的容器中运行 Windows 程序。如果你感兴趣，可以阅读[微软的 Containers on Windows Documentation](https://docs.microsoft.com/en-us/virtualization/windowscontainers/) 和 [Docker Windows Containers 的介绍](https://www.docker.com/products/windows-containers)。这样的容器无法运行 Linux 程序，下面也不会涉及到。

### 在 Linux 上安装 {#install-on-linux}

各大发行版的软件源包含 Docker，也可以跟从[官方文档](https://docs.docker.com/install/linux/docker-ce/debian/)，安装其提供的 Docker 社区版本。

!!! info "docker, docker.io 和 docker-ce"

    首先，在 Debian/Ubuntu 上，**不要运行 `sudo apt install docker`**。现在，这里安装的 `docker` 是一个系统托盘程序，和本章的 Docker **没有任何关系**。

    `docker.io` 是由 Debian/Ubuntu 维护的 Docker 版本，和软件源里的其他程序一样，它比官方的最新版本要稍微老一些。它所依赖的程序库由 Debian/Ubuntu 软件源中的其他软件包提供。

    而 `docker-ce` 是由 Docker 官方维护的。它依赖的程序库都被打包在了这个包中。本章中，可以安装这两个版本中的任意一个。

!!! warning "不要在 WSL1 上安装 Docker"

    WSL1 在 Windows 上提供了方便的 Linux 环境。但很遗憾，Docker 的核心服务无法在 WSL1 上运行，直接安装是无法使用的。虽然可以把 WSL 中的 Docker 的命令行工具连接到 Docker for Windows 的核心服务上，但是比较麻烦，这里不推荐这样做。

### 配置 Registry Mirror（可选，推荐） {#setup-registry-mirror}

!!! failure "此段落需要编辑，添加可用的 Registry Mirror。"

Docker 默认从 Docker Hub 上拖取所需要的镜像。但由于网络原因，拖取的过程可能会比较慢。幸运的是，一些服务在中国提供了 Docker Hub 的镜像，~~微软 Azure 和~~网易云就是其中两个。

为了使用~~微软 Azure 和~~网易云的 Docker Hub 镜像，在 Debian/Ubuntu 上，可以编辑 `/etc/docker/daemon.json` 文件（如果文件不存在，请新建一个），写入以下内容。

```json
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com"
  ]
}

```

使用 `sudo systemctl restart docker` 命令重启 Docker 服务后，再次运行 `docker info` 命令，可以看到如下输出：

```text
 Registry Mirrors:
  https://hub-mirror.c.163.com/
```

如果你看到了上面的输出，说明你的 Docker Registry Mirror 已经配置好了。

### 使用 Hello World 测试 Docker 安装 {#verify-docker-setup}

Docker 官方提供了最精简的 `hello-world` 镜像，可以用来验证 Docker 安装是否正确、是否正常工作。尝试运行 `docker run --rm hello-world` 看看吧。

```text
$ docker run --rm hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

如果你看到了像上面这样的输出，说明你安装的 Docker 已经一切准备就绪，可以使用了。

## 使用 Docker 容器 {#use-docker}

接下来我们来尝试几个例子，体验 Docker 环境的独立性与易用性。

!!! failure "以下内容均为草稿，亟待扩充，不是正式内容"

### 在 Ubuntu 容器中使用 shell {#use-ubuntu-bash}

- `docker run ubuntu` blah blah

### 在 Python 容器中使用 Python 命令行 {#use-python-repl}

- `docker run python` blah blah

### 在 MkDocs 容器中构建本书 {#use-mkdocs-material-build}

- 从 GitHub 上获取本书源码
- `docker run -v aaa:bbb -p 8000:8000 squidfunk/mkdocs-material server` blah blah

## 构建自己的 Docker 镜像 {#build-docker-image}

### 手工构建镜像 {#build-manually}

- docker exec 进去把东西准备好，然后 `docker commit`

### 使用 Dockerfile 自动化构建 {#build-with-dockerfile}

!!! tip "尽量减少 Docker 镜像的层数"

    TBA

## 使用 Docker Compose 自动运行容器 {#docker-compose}

### 子项目？
