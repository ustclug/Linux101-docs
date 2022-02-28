# 拓展阅读 {#supplement}

## Python 环境的另一种管理方式：Anaconda {#anaconda}

## 动态链接与静态链接 {#dynamic-or-static-link}

在大部分情况下，我们编译的程序都是动态链接的。动态链接在这里指程序文件还依赖其他库文件，可以使用 `ldd` 命令确认：

```shell
$ cat hello.c
#include <stdio.h>

int main() {
    puts("Hello, world!");
    return 0;
}
$ gcc -o hello hello.c
$ ldd ./hello
	linux-vdso.so.1 (0x00007ffc49703000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f36767d3000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f36769ea000)
```

这里，我们编译得到程序就依赖于 `linux-vdso.so.1`、`libc.so.6` 和 `/lib64/ld-linux-x86-64.so.2` 三个库文件，如果系统中没有这三个库文件，程序就无法执行。

??? info "这三个文件的用途"

    可以看到，即使是 Hello, world 这么简单的程序，也需要外部库文件。

    - linux-vdso.so.1：这个库是为了减小用户程序调用系统调用产生的切换模式（用户态 -> 内核态 -> 用户态）的开销而设计的。这个文件事实上并不存在。在内核加载程序时，这一部分会被自动加载入程序内存中。详情可参考 vdso(7) 文档。
    - libc.so.6：C 运行时库，提供各种 C 函数的实现。
    - ld-linux-x86-64.so.2：动态链接加载器。当程序需要动态链接库中的函数时负责查找并加载对应的函数。

我们在编写程序时，有时需要使用到第三方的库，此时需要加上 `-l` 参数指定在**链接**时链接到的库。

```shell
$ gcc -o thread thread.c -lpthread  # 编译一个依赖于 pthread 线程库的应用
$ ldd ./thread  # 可以看到多出了 libpthread.so.0 的动态链接依赖
	linux-vdso.so.1 (0x00007ffe6ad93000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fad173c7000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fad171d5000)
	/lib64/ld-linux-x86-64.so.2 (0x00007fad17407000)
```

对于复杂的应用来说，下载后可能会因为没有动态链接库而无法运行。这一点在打包、分发自己编写的程序时也要特别注意。

```console
$ ldd MegaCli64
	linux-vdso.so.1 (0x00007ffca1868000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fa77f6c9000)
	libncurses.so.5 => not found
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fa77f6c3000)
	libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007fa77f4e1000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fa77f392000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007fa77f375000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fa77f183000)
	/lib64/ld-linux-x86-64.so.2 (0x00007fa77f704000)
$ ./MegaCli64  # 缺少 libncurses.so.5，从而无法执行
./MegaCli64: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory
```

而静态链接则将依赖的库全部打包到程序文件中。

```shell
$ gcc -o hello-static hello.c -static  # 编译一个静态链接的应用
$ ldd ./hello-static  # 没有动态链接库的依赖
	not a dynamic executable
```

此时编译得到的程序文件没有额外的依赖，在其他机器上一般也能顺利运行。近年来流行的 Go 语言的一大特点也是静态链接，编译得到的程序有着很好的兼容性。

但是静态链接也存在一些问题。首先是程序大小，比较一下前面编译的 hello-static 和 hello 的大小吧：

```shell
$ ls -l hello hello-static
-rwxrwxr-x 1 ustc ustc  17K Feb 28 14:43 hello
-rwxrwxr-x 1 ustc ustc 852K Feb 28 14:39 hello-static
```

可以看到，动态链接的程序比较小，而静态链接的程序大小接近 1M，况且这还只是一个最简单的 hello world！并且在大小方面，静态链接的程序在运行时无法共享运行库的内存，从而导致内存占用也有一定程度增加。

其次，当运行库出现问题时，用户可以选择更新库，此时所有动态链接的程序都能得到修复，但是静态链接的程序由于不使用系统库，就不得不一个个重新编译。

最后一点是，Linux 的默认 C 库 glibc 对静态链接并不友好，如果程序使用了一部分函数，在静态链接时会受到限制。

```console
$ gcc -o getaddrinfo-example getaddrinfo.c -static
/usr/bin/ld: /tmp/ccPZTyKT.o: in function `main':
getaddrinfo.c:(.text+0xd2): warning: Using 'getaddrinfo' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
```

!!! tip "Musl libc"

    近年来，musl libc 开始流行，并且它也是 Alpine Linux 的 C 运行时库。它的特点是轻量、快速、对静态链接友好。我们也可以来试一下：

    ```shell
    $ sudo apt install musl-tools  # musl-tools 提供了 musl-gcc 等方便的编译工具
    $ musl-gcc -o hello-static-musl hello.c -static  # 静态链接 musl libc
    $ ls -lha hello hello-static hello-static-musl
    -rwxrwxr-x 1 ubuntu ubuntu  17K Feb 28 14:43 hello
    -rwxrwxr-x 1 ubuntu ubuntu 852K Feb 28 14:39 hello-static
    -rwxrwxr-x 1 ubuntu ubuntu  26K Feb 28 15:00 hello-static-musl
    $ # 可以看到静态链接 musl 得到的文件与动态链接接近，并且远小于静态链接 glibc 得到的文件。
    $ musl-gcc -o getaddrinfo-example-musl getaddrinfo.c -static
    $ # musl libc 的 getaddrinfo() 实现不依赖于额外的系统组件，所以可以正常静态链接
    ```

## 交叉编译示例 {#cross-compile-example}
