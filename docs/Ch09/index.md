# Shell 文本处理工具与正则表达式

!!! Warning "本文已基本完稿，正在审阅和修订中，不是正式版本。"

!!! abstract "导言"

    本章节将介绍一些常用的 shell 文本处理工具，它们可以帮助你更加得心应手地处理大量有规律的文本。

    为保持简介，各工具的介绍皆点到即止，进一步的用法请自行查找。

## 常用 shell 文字处理工具 {#tools-in-shell}

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
sort animals | uniq
```

只是去重排序明明可以用 `sort -u` ，uniq 工具是否多余了呢？实际上 uniq 还有其他用途。

`uniq -d` 可以用于仅输出重复行：

```shell
sort animals | uniq -d
```

`uniq -c` 可以用于统计各行重复次数：

```shell
sort animals | uniq -c
```

## 正则表达式 {#regular-expression}

正则表达式（regular expression）描述了一种字符串匹配的模式，可以用来检查一个串是否含有某种子串、将匹配的子串做替换或者从某个串中取出符合某个条件的子串等。

此处仅简单介绍正则表达式的一些用法，对正则表达式有更多兴趣，请移步补充内容。

### 特殊字符 {#special-char}

| 特殊字符 | 描述                                                                                                       |
| -------- | ---------------------------------------------------------------------------------------------------------- |
| \[\]     | 方括号表达式，表示匹配的字符集合，例如 \[0-9\],\[abcde\]                                                   |
| ()       | 标记子表达式起止位置                                                                                       |
| \*       | 匹配前面的子表达式零或多次                                                                                 |
| +        | 匹配前面的子表达式一或多次                                                                                 |
| ?        | 匹配前面的子表达式零或一次                                                                                 |
| \\       | 转义字符，除了常用转义外，还有："\b"匹配单词边界"；\B"匹配非单词边界等                                     |
| .        | 匹配除“\n"外的任意单个字符                                                                                 |
| \{\}     | 标记限定符表达式的起止。例如 \{n\} 表示匹配前一子表达式 n 次；\{n,\} 匹配至少 n 次；\{n,m\} 匹配 n 至 m 次 |
| \|       | 表明前后两项二选一                                                                                         |
| $        | 匹配字符串的结尾                                                                                           |
| ^        | 匹配字符串的开头，在方括号表达式中表示不接受该方括号表达式中的字符集合                                     |

以上特殊字符，若是想要匹配特殊字符本身，需要在之前加上转义字符“\”

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

基本正则表达式（Basic Regular Expressions）和扩展正则表达式（Extended Regular Expressions）是两种 POSIX 正则表达式风格。

BRE 可能是如今最老的正则风格了，对于部分特殊字符（如 `+`, `?`, `|`, `{`）需要加上转义符 `\` 才能表达其特殊含义。

ERE 与如今的现代正则风格较为一致，相比 BRE，上述特殊字符默认发挥特殊作用，加上 `\` 之后表达普通含义。

具体的例子在下文介绍工具时可以看到。

!!! question "思考题"

    什么是 DFA/NFA 正则表达式引擎？如今常见编程语言里的正则表达式实现和此处的 BRE/ERE 有什么异同？

## 常用 Shell 文字处理工具（正则） {#tools-with-re}

### grep {#grep}

grep 全称 Global Regular Expression Print，是一个强大的文本搜索工具，可以在一个或多个文件中搜索指定 pattern 并显示相关行。

grep 默认使用 BRE，要使用 ERE 可以 grep -E 或 egrep。

命令格式：`grep [option] pattern file`

一些用法：

-   -n 显示匹配到内容的行号
-   -v 显示不被匹配到的行
-   -i 忽略字符大小写

```shell
ls /bin | grep -n "^man$"
ls /bin | grep -v "[a-z]\|[0-9]"
ls /bin | grep -iv "[A-Z]\|[0-9]"
```

### sed {#sed}

sed 全称 Stream EDitor，即流编辑器，可以方便地对文件的内容进行逐行处理。

sed 默认使用 BRE，要使用 ERE 可以 sed -E。

命令格式：

```shell
sed [options] 'command' file(s)
sed [options] -f scriptfile file(s)
```

此处的“commond”和“scriptfile”中的命令均指的是 sed 命令。

常见 sed 命令：

-   s 替换
-   d 删除
-   c 选定行改成新文本
-   a 当前行下插入文本
-   i 当前行上插入文本

```shell
echo -e "seD\nIS\ngOod" > sed_demo
sed "2d" sed_demo
sed "2d" sed_demo
sed "s/[a-z]/~/g" sed_demo
sed "3cpErfeCt" sed_demo
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
$ awk '$3 >0 { print $1, $2 * $3 }' awk_demo
kathy 40
Mark 100
Mary 121
Susie 76.5
```

示例中 `$1`，`$2`，`$3` 分别指代本行的第 1，2，3，列。特别地，$0 指代本行。

!!! question "思考题"

    如何使用 `sed` 对示例中文本的第二列数值求和？
