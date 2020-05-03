# 思考题解答 {#solution}

## Матрёшка {#meta}

!!! tips "提示"

	`man` 和 `tldr` 的用途是？

??? info "解答"

	答案非常简单：`man man` / `man tldr`, 和 `tldr man` / `tldr tldr` 即可。
	

## 查找需要安装的软件包 {#finding-package-you-need}

!!! tips "提示"

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

!!! tips "提示"

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

!!! tips "提示"

    `tar` 的 `-f` 的意义是什么？

??? info "解答"

	`*` 被 shell 展开，导致命令变成了这样：

    ```
    tar -cf file1 file2 ... target.tar
    ```

    此时，`tar` 会把 `file2` 一直到 `target.tar` 打包的结果放在 `file1` 文件中，于是 `file1` 的内容就被覆盖了。