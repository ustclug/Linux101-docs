# 思考题解答 {#solution}

## 阻止 ping 命令的输出 {#stop-ping-output}

!!! tip "提示"

    nohup 命令是如何操作的？

??? info "解答"

    当然是 IO 重定向。比如，如果我们希望稍后查看输出，可以重定向到一个文件；如果单纯不想查看输出，可以重定向到空文件 `/dev/null`（会在第五章介绍）以舍弃输出。

## 按下 Ctrl + C 后发生了什么 {#after-hitting-ctrl-c}

!!! tip "提示"

    这个问题涉及了键盘按键的处理与信号机制。（答案仅供参考）

??? info "解答"

    当我们在某个终端按下键盘上的 `Ctrl + C`，键盘发生按下 Ctrl——按下字母 C——字母 C 按键抬起——Ctrl 键抬起四个过程，将四个过程对应的扫描码送到键盘控制器。

    键盘控制器向 CPU 发出中断表示键盘有输入需要处理，CPU 调用对应的处理程序（一般是终端驱动）将扫描码翻译为键盘码，对应的字符如果允许，会回显到标准输出（显示器）。

    如果是普通字符，则字符存放到对应终端的缓冲区等待读取。

    如果像 `Ctrl + C` 这种特殊字符被检测到，则该处理程序向该终端上的 shell 进程发送 SIGINT，shell 再向其前台进程转发 SIGINT，进程接到该信号，执行对应的信号处理例程。一般情况下，程序将正常退出。

    我们可以使用 `stty -a` 命令列出终端驱动所识别的一些具有特殊含义的字符。注意该命令必须于真正的终端（使用 `Ctrl + Alt + Fn` 切换得到的终端）才可以使用。

## 查看系统中出现错误的服务 {#failed-services}

!!! tip "提示"

    `systemctl list-units` 可以查看系统中所有服务单元。

??? info "解答"

    使用 `systemctl list-units --state=failed` 来筛选即可，以下是一个例子：

    ```shell
    $ systemctl list-units --state=failed
    UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
    ● anacron.service        loaded failed failed Run anacron jobs
    ● binfmt-support.service loaded failed failed Enable support for additional executable binary formats
    ● rtkit-daemon.service   loaded failed failed RealtimeKit Scheduling Policy Service

    LOAD   = Reflects whether the unit definition was properly loaded.
    ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
    SUB    = The low-level unit activation state, values depend on unit type.

    3 loaded units listed.
    ```

    当系统中出现这一类服务时，`systemctl status` 也会显示系统的状态是 degraded（降级）。
