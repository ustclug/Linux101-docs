# 附录

## 编译安装

*参见：Compiling and Installing from Source [^1]*

*以下在 Ubuntu 18.04 下操作*

除了在正文中提到的几种常见的安装方法外，还有从源码编译安装这种方法，更多地常见于开源软件中。在一个新的平台上（如 amd64），只要有 GCC 编译器，既可以通过编译，快速地将许多常用的软件（如 x86\_64 平台上的软件）移植到新的平台上。当然，这并不能解决一些对特定指令集有依赖的软件的移植。

以 Nginx 软件为例

!!! Tip "Nginx 软件简介[^2]"
    Nginx 是一个异步框架的网页服务器，也可以用作反向代理、负载平衡器和 HTTP 缓存。

    Nginx 是免费的开源软件，根据类 BSD 许可证的条款发布。大量 Web 服务器使用 Nginx，通常作为负载均衡器。

### 安装依赖

在从源码安装 Nginx 前，需要为它的库安装依赖

* PCRE - 用于支持正则表达式

```
$ wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
$ tar -zxf pcre-8.43.tar.gz
$ cd pcre-8.43
$ ./configure
$ make
$ sudo make install
```

* zlib - 用于支持 HTTP 头部压缩

```
$ wget https://zlib.net/zlib-1.2.11.tar.gz
$ tar -zxf zlib-1.2.11.tar.gz
$ cd zlib-1.2.11
$ ./configure
$ make
$ sudo make install
```

* OpenSSL - 用于支持 HTTPS 协议

```
$ wget https://www.openssl.org/source/openssl-1.1.1c.tar.gz
$ tar -zxf openssl-1.1.1c.tar.gz
$ cd openssl-1.1.1c
$ ./Configure linux-x86_64 --prefix=/usr
$ make
$ sudo make install
```

> 在文档中第 4 步使用的是 `./Configure darwin64-x86_64-cc --prefix=/usr`，这个是在 macOS 下进行配置时使用的参数，对于在 Ubuntu 64bit 下，需要修改为 `linux-x86_64`

### 下载 Nginx 源代码
```
$ wget https://nginx.org/download/nginx-1.17.6.tar.gz
$ tar zxf nginx-1.17.6.tar.gz
$ cd nginx-1.17.6
```

### 从源码进行安装

#### 配置编译选项

```
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

!!! Tip "Tip"

    使用 `\` 符号将一行长命令分解为多行书写，便于阅读

#### 编译并安装
```
$ make
$ sudo make install
```

## 总结

从 Nginx 的从源码编译安装可以看出，无论是它的依赖还是主程序，主要过程均为如下几个

### 下载源码，并解压（wget、tar）
   > wget 将会在第五章进行详细阐述

### 运行 `./configure`

`configure` 脚本为了让一个程序能够在各种不同类型的机器上运行而设计的。在使用 `make` 编译源代码之前，`configure` 会根据自己所依赖的库而在目标机器上进行匹配。`configure` 文件一般为可执行文件（与权限位有关的将在第五章讲述）。

`configure` 脚本可以根据所在的系统环境生成相对应的 `Makefile` 文件，例如自动处理 GCC 版本、判断特定的函数是否在当前系统上可用、确定相应依赖头文件的位置、并对缺少的依赖库进行报错

在执行 `configure` 脚本时，可以传递相对应的参数达到生成不同的 `Makefile` 文件的目的。

!!! Example ""
    在上面的对 Nginx 源代码进行 `./configure` 时，传入了一些参数，实现了：

    * 指定了一部分配置文件的位置（`sbin-path`、`conf-path`、`pid-path`）
    * 说明了需要添加或删除的模块（`http_ssl_module`、`steam`、`pcre`、`zlib`、`http_empty_gif_module`）
    * 指定了依赖库的位置（`../pcre-8.43` 与 `../zlib-1.2.11`）

### 执行 `make`

`make` 程序会根据 `configure` 生成的 `Makefile` 文件，执行一系列的命令，调用 `gcc`、`cc` 等程序，将源代码编译为二进制文件。

### 执行 `sudo make install`

在这个过程中，`make` 命令会将编译好的二进制文件拷贝到相对应的安装目录，拷贝用户手册等

## 引用来源

[^1]: https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#compiling-and-installing-from-source

[^2]: https://zh.wikipedia.org/wiki/Nginx
