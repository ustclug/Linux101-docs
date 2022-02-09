# man 文档的一些示例

作为手册而非教程，man 文档面面俱到，非常详细。当然，详细的后果，就是我们在阅读的时候很容易变得一头雾水。

必须承认的是，尽管 man 文档有一些有中文翻译（部分软件包的手册自带翻译，另一些上游不提供手册页翻译的则在 [manpages-zh 项目](https://github.com/man-pages-zh/manpages-zh)中翻译。对于后者，安装 `manpages-zh` 软件包即可），但是阅读它们，仍然是一件非常痛苦的事情。况且中文翻译有一些也已经十分老旧（例如，`execve()` 文档的最新翻译仍然在 2003 年 5 月），且可能有一些错误。所以建议有能力的同学尽可能阅读英文版本的 man 文档。

!!! info "我希望改进开源软件与文档的中文翻译！"

    2020 年初编写此文时，举的翻译错误的例子是：

    > （例如，`man(1)` 的文档中介绍 `-a|-b` 的含义的时候，将 "cannot be used together" 翻译为了「可以一起使用」）

    在 2022 年初修订时这个错误仍然存在，在向上游反馈后这个翻译问题[很快被修复](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1005139)，并且相关修复有希望进入到 Ubuntu 22.04 LTS 中。因此，向上游反馈翻译问题是解决这类翻译错误最有效的途径。

    对于大部分项目来说，你都能找到对应翻译项目的位置。例如，`manpages-zh` 的每篇翻译手册最后就有：

    ```
    跋
       本页面中文版由中文 man 手册页计划提供。
       中文 man 手册页计划：https://github.com/man-pages-zh/manpages-zh
    ```

    有时候翻译的来源不太容易找到，此时可以去上游项目确认其翻译的流程，或者去一些流行的托管开源项目翻译的平台寻找，例如：

    - [Translation Project](https://translationproject.org/team/zh_CN.html)，托管了一些常见软件的翻译。上文提到的 `man(1)` 的翻译就在这里（`man-db`）；
    - [Transifex](https://www.transifex.com/)，例如 [Xfce 桌面环境的翻译](https://www.transifex.com/xfce/public/)即托管在其上；
    - [Hosted Weblate](https://hosted.weblate.org/)
    - [Launchpad](https://translations.launchpad.net/)
    - [Crowdin](https://crowdin.com/)

    此外，一些大型项目会选择自己托管翻译平台：

    - [Fedora Weblate](https://translate.fedoraproject.org/)
    - [GNOME l10n](https://l10n.gnome.org/teams/zh_CN/)
    - [KDE Localization](https://l10n.kde.org/team-infos.php?teamcode=zh_CN)

    如果对翻译（本地化）有进一步兴趣，可以阅读 [AOSC 版大陆简中自由软件本地化工作指南](https://repo.aosc.io/aosc-l10n/zh_CN_l10n.pdf)了解更多技术信息。

下面会给出一些 man 文档以及其内容结构的解释，以帮助你更好地理解，man 文档到底在做什么长篇大论。

## 数字的含义 {#man-sections}

在查阅资料时，你常常会见到如 `chmod(1)` 或 `mount(8)` 这样的表达方式。正如上面所述，数字表示这个条目所属的章节。

但是为什么要加数字呢？这是因为不同的章节可能有相同的条目，例如 `chmod` 既是一条命令，又是一个系统调用。当你要查看 `chmod` 命令的 man 文档时，你会去看 `chmod(1)`；而当你要查看 `chmod` 系统调用的 man 文档时，你会去看 `chmod(2)`。这时候条目后面数字的作用就体现出来了，你可以放心的说 _chmod(1) 内部使用了 chmod(2)_ 这样的话而不必担心造成困惑。

## 命令行工具：以 `su` 为例

```
SU(1)                            User Commands                           SU(1)
（第一行的标题是 User Commands，两边的 SU(1) 代表这篇文档是关于 `su` 的，在文档第一卷。
第一卷与 Shell 命令和程序有关。更多信息可以查看 man man 中 DESCRIPTION 一节的内容。）

NAME（名字，包含了我们的主角的名字 `su`，和它的简要介绍。）
       su - run a command with substitute user and group ID

SYNOPSIS（概要，包含了命令参数的结构。）
       su [options] [-] [user [argument...]]
       （可能你会对这样的内容感到迷惑。但在概要中显示的内容格式有一个固定的格式模版。例如，
       [-ab] 代表参数是可选的，而 -a|-b 代表这两个参数是互斥的。同样可以查看 man man
       的介绍。）

DESCRIPTION（介绍，大致描述了它能够做什么事情）
       su allows to run commands with a substitute user and group ID.

       When  called  without  arguments, su defaults to running an interactive
       shell as root.

       For backward compatibility, su defaults to not change the  current  di‐
       rectory  and to only set the environment variables HOME and SHELL (plus
       USER and LOGNAME if the target user is not root).  It is recommended to
       always use the --login option (instead of its shortcut -) to avoid side
       effects caused by mixing environments.

       This version of su uses PAM for  authentication,  account  and  session
       management.   Some  configuration options found in other su implementa‐
       tions, such as support for a wheel group, have  to  be  configured  via
       PAM.

       su  is mostly designed for unprivileged users, the recommended solution
       for privileged users (e.g. scripts executed by root) is to use non-set-
       user-ID  command  runuser(1)  that  does not require authentication and
       provide separate PAM configuration. If the PAM session is not  required
       at all then the recommend solution is to use command setpriv(1).
       （看完这段话之后，你可能会感到非常非常迷惑：PAM 是什么？最后一段到底在说啥？这种感觉是
       很正常的。从文档的立场来讲，它不得不面面俱到，描述所有可能的情况，而有些情况你根本不会遇
       到。
       不过，就算我们忽略一些问题（先不管 PAM 是啥），我们仍然可以了解到很多信息，比如说：
       - 推荐使用 `su -` 而不是 `su`，这可以防止（当前用户和切换目标用户不同的）环境混起来
       带来问题。
       - `root` 用户更推荐使用 `runuser` 代替 `su`，因为不需要认证为其他用户，且在 PAM
       方面更好。）

OPTIONS（选项，包含了所有参数的语法和介绍）
       -c, --command=command
              Pass command to the shell with the -c option.

       -f, --fast
              Pass  -f to the shell, which may or may not be useful, depending
              on the shell.

       -g, --group=group
              Specify the primary group.  This option is available to the root
              user only.

       -G, --supp-group=group
              Specify  a  supplemental group.  This option is available to the
              root user only.  The first specified supplementary group is also
              used as a primary group if the option --group is unspecified.

       -, -l, --login
              Start  the shell as a login shell with an environment similar to
              a real login:

                 o      clears all the environment variables except  TERM  and
                        variables specified by --whitelist-environment

                 o      initializes  the  environment  variables  HOME, SHELL,
                        USER, LOGNAME, and PATH

                 o      changes to the target user's home directory

                 o      sets argv[0] of the shell to '-' in order to make  the
                        shell a login shell

       -m, -p, --preserve-environment
              Preserve  the  entire  environment,  i.e.  it does not set HOME,
              SHELL, USER nor LOGNAME.  This option is ignored if  the  option
              --login is specified.

       -P, --pty
              Create pseudo-terminal for the session. The independent terminal
              provides better security as user does not  share  terminal  with
              the  original session.  This allow to avoid TIOCSTI ioctl termi‐
              nal injection and another security attacks against terminal file
              descriptors.  The  all session is also possible to move to back‐
              ground (e.g. "su --pty - username -c  application  &").  If  the
              pseudo-terminal  is enabled then su command works as a proxy be‐
              tween the sessions (copy stdin and stdout).

              This feature is EXPERIMENTAL for now and may be removed  in  the
              next releases.

       -s, --shell=shell
              Run  the  specified  shell instead of the default.  The shell to
              run is selected according to the following rules, in order:

                 o      the shell specified with --shell

                 o      the shell specified in the environment variable SHELL,
                        if the --preserve-environment option is used

                 o      the  shell  listed  in  the passwd entry of the target
                        user

                 o      /bin/sh

              If the target user has a restricted shell (i.e.  not  listed  in
              /etc/shells), the --shell option and the SHELL environment vari‐
              ables are ignored unless the calling user is root.

       --session-command=command
              Same as -c but do not create a new session.  (Discouraged.)

       -w, --whitelist-environment=list
              Don't reset environment variables specified in  comma  separated
              list  when  clears environment for --login. The whitelist is ig‐
              nored for the environment variables HOME, SHELL, USER,  LOGNAME,
              and PATH.

       -V, --version
              Display version information and exit.

       -h, --help
              Display help text and exit.
       （这里按照字典序介绍了所有的参数。对于想要详尽了解命令使用的人来说没有什么问题，而对于想
       要快速找到自己想要的参数的人来说，阅读这样的文档确实会让人一头雾水。
       你可以按下 /，然后输入搜索关键词快速搜索，按 n 查看下一个搜索项，按 N 查看上一个搜索项。
       至于专有名词，你可能不得不去了解它们的含义。查看相关的文档，或者在互联网上搜索。）

SIGNALS（信号，信号的含义详见进程一章）
       Upon  receiving  either  SIGINT,  SIGQUIT or SIGTERM, su terminates its
       child and afterwards terminates itself with the received  signal.   The
       child  is  terminated by SIGTERM, after unsuccessful attempt and 2 sec‐
       onds of delay the child is killed by SIGKILL.
       （你会注意到，不是所有程序手册都有这一节。不同的程序，文档的结构可能不一样。）

CONFIG FILES（配置文件）
       su reads the /etc/default/su and /etc/login.defs  configuration  files.
       The following configuration items are relevant for su(1):

       FAIL_DELAY (number)
           Delay  in  seconds in case of an authentication failure. The number
           must be a non-negative integer.

       ENV_PATH (string)
           Defines the PATH environment variable for a regular user.  The  de‐
           fault value is /usr/local/bin:/bin:/usr/bin.

       ENV_ROOTPATH (string)
       ENV_SUPATH (string)
           Defines  the PATH environment variable for root.  The default value
           is /usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin.

       ALWAYS_SET_PATH (boolean)
           If set to yes and --login and --preserve-environment were not spec‐
           ified su initializes PATH.

       The  environment  variable  PATH may be different on systems where /bin
       and /sbin are merged into /usr.

EXIT STATUS（退出状态）
       su normally returns the exit status of the command it executed.  If the
       command  was  killed  by  a signal, su returns the number of the signal
       plus 128.

       Exit status generated by su itself:

                 1      Generic error before executing the requested command

                 126    The requested command could not be executed

                 127    The requested command was not found
       （退出状态是什么？还记得你写 C 程序时在 `main()` 里面最后的 `return 0;` 吗？0 就是
       你的程序的退出状态。一般来说，0 代表程序运行成功，而非 0 值代表程序没有完成它预期的功能，
       或者用户输入了错误的选项。
       你可以输入 `echo $?` 查看上一条命令的退出状态。）

FILES（相关文件）
       /etc/pam.d/su    default PAM configuration file
       /etc/pam.d/su-l  PAM configuration file if --login is specified
       /etc/default/su  command specific logindef config file
       /etc/login.defs  global logindef config file

NOTES（附录）
       For security reasons su always logs failed log-in attempts to the  btmp
       file,  but it does not write to the lastlog file at all.  This solution
       allows to control su behavior by PAM configuration.  If you want to use
       the pam_lastlog module to print warning message about failed log-in at‐
       tempts then the pam_lastlog has to be configured to update the  lastlog
       file as well. For example by:

              session  required  pam_lastlog.so nowtmp

SEE ALSO（另寻，包含了一些相关的命令。可以用 `man 号码 名称` 的格式查看这些命令的文档。）
       setpriv(1), login.defs(5), shells(5), pam(8), runuser(8)

HISTORY（历史记录）
       This  su  command was derived from coreutils' su, which was based on an
       implementation by David MacKenzie. The util-linux has  been  refactored
       by Karel Zak.

AVAILABILITY（「可用性」，即，我可以在哪里获得这个程序？）
       The  su command is part of the util-linux package and is available from
       Linux  Kernel   Archive   ⟨https://www.kernel.org/pub/linux/utils/util-
       linux/⟩.

util-linux                         July 2014                             SU(1)
```

## 程序库函数：以 `strcmp()` 为例

文档第三卷是程序库函数的信息，包括了 C 语言的标准库函数。

```
STRCMP(3)                  Linux Programmer's Manual                 STRCMP(3)

NAME
       strcmp, strncmp - compare two strings

SYNOPSIS（概要，这里包含了你需要 include 的头文件，以及相关函数的声明。）
       #include <string.h>

       int strcmp(const char *s1, const char *s2);

       int strncmp(const char *s1, const char *s2, size_t n);
       （这里也会有需要的编译和链接参数，当然对 `strcmp()` 来说是不需要这些的。）

DESCRIPTION
       The  strcmp()  function compares the two strings s1 and s2.  It returns
       an integer less than, equal to, or greater than zero if  s1  is  found,
       respectively, to be less than, to match, or be greater than s2.

       The  strncmp()  function  is similar, except it compares only the first
       (at most) n bytes of s1 and s2.

RETURN VALUE（返回值，有些函数会包含返回后参数的情况）
       The strcmp() and strncmp() functions return an integer less than, equal
       to, or greater than zero if s1 (or the first n bytes thereof) is found,
       respectively, to be less than, to match, or be greater than s2.

ATTRIBUTES（属性）
       For an  explanation  of  the  terms  used  in  this  section,  see  at‐
       tributes(7).

       ┌────────────────────┬───────────────┬─────────┐
       │Interface           │ Attribute     │ Value   │
       ├────────────────────┼───────────────┼─────────┤
       │strcmp(), strncmp() │ Thread safety │ MT-Safe │
       └────────────────────┴───────────────┴─────────┘
       （从 man 7 attributes 中，可以得到此章会使用的专有名词的解释。这里我们可以看到，
       `strcmp()` 系列函数是线程安全的。）
CONFORMING TO（符合的标准，可以看到熟悉的 POSIX 和 C89、C99 标准）
       POSIX.1-2001, POSIX.1-2008, C89, C99, SVr4, 4.3BSD.

SEE ALSO（另寻，表明这些库函数也和 `strcmp()` 相关）
       bcmp(3),   memcmp(3),   strcasecmp(3),   strcoll(3),  string(3),  strn‐
       casecmp(3), strverscmp(3), wcscmp(3), wcsncmp(3)

COLOPHON（作者信息、文档来源等信息）
       This page is part of release 4.16 of the Linux  man-pages  project.   A
       description  of  the project, information about reporting bugs, and the
       latest    version    of    this    page,    can     be     found     at
       https://www.kernel.org/doc/man-pages/.

                                  2015-08-08                         STRCMP(3)
```

## 系统调用：以 `kill()` 为例

文档第二卷是关于系统调用的信息。当然，很多系统调用都由 C 运行时库包装了一层，否则用起来很麻烦。一个目前还没有被包装的系统调用的例子是 `copy_file_range()`，你需要在你的代码里面使用 `syscall()` 去手动包装它，才能方便地使用。

```
KILL(2)                    Linux Programmer's Manual                   KILL(2)

NAME
       kill - send signal to a process

SYNOPSIS
       #include <sys/types.h>
       #include <signal.h>

       int kill(pid_t pid, int sig);

   Feature Test Macro Requirements for glibc (see feature_test_macros(7)):

       kill(): _POSIX_C_SOURCE
       （这里的话，出现了 "Macro Requirements"，表明 kill() 函数需要在 include 文件之前
       作宏定义 _POSIX_C_SOURCE 来正常使用。当然，很多 Macro 都是默认包含的，可以在
       feature_test_macros 文档中的 Default definitions, implicit definitions,
       and combining definitions 一小节中找到）

DESCRIPTION
       The  kill()  system  call can be used to send any signal to any process
       group or process.

       If pid is positive, then signal sig is sent to the process with the  ID
       specified by pid.

       If pid equals 0, then sig is sent to every process in the process group
       of the calling process.

       If pid equals -1, then sig is sent to every process for which the call‐
       ing  process  has  permission  to  send  signals,  except for process 1
       (init), but see below.

       If pid is less than -1, then sig  is  sent  to  every  process  in  the
       process group whose ID is -pid.

       If  sig  is  0,  then  no  signal is sent, but existence and permission
       checks are still performed; this can be used to check for the existence
       of  a  process  ID  or process group ID that the caller is permitted to
       signal.

       For a process to have permission to send a signal, it  must  either  be
       privileged (under Linux: have the CAP_KILL capability in the user name‐
       space of the target process), or the real or effective user ID  of  the
       sending  process must equal the real or saved set-user-ID of the target
       process.  In the case of SIGCONT, it suffices when the sending and  re‐
       ceiving processes belong to the same session.  (Historically, the rules
       were different; see NOTES.)

RETURN VALUE
       On success (at least one signal was sent), zero is returned.  On error,
       -1 is returned, and errno is set appropriately.
       （一般来说，系统调用出错时，会返回非 0 值，且设置全局的 errno 值。
       不同的 errno 值对应了不同的错误，可以查看 errno 的文档。）

ERRORS（错误解释）
       EINVAL An invalid signal was specified.

       EPERM  The  process  does not have permission to send the signal to any
              of the target processes.

       ESRCH  The process or process group does not exist.  Note that  an  ex‐
              isting  process might be a zombie, a process that has terminated
              execution, but has not yet been wait(2)ed for.
       （这些大写字符串代表了 errno 中不同的错误值。可以使用 `perror()` 输出系统的报错信息。）

CONFORMING TO（符合的标准，可以看到这里没有 C89 这类值了，因为 `kill()` 不是标准 C 库函数。）
       POSIX.1-2001, POSIX.1-2008, SVr4, 4.3BSD.

NOTES
       The only signals that can be sent to process ID 1,  the  init  process,
       are  those  for  which  init  has explicitly installed signal handlers.
       This is done to assure the system is not brought down accidentally.

       POSIX.1 requires that kill(-1,sig) send sig to all processes  that  the
       calling process may send signals to, except possibly for some implemen‐
       tation-defined system processes.  Linux allows a process to signal  it‐
       self,  but  on  Linux the call kill(-1,sig) does not signal the calling
       process.

       POSIX.1 requires that if a process sends a signal to  itself,  and  the
       sending  thread  does  not have the signal blocked, and no other thread
       has it unblocked or is waiting for it in sigwait(3), at least  one  un‐
       blocked  signal  must  be  delivered  to  the sending thread before the
       kill() returns.

   Linux notes
       Across different kernel versions, Linux has  enforced  different  rules
       for the permissions required for an unprivileged process to send a sig‐
       nal to another process.  In kernels 1.0 to 1.2.2,  a  signal  could  be
       sent  if  the effective user ID of the sender matched effective user ID
       of the target, or the real user ID of the sender matched the real  user
       ID  of  the  target.  From kernel 1.2.3 until 1.3.77, a signal could be
       sent if the effective user ID of the sender matched either the real  or
       effective  user  ID of the target.  The current rules, which conform to
       POSIX.1, were adopted in kernel 1.3.78.
       （很多系统调用都是 POSIX 标准，但是在 Linux 上可能会有一些地方不太一样。）

BUGS（问题，你需要绕开这些坑）
       In 2.6 kernels up to and including 2.6.7, there was a  bug  that  meant
       that  when  sending  signals to a process group, kill() failed with the
       error EPERM if the caller did not have permission to send the signal to
       any  (rather  than  all) of the members of the process group.  Notwith‐
       standing this error return, the signal was still delivered  to  all  of
       the processes for which the caller had permission to signal.

SEE ALSO
       kill(1),    _exit(2),    signal(2),   tkill(2),   exit(3),   killpg(3),
       sigqueue(3), capabilities(7), credentials(7), signal(7)

COLOPHON
       This page is part of release 4.16 of the Linux  man-pages  project.   A
       description  of  the project, information about reporting bugs, and the
       latest    version    of    this    page,    can     be     found     at
       https://www.kernel.org/doc/man-pages/.

Linux                             2017-09-15                           KILL(2)
```
