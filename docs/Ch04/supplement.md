!!! Failure "本文目前尚未完稿，存在诸多未尽章节且未经审阅，不是正式版本。"

## 思考题解答



## Linux下进程查看原理

正文提到，htop 命令的前身是 ps 命令。ps 做为查看进程的基本命令，仅仅提供静态输出，并不能提供实时监控，但是它至少足够基础，可以供 strace 命令分析。

!!! info "strace 命令"
    strace 可以追踪程序使用的系统调用，输出在屏幕上，是一个 debug 工具。此处用来追踪 strace 打开的文件。
    
    strace 开头字母为 s 是由于该命令为 Sun™ 系统移植而来的调用追踪程序。
    
    （提醒一下 strace 输出到 stderr，需要将输出[重定向到 stdin ↗](/Ch09/# redirect)后才能使用 grep 等工具。）
    
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
说实在的，这里输出实在多，所幸有许多重复的内容，上面是其中的典型案例。

可以大致猜测，ps 通过打开 `/proc/1` 文件夹下的 `stat` 和 `status` 文件，获得1号进程的信息。我们也可以试着打开它：

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
...
```
也许第一个文件不是那么好看，但第二个文件就很直白了。至此可以得出结论，根目录下 `/proc` 文件夹储存进程信息，而 htop 等命令通过对该文件夹下的文件进行自动读取来监视进程。实际上，`/proc` 是一个虚拟的文件系统，存在于内存中，反映着系统的运行状态。

## systemd service 文件结构

## systemd VS init

二位作用都是用户进程的祖宗，负责维系用户

## 常见服务一览 （先列举再排序）

### 系统服务


### 对外服务
### mail server

### DNS server

### proxy server

###


## 补充链接（linux相关的一些细节）

- 内核文件为什么以 **vmlinuz-版本号** 命名？
    
    <p style="font-size: smaller">简言之，vm是virtual memory，z代表内核被gzip压过，详细情况见[www.linfo.org/vmlinuz.html↗](http://www.linfo.org/vmlinuz.html)，中文 [www.cnblogs.com/beanmoon/archive/2012/10/23/2735886.html↗](https://www.cnblogs.com/beanmoon/archive/2012/10/23/2735886.html)</p>

- 我们一般使用的命令都十分简洁，那么它们都是哪些单词的缩写呢？
    
    <p style="font-size: smaller">许多情况下，不接触命令所对应的全称是无法记住命令的，然而从英文解释中我们可以自然地知道命令采用哪几个字母作为缩写，从而由名称得知命令用法。欲知详情，请看 [The Ultimate A To Z List of Linux Commands | Linux Command Line Reference](https://fossbytes.com/a-z-list-linux-command-line-reference/)</p>

- 你注意到键盘上有一个截图快捷键（类似于print screen）了吗？但这不是重点，重点是在某些键盘布局中，它和system request合体了。虽然system request在Windows下失去了意义，但Linux下可以通过该按键直接调用内核命令，拯救卡死的系统呢。<a href="https://www.howtogeek.com/119127/use-the-magic-sysrq-key-on-linux-to-fix-frozen-x-servers-cleanly-reboot-and-run-other-low-level-commands/">详情↗</a> 