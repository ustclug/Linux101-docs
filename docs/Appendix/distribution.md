# 其他的 Linux 发行版：技术差异简介

在 Linux 101 讲义中，我们默认使用的发行版是 Ubuntu。当然，可能你正在使用其他的 Linux 发行版。尽管大部分的内容都是通用的，但发行版之间仍然或多或少存在一些差别。下面会简要介绍其他的发行版中需要注意的地方。

## Debian GNU/Linux，与其他的 Debian 衍生版本

Ubuntu 基于 Debian，并且相比 Debian 而言更加新手友好。而 Debian 的开发周期更慢，它的 Stable 分支也更加稳定。在很多方面来说，它们的区别不大，但是仍然需要注意一些事情：

- 不同的发行版、不同的分支的软件源不能混用。向 Debian 添加 Ubuntu 或 Ubuntu PPAs 的源可能会导致软件依赖的混乱。
- Debian 不会预置一些 Ubuntu 特有的特性。从 `snap`, Livepatch（在不停机的情况下修复内核漏洞的服务）到 `zsys`（由 Ubuntu 开发的 ZFS 管理工具）都不会预置在 Debian 中。
- 在日常使用中，Debian 也有一些小的区别，例如默认情况下，`/sbin` 不在普通用户的 PATH 中。

## CentOS 与 Fedora

### 软件包管理

「红帽系」的 Linux 发行版与 Ubuntu 等 Debian 系列的发行版最直观的区别就在于它们使用的软件包管理方式不一样。一般使用 `dnf`（推荐）或者 `yum` 来进行软件包管理。`dnf` 和 `yum` 都是使用 Python 编写的程序，谨慎变动系统 Python 环境，以免出现问题。

简单使用：

```shell
$ sudo dnf install audacity  # 安装 audacity
$ sudo dnf remove firefox  # 卸载 firefox
$ sudo dnf search thunderbird  # 搜索 thunderbird
$ sudo dnf upgrade  # 更新系统
```

此外，`dnf` 和 `yum` 还可以回滚到以前的软件安装状态，具体可以自行搜索了解。

### 关于 SELinux

SELinux 是由 NSA 编写的开源的 Linux 安全模块，在 CentOS 和 Fedora 上都默认开启。SELinux 解决的问题是，传统的 DAC（自主访问控制, Discretionary Access Control）安全模型（我们在第五章中看到的 `rwx` 就是传统的模型）无法有效应对一些安全风险，如[^1]：

- 用户可能会把「任何人都可读取」的权限赋予在敏感文件（如 SSH 密钥）上。
- 用户的进程可以修改文件的安全性属性。例如，邮件程序可以（尽管不应该）将邮件文件设置为「任何人都可读取」。
- 用户的进程继承用户的权限，如果进程本身有问题或是不安全，那么攻击者可以以该用户的权限作任何事情。例如，如果浏览器被攻击，它可以读取到用户的 SSH 密钥，但浏览器显然不应该做这种事情。

虽然很多人安装完 CentOS/Fedora 之后做的头几件事之一，就是把 SELinux 关掉。它可能会导致一些「奇怪的」权限问题，或是让某些程序运行失败。

在 Ubuntu 等发行版中，与 SELinux 相对应的是 AppArmor。

## Arch Linux

### Arch Wiki

Arch Wiki (<https://wiki.archlinux.org/>) 是安装和使用 Arch Linux 必读的资料，内容非常详细。就算不是 Arch 的使用者，Wiki 的内容也非常有参考价值。

### 软件包管理

Arch 使用的默认软件包管理器是 `pacman`。以下是一些常用的命令。

```shell
$ sudo pacman -Syu  # 更新系统所有软件包
$ sudo pacman -S firefox  # 安装 Firefox
$ sudo pacman -Rs chromium  # 卸载 Chromium 和它的所有依赖
$ sudo pacman -Ss audacity  # 搜索 Audacity
```

#### 手动介入 (manual intervention)：更新失败时的处理方式

由于其滚动发行的特性，在更新时可能会出现安装错误的情况。一般来说，你需要关注 Arch 的主页新闻 (<https://www.archlinux.org/>)，当有软件包需要手动介入更新时，可以看到错误提示和解决方法。

#### AUR

AUR (Arch User Repository) 由 Arch 用户维护，是 Arch Linux 的一大特色。其上包含了大量的程序可供安装。用户可以对软件包评论、投票，与各自的维护者交流。

有很多的程序（统称为 AUR Helper）可以帮助从 AUR 上下载安装包，例如 `yay`。

[^1]: <https://wiki.centos.org/zh/HowTos/SELinux>
