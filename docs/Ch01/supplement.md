---
icon: material/puzzle
---

# 拓展阅读 {#supplement}

!!! Warning "本文已基本完稿，正在审阅和修订中，不是正式版本。"

## Android/Linux {#android-linux}

Android 是 Linux 发行版，但它不是 GNU/Linux，Android 不使用 GNU 的一系列工具和库。Android 还大幅度修改了 Linux 内核以精简运行时开销、适应移动设备。

[AOSP (Android Open Source Project)](https://source.android.google.cn/) 只使用了 GPL 许可证的 Linux Kernel，而在 Kernel 之上的 [ART (Android Runtime)](https://source.android.google.cn/docs/core/runtime)、Bionic C 库、驱动透明化的 [HAL (Hardware Abstraction Layer)](https://source.android.google.cn/docs/core/architecture/hal) 则作为用户态存在，避免 Android 系统框架、Google 移动应用服务框架（GMS）和各厂商的驱动程序被 GPL 感染而开源。

![](images/Android-Stack.png)

Android 软件堆栈
{: .caption }

??? tip "GPL 感染，以及开源许可证的区别"

    简单而不太严谨地来说，如果你的程序使用了 GPL 许可证的代码，那么你的程序就必须以 GPL 许可证开源，这被称为「GPL 感染」。由于许多公司不希望自己的代码被感染开源，因而 Android 经过设计规避了相关的法律问题，只需要厂商将对 Linux 内核的修改开源即可。

    一个被 GPL 感染的例子是用于嵌入式路由器设备的 OpenWrt。由于 Linksys 在编写自己的无线路由器固件时使用了 GPL 的代码，因此不得不将相关的代码开源。OpenWrt 即由此发展而来。

    GPL 许可证是在第一章正文中提到的「著作传」（Copyleft）许可的代表。而另一类开源许可证则更加宽松，允许用户在署名等前提下将代码使用在闭源软件中。这样的许可证代表如 MIT 许可证、Apache 许可证等。

    目前，GitHub 网页版在创建 `LICENSE` 文件时，会给出一些开源许可证的选项以供选择。网络上也有相关的资料以供需要选择开源许可证的开发者们参考。

## 禁用 SELinux {#disable-selinux}

读者在使用 Fedora、CentOS、Scientific Linux、RHEL 等系统时，可能会遇到这样的错误：

-   SELinux is preventing XXXX from read access on the file YYYY.

这是因为有一个叫做 SELinux 的安全增强组件阻止了一些有潜在风险的操作。

SELinux 的全称是 Security-Enhanced Linux，起初是为了弥补 Linux 下没有强制访问控制（Mandatory Access Control, MAC）的缺憾。我们在[附录](../Appendix/distribution.md#selinux)中也对 SELinux 做了进一步的介绍。

但是 SELinux 的设置相当繁复，由于默认设置不可能尽善尽美，一些配置上的小问题可能会影响用户的正常使用，而初学者没有足够的技能去调试 SELinux 策略。因此在初学时，可以暂且关闭 SELinux，在掌握足够的技能后再启用它。

??? tip "AppArmor"

    在 Debian、Ubuntu 系发行版中，默认使用的是称作 AppArmor 的同类组件。与 SELinux 相比，AppArmor 更简单一些，且一般不会对用户的正常使用造成困扰。

SELinux 有 3 种工作模式：

1. `enforcing`：SELinux 根据安全策略，积极阻止有潜在风险的操作。
2. `permissive`：SELinux 仅记录会被阻止的操作在日志中，但不做任何事。
3. `disabled`：SELinux 被彻底禁用，日志也不记录。

因此，只需将 SELinux 置于 `permissive` 或 `disabled` 状态即可。

使用 `sestatus` 命令查看 SELinux 状态：

```console
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

## 虚拟机镜像常见问题 {#vm-faq}

本部分提供有关我们提供的 XUbuntu 虚拟机镜像的常见问题以及解答。

### 屏幕缩放 {#vm-scale}

如果在高分屏（HiDPI）上安装系统，可能会遇到屏幕缩放的问题。可以通过以下方法确认自己是否正在使用高分屏：

-   Windows: 桌面右键，点击「显示设置」，在「缩放与布局」中查看其中的百分比，如果大于 100%，则是高分屏。
-   Mac: 如果你的 Mac 是 Retina 屏幕，那么它就是高分屏。也可以对比「关于本机」->「更多信息」中显示器的分辨率规格与「显示器设置」中实际的分辨率。

因此，虚拟化软件有两种策略。以物理分辨率为 2560x1600，逻辑分辨率为 1440x900，全屏显示为例（缩放比大约为 178%）：

-   向虚拟机汇报实际的物理像素（2560x1600），这样默认情况（不缩放）下虚拟机中的文字和图标会变得非常小。
-   向虚拟机汇报缩放后的像素（1440x900），这样默认情况下虚拟机中的文字和图标大小是正常的，但是会模糊一些。

如果对显示效果不满意，可以采取以下任一方式调整。

#### 调整虚拟化软件的缩放策略 {#vm-hypervisor-scale-adjust}

VirtualBox 可以在启动后调整缩放策略。点击菜单栏的「查看」（或「视图」）->「虚拟显示屏 1」（或「虚拟显示器 1」），可以看到缩放比例选项，并且有两种包含了备注的比例：

-   100%（输出未缩放/unscaled output）：代表向虚拟机汇报实际的物理像素。
-   输出自动缩放/autoscaled output：代表向虚拟机汇报缩放后的像素。

默认选择的是 100% 选项，因此可能首次开机会发现界面过小。如果可以接受界面略显模糊，可以选择「输出自动缩放」。

VMware Fusion (macOS) 中，相关设置在设置中的「显示器」选项卡中。默认「使用 Retina 全分辨率显示」是关闭的，代表向虚拟机汇报缩放后的像素。

VMware Workstation (Windows) 中其默认会向虚拟机汇报实际的物理像素。取消选择「在虚拟机中自动调整用户界面大小」（如果有），启用拉伸模式并减小监视器最大分辨率可以实现 UI 大小正常且模糊的效果。免费版本的 Workstation Player 不支持拉伸模式。

#### 调整 Xfce 下的缩放 {#vm-xfce-scale-adjust}

Xfce 下有多处与缩放调整有关的设置。调整 Xfce 的缩放有两种方式：

-   调整显示器缩放设置
-   调整元素 DPI

点击左上角，选择设置管理。在「硬件」->「显示」中可以调整显示器缩放。

!!! bug "Xfce 的显示器缩放比 bug"

    Xfce 的显示器缩放比和正常人类认知是相反的——1.5x 的实际效果是 (1/1.5)x。
    这是一个[已知的 bug](https://gitlab.xfce.org/xfce/xfce4-settings/-/issues/259)，并且直到现在，可能是因为担心破坏现有用户的设置，还没有被修复。

因此，如果你需要缩放，需要选择「自定义」，然后输入你想要的缩放比的倒数（保留一位小数）——例如，1.5x 的缩放需要输入 0.7。
并且有可能元素仍然是不清晰的。因此这里更推荐调整元素 DPI 的做法。

在「外观」->「字体」中可以调整元素 DPI。默认情况下，Xfce 的 DPI 是 96，将其乘以预期的缩放比并输入。
此时可能会发现 UI 不太协调，以下提供了一些可能需要调整的设置，按类似方式相乘即可：

-   桌面图标：右键桌面 -> 桌面设置 -> 图标 -> 图标大小
-   托盘大小：右键面板 -> 面板 -> 面板首选项 -> 「尺寸」下面的「行大小」
-   鼠标光标：设置 -> 硬件 -> 鼠标和触摸板 -> 主题 -> 光标大小

### 扩大磁盘大小 {#vm-disk-resize}

为了在可用磁盘空间较小的情况下也能快速体验，我们提供的虚拟机镜像磁盘仅设置了 5G，有可能会遇到空间不足的问题。
VMware 的操作较为直观，而 VirtualBox 将工具放在了较深的位置：
需要选择 Tools 旁的菜单，点击 Media 后在右侧双击对应的磁盘，即可扩容。

视虚拟化软件实现，扩大磁盘后进入系统可能需要进行额外的操作。打开终端，输入 `sudo fdisk -l` 确认**分区**是否被扩大
（密码不会显示 `*`，输入之后什么都不显示是正常的，确认输入正确后按下回车即可）：

```console
$ sudo fdisk -l
[sudo] ustc 的密码：
Disk /dev/sda: 10 GiB，10737418240 字节，20971520 个扇区
Disk model: VBOX HARDDISK
单元：扇区 / 1 * 512 = 512 字节
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：gpt
磁盘标识符：12526913-E330-4CA7-A379-90A87EF858B0

设备         起点    末尾    扇区  大小 类型
/dev/sda1     2048  499711  497664  243M EFI 系统
/dev/sda2   499712  20971486  20471775  9.8G Linux 文件系统
```

这里可以看到，`/dev/sda2` 这个**分区**被自动扩大了。
如果没有，那么可以输入以下命令（请勿输入 `$ `，详见[记号约定](../notations.md#command-line)）：

```console
$ LANGUAGE=C sudo growpart /dev/sda 2
```

!!! bug "growpart 在非英语环境下的 bug"

    在非英语环境中，由于 growpart 脚本会尝试检查 sfdisk 工具的版本，而其无法识别翻译之后的版本信息，因此会报错。这里使用 `LANGUAGE=C` 来临时将环境变量 `LANGUAGE` 设置为英语，以避免这个问题。

    该问题已经[在上游修复](https://github.com/canonical/cloud-utils/pull/30)。但是 Ubuntu 22.04 未包含这个修复。

在扩大分区后，还需要扩大**文件系统**。使用 `df -h` 检查 `/dev/sda2` 上文件系统的使用情况。
VMware 与 VirtualBox 的扩容操作可能都不会自动扩大文件系统，因此需要执行以下命令，手动扩大文件系统。

```console
$ sudo resize2fs /dev/sda2
```

如果有过分区经验，也可以安装图形化的 GParted 工具进行操作。

### 虚拟机网卡的“模式” {#vm-nic-modes}

在虚拟机中使用网络设备时，会发现虚拟机一般有三种网卡模式，分别叫做 `Bridged`（桥接）、`NAT`（网络地址转换）、`Host only`（仅主机）。虚拟机中的网络设备，是虚拟网卡（Virtual NIC），其背后需要与某个网络连接，才能实现通信功能。

在安装虚拟机前，设备上的网络通常是这样的：

```mermaid
flowchart TD
    HSP[主机上的程序] --> HS
    HS[主机] -->|物理网卡 10.1.2.3| IN[外部网络]
```

#### 桥接模式 {#bridge-mode}

在这种模式下，虚拟机程序（例如 VMWare）会在主机上创建一个虚拟交换机。虚拟交换机上，接入了原来的物理网卡（例如有线网卡或者 Wi-Fi 适配器等）、虚拟机中安装的虚拟网卡、主机上的虚拟网卡。在这种配置下，虚拟机和主机都暴露在外部网络下，分别使用**不同的 IP**。

```mermaid
flowchart TD
    VMP1[虚拟机上的程序] --> VM1
    VMP2[虚拟机上的程序] --> VM2
    HSP[主机上的程序] --> HS
    VM1[虚拟机] -->|虚拟网卡 10.1.2.4| SW[虚拟交换机]
    VM2[虚拟机] -->|虚拟网卡 10.1.2.5| SW[虚拟交换机]
    HS[主机] -->|虚拟网卡 10.1.2.3| SW[虚拟交换机]
    SW -->|物理网卡 10.1.2.3/4/5| IN[外部网络]
```

#### 网络地址转换模式 {#nat-mode}

与桥接模式不同，网络地址转换下，虚拟机和主机**共用一个 IP**，虚拟机之间用虚拟交换机连接。从外部网络看来，虚拟机上的程序和主机上的程序发出的请求是一样的。

```mermaid
flowchart TD
    VM1[虚拟机] -->|虚拟网卡 192.168.100.100| SW[虚拟交换机 192.168.1.x]
    VM2[虚拟机] -->|虚拟网卡 192.168.100.101| SW
    SW -->|192.168.1.x| NAT[NAT 网络地址转换]
    NAT -->|10.1.2.3| HS
    HSP[主机上的程序] -->|10.1.2.3| HS
    HSP -->|虚拟网卡 192.168.100.1| SW
    HS[主机] -->|物理网卡 10.1.2.3| IN[外部网络 10.x.x.x]
```

#### 仅主机模式 {#hostonly-mode}

仅主机模式类似 NAT，但是虚拟机不能与外部网络通信。

```mermaid
flowchart TD
    VM1[虚拟机] -->|虚拟网卡 192.168.100.100| SW[虚拟交换机 192.168.1.x]
    VM2[虚拟机] -->|虚拟网卡 192.168.100.101| SW
    SW
    HSP[主机上的程序] -->|10.1.2.3| HS
    HSP -->|虚拟网卡 192.168.100.1| SW
    HS[主机] -->|物理网卡 10.1.2.3| IN[外部网络 10.x.x.x]
```

### 已知问题 {#vm-known-issues}

#### 在 macOS VirtualBox 下闪屏 {#virtualbox-flicker}

我们发现 VirtualBox 在导入镜像后会为虚拟机设置有问题的显卡控制器，导致在 macOS 下出现闪屏问题。
在虚拟机设置中将显示控制器修改为 VMSVGA 后可以解决此问题。

#### VirtualBox 下图形性能较差 {#virtualbox-graphics-performance}

在虚拟机设置中将显存调整至最大（128 MB），并且启动 3D 加速，可以提升图形性能。
如果仍未改善，建议选择「输出自动缩放」模式，降低虚拟机中的分辨率。

!!! note "macOS VirtualBox 的问题"

    macOS 下的 VirtualBox 经测试发现，在启用需要 OpenGL 的程序（如 glxgears）后可能会出现控制问题，无法正常操作窗口，原因不明。
    如果遇到类似的问题，可以考虑切换至 VMware Fusion Player。

## 配置与使用 SSH 连接远程的 Linux 服务器 {#ssh}

在本章节正文中，我们介绍了如何在本地运行 Linux 操作系统。但是在实际操作时，一个非常常见的需求是连接到远程的服务器。Linux 提供了非常方便安全的 SSH 功能，可以让用户连接到远程的 Linux 服务器命令行执行操作。

在这里，我们将简单介绍在服务器上配置 SSH，以及如何使用 SSH 连接到远程的服务器。

!!! warning "安装前请务必修改弱密码"

    互联网上有着大量爆破用户名和弱密码的自动化程序，如果密码很弱（位数不够长，或者使用了常见的密码），那么黑客就能很快使用 SSH 登录到你的系统中获取控制权，使得你的电脑（服务器）成为肉鸡（被黑客利用攻击其他服务器），在你的电脑上安装挖矿软件等恶意软件，删除你的数据进行勒索。甚至在校园网中，服务器由于 SSH 弱密码被攻击的例子也屡见不鲜。

    由于 SSH 服务器默认不关闭密码验证，在安装前请务必使用 `passwd` 命令修改弱密码！

在服务器上首先安装 `openssh-server` 软件包，它提供了 SSH 服务器的功能。

```console
$ sudo apt install openssh-server
```

启动并检查 SSH 服务状态：

```console
$ sudo systemctl start ssh
$ sudo systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2022-02-24 16:47:39 CST; 1min 15s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 1689 (sshd)
      Tasks: 1 (limit: 2250)
     Memory: 2.0M
     CGroup: /system.slice/ssh.service
             └─1689 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups

2月 24 16:47:39 ustclug-linux101 systemd[1]: Starting OpenBSD Secure Shell server...
2月 24 16:47:39 ustclug-linux101 sshd[1689]: Server listening on 0.0.0.0 port 22.
2月 24 16:47:39 ustclug-linux101 sshd[1689]: Server listening on :: port 22.
2月 24 16:47:39 ustclug-linux101 systemd[1]: Started OpenBSD Secure Shell server.
```

我们可以使用 `ssh` 命令直接连接到本地（localhost）的 SSH 服务器。其中 `@` 符号前的是登录的用户名，后面的是服务器的域名或 IP 地址。

```console
$ ssh ustc@localhost
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ECDSA key fingerprint is SHA256:czt1KYx+RIkFTpSPQOLq+GqLbLRLZcD1Ffkq4Z3ZR2U.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
ustc@localhost's password:
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.13.0-28-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

0 updates can be applied immediately.

Your Hardware Enablement Stack (HWE) is supported until April 2025.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

ustc@ustclug-linux101:~$
```

??? note "第一次连接时的提示"

    在初次连接时会有类似于下面这样的提示，需要输入 `yes` 才能继续连接：

    ```
    The authenticity of host 'localhost (127.0.0.1)' can't be established.
    ECDSA key fingerprint is SHA256:czt1KYx+RIkFTpSPQOLq+GqLbLRLZcD1Ffkq4Z3ZR2U.
    Are you sure you want to continue connecting (yes/no/[fingerprint])?
    ```

    这是因为初次连接时，SSH 不知道连接到的服务器是否真的是我们指定要连接的服务器：网络中的「中间人」可能会截获我们与服务器之间的网络流量，将自己伪装成对应的服务器。所以，SSH 会要求你确认密钥的指纹是否与预期相一致，如果不一致，则说明可能出现安全问题，应该立刻断开连接。

    服务器的密钥信息会记录在本地，之后连接相同的服务器就不会再弹出这个提示。如果远程服务器的密钥和本地记录的信息不一致，会输出类似下面的错误信息：

    ```
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
    Someone could be eavesdropping on you right now (man-in-the-middle attack)!
    It is also possible that a host key has just been changed.
    The fingerprint for the RSA key sent by the remote host is
    12:34:56:78:90:ab:cd:ef:12:23:34:45:56:67:78:89.
    Please contact your system administrator.
    Add correct host key in /home/ustc/.ssh/known_hosts to get rid of this message.
    Offending RSA key in /home/ustc/.ssh/known_hosts:12
    RSA host key for 127.0.0.1 has changed and you have requested strict checking.
    Host key verification failed.
    ```

    可能的原因是你连接到了错误的服务器、服务器的密钥被更换，或者最糟糕的可能性：有人在尝试对你进行网络攻击。

也可以测试一下从其他机器连接到服务器。

!!! tip "获取服务器的 IP 地址"

    可以使用 `ip a` 命令查看服务器的 IP 地址。

    如果无法连接，请检查服务器的防火墙是否放行了 TCP 22 端口。

!!! tip "配置密钥登录"

    上面我们提到，弱密码会导致黑客能够轻而易举从 SSH 入侵服务器，但是每次登录输入复杂密码会很烦，怎么办呢？其实，SSH 提供了一种相当方便、简单、安全的连接方式：密钥认证。它的原理是，用户生成一对密钥，将公钥放在服务器上，登录时 SSH 自动使用私钥认证，两者相符则允许用户登录。

    首先在自己的机器上使用 `ssh-keygen` 生成密钥：

    ```console
    $ ssh-keygen
    Generating public/private rsa key pair.
    Enter file in which to save the key (/home/ustc/.ssh/id_rsa):
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    Your identification has been saved in /home/ustc/.ssh/id_rsa
    Your public key has been saved in /home/ustc/.ssh/id_rsa.pub
    The key fingerprint is:
    SHA256:/+4tXnjnilyLQvwa+qEKx0IK2jOzHRj0Nbarr3Vot1E ustc@ustclug-linux101
    The key's randomart image is:
    +---[RSA 3072]----+
    |                 |
    |                 |
    |  .   +          |
    | . . o o         |
    |. . o . S.E      |
    |.o = . o oo  .   |
    |. B + B +.+.. + .|
    |   * O o =.=oB + |
    |  . +oo.+.o*O.+..|
    +----[SHA256]-----+
    ```

    这里的 passphrase 是密钥的密码，设置之后即使私钥被别人拿到也无法使用，可以不输入。最终得到的 `id_rsa` 是私钥（**千万不要分享给别人！**），`id_rsa.pub` 是公钥（可以公开）。

    在本地使用 `ssh-copy-id` 命令将公钥拷贝到服务器上：

    ```console
    $ ssh-copy-id ustc@localhost
    /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
    /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
    ustc@localhost's password:

    Number of key(s) added: 1

    Now try logging into the machine, with:   "ssh 'ustc@localhost'"
    and check to make sure that only the key(s) you wanted were added.
    ```

    如果服务器不允许使用密码登录，可以将用户目录下 `.ssh/id_rsa.pub` 文件的内容复制到机器对应用户的 `.ssh/authorized_keys` 文件中。

    配置完成后，可以考虑关闭 SSH 服务器的密码验证。做法是编辑 `/etc/ssh/sshd_config` 文件，将其中

    ```
    #PasswordAuthentication yes
    ```

    修改为

    ```
    PasswordAuthentication no
    ```

    然后让 SSH 服务器重新加载配置：

    ```console
    $ sudo systemctl reload ssh
    ```

    我们建议除非有特殊原因，否则所有正式生产环境服务器（例如实验室服务器）都应该关闭 SSH 密码验证。

## 适用于 Linux 的 Windows 子系统（Windows Subsystem for Linux，WSL） {#wsl}

如何将 Linux 下的软件与开发生态移植到 Windows 上？在 WSL 出现之前，开发者们进行了各种尝试。这也催生出了一些软件与方案，例如：

-   Cygwin。它包含了一大批 Linux 上的 GNU 和其他的开源工具。它的核心是一个程序库 (`cygwin1.dll`)，这个程序库在 Windows 环境下实现了 POSIX API 的功能。Linux 上的软件，可以通过**重新编译**，链接 Cygwin 的方式，在 Windows 上运行。
-   MinGW。它包含了 GCC 和 GNU Binutils 等工具的 Windows 移植。它不支持类似于 `fork()` 这样无法简单用 Windows API 实现的 POSIX API，但是相比于 Cygwin 来说更加轻量，甚至可以在 Linux 上使用 MinGW 交叉编译 Windows 程序。
-   MSYS2。使用 Cygwin 和 MinGW 组建的开发环境，并且使用 Pacman 作为包管理器。
-   Cooperative Linux。这个项目尝试让 Linux 内核和 Windows 内核同时运行在相同的硬件上。Linux 内核经过修改，以能够与 Windows 内核共享硬件资源。这个项目已经长期未活跃了。

当然，我们可以看到，没有一个稳定的方案可以不加修改地直接运行 Linux 程序，直到 WSL 出现。WSL 由微软开发，可以在 64 位的 Windows 10 和 Windows Server 2016 及以上的版本上运行原生（ELF 格式）的 Linux 程序（安装方法详见 WSL 的官方[安装指南](https://learn.microsoft.com/zh-cn/windows/wsl/install)）。

??? tip "不要将 WSL 与 Windows Services for UNIX (SFU) 混淆"

    你可能会在老版本的 Windows 上注意到，在「添加与删除 Windows 组件」的地方，有一个「基于 UNIX 的应用程序子系统」。需要注意的是，这个选项和 WSL 没有任何关系。它也无法直接运行 Linux 或者其他 UNIX 的程序。并且，这个子系统目前也已经停止了开发。

!!! warning "WSL 对宿主机文件系统的挂载"

    请注意，**WSL 可能将主机的文件系统挂载在子系统的某个位置（例如将主机的 `C:\` 挂载在 `/mnt/c/`）**。这在通常情况下会使得主机和 WSL 之间的文件共享更加方便，但也可能导致在子系统中执行文件操作（例如文件删除）时错误地操作了主机上的文件。

### WSL 1 {#wsl1}

WSL 1 面向 Linux 应用程序提供了一套兼容的内核接口，在 Linux 程序运行的时候，WSL 1 处理（Linux 使用的）ELF 可执行文件格式，将 Linux 的系统调用翻译为 Windows 的系统调用，从而运行 Linux 程序。WSL 1 中可以访问到 Windows 下的文件，也与主机共享网络。

### WSL 2 {#wsl2}

WSL 2 尝试解决一些 WSL 1 的方式难以解决的问题：

-   由于其是以翻译系统调用的方式实现 Linux 兼容，WSL 1 无法运行依赖于复杂内核特性的程序（如 Docker），无法运行硬件驱动程序。
-   没有硬件加速，图形性能差。OpenCL 与 CUDA 也尚未在 WSL 1 中实现。
-   受到各种因素的影响（如 Windows Defender），WSL 1 的 I/O 性能远低于 Linux 内核的实现。

WSL2 使用微软的 Hyper-V 虚拟化技术，运行一个轻量的、完整的 Linux 内核。

## 在使用 Apple Silicon 处理器的机型上配置 Linux 虚拟机 {#configure-vm-in-apple-silicon}

正在查看 Linux 101 的你可能正在使用基于 Apple Silicon 处理器的 Mac。此时使用在文章正文中的教程是无法安装虚拟机的。本节将帮助你使用 VMWare Fusion 在基于 Apple Silicon 处理器的 Mac 上配置一个 Ubuntu 20.04 的虚拟机。

!!! tip "你也可以使用 [UTM](https://mac.getutm.app) 来配置你的 Ubuntu 虚拟机。"

!!! question "什么是 Apple Silicon？"

    Apple Silicon（苹果硅）是对苹果公司使用 ARM 架构设计的单芯片系统（SoC）和封装体系（SiP）处理器之总称。它广泛运用在 iPhone、iPad、Mac 和 Apple Watch 以及 HomePod 和 Apple TV 等苹果公司产品。[^1]

    若想查看你的 Mac 是否使用了 Apple Silicon，请参照[这个网页](https://support.apple.com/en-us/HT211814)。

!!! question "x86-64 架构和 ARM64 两种架构都是什么？它们有什么区别？"

    ARM64（也被称为 AArch64）是 ARM 公司推出的 64 位处理器架构。它被广泛用于移动设备、嵌入式系统和服务器领域。与之前的 32 位架构相比，它具有更高的性能和更好的功耗管理。

    x86-64 也被称为 x64 或者 AMD64。它广泛应用于 PC 和服务器领域，并且兼容大部分之前的 32 位 x86 应用程序。

    在使用上，这两种架构是不兼容的，即针对一种架构编译的程序无法直接在另一种架构上运行。这也是使用 Apple Silicon 处理器的 Mac 无法通过正文中的流程配置 Ubuntu 虚拟机的原因。

### 使用 VMWare Fusion 配置你的第一个 Ubuntu 虚拟机 {#first-vm-on-vmware}

!!! warning "本节内容涉及到尚未完善的系统及软件，实际操作随时会发生变化。本次更新在 2023 年 2 月。"

可供参考的内容：

-   [The Unofficial Fusion 13 for Apple Silicon Companion Guide](https://communities.vmware.com/t5/VMware-Fusion-Documents/The-Unofficial-Fusion-13-for-Apple-Silicon-Companion-Guide/ta-p/2939907/jump-to/first-unread-message)

如果遇到以上文档中无法解决的问题，可以继续参考下面的两个针对于 VMWare Fusion 22H2 Tech Preview 的文档：

-   [Fusion 22H2 Tech Preview Testing Guide](https://communities.vmware.com/t5/Fusion-22H2-Tech-Preview/Fusion-22H2-Tech-Preview-Testing-Guide/ta-p/2867908)

-   [Tips and Techniques for the Apple Silicon Tech Preview 22H2](https://communities.vmware.com/t5/Fusion-22H2-Tech-Preview/Tips-and-Techniques-for-the-Apple-Silicon-Tech-Preview-22H2/ta-p/2893986)

#### 下载 VMWare Fusion 13 Player {#download-vmware-fusion}

在 [Download VMWare Fusion](https://www.vmware.com/products/fusion/fusion-evaluation.html) 上下载 VMware Fusion 13 Player，需要注册。

#### 下载 Ubuntu Server for ARM {#download-ubuntu-arm}

首先你需要选择 Ubuntu 发行版。截止到 2023 年 2 月，各个较新的发行版在 VMWare Fusion 上的支持情况为：

-   Ubuntu 20.04.5 LTS (Focal Fossa)：可以使用，需要经过改动才能修改图形界面的分辨率。
-   Ubuntu 22.04 LTS (Jammy Jellyfish)：从 Ubuntu 22.04.2 LTS 开始可以直接使用。

本节选用 Ubuntu 20.04.5 (arm64, server) 作为接下来安装的系统。

![](images/applesilicon_vmware/1.png)

你可以在 [中国科学技术大学开源软件镜像](https://mirrors.ustc.edu.cn/) 获取安装镜像。
{: .caption }

#### 在 VMWare Fusion 上安装 Ubuntu on ARM {#install-ubuntu-arm-on-vmware}

下载好安装镜像后，打开 VMWare Fusion，导入你下载的镜像：

![](images/applesilicon_vmware/2.png)

点击左上角的加号创建新的虚拟机
{: .caption }

![](images/applesilicon_vmware/3.png)

将你下载好的镜像拖入框中
{: .caption }

![](images/applesilicon_vmware/4.png)

导入完成之后使用默认配置即可，你也可以按照自己的需求对 configuration 进行对应的改动。
{: .caption }

![](images/applesilicon_vmware/6.png)

用键盘对命令行界面进行操作，在配置用户名前的配置一般可以选择默认配置。本页面中你需要配置你的用户名，服务器名称和密码。
{: .caption }

如果你不需要远程连接你的虚拟机，你可以不安装 `openssh-server` （当然，你可以在之后自行安装）。

Featured Server Snaps 一样可以选择不安装，可以之后自行配置。

安装完成之后会重启，之后你会进入命令行界面。这就是一个没有图形界面的虚拟机，你可以对它进行任何你想做的尝试了！

如果你需要带图形界面的虚拟机，只需要安装 `ubuntu-desktop` 即可。

```console
$ sudo apt-get install ubuntu-desktop
```

安装好之后需要重新启动虚拟机，这时你应该可以看到你的登陆界面了：

![](images/applesilicon_vmware/7.png)

虚拟机的图形界面
{: .caption }

值得注意的是，在选择软件源时，你应该使用 [Ubuntu Ports 源](https://mirrors.ustc.edu.cn/help/ubuntu-ports.html) 而不是 [Ubuntu 源](https://mirrors.ustc.edu.cn/help/ubuntu.html#id3)。

!!! bug "在 VMWare Fusion 13 Player 上安装的 Ubuntu 20.04.5 (arm64, server) 虚拟机并不原生支持修改分辨率"

    如果你通过上面的步骤安装好了带有图形界面的 Ubuntu 虚拟机，你可能会发现在设置中并不能调整图形界面的分辨率（它被限制在了 1024*768）。简而言之，这是因为 ARM64 版本的 Linux 内核从 5.14 版本开始才支持 VMWare 为 Linux 适配的图形驱动 `vmwgfx`。而 Ubuntu 20.04 原生 Linux 内核是 5.4 版本的，并不包含 VMWare 适配的驱动。所以如果你想修改 Ubuntu 虚拟机的分辨率的话，有两种选择：

    * 使用 Ubuntu 22.04 或 22.10：目前只有部分 daily build 版本可用。
    * 在 Ubuntu 20.04 上**禁用 Wayland**:

        ```console
        $ sudo nano /etc/gdm3/custom.conf
        ```

        解除该行的注释（删除下面这行代码之前的`#`）后，保存退出：

        ```bash
        #WaylandEnable=false
        ```

    接下来自行通过 HWE 升级 Ubuntu 20.04 的内核至 5.15:

    ```console
    $ sudo apt install --install-recommends linux-generic-hwe-20.04
    ```

    重启虚拟机，在设置中进行分辨率的修改。

## 使用 Ventoy {#using-ventoy}

使用 Ventoy 可以简单方便地从 U 盘或者其他移动介质安装各类操作系统（且支持在一个介质中存放多个系统镜像），当然也包括 GNU/Linux。有关如何使用 Ventoy，请参考其网站[^2]。

## 引用来源 {#references .no-underline}

[^1]: [Apple silicon - Wikipedia](https://en.wikipedia.org/wiki/Apple_silicon)
[^2]: [Ventoy 中文网站](https://www.ventoy.net/cn/index.html)
