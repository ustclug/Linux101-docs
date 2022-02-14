# 拓展阅读 {#supplement}

!!! success "本文已完稿并通过审阅，是正式版本。"

## 编译安装 [^1] {#compiling-installation}

本节的操作基于 Ubuntu 18.04 操作系统。

除了在正文中提到的几种常见的安装方法外，还有从源代码编译安装这种方法，更多地常见于开源软件中。在一个新的平台上（如 amd64），只要有 GCC 编译器，就可以通过编译，快速地将许多常用的软件（如 x86_64 平台上的软件）移植到新的平台上。当然，这并不能解决一些对特定指令集有依赖的软件的移植。

本文以编译安装 Nginx 软件作为示范。

!!! tip "Nginx 软件简介[^2]"

    Nginx 是一个异步框架的网页服务器，也可以用作反向代理、负载平衡器和 HTTP 缓存。

    Nginx 是免费的开源软件，根据类 BSD 许可证的条款发布。大量 Web 服务器使用 Nginx，通常作为负载均衡器。

### 安装依赖 {#install-dependencies}

在从源代码安装 Nginx 前，需要为它的库安装依赖：

- PCRE - 用于支持正则表达式。

```shell
$ wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
$ tar -zxf pcre-8.43.tar.gz
$ cd pcre-8.43
$ ./configure
$ make
$ sudo make install
```

- zlib - 用于支持 HTTP 头部压缩。

```shell
$ wget https://zlib.net/zlib-1.2.11.tar.gz
$ tar -zxf zlib-1.2.11.tar.gz
$ cd zlib-1.2.11
$ ./configure
$ make
$ sudo make install
```

- OpenSSL - 用于支持 HTTPS 协议。

```shell
$ wget https://www.openssl.org/source/openssl-1.1.1c.tar.gz
$ tar -zxf openssl-1.1.1c.tar.gz
$ cd openssl-1.1.1c
$ ./Configure linux-x86_64 --prefix=/usr
$ make
$ sudo make install
```

> 在文档中第 4 步使用的是 `./Configure darwin64-x86_64-cc --prefix=/usr`，这个是在 macOS 下进行配置时使用的参数，对于在 Ubuntu 64bit 下，需要修改为 `linux-x86_64`。

### 下载 Nginx 源代码 {#download-source}

```shell
$ wget https://nginx.org/download/nginx-1.17.6.tar.gz
$ tar zxf nginx-1.17.6.tar.gz
$ cd nginx-1.17.6
```

### 使用源代码安装 {#install-from-source}

#### 配置编译选项 {#configure}

```shell
$ ./configure \
--sbin-path=/usr/local/nginx/nginx \
--conf-path=/usr/local/nginx/nginx.conf \
--pid-path=/usr/local/nginx/nginx.pid \
--with-http_ssl_module \
--with-stream \
--with-pcre=../pcre-8.43 \
--with-zlib=../zlib-1.2.11 \
--without-http_empty_gif_module
```

!!! tip "分解长命令"

    使用 `\` 符号将一行长命令分解为多行书写，便于阅读。

#### 编译并安装 {#make-install}

```shell
$ make
$ sudo make install
```

### 总结 {#summary}

从 Nginx 的源代码编译安装可以看出，无论是它的依赖还是主程序，主要过程均经历如下几个步骤：

1.  使用 wget 等命令来下载源代码（通常是压缩包），并使用 tar 等命令对其解压。

    有关 wget 的知识将会在本书[第六章](../Ch06/index.md)进行详细阐述。

2.  执行 `./configure` 命令运行 configure 脚本。

    configure 脚本为了让一个程序能够在各种不同类型的机器上运行而设计的。在使用 make 编译源代码之前，configure 会根据自己所依赖的库而在目标机器上进行匹配。configure 文件一般为可执行文件（与权限位有关的将在第五章讲述）。

    configure 脚本可以根据所在的系统环境生成相对应的 Makefile 文件，例如自动处理 GCC 版本、判断特定的函数是否在当前系统上可用、确定相应依赖头文件的位置、并对缺少的依赖库进行报错。

    在执行 configure 脚本时，可以传递相对应的参数达到生成不同的 Makefile 文件的目的。

    !!! example "configure 脚本的参数"

        在上面的对 Nginx 源代码进行 `./configure` 时，传入了一些参数，实现了：

        * 指定了一部分配置文件的位置（`sbin-path`、`conf-path`、`pid-path`）；
        * 说明了需要添加或删除的模块（`http_ssl_module`、`steam`、`pcre`、`zlib`、`http_empty_gif_module`）；
        * 指定了依赖库的位置（`../pcre-8.43` 与 `../zlib-1.2.11`）。

3.  执行 `make` 命令。

    make 程序会根据 configure 生成的 Makefile 文件，执行一系列的命令，调用 gcc、cc 等程序，将源代码编译为二进制文件。

4.  执行 `(sudo) make install` 命令。

    在这个过程中，make 命令会将编译好的二进制文件拷贝到相对应的安装目录，拷贝用户手册等。

## tar 的替代与其他压缩软件 {#tar-alternative}

在 Linux 上的 tar 一般只支持 gzip、bzip、xz 和 lzip 几种压缩算法，如果需要解压 Windows 上更为常见的 7z、zip 和 rar 等，则需要寻求替代软件。

### unar {#unar}

unar 是 macOS 上的软件 [The Unarchiver](https://theunarchiver.com/) 的命令行工具，能够同样用于 Windows 和 Linux。

软件介绍：[Unar and Lsar | Command Line Tools for The Unarchiver](https://theunarchiver.com/command-line)。

Ubuntu 上直接使用 apt 安装即可：

```shell
$ sudo apt install unar
```

对于其他 Linux 发行版，请参照网站的介绍，安装合适的依赖以进行编译安装。

安装之后会得到两个命令：`unar` 和 `lsar`，分别用来解压存档文件以及浏览存档文件内容：

```shell
$ unar archive.zip -o output # 将存档文件提取到 output 文件夹中
$ lsar archive.zip # 浏览存档文件内容
$ lsar -l archive.zip # 查看详细信息
$ lsar -L archive.zip # 查看特别详细的信息
```

### 处理 ZIP 压缩包：`zip` 与 `unzip` {#zip}

`zip` 和 `unzip` 工具分别负责 ZIP 压缩包的压缩与解压缩，使用以下命令安装：

```shell
$ sudo apt install zip unzip
```

以下提供一些命令例子，更多的功能需要查看对应的文档：

```shell
$ zip -r archive.zip path/file1 path/dir1  # （递归地）压缩文件和目录
$ zip archive.zip path/file2 # 添加文件到已有的压缩包
$ unzip archive.zip # 解压缩
$ unzip archive.zip -d path/ # 解压缩到指定目录
$ unzip -l archive.zip # 浏览压缩包内容
```

### 处理 RAR 压缩包：`rar` 与 `unrar` {#rar}

`rar` 和 `unrar` 工具分别负责 RAR 压缩包的压缩与解压缩，使用以下命令安装：

```shell
$ sudo apt install rar unrar
```

!!! warning "RAR 压缩程序的版权问题"

    RAR 的解压缩程序是免费的（源代码也是公开的[^3]），但是压缩程序并不是。Windows 下的 WinRAR，以及上面安装的 Linux 的 `rar` 程序都是 [RARLAB](https://www.rarlab.com/) 的商业共享软件。尽管软件层面没有功能限制，但是根据 RARLAB 的要求，在经过 `rar` 的 40 天试用期后，需要购买授权。具体要求可在安装后查看 `/usr/share/doc/rar/order.htm` 文件。

例子如下：

```shell
$ rar a archive.rar path/file1 path/dir1 # 压缩文件和目录/添加文件和目录到压缩包
$ unrar x archive.rar # 解压缩
$ unrar x archive.rar path/ # 解压缩到指定目录
$ unrar l archive.rar # 浏览压缩包内容
```

RARLAB 仅提供了 Linux 下命令行界面的 RAR 压缩包处理工具。但在安装以上软件包后，Linux 下桌面环境中的压缩工具应当都能够支持 RAR 格式的处理。如有特殊需要，可以使用 Wine（Windows 兼容层）运行 WinRAR。

### 处理 7zip 等压缩包：`p7zip` {#7z}

Ubuntu 下 `p7zip-full` 包提供了 `7z` 等工具处理 7z 包（以及其他各种压缩格式）：

```
$ sudo apt install p7zip-full
```

!!! info "`7z`、`7za`、`7zr` 与 `p7zip` 的区别"

    `p7zip-full` 软件包同时提供了以上的命令行工具。其中 `7z`、`7za` 和 `7zr` 都是直接处理 7zip 压缩包的程序，区别如下[^4]：

    - `7z`：通过插件支持各类压缩格式的处理；
    - `7za`：是独立的程序，支持的格式比 `7z` 少一些；
    - `7zr`：轻量级的 `7za`，仅包含 7zip 等少量压缩算法支持的工具。

    而 `p7zip` 基于 `7za` 或 `7zr`，提供类似于 `gzip` 的接口。

以下给出 `7z` 命令行工具的一些例子：

```shell
$ 7z a archive.7z path/file1 path/dir1 # 压缩文件和目录/添加文件和目录到压缩包
$ 7z x archive.7z # 解压缩
$ 7z x archive.7z -opath/ # 解压缩到 path/ 目录下
$ 7z l archive.7z # 浏览压缩包内容
```

与 `rar` 类似，7z 未提供 GUI 工具。如有特殊需要，可以使用 Wine 运行 Windows 版的 7-Zip。

## 引用来源与注释 {#references .no-underline }

[^1]: 本节使用的示例参考自 Nginx 官方说明 [Compiling and Installing from Source](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#compiling-and-installing-from-source)。
[^2]: 信息来自维基百科条目：[Nginx](https://zh.wikipedia.org/wiki/Nginx)。
[^3]: 但是 `unrar` 不是开源软件，因为它的[协议](https://github.com/debian-calibre/unrar-nonfree/blob/master/license.txt)不允许使用其代码制作压缩 RAR 包的工具，这违背了开源软件的定义。
[^4]: 参考了 <https://wiki.archlinux.org/title/p7zip#Differences_between_7z,_7za_and_7zr_binaries> 与相关 man 文档编写。
