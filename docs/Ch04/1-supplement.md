**_以下内容为编者认为有参考价值应当提及的内容。为了不破坏章节主旨的连续性与阅读体验连续性，特置于此。_**

##Linux下进程查看的其他方式

##systemd VS init

二位作用都是用户进程的祖宗，负责维系用户

```html


##补充链接（linux相关的一些细节）

- 内核文件为什么以**vmlinuz-版本号**命名？
    
    <p style="font-size: smaller">简言之，vm是virtual memory，z代表内核被gzip压过，详细情况见<a href="http://www.linfo.org/vmlinuz.html">www
.linfo.org/vmlinuz
.html↗</a>，中文 <a href="https://www.cnblogs.com/beanmoon/archive/2012/10/23/2735886.html">www.cnblogs.com/beanmoon/archive
    /2012/10/23/2735886.html↗</a></p>

- 我们一般使用的命令都十分简洁，那么它们都是哪些单词的缩写呢？
    
    <p style="font-size: smaller">许多情况下，不接触命令所对应的全称是无法记住命令的，然而从英文解释中我们可以自然地知道命令采用哪几个字母作为缩写，从而由名称得知命令用法。here is <a href="https://fossbytes.com/a-z</p>
-list-linux-command-line-reference/">The Ultimate A To Z List of Linux Commands | Linux Command Line Reference<a/></p>

- Linux中有一个虚拟用户rtkit，运行rtkit-daemon（未证明普适性），不要以为是rootkit哦。