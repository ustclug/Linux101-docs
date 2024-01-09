---
icon: material/console
---

# Shell 高级文本处理与正则表达式

!!! Warning "本文已基本完稿，正在审阅和修订中，不是正式版本。"

!!! abstract "导言"

    本章节将介绍一些常用的 shell 文本处理工具，它们可以帮助你更加得心应手地处理大量有规律的文本。

    为保持简洁，各工具的介绍皆点到即止，进一步的用法请自行查找。

## 其他 shell 文本处理工具 {#tools-in-shell}

### sort {#sort}

sort 用于文本的行排序。默认排序方式是升序，按每行的字典序排序。

一些基本用法：

-   `-r` 降序（从大到小）排序
-   `-u` 去除重复行
-   `-o [file]` 指定输出文件
-   `-n` 用于数值排序，否则“15”会排在“2”前

```shell
$ echo -e "snake\nfox\nfish\ncat\nfish\ndog" > animals
$ sort animals
cat
dog
fish
fish
fox
snake
$ sort -r animals
snake
fox
fish
fish
dog
cat
$ sort -u animals
cat
dog
fish
fox
snake
$ sort -u animals -o animals
$ cat animals
cat
dog
fish
fox
snake
$ echo -e "1\n2\n15\n3\n4" > numbers
$ sort numbers
1
15
2
3
4
$ sort -n numbers
1
2
3
4
15
```

!!! tip "小知识"

    为什么有必要存在 `-o` 参数？试试重定向输出到原文件会发生什么吧。

### uniq {#uniq}

uniq 也可以用来排除重复的行，但是仅对连续的重复行生效。

通常会和 sort 一起使用：

```shell
$ sort animals | uniq
```

只是去重排序明明可以用 `sort -u` ，uniq 工具是否多余了呢？实际上 uniq 还有其他用途。

`uniq -d` 可以用于仅输出重复行：

```shell
$ sort animals | uniq -d
```

`uniq -c` 可以用于统计各行重复次数：

```shell
$ sort animals | uniq -c
```

## 正则表达式 {#regular-expression}

正则表达式（regular expression）描述了一种字符串匹配的模式，可以用来检查一个串是否含有某种子串、将匹配的子串做替换或者从某个串中取出符合某个条件的子串等。

此处仅简单介绍正则表达式的一些用法，对正则表达式有更多兴趣，请移步[拓展阅读](./supplement.md)。

### 特殊字符 {#special-char}

| 特殊字符        | 描述                                                                                                       |
| --------------- | ---------------------------------------------------------------------------------------------------------- |
| `[]`            | 方括号表达式，表示匹配的字符集合，例如 `[0-9]`、`[abcde]`                                                  |
| `()`            | 标记子表达式起止位置                                                                                       |
| `*`             | 匹配前面的子表达式零或多次                                                                                 |
| `+`             | 匹配前面的子表达式一或多次                                                                                 |
| `?`             | 匹配前面的子表达式零或一次                                                                                 |
| `\`             | 转义字符，除了常用转义外，还有：`\b` 匹配单词边界；`\B` 匹配非单词边界等                                   |
| `.`             | 匹配除 `\n`（换行）外的任意单个字符                                                                        |
| `{}`            | 标记限定符表达式的起止。例如 `{n}` 表示匹配前一子表达式 n 次；`{n,}` 匹配至少 n 次；`{n,m}` 匹配 n 至 m 次 |
| <code>\|</code> | 表明前后两项二选一                                                                                         |
| `$`             | 匹配字符串的结尾                                                                                           |
| `^`             | 匹配字符串的开头，在方括号表达式中表示不接受该方括号表达式中的字符集合                                     |

以上特殊字符，若是想要匹配特殊字符本身，需要在之前加上转义字符 `\`。

### 简单示例 {#re-example}

匹配正整数：

```
[1-9][0-9]*
```

匹配仅由 26 个英文字母组成的字符串：

```
^[A-Za-z]+$
```

匹配 Chapter 1-99 或 Section 1-99

```
^(Chapter|Section) [1-9][0-9]{0,1}$
```

匹配“ter”结尾的单词：

```
ter\b
```

### 基本/扩展正则表达式 {#bre-ere}

基本正则表达式（Basic Regular Expressions, BRE）和扩展正则表达式（Extended Regular Expressions, ERE）是两种 POSIX 正则表达式风格。

BRE 可能是如今最老的正则风格了，对于部分特殊字符（如 `+`, `?`, `|`, `{`）需要加上转义符 `\` 才能表达其特殊含义。

ERE 与如今的现代正则风格较为一致，相比 BRE，上述特殊字符默认发挥特殊作用，加上 `\` 之后表达普通含义。

具体的例子在下文介绍工具时可以看到。

!!! tip "帮助理解正则表达式的工具"

    [Regex101](https://regex101.com/) 网站集成了常见编程语言正则表达式的解析工具，在编写正则时可以作为一个不错的参考。

## 常用 Shell 文本处理工具（正则） {#tools-with-re}

### grep {#grep}

grep 全称 Global Regular Expression Print，是一个强大的文本搜索工具，可以在一个或多个文件中搜索指定 pattern 并显示相关行。

grep 默认使用 BRE，要使用 ERE 可以使用 `grep -E` 或 egrep。

命令格式：`grep [option] pattern file`

一些用法：

-   `-n`：显示匹配到内容的行号
-   `-v`：显示不被匹配到的行
-   `-i`：忽略字符大小写

```shell
$ ls /bin | grep -n "^man$"  # 搜索内容仅含 man 的行，并且显示行号
$ ls /bin | grep -v "[a-z]\|[0-9]"  # 搜索不含小写字母和数字的行
$ ls /bin | grep -iv "[A-Z]\|[0-9]"  # 搜索不含字母和数字的行
```

### sed {#sed}

sed 全称 Stream EDitor，即流编辑器，可以方便地对文件的内容进行逐行处理。

sed 默认使用 BRE，要使用 ERE 可以 sed -E。

命令格式：

```shell
$ sed [OPTIONS] 'command' file(s)
$ sed [OPTIONS] -f scriptfile file(s)
```

此处的 command 和 scriptfile 中的命令均指的是 sed 命令。

常见 sed 命令：

-   s 替换
-   d 删除
-   c 选定行改成新文本
-   a 当前行下插入文本
-   i 当前行上插入文本

```shell
$ echo -e "seD\nIS\ngOod" > sed_demo
$ cat sed_demo
seD
IS
gOod
$ sed "2d" sed_demo  # 删除第二行
seD
gOod
$ sed "s/[a-z]/~/g" sed_demo  # 替换所有小写字母为 ~
~~D
IS
~O~~
$ sed "3cpErfeCt" sed_demo  # 选定第三行，改成 pErfeCt
seD
IS
pErfeCt
```

### awk {#awk}

awk 是一种用于处理文本的编程语言工具，名字来源于三个作者的首字母。相比 sed，awk 可以在逐行处理的基础上，针对列进行处理。默认的列分隔符号是空格，其他分隔符可以自行指定。

awk 使用 ERE。

命令格式：`awk [options] 'pattern {action}' [file]`

awk 逐行处理文本，对符合的 patthern 执行 action。需要注意的是，awk 使用单引号时可以直接用 `$`，使用双引号则要用 `\$`。

一些示例：

```shell
$ cat awk_demo
Beth    4.00    0
Dan     3.75    0
kathy   4.00    10
Mark    5.00    20
Mary    5.50    22
Susie   4.25    18
$ # 选择第三列值大于 0 的行，对每一行输出第一列的值和第二第三列的乘积
$ awk '$3 >0 { print $1, $2 * $3 }' awk_demo
kathy 40
Mark 100
Mary 121
Susie 76.5
```

示例中 `$1`，`$2`，`$3` 分别指代本行的第 1、2、3 列。特别地，$0 指代本行。

awk 语言是「图灵完全」的，这意味着理论上它可以做到和其他语言一样的事情。这里我们不仅可以对每行进行操作，还可以定义变量，将前面处理的状态保存下来，以下是一个求和的例子：

```shell
$ awk 'BEGIN { sum = 0 } { sum += $2 * $3 } END { print sum }' awk_demo
337.5
```

关于 awk，有一本知名的书籍《The AWK Programming Language》（[中文翻译](https://github.com/wuzhouhui/awk)），感兴趣的读者可以考虑阅读。

## 思考题 {#questions}

!!! question "正则表达式引擎"

    什么是 DFA/NFA 正则表达式引擎？如今常见编程语言里的正则表达式实现和此处的 BRE/ERE 有什么异同？

!!! question "正则表达式练习 1：邮件标题匹配"

    最近你收到了很多垃圾邮件，而且垃圾邮件检测似乎没有生效。你发现这些垃圾邮件的标题似乎都满足一个正则表达式。这些垃圾邮件的标题类似如下：

    - `162935832----系统通知`
    - `166819038----系统警告`

    请写出能够匹配类似标题的正则表达式。

    此外，作为一个负责任的系统管理员，你订阅了 Debian Security 邮件列表（订阅后能够收到 Debian 安全更新的通知和说明邮件）。但是你发现，你的邮件系统真是成事不足败事有余，似乎喜欢把这些邮件放进垃圾邮件箱，要是漏掉了什么重要的安全更新就麻烦了！Debian Security 发送的邮件标题类似如下：

    - `[SECURITY] [DSA 5075-1] minetest security update`
    - `[SECURITY] [DSA 5059-1] policykit-1 security update`
    - `[SECURITY] [DSA 5086-1] thunderbird security update`

    同样，请写出能够匹配类似标题的正则表达式。

!!! question "正则表达式练习 2：弹幕过滤"

    某弹幕视频网站支持使用正则表达式过滤不想看到的弹幕。某日忍无可忍之下，你希望编写一条正则表达式过滤掉类似如下的弹幕（其中全角省略号为任意文本）：

    - `当年我就是听的这首歌才……`
    - `我就是听的这首歌帮……`
    - `当年爷……时就是听的这首歌`
    - `当年那天晚上要不是放这首歌我就被……`

    可以接受少许的误过滤（false positive）。

!!! question "正则表达式练习 3：Vscode 中的文本批量替换"

    Vscode 支持使用正则表达式语法查找与替换文本内容。有一天，你的项目中使用的某个函数更新了：调用方式从 `func1(a, b, c)` 变成了 `func1_new(c, b, a, null)`。其中假设 `a`、`b`、`c` 均为不含逗号的表达式。

    尝试写出搜索的正则表达式与替换目标表达式。提示：正则表达式中使用 `()` 包裹的为一组，在 vscode 的替换目标表达式中可以使用 `$1`、`$2` 的格式来引用第一组、第二组等内容。

!!! question "Shell 文本处理工具练习 1：文件内容替换"

    某 shell 脚本会随着图形界面启动而启动，启动后会根据环境变量替换某程序配置文件的内容。该配置文件内容如下：

    ```ini
    [settings]
    homepage=http://example.com/
    location-entry-search=http://cn.bing.com/search?q=%s
    ```

    我们希望编写一条或多条 sed 命令，使得脚本运行后配置文件被修改为：

    ```ini
    [settings]
    homepage=http://example.com/index_new.html
    location-entry-search=http://www.wolframalpha.com/input/?i=%s
    ```

    假设配置文件路径存储在变量 `$F` 中。请注意：图形界面可能会重置，此时脚本会对已经修改的配置文件再次修改，如果编写不小心，可能会得到错误的结果。

!!! question "Shell 文本处理工具练习 2：Nginx 日志分析"

    你的网站最近收到了一大批不正常的请求大量消耗服务器带宽，你希望通过 shell 文本处理工具确认攻击者的来源 IP。Nginx 访问日志的格式类似于如下：

    ```
    123.45.67.89 - - [01/Mar/2022:00:58:17 +0800] "GET /downloads/nonexist HTTP/1.1" 404 190 "-" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2226.0 Safari/537.36"
    ```

    其中我们主要关注 IP（第一列）和下载大小（第 10 列，例子中为 190）。请给出使用 `awk`、`sort` 等工具输出下载量最大的前 50 个 IP 的命令。

!!! question "Shell 文本处理工具练习 3：文件列表解析"

    Ports 是 BSD 系列操作系统管理编译软件的方式。下面我们将介绍 FreeBSD 操作系统中的 ports 目录结构。

    Ports 目录的第一层为不同软件的分类（诸如音频程序、数据库程序会分别放置在 audio 和 databases 目录下），第二层则为各个软件的目录。在绝大多数软件的目录下都有 `distinfo` 文件，用于描述其依赖的源代码包文件的名称、大小和 SHA256 校验值信息。

    例如，`gcc10` 软件包的 `distinfo` 位于 `lang/gcc10/distinfo`，内容类似如下：

    ```
    TIMESTAMP = 1619249722
    SHA256 (gcc-10.3.0.tar.xz) = 64f404c1a650f27fc33da242e1f2df54952e3963a49e06e73f6940f3223ac344
    SIZE (gcc-10.3.0.tar.xz) = 76692288
    ```

    你的任务是：搜索 ports 中的所有 distinfo，提取所有文件名和 SHA256，按照文件名以字典序排序并输出，每行格式要求如下：

    ```
    64f404c1a650f27fc33da242e1f2df54952e3963a49e06e73f6940f3223ac344 gcc-10.3.0.tar.xz
    ```

    现实中的 ports 文件可以从 <https://mirrors.ustc.edu.cn/freebsd-ports/ports.tar.gz> 下载解压得到。

    注意：少量 `distinfo` 文件的 SHA256 对应行最后会有多余的空格或制表符，需要妥善处理。
