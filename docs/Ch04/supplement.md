# 拓展阅读 {#supplement}

!!! Failure "本文目前尚未完稿，存在诸多未尽章节且未经审阅，不是正式版本。"

## Linux 下进程查看原理 {#proc}

正文提到，htop 命令的前身是 ps 命令。ps 做为查看进程的基本命令，仅仅提供静态输出，并不能提供实时监控，但是它至少足够基础，可以供 strace 命令分析。

!!! info "strace 命令"

    strace 可以追踪程序使用的系统调用，输出在屏幕上，是一个程序调试工具。此处用来追踪 ps 打开的文件。

    strace 开头字母为 s 是由于该命令为 Sun™ 系统移植而来的调用追踪程序。

    （注意 strace 会输出到标准错误 (stderr)，需要将输出重定向到标准输出之后通过管道后才能使用 grep 等工具。关于重定向、管道等内容，可以查看[第九章](/Ch09/)。）

```shell
$ strace ps
...
openat(AT_FDCWD, "/proc/1/stat", O_RDONLY) = 6
read(6, "1 (systemd) S 0 1 1 0 -1 4194560"..., 1024) = 193
close(6)                                = 0
openat(AT_FDCWD, "/proc/1/status", O_RDONLY) = 6
read(6, "Name:\tsystemd\nUmask:\t0000\nState:"..., 1024) = 1024
read(6, "00,00000000,00000000,00000000,00"..., 1024) = 295
close(6)
...
```

`strace` 会输出很多内容，上面是其中的典型案例。

可以大致猜测，ps 通过打开 `/proc/1` 文件夹下的 `stat` 和 `status` 文件，获得 1 号进程的信息。我们也可以试着打开它：

```shell
$ cat /proc/1/stat                  # 是否添加 sudo 会导致读取出不同内容
1 (systemd) S 0 1 1 0 -1 4194560 113722 4652720 87 2258 79 670 19018 28647 \
20 0 1 0 4 231030784 2252 18446744073709551615 1 1 0 0 0 0 671173123 4096 1260 \
0 0 0 17 0 0 0 135 0 0 0 0 0 0 0 0 0 0

$ cat /proc/1/status
Name:	systemd
Umask:	0000
State:	S (sleeping)
Tgid:	1
Ngid:	0
Pid:	1
PPid:	0
TracerPid:	0
Uid:	0	0	0	0
Gid:	0	0	0	0
FDSize:	256
Groups:
NStgid:	1
NSpid:	1
NSpgid:	1
（以下内容省略）
```

也许第一个文件不是那么好看，但第二个文件就很直白了。至此可以得出结论，根目录下 `/proc` 文件夹储存进程信息，而 htop 等命令通过对该文件夹下的文件进行自动读取来监视进程。实际上，`/proc` 是一个虚拟的文件系统，存在于内存中，反映着系统的运行状态。

<!-- - 内核文件为什么以 **vmlinuz-版本号** 命名？

    <p style="font-size: smaller">简言之，vm是virtual memory，z代表内核被gzip压过，详细情况见[www.linfo.org/vmlinuz.html↗](http://www.linfo.org/vmlinuz.html)，中文 [www.cnblogs.com/beanmoon/archive/2012/10/23/2735886.html↗](https://www.cnblogs.com/beanmoon/archive/2012/10/23/2735886.html)</p>

- 我们一般使用的命令都十分简洁，那么它们都是哪些单词的缩写呢？

    <p style="font-size: smaller">许多情况下，不接触命令所对应的全称是无法记住命令的，然而从英文解释中我们可以自然地知道命令采用哪几个字母作为缩写，从而由名称得知命令用法。欲知详情，请看 [The Ultimate A To Z List of Linux Commands | Linux Command Line Reference](https://fossbytes.com/a-z-list-linux-command-line-reference/)</p> -->

## SysRq: 进行紧急的系统维护操作 {#sysrq}

你可能会注意到，你的键盘上好像有一个从未使用过的键：SysRq。其实它在 Linux 上可以对内核进行一些操作，尤其是在紧急的情况下（例如，界面卡死），可以用来关闭进程、干净地（在不损坏文件系统的情况下）重启系统等操作。

执行 `cat /proc/sys/kernel/sysrq` 可以查看这个功能是否启用，如果是 1 的话，就可以使用 SysRq 键了。按住 Alt + SysRq，再按下其他特定的按键，就可以执行特定的功能。

一个口诀是 "BUSIER"，反过来就是 "REISUB"，是一套可以（尽可能在）在操作界面无响应的时候干净地重启系统的按键。按住 Alt + SysRq 后依次按下这六个键即可。

- R: 从 X 桌面环境夺回键盘的控制权。
- E: 向除了 init (PID = 1) 以外的进程发送 SIGTERM 信号，要求它们干净地退出。
- I: 向除了 init 以外的进程发送 SIGKILL 信号，强制退出。
- S: 从内存同步文件修改到文件系统。
- U: 重新挂载所有的文件系统为只读状态。
- B: 立刻重启系统。

## Linux 中的优先级 {#priority}

## 关于 `fork()` {#fork}

通过以下实验，我们可以尝试使用 fork 系统调用体验建立父子进程关系。

程序文件 `forking.c`：

```c
#include <stdio.h>
#include <unistd.h>  // Unix standard header，提供 POSIX 标准 API

int main() {
    for (int i = 0; i < 3; i++)
    {
        int pid = fork();   // fork 系统调用，全面复制父进程所有信息。
        if (pid == 0) {
            // 子进程返回 pid=0。
            printf("I'm child, forked in %d turn\n", i);
        } else if (pid < 0)  {
            // fork 失败，pid 为负值。
            printf("%d turn error\n", i);
        } else  {
            // 父进程返回子进程 pid。
            printf("I'm father of %d turn, child PID = %d\n", i, pid);
        }
        sleep(3);
    }
    sleep(1000);
    return 0;
}
```

随后，在文件所在目录下打开 shell，运行 `gcc forking.c -o forking && ./forking`，就可以在另一终端打开 htop 查看成果了。

![forking](images/forking.png)

按下 T 键，界面显示的进程将转化为树状结构，直观描述了父子进程之间的关系。此处可以明显观察到树梢子进程的 PID 等于父进程的 PPID。

同时由 shell 进程创立的 forking 进程的进程组号 (PGRP) 为自己的 PID，剩余进程的 PGRP 则继承自最开始的 forking 进程， PGRP 可以通过系统调用修改为自身，从原进程组中独立出去另起门户。

接下来会看到进程 SID 一律为该进程的控制 shell 的 PID。

!!! question "问题"

    上述实验中，输入 `./forking` 后一共产生了多少个进程呢，可以不看 htop 就推算出来吗？

## 编程处理信号 {#signal-programming}

你可能会注意到，有些程序对你按下 Ctrl + C 的操作会有一些独特的响应，例如 `ping`，如果使用 Ctrl + C 键盘中断 (SIGINT)，在程序终止之前会有一段总结；而使用 SIGTERM 不会有此效果。

这个实验中，我们使用系统调用 `signal()` 来重新设置进程对信号的响应函数。

程序文件 `signal_handle.c`：

```c
#include <stdio.h>
#include <signal.h>   // 定义了变更信号处理函数的方法以及一些信号对应的常量（如 #define SIGTERM 15）
#include <unistd.h>   // sleep 函数

void sig_handler(int sig);  // 设置一个处理信号的函数

int main() {
    signal(SIGTERM, sig_handler);    // 替换默认终止信号处理例程
    // signal(SIGINT, sig_handler);  // 替换键盘中断（keyboard interrupt）处理例程
    // signal(SIGHUP, sig_handler);  // 替换控制进程挂起信号处理例程
    // signal(SIGKILL, sig_handler); // 替换……不存在的！

    while (1) {
        sleep(10);  // do something
    }
}


void sig_handler(int sig) {
    printf("hi!\n");     // 在收到信号时输出
    // fflush(stdout);   // 如果你的输出内容不包括回车，或许需要刷新缓冲区才能看到效果。因为标准输出是按行缓冲的。
}
```

随后，在文件所在目录下打开 shell，运行 `gcc signal_handle.c -o signal_handle && ./signal_handle`，就可以在另一终端打开 htop 来试验了。

!!! warning "可重入性"

    事实上，这个程序存在一个隐含的问题：如果在运行 `sig_handler()` 的时候，又有信号输入，会发生什么呢？

    这就牵扯到「可重入性」(reentrant) 这个概念了。如果某程序可以在任意时刻被中断，并且这个程序在中断返回之前又再次被中断的代码执行而不会出现错误，那么它就是「可重入」的。信号处理函数应当可重入，以保证安全执行。不是所有的函数都是可重入的，访问 `man signal-safety`，可以查看到一份可重入库函数的列表。

    当然很遗憾，`printf()` 不是可重入的。

## Systemd service 的文件结构

## `init` 的历史

## 常见服务一览

### 系统服务

### 对外服务

### mail server

### DNS server

### proxy server
