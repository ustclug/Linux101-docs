# 拓展阅读 {#supplement}

!!! warning "本文已基本完稿，正在审阅和修订中，不是正式版本。"

## 编译安装 [^1] {#compiling-installation}

*本节的操作基于 Ubuntu 18.04 操作系统。*

除了在正文中提到的几种常见的安装方法外，还有从源代码编译安装这种方法，更多地常见于开源软件中。在一个新的平台上（如 amd64），只要有 GCC 编译器，就可以通过编译，快速地将许多常用的软件（如 x86\_64 平台上的软件）移植到新的平台上。当然，这并不能解决一些对特定指令集有依赖的软件的移植。

本文以编译安装 Nginx 软件作为示范。

!!! tip "Nginx 软件简介[^2]"

    Nginx 是一个异步框架的网页服务器，也可以用作反向代理、负载平衡器和 HTTP 缓存。

    Nginx 是免费的开源软件，根据类 BSD 许可证的条款发布。大量 Web 服务器使用 Nginx，通常作为负载均衡器。

### 安装依赖 {#install-dependencies}

在从源代码安装 Nginx 前，需要为它的库安装依赖：

* PCRE - 用于支持正则表达式。

```shell
$ wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
$ tar -zxf pcre-8.43.tar.gz
$ cd pcre-8.43
$ ./configure
$ make
$ sudo make install
```

* zlib - 用于支持 HTTP 头部压缩。

```shell
$ wget https://zlib.net/zlib-1.2.11.tar.gz
$ tar -zxf zlib-1.2.11.tar.gz
$ cd zlib-1.2.11
$ ./configure
$ make
$ sudo make install
```

* OpenSSL - 用于支持 HTTPS 协议。

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

1. 使用 wget 等命令来下载源代码（通常是压缩包），并使用 tar 等命令对其解压。

	有关 wget 的知识将会在本书[第六章](../Ch06/index.md)进行详细阐述。

2. 执行 `./configure` 命令运行 configure 脚本。

	configure 脚本为了让一个程序能够在各种不同类型的机器上运行而设计的。在使用 make 编译源代码之前，configure 会根据自己所依赖的库而在目标机器上进行匹配。configure 文件一般为可执行文件（与权限位有关的将在第五章讲述）。

	configure 脚本可以根据所在的系统环境生成相对应的 Makefile 文件，例如自动处理 GCC 版本、判断特定的函数是否在当前系统上可用、确定相应依赖头文件的位置、并对缺少的依赖库进行报错。

	在执行 configure 脚本时，可以传递相对应的参数达到生成不同的 Makefile 文件的目的。

	!!! example "configure 脚本的参数"

		在上面的对 Nginx 源代码进行 `./configure` 时，传入了一些参数，实现了：

		* 指定了一部分配置文件的位置（`sbin-path`、`conf-path`、`pid-path`）；
		* 说明了需要添加或删除的模块（`http_ssl_module`、`steam`、`pcre`、`zlib`、`http_empty_gif_module`）；
		* 指定了依赖库的位置（`../pcre-8.43` 与 `../zlib-1.2.11`）。

3. 执行 `make` 命令。

	make 程序会根据 configure 生成的 Makefile 文件，执行一系列的命令，调用 gcc、cc 等程序，将源代码编译为二进制文件。

4. 执行 `(sudo) make install` 命令。

	在这个过程中，make 命令会将编译好的二进制文件拷贝到相对应的安装目录，拷贝用户手册等。

## tar 的替代

在 Linux 上的 tar 一般只支持 gzip、bzip、xz 和 lzip 几种压缩算法，如果需要解压 Windows 上更为常见的 7z、zip 和 rar 等，则需要寻求替代软件

### unar

```shell
apt install unar
```

安装之后会得到两个命令：`unar` 和 `lsar`，分别用来解压存档文件以及浏览存档文件内容

```shell
# 将存档文件提取到 output 文件夹中
unar archive.zip -o output

# 浏览存档文件内容
lsar archive.zip
# 查看详细信息
lsar -l archive.zip
# 查看特别详细的信息
lsar -L archive.zip 
```


## 引用来源 {#references .no-underline }

[^1]: 本节使用的示例参考自 Nginx 官方说明 [Compiling and Installing from Source](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#compiling-and-installing-from-source)。

[^2]: 信息来自维基百科条目：[Nginx](https://zh.wikipedia.org/wiki/Nginx)。
