# 五：用户与用户组、文件权限、文件系统层次结构（补充材料）

## 文件系统的特殊权限位

有一个有趣的问题：众所周知（只要你看过了本章的主要内容），`/etc/shadow` 只有 `root` 用户可以查看和修改。但是，我作为一个普通用户，可以使用 `passwd` 修改自己的密码。而要修改密码，就必须修改 `/etc/shadow`，而我执行的 `passwd` 程序（应该）只拥有我的权限。难道 `passwd` 有什么魔法可以去动 `/etc/shadow` 吗？

是的。这样的魔法，是由文件系统特殊权限位 `setuid` 赋予的。有三个特殊权限位：setuid, setgid 和 sticky。

- `setuid`: 以文件所属的用户的身份 (UID) 执行此程序。
- `setgid`: 对文件来说，以文件所属的用户组的身份 (GID) 执行此程序；对目录来说，在这个目录下创建的文件的用户组都与此目录本身的用户组一致，而不是创建者的用户组。
- `sticky` (restricted deletion flag): 目录中的所有文件只能由文件所有者（除 `root` 以外）删除或者移动。一个典型的例子是临时文件夹 `/tmp`，在此文件夹中你可以创建、修改、重命名、移动、删除自己的文件，但是动不了别人的文件。

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

拥有 `setuid` 位、所有者为 `root` 的程序是非常危险的，因为稍不谨慎，它们的漏洞就会直接让普通的无权限用户获得 `root` 权限的大门，这在服务器上是及其致命的。近期，`sudo` 就爆出一个安全漏洞 (CVE-2019-18634)，对于 1.8.31 之前的版本，`sudo` 在开启了 `pwfeedback` 选项（将输入的密码显示为 \* 号，而非不显示）之后，有一个缓冲区溢出漏洞可以被利用来以 `root` 的身份执行任意命令。

当然，Linux 在发展中也在尽可能减少 `setuid` 程序的使用。例如 `ping` 程序因为需要创建只能由 `root` 用户创建的原始 (raw) 的网络套接字 (socket)，在以往也是一个 `setuid` 程序。但是随着 "Capabilities" 的概念引入 Linux 内核，`ping` 不再需要 `setuid`，只需要为它设置创建原始网络套接字的 capability 即可，提高了系统的安全性。