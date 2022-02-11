# 思考题解答 {#solution}

## 设定 HTTP 请求头

??? info "解答"

    `curl` 的 `-H` 参数可以设定 HTTP 的请求头，如 `curl -v -H 'User-Agent: Test' http://www.baidu.com`.

    而对于 `wget`，对应的参数则是 `--header`.

## 关于断点续传

!!! tip "提示"

    可能需要简单学习 HTTP 协议的大体特性。另外，如果你想要实现这样一个特性，你会希望服务器支持什么功能呢？

??? info "解答"

    关键词是：Range 和 Content-Range.

    客户端如果需要从断开的地方重新开始，那么它需要向服务器指定需要下载的文件的范围，这个工作由 HTTP 请求头 `Range` 完成。而服务器在响应这样的请求时，响应头就包含 `Content-Range`，标志实际包含的文件内容的范围。

    当然，不是所有服务器都支持这个特性，所以有的时候你可能会发现，「断点续传」会失败。

## `/usr/bin/env`

!!! tip "提示"

    一个常见的例子是，`#!/usr/bin/env python3`.

??? info "解答"

    `#!` (Shebang) 指定了脚本文件由哪一个程序去解释，但是可以发现，这个程序必须是绝对路径。这导致了在跨平台的时候，这样的脚本容易出现问题：比如说可能在不同的环境中，Python 3 可能在 `/usr/bin/python3`, 可能在 `/usr/local/bin/python3`，甚至可能在其他的地方（比如说，如果你安装了 pyenv，那么就在 `~/.pyenv/shims/python3`）。

    `/usr/bin/env` 的功能是，在指定的环境变量中执行命令，它的参数可以不是程序的绝对路径。这个特性就让它变成了 Shebang 的常客：只要 `env` 在 `/usr/bin` 下面（一般都是这样子的），并且后面的命令可以执行，那么就没有问题了。

## Shell 脚本编写练习 #1

!!! tip "提示"

    可以使用循环和通配符来完成。另外也需要简单掌握 ffmpeg 的使用（不需要对编码参数等有所了解）。

??? info "解答"

    参考脚本：

    ```shell
    #!/bin/bash

    for i in *.mp4
    do
      ffmpeg -i "$i" "${i%.mp4}.mp3"
    done
    ```

    这里 `"${i%.mp4}.mp3"` 实现的是将文件扩展名中的 `.mp4`（即最后被匹配到的 `.mp4`）抹去，并在之后的文件名后面加上 `.mp3`。这个特性被称为[参数操作](http://mywiki.wooledge.org/BashSheet#Parameter_Operations)。

    `"${i/.mp4/.mp3}"` 的效果是类似的，但是直接将 `.mp4` 替换为 `.mp3` 的问题是，如果有视频文件名为 `xxx.mp4.xxx.mp4` 的话，非扩展名部分的 `mp4` 也会变为 `mp3`。

## Shell 脚本编写练习 #2

!!! tip "提示"

    简单的数学计算，分支指令，与 `&&`。

??? info "解答"

    参考脚本：

    ```shell
    #!/bin/bash

    if [ -z "$1" ]
    then
        echo "Usage" "$0" "NUMBER"
    else
        x="$1"
        y=$((x*x))
        ./a "$x" && ./b "$y"
    fi
    ```

## Shell 脚本编写练习 #3

!!! tip "提示"

    这里，需要解析 HTML 中所有的（`a` 标签的）`href` 属性，挑选出所有后缀为 `.pdf` 的文件，并调用 `wget` 下载。

??? info "解答"

    参考脚本：

    ```shell
    #!/bin/bash

    url="http://staff.ustc.edu.cn/~bjye/em/student/2019S/2019S.htm"
    baseurl="http://staff.ustc.edu.cn/~bjye/em/student/2019S/"
    list=$(curl "$url" | grep -Eoi 'href=".+\.pdf' | cut -c 7-)
    for i in $list
    do
        wget "$baseurl$i"
    done
    ```

    注意：在不同的环境中，`grep` 等程序有一些细节上的差异。例如，以上的脚本就无法在 macOS 环境中很好地运行（需要安装 GNU grep）。

    另外，此 Shell 脚本只适用于这个特定的页面，并且没有去重。如果需要更加通用的从 HTML 中提取链接并下载的方案，可能需要使用其他编程语言中更加成熟的 HTML 解析框架。
