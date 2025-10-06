---
icon: material/server-network
---

# 网络、文本处理工具与 Shell 脚本

!!! success "本文已完稿并通过审阅，是正式版本。"

!!! abstract "导言"

    很多 Linux 的初学者都会对以下这些问题感到迷惑：

    - 如何把命令的输出放到文件里？如何把命令的输出作为其他命令的输入？
    - 在命令行黑乎乎的窗口，我要怎么下载文件？
    - 在命令行下，下载任务可以放在后台吗？如果我在命令行下结束下载任务，会不会使已下载部分全部白费？
    - 在命令行下怎么查找与替换文件中的字符串？
    - Bash 语法和 C 语言类似吗？和 Powershell 类似吗？
    - Bash script 出 bug 的时候我该如何调试呢？

    下面内容可以解答你的疑问。

## I/O 重定向与管道 {#redirection-and-pipe}

### 重定向 {#redirection}

一般情况下命令从**标准输入（stdin）**读取输入，并输出到**标准输出（stdout）**，默认情况下两者都是你的终端。使用重定向可以让命令从文件读取输入/输出到文件。下面是以 `echo` 为例的重定向输出：

```console
$ echo "Hello Linux!" > output_file # 将输出写入到文件（覆盖原有内容）
$ cat output_file
Hello Linux!
$ echo "rewrite it" > output_file
$ cat output_file # 可以看到原来的 Hello Linux! 被覆盖了。
rewrite it
$ echo "append it" >> output_file # 将输出追加到文件（不会覆盖原有内容）
$ cat output_file
rewrite it
append it
```

无论是 `>` 还是 `>>`，当输出文件不存在时都会创建该文件。

重定向输入使用符号 `<`：

```shell
command < inputfile
command < inputfile > outputfile
```

!!! tip "小知识"

    除了 stdin 和 stdout 还有标准错误（stderr），他们的编号分别是 0、1、2。stderr 可以用 `2>` 重定向（注意数字 2 和 > 之间没有空格）。

    使用 `2>&1` 可以将 stderr 合并到 stdout。

### 管道 {#pipe}

管道（pipe），操作符 `|`，作用为将符号左边的命令的 stdout 接到之后的命令的 stdin。管道不会处理 stderr。

![管道示例](./images/pipe.png)

管道是类 UNIX 操作系统中非常强大的工具。通过管道，我们可以将实现各类小功能的程序拼接起来干大事。

示例如下：

```console
$ ls / | grep bin  # 筛选 ls / 输出中所有包含 bin 字符串的行
bin
sbin
```

## 网络下载 {#download-utils}

### 为何使用 wget 和 cURL {#why-wget-and-curl}

在 Windows 下，很多人下载文件时会使用「迅雷」、「QQ 旋风」（停止运营）、「IDM」之类的软件来实现下载。那么在 Linux 环境下呢？在终端下，没有可视化软件提供点击下载。即使有桌面环境，有 Firefox 可以很方便地下载文件，硬件资源也会被很多不必要的服务浪费。通过以下内容讲述的 wget (`wget`) 和 cURL (`curl`) 工具，我们可以 Linux 上进行轻量的下载活动。

### Wget {#wget}

`wget` 是强力方便的下载工具，可以通过 HTTP 和 FTP 协议从因特网中检索并获取文件。

#### Wget 的特点 {#wget-features}

- 支持以非交互方式工作，能够在用户注销后在后台进行工作。

- 在不稳定的连接中依旧可以正常工作，支持断点续传功能。

- 支持 HTML 页面以及 FTP 站点的递归检索，您可以使用它来获取网站的镜像，或者像爬虫一样遍历网络。

- 在文件获取时可以增加时间标记，因此可以自动识别远程文件自上次检索后是否发生更改，并自动检索新版本。

- 支持代理服务器，以减轻网络负载，加快检索速度。

#### 使用 Wget {#wget-usage}

使用 `man wget` 得到的结果为 `wget [option]... [URL]...`，其中的更多参数可以通过查看帮助 `wget -h` 来获取。

常用的选项

| 选项                           | 含义                                   |
| ------------------------------ | -------------------------------------- |
| `-i`, `--input-file=文件`      | 下载本地或外部文件中的 URL             |
| `-O`, `--output-document=文件` | 将输出写入文件                         |
| `-b`, `--background`           | 在后台运行 wget                        |
| `-d`, `--debug`                | 调试模式，打印出 wget 运行时的调试信息 |

??? example "范例"

    批量下载 filelist.txt 中给出的链接：

    ```console
    $ wget -i filelist.txt
    ```

    安装 oh-my-zsh：

    ```console
    $ sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    ```

### cURL {#curl}

cURL (`curl`) 是一个利用 URL 语法在命令行下工作的文件传输工具，其中 c 意为 client。虽然 cURL 和 Wget 基础功能有诸多重叠，如下载。但 cURL 由于可自定义各种请求参数，所以在模拟 web 请求方面更擅长；wget 由于支持 FTP 协议和递归遍历，所以在下载文件方面更擅长。

#### 使用 cURL {#curl-usage}

同 `wget` 部分，我们可以查看帮助 `curl -h` 了解其用法。

常用的选项

| 选项 | 含义                                                      |
| ---- | --------------------------------------------------------- |
| `-o` | 把远程下载的数据保存到文件中，需要指定文件名              |
| `-O` | 把远程下载的数据保存到文件中，直接使用 URL 中默认的文件名 |
| `-I` | 只展示响应头内容                                          |

??? example "范例"

    输出必应主页的代码：

    ```console
    $ curl "http://cn.bing.com"
    ```

    使用重定向把必应页面保存至 `bing.html` 本地：

    ```console
    $ curl "http://cn.bing.com" > bing.html
    ```

    也可以使用 `-o` 选项指定输出文件：

    ```console
    $ curl -o bing.html "http://cn.bing.com"
    ```

    下载 USTCLUG 的 logo：

    ```console
    $ curl -O "https://ftp.lug.ustc.edu.cn/misc/logo-whiteback-circle.png"
    ```

    只展示 HTTP 响应头内容：

    ```console
    $ curl -I "http://cn.bing.com"
    ```

!!! warning "关于从 Internet 获取的脚本"

    直接通过 `curl` 或者 `wget` 等工具从 Internet 获取脚本然后通过管道传给 `sh` 等 Shell 执行是非常危险的操作。运行脚本前，请确保脚本是从正确的地址下载的，并仔细检查要执行的脚本内容。

### 其他 {#download-others}

除了 Wget、cURL，还有 mwget（多线程版本 wget）、Axel、Aria2（支持 BT 协议、支持 JSON-RPC 和 XML-RPC 接口远程调用）之类下载工具，其中 Aria2 在 Windows 下使用也很广泛。

## 文本处理 {#text-utils}

在进行文本处理时，我们有一些常见的需求：

- 获取文本的行数、字数
- 比较两段文本的不同之处
- 查看文本的开头几行和最后几行
- 在文本中查找字符串
- 在文本中替换字符串

下面介绍如何在 shell 中做到这些事情。

### 文本统计：wc {#wc}

`wc` 是文本统计的常用工具，它可以输出文本的行数、单词数与字符（字节）数。

```console
$ wc file
     427    2768   20131 file
```

!!! warning "统计中文文本时的问题"

    `wc` 在统计中文文本时，会出现一些问题，比如：

    ```console
    $ echo '中文测试' | wc
    1       1      13
    ```

    这里显示文本只有 1 个单词，但是有 13 个字符，这显然是不对的。

    对于字符数统计结果，可以使用 `wc -m` 命令要求 `wc` 考虑宽字符：

    ```console
    $ echo '中文测试' | wc -m
    5
    ```

    换行符也是一个符号，所以结果为 5（而非 4）。

    由于中文文本的单词统计涉及分词算法问题，`wc` 无法准确统计。

### 文本比较：diff {#diff}

diff 工具用于比较两个文件的不同，并列出差异。

```console
$ echo hello > file1
$ echo hallo > file2
$ diff file1 file1
$ diff file1 file2
1c1
< hello
---
> hallo
```

!!! tip "小知识"

    加参数 `-w` 可忽略所有空白字符， `-b` 可忽略空白字符的数量变化。

    假如比较的是两个文本文件，差异之处会被列出；假如比较的是二进制文件，只会指出是否有差异。

### 文本开头与结尾：head & tail {#head-and-tail}

顾名思义，head 和 tail 分别用来显示开头和结尾指定数量的文字。

以 head 为例，这里给出共同的用法：

- 不加参数的时候默认显示前 10 行
- `-n <NUM>` 指定行数，可简化为 `-<NUM>`
- `-c <NUM>` 指定字节数

```console
$ head file  # 显示 file 前 10 行
$ head -n 25 file  # 显示 file 前 25 行
$ head -25 file  # 显示 file 前 25 行
$ head -c 20 file  # 显示 file 前 20 个字符
$ tail -10 file  # 显示 file 最后 10 行
```

除此以外，tail 还有一个非常实用的参数 `-f`：当文件末尾内容增长时，持续输出末尾增加的内容。这个参数常用于动态显示 log 文件的更新（试一试 `tail -f /var/log/syslog`）。

### 文本查找：grep {#grep}

`grep` 命令可以查找文本中的字符串：

```console
$ grep 'hello' file  # 查找文件 file 中包含 hello 的行
$ ls | grep 'file'  # 查找当前目录下文件名包含 file 的文件
$ grep -i 'Systemd' file  # 查找文件 file 中包含 Systemd 的行（忽略大小写）
$ grep -R 'hello' .  # 递归查找当前目录下内容包含 hello 的文件
```

!!! info "不止如此！"

    grep 事实上是非常强大的查找工具，[第九章](../Ch09/index.md)将在介绍正则表达式语法之后进一步介绍 grep。

### 文本替换：sed {#sed}

`sed` 命令可以替换文本中的字符串：

```console
$ sed 's/hello/world/g' file  # 将文件 file 中的 hello 全局（global）替换为 world 后输出
$ sed 's/hello/world/' file  # 将文件 file 的每一行第一个出现的 hello 替换为 world 后输出
$ echo 'helloworld' | sed 's/hello/world/g'  # 管道也是可以的
$ sed -i 's/hello/world/g' file  # -i 参数会直接写入文件，操作前记得备份哦！
$ sed -i.bak 's/hello/world/g' file  # 当然，也可以让 sed 帮你备份到 file.bak
```

对于大多数用户来说，最常用 `sed` 的场合是替换软件源的时候。在阅读了上面的示例之后，以下例子就很简单了：

```console
$ sudo sed -i 's/cn.archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
$ sudo sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
$ sudo sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
```

!!! info "同样不止如此！"

    sed 事实上是非常强大的文本操作工具，不仅支持正则表达式，而且能够做的操作也不止是替换。[第九章](../Ch09/index.md)将进一步介绍 sed。

## Shell 脚本 {#shell-scripts}

### 什么是 Shell {#what-is-shell}

Shell 是 Linux 的命令解释程序，是用户和内核之间的接口。除了作为命令解释程序外，Shell 同时还提供了一个可支持强大脚本语言的程序环境。

### Bash {#bash}

Bourne Shell (`sh`)，是 Unix 系统的默认 Shell，简单轻便，脚本编程功能强，但交互性差。

Bourne Again Shell，即 Bash，是 GNU 开发的一个 Shell，也是大部分 Linux 系统的默认 Shell，是 Bourne Shell 的扩展。

Bash 允许用户定制环境以满足自己需要。通过修改环境文件 `.bash_profile`、`.bashrc`、`.bash_logout`，配置合适的环境变量，可以改变主目录、命令提示符、命令搜索路径等用户工作环境。

此外，bash 也支持使用 `alias` 别名代替命令关键字（`alias name='命令'`）。输入 `alias`，可以查看目前存在的别名：

```console
$ alias
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
$ ll  # 执行 ll 相当于执行 ls -alF
总用量 128
drwxr-xr-x 18 ustc ustc 4096 2月  28 00:51 ./
drwxr-xr-x  3 root root 4096 11月 17 20:26 ../
drwxr-xr-x  2 ustc ustc 4096 11月 17 20:45 公共的/
drwxr-xr-x  2 ustc ustc 4096 11月 17 20:45 模板/
（以下省略）
```

!!! tip "其他 shell 的 alias"

    除了 bash 以外，其他的 shell 也有 alias 的支持。例如在 zsh 中也可以使用 `alias` 命令查看所有的 alias 列表。

    部分 shell 会自带一些 alias，例如 [fish 中的 `ll` 就是 `ls -lh` 的别名](https://github.com/fish-shell/fish-shell/blob/daf96a35b57f52eea19302f615283e7c1486ab8c/share/functions/ll.fish#L5)。特别地，Windows 自带的 PowerShell 中的 alias 存在一些争议，例如其对 `curl` 的 alias 实际上是 `Invoke-WebRequest`，而这个命令和上文介绍的 curl 的行为完全不同，给用户带来了困惑。

!!! tip "检查命令是否被 alias"

    如果发现某些命令的行为不符合预期，可以使用 `type` 命令检查该命令是否被 alias 了：

    ```console
    $ type ls
    ls is aliased to `ls --color=auto'
    ```

### Bash 脚本的运行 {#run-bash-script}

可以使用几种方法运行 Bash 脚本：

- 在指定的 Shell 下执行，将脚本程序名作为 Shell 的第一个参数：

    ```console
    $ bash show.sh [option]
    ```

- 将脚本设置为可执行，然后像外部命令一样执行：

    ```console
    $ chmod a+x show.sh
    $ ./show.sh [option]
    ```

!!! tip "关于 `.` 命令"

    与直接执行脚本，或者指定 shell 执行脚本不同，使用 `.` 命令执行脚本会在当前 shell 中执行脚本，而不是新建一个 shell 去执行脚本。这意味着，脚本中的变量赋值、函数定义以及切换目录（`cd` 命令）等变化都会在当前 shell 中生效。

    在 bash 中，`source` 命令与 `.` 命令等价。有些情况下，使用 `.` 执行脚本是有必要的，例如在激活 Python 的虚拟环境时：

    ```shell
    . venv/bin/activate
    ```

    但是绝大多数时候，如果不清楚 `.` 或 `source` 命令的行为，不建议使用这种方式执行脚本。

许多 Bash 脚本会在文件首行加上 `#!/bin/bash` 。这里 `#!` 符号的名称是 shebang（也叫 sha-bang，即 sharp `#` 与 bang `!`）。当一个文本文件首行有 shebang，且以可执行模式执行时，shebang 后的内容会看作这个脚本的解释器和相关参数，系统会执行解释器命令，并将脚本文件的路径作为参数传递给该命令。

例如，某个 `foo.sh` 首行为 `#!/bin/bash`，则执行 `./foo.sh` 就等于执行 `/bin/bash ./foo.sh`。

??? question "没有 shebang 的脚本呢？"

    你可能会注意到，有些脚本并没有 shebang，但是仍然可以在命令行中正常执行。这是因为尽管 Linux 操作系统无法识别这个脚本的解释器（Linux 要求合法的脚本文件前两个字节必须是 `#!`，否则返回 `ENOEXEC`），应用程序仍然可以自行采用不同的处理方式，例如：

    1. 如果你当前使用的 shell 是 Bash，它会尝试启动一个新的 Bash 进程来执行该脚本。
    2. 对于一些其他应用程序，如果它们使用的是 `execlp`, `execvp` 或 `execvpe` 等 C 语言库函数来运行其他程序的话，含有 `p` 后缀的 exec 系列函数会尝试调用 `/bin/sh` 来执行脚本。
    3. 如果以上情况都不符合，那么程序可能会直接输出错误信息，例如：

        ```text
        ./foo.sh: Exec format error
        ```

Bash 也支持在同一个行中安排多个命令：

| **分隔符**        | **说明**                                                             |
| ----------------- | -------------------------------------------------------------------- |
| `;`               | 按命令出现的先后，顺序执行                                           |
| `&&`              | 先执行前面的命令，若成功，才接着执行后面命令；若失败，不执行后面命令 |
| <code>\|\|</code> | 先执行前面的命令，若成功，不执行后面命令；若失败，才执行后面命令     |
| 后缀 `&`          | 后台方式执行命令                                                     |

组命令：

- 使用 `{ 命令1; 命令2; … }`，组命令在 shell 内执行，不会产生新的进程，注意花括号和命令之间的空格。

- 使用 `(命令1; 命令2; …)`，组命令会建立独立的 shell 子进程来执行组命令，这里的圆括号周围并不需要空格。

??? example "组命令示例"

    ```console
    $ pwd  # 当前在家目录
    /home/ustc
    $ (cd /tmp; pwd;)
    /tmp
    $ pwd  # 仍然在家目录
    /home/ustc
    $ { cd /tmp; pwd; }
    /tmp
    $ pwd  # 移动到了 /tmp 目录
    /tmp
    ```

    执行组命令 `{ cd /tmp; pwd; }` 后，当前目录会被修改，但是执行 `(cd /tmp; pwd;)` 不会修改当前目录。

### shell 变量 {#bash-variables}

像大多数程序设计语言一样，shell 也允许用户在程序中使用变量。但 shell 不支持数据类型，它将任何变量值都当作字符串。但从赋值形式上看，可将 shell 变量分成四种形式：用户自定义、环境变量、位置变量和预定义特殊变量。

#### 用户自定义变量 {#bash-user-variables}

变量定义：`name=串`，其中 `=` 两边不允许有空格。如果字串中含空格，就要用双引号括起。在引用时，使用 `$name` 或 `${name}`，后者花括号是为了帮助解释器识别变量边界。

已定义的变量可以通过 `unset name` 来删除。

!!! example "变量使用示例"

    变量定义：

    ```shell
    for skill in Ada Coffee Action Java; do
        echo "I am good at ${skill}Script"
    done
    ```

    输出：

    ```
    I am good at AdaScript
    I am good at CoffeeScript
    I am good at ActionScript
    I am good at JavaScript
    ```

    如果不给 `skill` 加花括号标明变量名的边界，写成 `echo "I am good at $skillScript"` ，解释器就会把 `$skillScript` 当成一个变量（其值为空）。

    删除变量：

    ```shell
    Today=1024
    unset Today
    echo $Today
    ```

    输出为空。

??? tip "处理未定义的变量"

    在以上的例子中，我们可以注意到 bash 中未定义的变量默认值为空值。在编写 shell 脚本时，我们可能会希望能够严格一些：如果变量未定义，就直接报错退出。这样的话，如果变量名出现了拼写错误，我们就能第一时间发现。

    可以在脚本开头加上 `set -u` 来实现这一点：

    ```shell
    #!/bin/bash

    set -u
    echo $nonexist
    echo "This will never be printed."
    ```

    执行可以发现输出类似如下的错误：

    ```
    example.sh: line 4: nonexist: unbound variable
    ```

#### 环境变量 {#bash-environment-variables}

每个用户登录系统后，Linux 都会为其建立一个默认的工作环境，由一组环境变量定义，用户可以通过修改这些环境变量，来定制自己工作环境。在 Bash 中，可用 `env` 命令列出所有已定义的环境变量。通常，用户最关注的几个变量是：

- `HOME`：用户主目录，一般情况下为 `/home/用户名`。

- `LOGNAME`：登录用户名。

- `PATH`：命令搜索路径，路径以冒号分割。当我们输入命令名时，系统会在 `PATH` 变量中从前往后逐个搜索对应的程序是否在目录中。

- `PWD`：用户当前工作目录路径。

- `SHELL`：默认 shell 的路径名。

- `TERM`：使用的终端名。

可以使用 `export` 命令来定义环境变量。在同一个 shell 中使用 `export` 定义之后，这个环境变量会一直保留，直到这个 shell 退出。

```console
$ export A=1
$ env | grep A=
A=1
```

此外，也可以在命令前加上环境变量的定义。此时只有这一条命令的环境变量出现变化。

```console
$ B=1 env | grep B=
B=1
$ env | grep B=
$ # B=1 的环境变量定义仅对该命令有效
```

#### 位置变量 {#bash-positional-parameters}

- Shell 解释用户的命令时，把命令程序名后面的所有字串作为程序的参数。分别对应 `$1`、`$2`、`$3`、……、`$9`，程序名本身对应 `$0`。

- 可用 `shift <n>` 命令，丢弃开头的 n 个位置变量，改变 `$1`、`$2`、`$3` 等的对应关系。

- 可用 `set` 命令，重置整个位置变量列表，从而给 `$1`、`$2`、`$3` 等赋值。

??? example "范例"

    ```console
    $ set one two three
    $ echo $1,$2,$3
    one,two,three
    $ shift 2
    $ echo $1,$2,$3
    three,,
    $ # 此时 $2 和 $3 已不存在
    ```

#### 特殊变量 {#bash-special-variables}

Shell 中还有一组有 shell 定义和设置的特殊变量，用户只能引用，而不能直接改变或重置这些变量。

| 特殊变量 | 说明                                           |
| -------- | ---------------------------------------------- |
| `$#`     | 命令行上的参数个数，不包括 `$0`                |
| `$?`     | 最后命令的退出代码，0 表示成功，其它值表示失败 |
| `$$`     | 当前进程的 PID                                 |
| `$!`     | 最近一个后台运行进程的进程号                   |
| `$*`     | 命令行所有参数构成的一个字符串                 |
| `$@`     | 用双引号括起的命令行各参数拼接构成的一个字符串 |

#### 特殊字符 {#bash-special-tokens}

- 反斜杠，消除单个字符的特殊含义。
    - 包含空白字符（空格和制表符）、反斜杠本身、各种引号，以及 `$`、`!` 等。
    - 与其他语言不同，shell 中反斜杠不会将普通字符转义为其他含义（例如 `\n` 不会被视作换行符）。

- 使用双引号包裹字符串可以消除空白字符切分参数的特殊含义，但是很多其他特殊字符的特殊含义仍然保留。双引号也被称为「弱引用」。

- 单引号，能消除所有特殊字符的特殊含义，包括反斜杠，因此单引号字符串中不能使用反斜杠转义单引号本身。单引号也被称为「强引用」。

- 反引号（`` ` ``）括起的字符串，被 shell 解释为命令，执行时用命令输出结果代替整个反引号对界限部分。
    - 与反引号相同的语法是 `$(command)`，它的好处是界限更明确，且可以嵌套。因此编写新脚本时，更建议使用此语法。

!!! example "特殊字符示例"

    ```console
    $ ls /mnt/c/Program Files/
    ls: cannot access /mnt/c/Program: No such file or directory
    ls: cannot access Files/: No such file or directory
    $ # 对于 ls 来说，它接收到了两个参数：/mnt/c/Program 和 Files/，因此会报错。
    $ # 可以使用反斜杠来转义空格
    $ ls /mnt/c/Program\ Files/  # 输出省略
    $ # 或者使用双引号或单引号包裹
    $ ls "/mnt/c/Program Files/"
    $ ls '/mnt/c/Program Files/'
    $ echo "$PWD"  # 双引号中仍然可以使用各种 shell 特殊符号
    /home/ustc
    $ echo '$PWD'  # 但是单引号则不行
    $PWD
    $ ls -lh `which ls`  # 查看 ls 命令对应的程序信息，使用反引号语法
    -rwxr-xr-x 1 root root 139K Sep  5  2019 /usr/bin/ls
    $ ls -lh $(which ls) # 使用 $(command) 语法也是一样的
    -rwxr-xr-x 1 root root 139K Sep  5  2019 /usr/bin/ls
    ```

### 变量输入与输出 {#bash-input-output}

#### 输入 {#bash-input}

可以使用 `read` 命令读取用户输入，并将输入的内容赋值给变量。其中 `-p` 参数后可以设置输出的提示信息。

```console
$ name=""
$ read -p "Enter your name: " name  # 输出提示，然后从输入读取一个值，存储到 $name 中
Enter your name: linux
$ echo $name
linux
```

在使用 `read` 时，建议加上 `-r` 参数，否则 `\` 会被视为转义符号。

```console
$ message=""
$ read -p "Enter your message: " message
Enter your message: \(^o^)/~
$ echo $message  # 可以看到，反斜杠被认为是转义符号，结果被丢弃
(^o^)/~
$ read -r -p "Enter your message: " message
Enter your message: \(^o^)/~
$ echo $message  # 加上 -r 参数后，反斜杠完好无损
\(^o^)/~
```

#### 输出 {#bash-output}

可以使用 `echo` 命令输出变量信息。其中 `-n` 参数不会在结尾输出换行符，而 `-e` 参数会解析文本中的转义字符（例如 `\n`）。

```console
$ echo -n "hello"
hello$ # 由于这里 echo 结尾不输出换行，shell 就会在这里继续接受用户输入
$ # 这也是为什么在 C 语言中最后的 printf 输出需要加上 \n 的原因
$ name="linux"
$ echo "Hello $name.\nWelcome to bash!"  # 可以看到 \n 没有被转义成换行
Hello linux.\nWelcome to bash!
$ echo -e "Hello $name.\nWelcome to bash!"  # 加上 -e 之后就被转义了
Hello linux.
Welcome to bash!
```

此外，`printf` 命令也可以用来输出，它的使用方法类似于 C 中的 `printf()` 函数。

```console
$ name="linux"
$ printf "Hello %s" "$name"
Hello linux$ # 和 echo 不同，printf 结尾默认不输出换行符
$ printf "Hello %s\n" "$name"
Hello linux
$ # 所以为了正常显示，需要在结尾补上 \n
```

### 算术运算 {#bash-arithmetic}

在 Bash 中进行算术运算，需要使用 `expr` 计算算术表达式值或 `let` 命令赋值表达式值到变量。基本运算符是 `+`、`-`、`\*` (转义)、`/`、`%`。在 `expr` 中，运算符两边与操作数之间必须有空格，小括号要转义；但 `let` 则没有这个要求，运算符前后有无空格均可，小括号不需转义，但 `=` 前后不能有空格。

另外，所有标准的 shell 都支持另一种语法 `(( 表达式 ))`，其中 `表达式` 是一个 C 风格的数学表达式，可以计算，也可以赋值。`(( 表达式 ))` **是一条完整的命令**，命令的返回值为 0 或 1。若表达式的结果非零，那么 `(( 表达式 ))` 命令返回零，而当表达式结果为零时命令返回 1。

??? example "`(( 表达式 ))` 的返回值"

    ```console
    $ (( 1 + 1 ))
    $ echo $?  # 结果为 2，所以返回值为 0
    0
    $ (( 1 - 1 ))
    $ echo $?  # 返回值为 1，因为结果是 0
    1
    ```

使用 `$(( 表达式 ))` 可以将计算结果用作为命令行的一部分，就像使用变量一样。

??? example "`expr` 和 `let` 使用示例"

    ```console
    $ expr length "ustclug"
    7
    $ let a=0
    $ echo $a
    0
    $ let a++
    $ echo $a
    1
    $ ((a+=1))
    $ echo $a
    2
    $ echo $((a+=a/a))
    3
    ```

### 条件表达式 {#expr}

条件表达式写成 `test 条件表达式`，或 `[ 条件表达式 ]`，注意表达式与方括号之间有空格。

<!-- prettier-ignore-start -->

字符串比较

:   | 表达式                  | 含义                                     |
    | ----------------------- | ---------------------------------------- |
    | `string1 = string2`     | 如果两个串相等，则结果为真（true: 0）    |
    | `string1 != string2`    | 如果两个串不相等，则结果为真             |
    | `string` 或 `-n string` | 如果字符串 string 长度不为 0，则结果为真 |
    | `-z string`             | 如果字符串 string 长度为 0，则结果为真   |

数值比较

:   表达式：`int1 [option] int2`，其中的参数可以用下列替换。

    | 参数  | 说明     |
    | ----- | -------- |
    | `-eq` | 等于     |
    | `-ne` | 不等于   |
    | `-gt` | 大于     |
    | `-ge` | 大于等于 |
    | `-lt` | 小于     |
    | `-le` | 小于等于 |

文件状态

:   | 表达式    | 含义                 |
    | --------- | -------------------- |
    | `-r file` | 文件存在且可读       |
    | `-w file` | 文件存在且可写       |
    | `-x file` | 文件存在且可执行     |
    | `-f file` | 文件存在且为普通文件 |
    | `-d file` | 文件存在且为目录     |
    | `-s file` | 文件存在且长度大于 0 |

复合逻辑表达式

:   | 表达式           | 含义   |
    | ---------------- | ------ |
    | `! expr`         | 否运算 |
    | `expr1 –a expr2` | 与运算 |
    | `expr1 –o expr2` | 或运算 |

<!-- prettier-ignore-end -->

### 流程控制 {#flow-control}

<!-- prettier-ignore-start -->

条件分支：if

:   序列中可嵌套 if 语句，在 shell 中也允许有多个 elif ，但 shell 的流程控制不可为空。末尾的 `fi` 就是 `if` 倒过来写，后面还会遇到类似的结束符。

    ```shell
    if condition1
    then
      commands1
    elif condition2
    then
      commands2
    else
      commands3
    fi
    ```

按值选择：case

:   选项值必须以右括号 `)` 结尾，若匹配多个离散值，用 `|` 分隔。这里的 `esac` 也是 `case` 倒着写。

    ```shell
    case <variable> in
    value1|value2)
      command1
      command2
      ;;
    value3)
      command3
      ;;
    *)
      command4
      ;;
    esac
    ```

枚举循环：for

:   for 循环可以对一个列表中的每个值都执行一系列命令。

    ```shell
    for var in list
    do
      commands $var
    done
    ```

条件循环：while 和 until

:   while 循环用于不断执行一系列命令，命令通常为测试条件。until 与 while 相反，仅在测试条件失败时循环。

    ```shell
    while condition
    do
      commands
    done

    until condition
    do
      commands
    done
    ```

<!-- prettier-ignore-end -->

??? example "流程控制样例"

    ```shell
    #!/bin/bash

    MAX_NO=0
    read -r -p "Enter Number between (5 to 9) : " MAX_NO
    if ! [ "$MAX_NO" -ge 5 -a "$MAX_NO" -le 9 ] ; then
      echo "I ask to enter number between 5 and 9, Okay"
      exit 1
    fi

    clear

    for i in `seq $MAX_NO`
    do
      for s in `seq $MAX_NO -1 $i`
      do
        echo -n " "
      done
      for j in `seq $i`
      do
        echo -n " ."
      done
      echo ""
    done

    for i in `seq $MAX_NO -1 1`
    do
      for s in `seq $i $MAX_NO`
      do
        echo -n " "
      done
      for j in `seq $i`
      do
        echo -n " ."
      done
      echo ""
    done
    ```

    输出结果：

    ```shell
    Enter Number between (5 to 9) : 9

             .
            . .
           . . .
          . . . .
         . . . . .
        . . . . . .
       . . . . . . .
      . . . . . . . .
     . . . . . . . . .
     . . . . . . . . .
      . . . . . . . .
       . . . . . . .
        . . . . . .
         . . . . .
          . . . .
           . . .
            . .
             .
    ```

!!! tip "seq 命令"

    seq 命令用于生成数列，命令格式如下：

    ```shell
    seq [OPTION]... LAST
    seq [OPTION]... FIRST LAST
    seq [OPTION]... FIRST INCREMENT LAST
    ```

    首项 `FIRST` 和公差 `INCREMENT` 默认值为 1。

    例如，执行指令 `seq 10`，将得到如下数列：

    ```
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
    ```

除此之外，用于流程控制的还有在 C 语言中同样常见的 `break` 和 `continue`。与 C 语言不同的是，它们还接受一个数字作为参数，即 `break n` 和 `continue n`，其中参数 `n` 均表示跳出或跳过 n 层循环。

### 函数 {#functions}

与其他编程语言类似，shell 也可以定义函数。其定义格式为：

```shell
# POSIX syntax
name() {
    commands
    [return <int>]
}

# Bash syntax
function name {
    commands
    [return <int>]
}
```

其中函数的参数可以像命令一样通过 `$1`、`$2`、`$3` 等获取，返回值可以显式用 `return` 返回，或以最后一条命令运行结果作为返回值。在函数中使用 `return` 会结束本次函数执行，而使用 `exit` 会直接结束退出包含函数的当前脚本程序。

函数在使用前必须定义，因此应将函数定义放在脚本开始的部分。在调用函数时仅使用其函数名即可。

??? example "范例"

    某带函数的某脚本程序内容如下：

    ```shell
    #!/bin/bash
    hello() {
      echo "hello $1, today's date is `date`"
    }
    echo "going to call test function:"
    hello ustc
    ```

    运行脚本，输出结果：

    ```text
    going to call test function:
    hello ustc, today's date is Tue Feb 22 22:22:22 CST 2022
    ```

### Bash 脚本调试 {#bash-debugging}

Bash shell 本身提供了调试方法：

- 命令行中：`$ bash -x script.sh`。

- 脚本开头：`#!/bin/bash -x`。

- 在脚本中用 set 命令调整（`set -x` 启用，`set +x` 禁用）。

其中参数选项可以更改，`-n`：读一遍脚本中的命令但不执行，用于检查语法错误；`-v`：一边执行脚本、一边将执行过的脚本命令打印到标准输出；`-x`：提供跟踪执行信息，将执行的每一条命令和结果依次打印出来。注意避免几种调试选项混用。

除了 Bash shell 内置的选项，还有 [BASH Debugger](http://bashdb.sourceforge.net/)、[shellcheck](https://github.com/koalaman/shellcheck) 等第三方脚本分析工具。

## 思考题 {#thinking-questions}

!!! question "I/O 重定向的小细节"

    `wc -l file` 和 `wc -l < file` 输出有什么区别？为什么？

    `echo < file` 会输出什么？

!!! question "设定 HTTP 请求头"

    尝试查询 `curl` 和 `wget` 的文档，给出设定 HTTP 请求头的方法。

    附：HTTP 在请求时，会发送诸如以下的信息：

    ```
    GET / HTTP/1.1
    Host: cn.bing.com
    User-Agent: curl/7.54.0
    Accept: */*
    ```

    在 `GET / HTTP/1.1` 下面的几行就是 HTTP 请求头。

    HTTP 请求头在向服务器发送 HTTP 请求时发出，包含了诸如访问服务的域名（Host）、用户程序标识（User-Agent）、希望接收到的语言（Accept-Language）等各种信息。

!!! question "关于断点续传"

    查找资料，了解下载器的「断点续传」功能依赖于什么 HTTP 特性？

!!! question "/usr/bin/env"

    你可能会发现，某些脚本（不仅仅是 shell 脚本）的第一行开头为 `#!/usr/bin/env`。尝试解释原因。

!!! question "Shell 脚本编写练习 #1"

    `ffmpeg` 程序可以提取视频中的音频流，并输出到音频格式文件（如 MP3）。

    现在，你下载了很多视频在目录下（可以假设后缀相同，例如都是 flv）。你需要提取这些视频的音频轨道到 MP3 文件中。尝试搜索 ffmpeg 的使用资料，编写一个 shell 脚本实现。

!!! question "Shell 脚本编写练习 #2"

    现有两个程序 `./a` 和 `./b`，它们分别接受一个数字作为参数。现在需要编写一个脚本，要求：

    - 检查输入的第一个参数 (设为 x) 是否存在。如果不是，输出提示，结束。
    - 先执行 `./a`，以 x 作为第一个参数。如果 `./a` 执行成功，就执行 `./b`，以 **x 的平方**作为第二个参数。

    假设输入 x 是数字且不大。

!!! question "Shell 脚本编写练习 #3 (难)"

    建议阅读[第九章](../Ch09/index.md)后再尝试完成本题。

    尝试编写一个 shell 脚本，下载某个网页上所有的 PDF 文件（例如 [2019年春季全校《电磁学》小论文竞赛获奖名单](http://staff.ustc.edu.cn/~bjye/em/student/2019S/2019S.htm) 这个网页）。已知所有的文件都以小写的 `.pdf` 结尾，并且都在 `a` 标签的 `href` 属性中。

## 引用来源 {#references .no-underline}

- [catonmat](https://catonmat.net/cookbooks)
- [vbird](http://cn.linux.vbird.org)
- [runoob](https://www.runoob.com/linux/linux-shell.html)
- [linuxde](https://man.linuxde.net)
- [Bash Quoting](https://www.gnu.org/software/bash/manual/html_node/Quoting.html)
