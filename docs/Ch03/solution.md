---
icon: material/tooltip-question
---

# 思考题解答 {#solution}

## Матрёшка {#meta}

!!! tip "提示"

    `man` 和 `tldr` 的用途是？

??? info "解答"

    答案非常简单：`man man` / `man tldr`, 和 `tldr man` / `tldr tldr` 即可。

## 查找需要安装的软件包 {#finding-package-you-need}

!!! tip "提示"

    `apt` 有一些相关的小工具，可能可以帮到你。

??? info "解答"

    我们可以使用 `apt-file`（需要手动安装）来查找包含某个特定文件的软件包。在运行 `sudo apt-file update` 建立索引之后，可以用 `apt-file search 文件名` 来进行搜索。

    一个例子：

    ```
    $ apt-file search libc++.so
    libc++-7-dev: /usr/lib/llvm-7/lib/libc++.so
    libc++-7-dev: /usr/lib/x86_64-linux-gnu/libc++.so
    libc++-8-dev: /usr/lib/llvm-8/lib/libc++.so
    libc++-8-dev: /usr/lib/x86_64-linux-gnu/libc++.so
    libc++1-7: /usr/lib/llvm-7/lib/libc++.so.1
    libc++1-7: /usr/lib/llvm-7/lib/libc++.so.1.0
    libc++1-7: /usr/lib/x86_64-linux-gnu/libc++.so.1
    libc++1-7: /usr/lib/x86_64-linux-gnu/libc++.so.1.0
    libc++1-8: /usr/lib/llvm-8/lib/libc++.so.1
    libc++1-8: /usr/lib/llvm-8/lib/libc++.so.1.0
    libc++1-8: /usr/lib/x86_64-linux-gnu/libc++.so.1
    libc++1-8: /usr/lib/x86_64-linux-gnu/libc++.so.1.0
    ```

## 硬链接与软链接的判断 {#hard-and-soft-links}

!!! tip "提示"

    你可能需要理解 `ls -l` 输出的含义。

??? info "解答"

    软链接的判断非常简单。如果是软链接的话，`ls -l` 对应的文件会明确写出其指向的文件。

    ```
    $ ls -l /usr/bin/vim
    lrwxrwxrwx 1 root root 21 Jul 21  2019 /usr/bin/vim -> /etc/alternatives/vim
    ```

    那么如何判断硬链接呢？我们可以试一下。

    ```
    $ touch file
    $ ln file hardfile
    $ touch other  # 无硬链接的文件
    $ ls -l
    total 0
    -rw-r--r-- 2 user user 0 May  3 13:07 file
    -rw-r--r-- 2 user user 0 May  3 13:07 hardfile
    -rw-r--r-- 1 user user 0 May  3 13:07 others
    ```

    可以注意到，`ls -l` 输出的第二列中，互为硬链接的 `file` 和 `hardfile` 的值为 2。这个值便是对应的文件拥有的硬链接个数。

    也可以使用 `stat` 来查看。

    ```
    $ stat hardfile
    File: hardfile
    Size: 0         	Blocks: 0          IO Block: 4096   regular empty file
    Device: fe01h/65025d	Inode: 531077      Links: 2
    Access: (0644/-rw-r--r--)  Uid: ( 1000/   user)   Gid: ( 1000/   user)
    Access: 2020-05-03 13:07:06.420556709 +0800
    Modify: 2020-05-03 13:07:06.420556709 +0800
    Change: 2020-05-03 13:07:15.500656671 +0800
    Birth: -
    ```

## 错误使用 tar 命令导致的文件丢失 {#data-loss-by-tar}

!!! tip "提示"

    `tar` 的 `-f` 的意义是什么？

??? info "解答"

    `*` 被 shell 展开，导致命令变成了这样：

    ```
    tar -cf file1 file2 ... target.tar
    ```

    此时，`tar` 会把 `file2` 一直到 `target.tar` 打包的结果放在 `file1` 文件中，于是 `file1` 的内容就被覆盖了。

## 为什么 `mv` 命令不需要 `-r` (recursive) 参数 {#why-mv-does-not-need-recursive}

!!! tip "提示"

    复制文件夹的过程需要创建新的文件和文件夹，而移动文件夹的操作可以看作是「重命名」。

??? info "解答"

    在移动文件夹时，`mv` 事实上调用了 `rename` 系统调用，即重命名。由于目录是一个树状结构，那么移动文件夹只需要修改这个「文件夹节点」本身的位置与名称即可，不需要对文件夹内的文件（它的子树）做递归的操作。而假使在复制的时候只处理单个「文件夹节点」，那么复制得到的新文件夹中存储的文件和原文件夹存储的文件就会指向相同的文件（而不是再复制一份新的），而这是不符合「复制」这个操作的预期的，所以在复制时，需要递归地复制「文件夹节点」和它的子树，这就是 `mv` 不需要 `-r` 而 `cp`（以及其他类似的操作）需要 `-r` 的原因。

## 为什么不建议使用 `apt-key` {#why-not-use-apt-key}

!!! tip "提示"

    `sudo apt-key add -` 命令将密钥添加到了全局信任。

??? info "解答"

    如果使用 `apt-key` 信任密钥，在私钥泄漏之后，攻击者可以使用泄漏的私钥为其他软件包签名，而信任这对密钥的用户就有可能从其他软件源下载软件包时下载并安装攻击者签名的软件包。

    一个场景是：

    1. 你使用 `apt-key` 信任了软件源 A 的密钥；
    2. 软件源 A 的私钥不幸被攻击者 E 得到；
    3. 攻击者 E 成为了你连接网络的中间人，能够截获、修改所有明文的 HTTP 流量；
    4. 攻击者 E 为后门软件 X 打包并签名；
    5. 只要软件源配置中有使用 HTTP 协议的软件源（不一定是软件源 A），攻击者就可以在你安装其他软件包时悄悄将 X 安装到你的机器上。

    如果单独设置每个软件源信任的密钥，那么造成的攻击面相比之下就小得多了。

    在 2021 年 12 月，Cloudflare 发表[博客](https://blog.cloudflare.com/dont-use-apt-key/)称其 Cloudflare WARP 软件源的私钥疑似泄漏，并且指出了 `apt-key` 信任密钥带来的可能的安全隐患。此后，一些开源软件（如 Docker）的帮助文档也相应更新。
