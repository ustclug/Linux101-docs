---
icon: material/tooltip-question
---

# 思考题解答 {#solution}

## nobody 用户

!!! tip "提示"

    我们提到，为什么要对网络服务创建用户？

??? info "解答"

    将**所有**的网络服务放在同一个用户来执行显然是不明智的选择：如果有一个服务被攻击，那么其他同用户的服务也同时会被攻击者控制。

## 系统用户的默认 Shell

!!! tip "提示"

    尝试执行一下系统用户的 Shell，可以看到什么？

??? info "解答"

    ```console
    $ /usr/sbin/nologin
    This account is currently not available.
    $ /bin/false
    $ echo $?
    1
    ```

    以它们作为系统用户的默认 Shell，也就实现了「无法登录」的效果，提高了系统用户的安全性。以下是一个能够说明其「安全性」的例子：

    假设某个（运行在某系统用户上的）服务被攻击者发现可以任意以某系统用户的权限写入文件。假设 SSH 开启，攻击者可以把自己的公钥写入 `~/.ssh/authorized_keys`，然后使用自己的私钥登录此用户，得到 shell。

    但是，如果系统用户的 shell 设置为了 `/usr/sbin/nologin` 或者 `/bin/false`，那么即使发生了这种情况，攻击者也无法使用 SSH 连接到 shell，或者执行其他命令。这就提高了系统的安全性。

## 启用 root 用户

??? info "解答"

    `/etc/shadow` 第二列（记录密码哈希的那一列）的 `!` 或 `*` 表明这个用户不允许使用密码登录。那么我们再用 `passwd` 设置个密码就可以了。

    如果要重新禁止使用密码登录 `root` 用户的话，`passwd -l root` 即可。

## 文件的可执行权限

??? info "解答"

    它**可以**被执行，但是执行显然会出错。Linux 下的可执行文件一般有两类：第一类是 ELF 二进制文件，它的文件开头的十六进制是 `7F 45 4C 46`（这一串有特征的字符被称为「文件标识 (Signature)」，方便程序判断文件的格式信息）；第二类是脚本，脚本的开头一般有 `#!` (Shebang) 标明文件由什么程序解析。

    显然，Linux 不会认为一个 MP3 音频文件是 ELF（文件标识不一致），也不是脚本，那么直接执行，就会报出 `cannot execute binary file: Exec format error` 的错误。

## `sudo cd`?

!!! tip "提示"

    `cd` 是一个「程序」吗？

??? info "解答"

    如果你真的去执行 `sudo cd`，那么会看到:

    ```console
    $ sudo cd a
    sudo: cd: command not found
    ```

    这是因为，`cd` 是 shell 的**内建命令**，而不是某个具体的程序，而 `sudo` 的功能，是以其他用户 (一般是 root) 的身份执行程序。

    那么 `cd` 可以实现成（外置的）程序吗？答案是不能：因为切换工作目录的系统调用 (`chdir()`) 只能切换当前的程序的工作目录。如果实现成了外置的程序，那么切换完退出之后，shell 的工作目录仍然不会变化。

## Debian 与 Ubuntu 的区别之一：普通用户运行 `useradd` 等命令

??? info "解答"

    这里可能不止权限不足的问题。这是因为，`useradd` 存在于 `/sbin` 下，而在 Debian 中，这个目录并不在普通用户登录后默认的 `PATH` 环境变量中（但 Ubuntu 下则不一样：`/sbin` 也在普通用户的 `PATH` 环境变量中）。也就是说，Shell 并不会去 `/sbin` 中查找 `useradd`，自然就会提示 `command not found`。如果改成完整路径（`/sbin/useradd`）就可以了。
