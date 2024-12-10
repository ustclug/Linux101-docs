---
icon: material/puzzle
---

# 拓展阅读 {#supplement}

## Python 环境的另一种管理方式：Conda {#conda}

Conda 是一个广泛使用的开源的包管理与环境管理系统。Miniconda 与 Anaconda 是两个广为人知的基于 Conda 的 Python 的发行版本。

### Anaconda 与 Miniconda {#anaconda-and-miniconda}

Miniconda 和 Anaconda 都是开源的 Python 的发行版本。

Miniconda 是 Anaconda 的免费迷你版本，只包含了 Conda、Python 及其依赖，以及少量其他有用的包，例如 pip 和 zlib。而 Anaconda 则额外包含了 250 多个自动安装的科学软件包，例如 SciPy 和 NumPy，并且测试了这些软件包之间的兼容性。Anaconda 分为个人版、商业版、团队版、企业版，除了个人版以外，其余版本均为付费产品。

### 安装 Miniconda {#install-miniconda}

从官网下载安装 Miniconda，并进入虚拟环境。

```console
$ sh -c "$(wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O -)"

# 前面的选项可以保持默认，也可以自行修改
please answer 'yes' or 'no':
>>> yes
# 选择 Miniconda 的安装路径
Miniconda3 will now be installed into this location:
>>> ~/.miniconda3
# 添加配置信息到 ~/.bashrc 文件，这样每次打开终端时会自动激活虚拟环境
Do you wish the installer to initialize Miniconda3 by running conda init? [yes|no]
[no] >>> yes

$ source ~/.bashrc # 应用配置文件信息，激活虚拟环境
```

### Conda 作为包管理器 {#conda-as-package-management-system}

类似于 pip，可以使用 `conda install` 来安装软件包。部分软件包既可以使用 pip 安装，也可以使用 conda 安装。
相比于 pip，conda 会执行更加严格的依赖检查，并且除了 Python 软件包外，还可以安装一些 C/C++ 软件包，例如 cudatoolkit、mkl 等。相对的，conda 支持的 Python 软件包的数量远少于 PyPI。

### Conda 作为环境管理器 {#conda-as-environment-management-system}

类似于 Virtualenv，可以使用 conda 来管理虚拟环境。

常见的使用方式如下：

```console
$ conda create -n venv python=3.11 # 创建一个名为 venv，Python 版本为 3.11 的虚拟环境
# 请确认虚拟环境已经成功创建
$ conda activate venv # 切换到名为 venv 的虚拟环境
$ conda deactivate # 退出当前虚拟环境
```

### 导出导入环境 {#export-import-env}

在一些 Python 项目中，你能找到一个 `environment.yml` 文件。
此文件类似于 `requirements.txt`，是 Conda 用以描述环境配置的文件。
你可以利用此文件来分享或复制环境，从而运行其他人的项目。

`environment.yml` 文件不会自动生成。
为了获取当前环境所对应的 `environment.yml` 文件，你需要使用以下命令：

```console
$ conda env export > environment.yml
```

此文件会包含当前环境下所有已装包的版本信息以便复现。
如果你只需要导出明确由用户自己安装的包、而不包含这些包的依赖，可以使用 `--from-history` 选项。

通过 `environment.yml` 文件，你可以使用以下命令来复现环境：

```console
$ conda env create -f environment.yml
```

复现出的环境的名字与原环境相同、由 `environment.yml` 文件的 `name` 字段传递。
相似的，环境的存放位置由 `prefix` 字段传递。

??? info "由 pip 安装的包"

    使用 `--from-history` 选项时，由 pip 安装的包不会被包含在 `environment.yml` 文件中。
    而在不使用此选项的一般情况下，由 pip 安装的包会被记录在 `environment.yml` 文件中的 `pip` 列表内，因而可以被复现。

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
    -rwxrwxr-x 1 ustc ustc  17K Feb 28 14:43 hello
    -rwxrwxr-x 1 ustc ustc 852K Feb 28 14:39 hello-static
    -rwxrwxr-x 1 ustc ustc  26K Feb 28 15:00 hello-static-musl
    $ # 可以看到静态链接 musl 得到的文件与动态链接接近，并且远小于静态链接 glibc 得到的文件。
    $ musl-gcc -o getaddrinfo-example-musl getaddrinfo.c -static
    $ # musl libc 的 getaddrinfo() 实现不依赖于额外的系统组件，所以可以正常静态链接
    ```

## 交叉编译示例 {#cross-compile-example}

有时候，我们需要为其他的平台编写程序，例如：

-   我正在使用的电脑是 x86_64 架构的，但是我现在需要给树莓派编写程序（体系结构不同）。
-   我正在使用 Linux，但是我现在需要编译出一个 Windows 程序（操作系统不同）。

怎么办呢？只能用虚拟化程序运行目标架构，然后在上面跑编译了吗？这样会很麻烦、速度可能会很慢，甚至有的时候不可行（例如性能低下的嵌入式设备，可能连编译器都加载不了）。

这时候就需要交叉编译了。对于常见的架构，Ubuntu/Debian 提供了对应的交叉编译器，很大程度方便了使用。以下将给出交叉编译简单的示例。

### 在 x86_64 架构编译 aarch64 的程序 {#x86_64-cross-compile-aarch64}

Aarch64 是 ARM 指令集的 64 位架构。

```console
$ sudo apt install gcc-aarch64-linux-gnu  # 安装交叉编译到 aarch64 架构的编译器，同时也会安装对应架构的依赖库
$ aarch64-linux-gnu-gcc -o hello-aarch64 hello.c  # 直接编译即可
$ file hello-aarch64  # 看一下文件信息，可以看到是 aarch64 架构的
hello-aarch64: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=09d2ad67b8e2f3b4befe3ce846182743d27910db, for GNU/Linux 3.7.0, not stripped
$ ./hello-aarch64  # 无法直接运行，因为架构不兼容
-bash: ./hello-aarch64: cannot execute binary file: Exec format error
$ sudo apt install qemu-user-static  # 安装 qemu 模拟器
$ qemu-aarch64-static ./hello-aarch64  # 使用 aarch64 模拟器运行程序
/lib/ld-linux-aarch64.so.1: No such file or directory
$ # 为什么仍然无法运行？这是因为 qemu 不知道从哪里找运行时库
$ # 需要补充 QEMU_LD_PREFIX 环境变量
$ QEMU_LD_PREFIX=/usr/aarch64-linux-gnu/ qemu-aarch64-static ./hello-aarch64
Hello, world!
```

### 在 Linux 下编译 Windows 程序 {#linux-cross-compile-windows}

这里使用 mingw 来进行交叉编译。

```console
$ sudo apt install gcc-mingw-w64  # 安装 mingw 交叉编译器
$ sudo apt install wine  # 安装 wine Windows 兼容层（默认仅安装 64 位架构支持）
$ x86_64-w64-mingw32-gcc -o hello.exe hello.c  # 编译为 64 位的 Windows 程序
$ file hello.exe  # 确认为 Windows 程序
hello.exe: PE32+ executable (console) x86-64, for MS Windows
$ wine hello.exe  # 使用 wine 运行
it looks like wine32 is missing, you should install it.
as root, please execute "apt-get install wine32"
wine: created the configuration directory '/home/ubuntu/.wine'
（忽略首次配置的输出）
wine: configuration in L"/home/ubuntu/.wine" has been updated.
Hello, world!
```

MinGW 也可以编译 Windows 下的图形界面应用程序。以下的程序例子来自 [Windows Hello World Sample](https://docs.microsoft.com/en-us/windows/win32/learnwin32/windows-hello-world-sample)（MIT License），稍作修改以符合 C 语言的语法。

```c
// winhello.c
#ifndef UNICODE
#define UNICODE
#endif

#include <windows.h>

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE _, PWSTR pCmdLine, int nCmdShow)
{

    // Register the window class.
    const wchar_t CLASS_NAME[]  = L"Sample Window Class";

    WNDCLASS wc = { };

    wc.lpfnWndProc   = WindowProc;
    wc.hInstance     = hInstance;
    wc.lpszClassName = CLASS_NAME;

    RegisterClass(&wc);

    // Create the window.

    HWND hwnd = CreateWindowEx(
        0,                              // Optional window styles.
        CLASS_NAME,                     // Window class
        L"Learn to Program Windows",    // Window text
        WS_OVERLAPPEDWINDOW,            // Window style

        // Size and position
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,

        NULL,       // Parent window
        NULL,       // Menu
        hInstance,  // Instance handle
        NULL        // Additional application data
        );

    if (hwnd == NULL)
    {
        return 0;
    }

    ShowWindow(hwnd, nCmdShow);

    // Run the message loop.
    MSG msg = { };
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    switch (uMsg)
    {
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;

    case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            // All painting occurs here, between BeginPaint and EndPaint.
            FillRect(hdc, &ps.rcPaint, (HBRUSH) (COLOR_WINDOW+1));
            EndPaint(hwnd, &ps);
        }
        return 0;
    }

    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}
```

```console
$ x86_64-w64-mingw32-gcc -o winhello.exe winhello.c
/usr/bin/x86_64-w64-mingw32-ld: /usr/lib/gcc/x86_64-w64-mingw32/9.3-win32/../../../../x86_64-w64-mingw32/lib/libmingw32.a(lib64_libmingw32_a-crt0_c.o): in function `main':
./build/x86_64-w64-mingw32-x86_64-w64-mingw32-crt/./mingw-w64-crt/crt/crt0_c.c:18: undefined reference to `WinMain'
collect2: error: ld returned 1 exit status
$ # 编译失败，这是因为编译 Windows Unicode（UTF-16）程序需要额外的参数 -municode。
$ # 参见 https://sourceforge.net/p/mingw-w64/wiki2/Unicode%20apps/
$ x86_64-w64-mingw32-gcc -o winhello.exe winhello.c -municode
$ wine winhello.exe  # 需要在图形界面下执行，或者复制到 Windows 中执行亦可
```
