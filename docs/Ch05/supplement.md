# 拓展阅读 {#supplement}

## 文件系统的特殊权限位 {#special-permission-bit}

有一个有趣的问题：众所周知（只要你看过了本章的主要内容），存储密码的 `/etc/shadow` 只有 `root` 用户可以查看和修改。但是，我作为一个普通用户，可以使用 `passwd` 修改自己的密码。而要修改密码，就必须修改 `/etc/shadow`，而我执行的 `passwd` 程序（应该）只拥有我的权限（否则用户权限就没有任何意义了）。难道 `passwd` 有什么魔法可以去动 `/etc/shadow` 吗？

是的。这样的「魔法」，是由文件系统特殊权限位 `setuid` 赋予的。有三个特殊权限位：setuid, setgid 和 sticky。

-   `setuid`: 以文件所属的用户的身份 (UID) 执行此程序。
-   `setgid`: 对文件来说，以文件所属的用户组的身份 (GID) 执行此程序；对目录来说，在这个目录下创建的文件的用户组都与此目录本身的用户组一致，而不是创建者的用户组。
-   `sticky` (restricted deletion flag): 目录中的所有文件只能由文件所有者（除 `root` 以外）删除或者移动。一个典型的例子是临时文件夹 `/tmp`，在此文件夹中你可以创建、修改、重命名、移动、删除自己的文件，但是动不了别人的文件。

??? tip "setuid 和 sticky 位的历史"

    聪明的你可能已经注意到了：setuid 和 setgid 对可执行程序具有相同的语义，但 setuid 对目录没有作用。事实上大部分的 UNIX 系统和所有的 Linux 都从未对“设有 setuid 的目录”赋予过任何特别含义，但仍然有少部分系统可以配置为对目录中的 setuid 位采取和 setgid 位类似的语义，即此目录中新建的文件所有者与此目录的所有者一致，而不是为文件的创建者所有。这“少部分系统”中的一个例子是 FreeBSD，但仅当文件系统在挂载时配置了 `suiddir` 参数（[FreeBSD](https://www.freebsd.org/cgi/man.cgi?query=mount&sektion=8&apropos=0&manpath=FreeBSD+6.1-RELEASE)）。

    在很早的时候（1974 年 Unix 第五版），sticky bit 是为可执行文件设计的，它告诉操作系统在程序运行结束后将程序的代码段（text 段）保留在内存或交换区中，以便下一次更快地启动这个程序，因此这个位被称作 sticky（粘滞位）。由于现代计算机存储容量的增加和操作系统缓存功能的完善，已经没有系统再将 sticky bit 解释为这个最初的含义了。在 Linux 系统中，文件上的 sticky bit 从未有过任何功能，仅有目录的 sticky bit 功能如上所述。

我们可以看一下，`/usr/bin/passwd` 的文件权限设置：

```shell
$ ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 67992 Aug 29  2019 /usr/bin/passwd
```

可以看到，本来是执行权限位的地方变成了 `s`。这代表此文件有 `setuid` 特殊权限位。在你执行 `passwd` 的时候，它的实际权限和 `root` 一样，只是它知道，执行它的人是你（而非 `root`），所以只提供修改你自己的密码的功能。

同样，`su` 和 `sudo` 也有 `setuid` 权限位：

```
$ ls -l /usr/bin/su
-rwsr-xr-x 1 root root 67816 Jan  9 02:59 /usr/bin/su
$ ls -l /usr/bin/sudo
-rwsr-xr-x 1 root root 161448 Feb  1 01:07 /usr/bin/sudo
```

所以它们可以帮你切换用户、提升权限。

拥有 `setuid` 位、所有者为 `root` 的程序是非常危险的，因为稍不谨慎，它们的漏洞就会直接让普通的无权限用户获得 `root` 权限的大门，这在服务器上是及其致命的。`sudo` 曾经爆出一个安全漏洞（CVE-2019-18634），对于 1.8.31 之前的版本，`sudo` 在开启了 `pwfeedback` 选项（将输入的密码显示为 \* 号，而非不显示）之后，有一个缓冲区溢出漏洞可以被利用来以 `root` 的身份执行任意命令；而在 2022 年初，另一个用于验证用户身份、提升权限的工具 `pkexec` 也被爆出安全漏洞（CVE-2021-4034）：由于编写 C 语言程序时未考虑到 `main()` 函数参数 `argc` 可以为 0 的情况，攻击者可以编写程序引发其逻辑问题，从而提升自己的权限。

当然，Linux 在发展中也在尽可能减少 `setuid` 程序的使用。例如 `ping` 程序因为需要创建只能由 `root` 用户创建的原始 (raw) 的网络套接字 (socket)，在以往也是一个 `setuid` 程序。但是随着 "Capabilities" 的概念引入 Linux 内核，`ping` 不再需要 `setuid`，只需要为它设置创建原始网络套接字的 capability 即可，提高了系统的安全性。

## 实际用户与有效用户 {#uid-and-euid}

于是，我们就有了另一个问题：如果 `passwd` 在执行的时候的权限是 `root` 的话，那它是怎么知道是我（而不是 `root`）执行它的呢？

在 Linux 中，有两个系统调用可以获取当前进程归属的 UID：`getuid()` 和 `geteuid()`。前者对应的是「实际用户」(Real user)，是实际运行（拥有）这个进程的用户，后者对应的是「有效用户」(Effective user)，对应拥有的权限。在运行 `passwd` 的时候，有效用户是 `root`，所以可以修改 `/etc/shadow`；而实际用户是你，所以它不会让你修改别人的密码。

对用户组来说，也有实际用户组 (GID) 和有效用户组 (EGID) 的区别。

## 「登录 Shell」(Login shell) 与「非登录 Shell」(Non-login shell) {#login-and-non-login-shell}

在前文中我们提到，`su` 和 `su -` 是有区别的。你也可能在学习 Linux 的时候会好奇：为什么我按下 Ctrl + Alt + F\[1-7\] 的时候出现的 TTY 会问我要用户名和密码，但是在桌面环境中点「终端」，不需要再输入用户名和密码，就可以操作。

这就在于「登录 Shell」和「非登录 Shell」的差别了。「登录 Shell」是属于你的当前会话操作中的第一个进程，一般是在你输入用户名和密码之后打开的 Shell。常见的场景有：

-   `su -` 之后的 Shell。
-   SSH 登录机器后的 Shell
-   Ctrl + Alt + F\[1-7\] 之后 TTY 中的 Shell

而「非登录 Shell」的常见场景：

-   `su` 打开的是「非登录 Shell」
-   在桌面环境中打开的终端（模拟器），启动的也是「非登录 Shell」

一般地，「登录 Shell」会额外加载 `profile` 文件（文件名根据你使用的 Shell 的不同而有区别），且它的 `argv[0][0] == '-'`（相信你已经学过 C 语言了）。可以用以下方法验证：

```shell
$ echo $0  # 查看当前 Shell 的 argv[0] 的值
-bash
$ # 是 Login shell
$ sudo su # 进入 root
# echo $0
bash
# # 是 Non-login shell
```
