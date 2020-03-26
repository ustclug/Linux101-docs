# 拓展阅读

!!! failure "本文目前尚未完稿，存在诸多未尽章节且未经审阅，不是正式版本。"

## Android/Linux {#android-linux}

## 关闭 SELinux {#close-seLinux}

读者在使用 Fedora、CentOS、Scientific Linux、RHEL 等系统时，可能会遇到这样的错误：

* SELinux is preventing XXXX from read access on the file YYYY.

这是因为有一个叫做 SELinux 的安全增强组件阻止了一些有潜在风险的操作。

SELinux 的全称是 Security-Enhanced Linux，起初是为了弥补 Linux 下没有强制访问控制（Mandatory Access Control, MAC）的缺憾，但是 SELinux 的设置相当繁复，由于默认设置不可能尽善尽美，一些配置上的小问题可能会影响用户的正常使用，而初学者没有足够的技能去调试 SELinux 策略。因此在初学时，可以暂且关闭 SELinux，在掌握足够的技能后再启用它。

??? tip "AppArmor"

    在 Debian、Ubuntu 系发行版中，默认使用的是称作 AppArmor 的同类组件。与 SELinux 相比，AppArmor 更简单一些，且一般不会对用户的正常使用造成困扰。

SELinux 有 3 种工作模式：

1. `enforcing`：SELinux 根据安全策略，积极阻止有潜在风险的操作。
2. `permissive`：SELinux 仅记录会被阻止的操作在日志中，但不做任何事。
3. `disabled`：SELinux 被彻底禁用，日志也不记录。

因此，只需将 SELinux 置于 `permissive` 或 `disabled` 状态即可。

使用 `sestatus` 命令查看 SELinux 状态：

```
$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      31
```

使用 `setenforce 0` **临时** 改变 SELinux 状态到 `permissive`，这个状态在重启后将恢复为配置文件指定的默认值。

```
# setenforce 0
```

修改 SELinux 的配置文件可以永久改变 SELinux 的工作状态。

1. 使用 root 权限编辑 `/etc/selinux/config` 文件；
2. 将 `SELINUX=enforcing` 中的 `enforcing` 改为 `disabled` 或 `permissive`。

编辑完成后，使用 `sestatus` 可以看到修改效果：

```
[...]
Current mode:                   permissive  # <-
Mode from config file:          permissive  # <- 或 disabled
[...]
```

## 适用于 Linux 的 Windows 子系统 (Windows Subsystem for Linux, WSL) {#wsl}

如何将 Linux 下的软件与开发生态移植到 Windows 上？在 WSL 出现之前，开发者们进行了各种尝试。这也催生出了一些软件与方案，例如：

- Cygwin。它包含了一大批 Linux 上的 GNU 和其他的开源工具。它的核心是一个程序库 (`cygwin1.dll`)，这个程序库在 Windows 环境下实现了 POSIX API 的功能。Linux 上的软件，可以通过**重新编译**，链接 Cygwin 的方式，在 Windows 上运行。
- MinGW。它包含了 GCC 和 GNU Binutils 等工具的 Windows 移植。它不支持类似于 `fork()` 这样无法简单用 Windows API 实现的 POSIX API，但是相比于 Cygwin 来说更加轻量，甚至可以在 Linux 上使用 MinGW 交叉编译 Windows 程序。
- MSYS2。使用 Cygwin 和 MinGW 组建的开发环境，并且使用 Pacman 作为包管理器。
- Cooperative Linux。这个项目尝试让 Linux 内核和 Windows 内核同时运行在相同的硬件上。Linux 内核经过修改，以能够与 Windows 内核共享硬件资源。这个项目已经长期未活跃了。

当然，我们可以看到，没有一个稳定的方案可以不加修改地直接运行 Linux 程序，直到 WSL 出现。WSL 由微软开发，可以在 64 位的 Windows 10 和 Windows Server 2019 上运行 ELF 格式的 Linux 程序。

!!! tip 不要将 WSL 与 Windows Services for UNIX (SFU) 混淆

    你可能会在老版本的 Windows 上注意到，在添加与删除 Windows 组件的地方，有一个「基于 UNIX 的应用程序子系统」。需要注意的是，这个选项和 WSL 没有任何关系。它也无法直接运行 Linux 或者其他 UNIX 的程序。并且，这个子系统目前也已经停止了开发。

### WSL1

第一代的 WSL (WSL1) 面向 Linux 应用程序提供了一套兼容的内核接口，在 Linux 程序运行的时候，WSL1 处理（Linux 使用的）ELF 的可执行文件格式，将 Linux 的系统调用翻译为 Windows 的系统调用，从而运行 Linux 程序。WSL1 中可以访问到 Windows 下的文件，也与主机共享网络。

### WSL2

第二代的 WSL (WSL2) 尝试解决一些 WSL1 的方式难以解决的问题：

- 由于其是以翻译系统调用的方式实现 Linux 兼容，WSL1 无法运行依赖于内核复杂特性的程序（如 Docker），无法运行硬件驱动程序。
- 没有硬件加速，图形性能差。OpenCL 与 CUDA 也尚未在 WSL1 中实现。
- 受到各种因素的影响（如 Windows Defender），WSL1 的 I/O 性能远低于 Linux 内核的实现。

WSL2 使用微软的 Hyper-V 虚拟化技术，运行一个轻量的、完整的 Linux 内核。