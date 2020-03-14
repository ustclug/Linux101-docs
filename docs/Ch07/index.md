# 七：Linux 上的编程

!!! failure "本文主体内容已完成，但尚有几个补充小知识未完成，整体上应不影响阅读。"

!!! abstract "导言"

    作为一个成熟而实用的系统，在 Linux 上如何进行日常的编程开发呢？
    这一章将解答一下几个问题：

    - Linux 上的 C/C++ 开发
    - Linux 上的 Python 开发
    - Linux 上编程语言开发的范式与共性

## C 语言开发

C 语言是大学编程语言教学中几乎必定讲解的一门编程语言。
在 Linux 上，C 语言拥有着近乎系统级的支持。
在 Linux 上开发 C 语言（以及 C++）是一件非常简单的事。

### 从单文件开始

让我们从单个文件的 C 语言代码开始。

使用任意一个文本编辑器，利用前面讲过的知识，新建一个文件。
我们假设这个文件叫 main.c。
为这个文件填上以下内容：

```c
// main.c
#include <stdio.h>

int main() {
  printf("Hello World!\n");
  return 0;
}
```

这是一个简单的 Hello World 程序。
让我们从它开始。

我们使用系统自带的 C 编译器：gcc，对这个文件进行编译，生成二进制文件：

```console
$ ls
main.c
$ gcc main.c -o main
$ ls
main.c main
$ ./main
Hello World!
```

让我们分析一下上面几个指令：

`gcc` 是 gcc 这个编译器对应的指令，一般位于 /usr/bin/gcc，是一个 C 编译器。

后面的 `main.c` 是源文件名。

`-o` 是一个选项（option），紧随 `-o` 指定了输出的二进制文件的文件名 `main`。

我们应当注意到，`gcc main.c -o main` 这条指令没有打印出任何内容。
这是因为整个编译过程是成功的，gcc 没有需要报告的内容，因此保持沉默。

运行生成的 `main` 后，我们成功地看到了 "Hello World!"。

### 多文件的状况

只在一个文件中填写代码对于开发而言是不够的：
个人维护一个小项目时尚且可行，但当你面临的是一个多人开发、模块复杂、功能繁多的大项目时
（无论是在公司工程中还是在实验室科研里，这都是普遍的情况），
拆分代码到多个文件才是一个明智的决定。

!!! info "C 语言的多文件实现"

    我们假设你对于 C 语言的多文件实现有着基本的认知：
    即能够在之前的系统（Windows 或 Mac OS，或其他，如果你是的话）中的 IDE 内完成 C 语言的多文件开发。

    如果你不会，别急，这里将做一个简单的介绍：

    假设你拥有一下两个文件：

    ```c
    // main.c
    int main() {
      print();
      return 0;
    }
    ```

    ```c
    // print.c
    #include <stdio.h>

    void print() {
      printf("Hello World!\n");
    }
    ```

    那为了在 main.c 中引用 `void print()` 这个函数，你需要做以下几件事：

    - 在当前目录下新建一个头文件 print.h；
    - 在 print.h 中填入以下内容：

    ```c
    // print.h
    #ifndef PRINT
    #define PRINT

    void print();

    #endif  // PRINT
    ```

    这里的 `#ifndef ... #define ... #endif` 是头文件保护，防止同一头文件被 `#include` 两次造成重复声明的错误，
    如果你不理解这部分也没关系，只需保证 `void print();` 这一行声明存在即可。

    - 在 main.c 和 print.c 中同时 `#include "print.h"`。

    这样，程序就可以被成功编译了。
    具体的操作过程将在下方的正文中讲解。

我们首先创建以下三个文件：

```c
// main.c
int main() {
  print();
  return 0;
}
```

```c
// print.c
#include <stdio.h>

void print() {
  printf("Hello World!\n");
}
```

```c
// print.h
#ifndef PRINT
#define PRINT

void print();

#endif  // PRINT
```

怎么编译它们呢？
我们将介绍以下几种方法：

#### gcc 所有文件

gcc 可以自动进行简单的分析完成编译。
你可以使用以下的指令：

```console
$ ls
main.c print.c print.h
$ gcc main.c print.c -o main
$ ls
main.c print.c print.h main
$ ./main
Hello World!
```

同样让我们分析以下指令：

`gcc main.c print.c -o main` 中没用包含 print.h 这个头文件。
gcc 可以根据 `#include` 和系统中的一些环境变量找到这个文件。
当然，加上 print.h，变成 `gcc main.c print.c print.h -o main` 也是可以的，并不会有错误出现。

#### gcc 一步步编译，最后统一链接

首先让我们看一下指令：

```console
$ ls
main.c print.c print.h
$ gcc main.c -c
$ ls
main.c print.c print.h main.o
$ gcc print.c -c
$ ls
main.c print.c print.h main.o print.o
$ ld main.o print.o -o main
$ ls
main.c print.c print.h main.o print.o main
$ ./main
Hello World!
```

这里我们使用了 `gcc -c`。
`-c` 将会把源文件编译为对象文件（object file， .o 这个后缀就来源于 object 的首字母）。
对象文件是二进制文件，不过它不可执行，因为对应到其中一些需要引用外部代码的地方，是用占位数替代的，无法实现函数调用。

注意到我们在 `gcc -c` 中没有添加 `-o` 选项，因为 `-c` 存在时 gcc 总会生成相同文件名（这里特指 basename，main.c 的 main 部分）的、
后缀名为 .o 的对象文件。

生成了对象文件之后，我们使用了 `ld` 来生成二进制目标文件。
这是在完成链接过程，使得对象文件中的机器指令调用能够成功调用。
在这里，你可以把 `ld` 替换为 `gcc`，`gcc` 这一指令会根据输入的文件调用相应的程序（如 ld）完成整个编译流程。
即 `gcc main.o print.o -o main` 也是可行的。

!!! info "gcc 的四个部分，编译的过程"
    <!--TODO-->

#### 构建工具（build tool）：Makefile

另一个选择是使用构建工具 Makefile。让我们继续之前的例子：

在同一目录下创建一个名为 `Makefile` 的文件，其内容为：

```make
main.o: main.c print.h
print.o: print.c print.h
main: main.o print.o
```

然后在当前目录下执行：

```console
$ ls
main.c print.c print.h Makefile
$ make main
$ ls
main.c print.c print.h Makefile main
$ ./main
Hello World!
```

为了解释这一过程，我们先来看看 Makefile 的内容：

其中

```make
main.o: main.c print.h
```

这一行，通过冒号分割，指定了一个名为 `main.o` 的目标，其依赖为 `main.c` 和 `print.h`。
由于整个文件中没有名为 `main.c` 的目标，所以 Makefile 会认为对应的 `main.c` 文件为一个依赖，`print.h` 同理。

在指定了目标和依赖后，紧接着的下一行如果用 **Tab** 缩进，则可以指定利用依赖获得目标的指令。
例如：

```make
main.o: main.c print.h
    gcc main.c -c  # 一定要用 Tab 缩进而不是 4 个 / 2 个空格——这是历史遗留问题。
```

则如果要获得 `main.o` 这个目标，则会执行 `gcc main.c -c` 这个指令。
如果没有指定命令，Makefile 会尝试从文件后缀之类的地方获取信息，推测你需要的指令。
例如此处即使不显式写出指令，Makefile 也知道用 gcc 来完成编译。

最终我们在 shell 中执行 `make main`，正是指定了一个最终目标。
如果不提供这个目标，Makefile 则会选择 Makefile 文件中第一目标。
为了获得最终目标，Makefile 会递归地获取依赖、执行指令。

最终，我们能够获得需要的 main 二进制程序。

Makefile 最大的亮点在于，引入了文件间的依赖关系。
在使用它进行构建（build，生成目标程序的过程）时，Makefile 可以根据文件间的依赖关系和文件更新时间，找出需要重新编译的文件。
这在项目较大时能够节省构建所需的时间，同时也能够解决一些由于编译链接顺序造成的问题。
相较与输入一大串指令，单个的 `make [target]` 甚至是仅仅 `make`，也更加优雅和方便。

!!! info "复杂的、可拓展的 Makefile"
    <!--TODO-->

#### 其他的构建工具：CMake，ninja……

一个大的工程可能有上十万行代码，上万文件，如果一一写进 Makefile，那会非常痛苦，且几乎不可能维护。

为了更好的构建程序，大家想出了“套娃”的办法：用一个程序来生成构建所需的配置，CMake 在这一想法下诞生了。

CMake 在默认情况下，可以通过 `cmake` 指令生成 Makefile，再进一步进行 `make`。

对于 CMake 的使用讲解已经超出了本课程的讲解范围。
而且 CMake 作为一个足够成熟、也足够年长的工具，也有历史遗留问题和新时代下的新思路。
正如 C++ 和 Mordern C++，CMake 也有 Mordern CMake，更有像微软的 vcpkg 这样的新的辅助工具和解决方案。
如果你想了解 CMake 的一些知识，可以考虑看一些较新的、关于 Mordern CMake 的博客，以及官方的最新文档。

另一个需要提一下的是 ninja。ninja 和 Makefile、autoconf 较类似，是构建工具，所属抽象层次低于 CMake。

ninja 的特点的是相较与 Makefile 更快，对于多线程编译的支持更好。
详细信息可以到 ninja 的官方网站查看。

### 关于 C++

C++ 的工具链与 C 的是相似的。实际上，只需将上面内容中的 `gcc` 指令改为 `g++`，你就能同样的完成 C++ 的开发。

实际上 gcc 这个软件包，本身就包括了 C、C++、Objective C 等语言的各种开发工具。

## Python 语言开发

Python 作为一门年长但恰逢新春的解释型语言，也被业界广泛使用。
相较于 Windows，在 Linux 上开发 Python 或许会更加简单。

### 解释器 python

Python，或者说一般的 Python（CPython）程序的运行，依靠的是 Python 解释器（interpreter）。
在 Python 解释器中，Python 代码首先被处理成一种字节码（bytecode，与 JVM 运行的字节码不是一个东西，但有相似之处），
然后再交由 PVM（Python virtual machine）进行执行，从而实现跨平台和动态等特性。

### 包管理器 pip

!!! info "模块，包"
    <!--TODO-->

为使用外部的第三方包，Python 提供了一个包管理器：pip。

pip 和 apt 之类的包管理器有相似之处：完成包的安装和管理，完成依赖的分析，等等。
不过 pip 管理的是 Python 包，可以在 Python 代码中使用这些包。让我们看下面的例子：

```console
# 安装 Python 3 和 pip。对于 Python 2 和 3 间的纠纠缠缠，我们将在之后讲解。
$ sudo apt install python3 python3-pip

# 测试一下看看，是否能够正常使用它们。
# 请保证在 `python` 和 `pip` 后有 3 这个数字。这也是历史遗留问题。
$ python3 -V
$ pip3 -V

# 暂时忽略以下两条指令，我们会在之后讲解。
$ python3 -m venv venv
$ source venv/bin/activate
(venv)$ ls
venv

# 安装一个 Python 包 a、b，以及 a、b 依赖的 Python 包。
(venv)$ pip3 install a b

# 卸载一个 Python 包 b。注意：这不会删除之前一起安装的 b 的依赖。
(venv)$ pip3 uninstall b
```

安装了 a 之后，我们就能在代码中使用 a 这个包了。

```python3
# main.py
import a

print(a)
```

```console
(venv)$ python3 main.py
<module 'a' from '...'>
```

这样，我们就完成了对外部 Python 包的安装和引用。

### 依赖管理

一个软件一般含有众多依赖，尤其是对于追求易用、外部库众多的 Python 而言，使用外部库作为依赖是常事。

此处我们将尝试给出各种使用较多的 Python 依赖管理方案。

#### requirements.txt

在一些项目下，你可能会发现一个名为 `requirement.txt` 的文件，里面是一行行的 Python 包名和一些对于软件版本的限制，例如：

```txt
# requirements.txt
django
pytest>=3.0.0
pytest-cov==1.0.0
```

为了安装这些 Python 包，使用以下指令：

```console
$ pip3 install -r requirements.txt
```

这将从 `requirements.txt` 文件中逐行读取包名和版本限制，并由 pip 完成安装。

这种方案特点是简单明了，但对于依赖的处理能力不足。

#### setuptools

在 PyPI，即 pip 获取 Python 包的来源中，更多的选择是使用 setuptools。
setuptools 不是 Python 官方的项目，但它已成为 Python 打包（packaging）的事实标准。

常见的状况是目录下会有一个名为 `setup.py` 的文件。
要安装依赖，只需：

```console
$ ls
setup.py
$ pip3 install .
```

这种方案特点是使用广泛，能提供的信息和配置较全，但配置起来也较复杂。

#### 其他的：pip-tools、pipenv……

<!--conda-->

pip-tools 是对于 requirements.txt 方案的增强。
它额外提供了 `requirements.dev` 文件，从而完成了对于依赖版本锁定的支持。

pipenv 则是一个更加全面的解决方案，它提供了类似于 npm 的配置文件和 lock 文件，对于依赖有非常强的管理功能。
但其完成度和工业中的稳定性尚有待证明。

Python 有非常多的依赖管理方案，某种意义上讲是自带的 pip 管理功能不足所造成的。
一般而言，只需熟悉常用的 requirements.txt 和 setuptools 方案即可。

### Virtualenv

让我们考虑以下情况：

Python 通过 pip 安装的包，默认安装在系统目录 `/usr/lib/python[version]` 下，
当传入了一个 `--user` 选项时，则会安装在用户目录 `~/.local/lib/python[version]` 下。
当普通地运行 Python 解释器时，这两个目录下的包均可见。

现在假设用户目录下已有一个包 `a`，版本为 `1.0.0`。
现在我们需要开发一个程序，也需要包 `a`，但要求版本大于 `2.0.0`。

由于 pip 不允许安装不同版本的同一个包，当你运行 `pip3 install a>=2.0.0` 时，pip 会更新 `a` 到 `2.0.0`，
那原先依赖于 `a==1.0.0` 的软件就无法正常运行了。

为了解决这一问题，允许不同软件使用不同版本的包，Python 提供了 Virtualenv 这个工具。
其使用方法如下：

一般 Virtualenv 会带在默认安装的 Python 中。
如果没有，可以用 `sudo apt install python3-venv` 来安装。

常见的做法是使用 Python 的模块运行来完成在 shell 中的执行：

```console
$ python3 -m venv venv
```

以上指令中，`-m` 表示运行一个指定的模块，前一个 `venv` 指运行 venv 这个包的主模块 `__main__`，
后一个 `venv` 是参数，为生成目录的路径。
这将使 venv 在当前目录下生成一个名为 `venv` 的目录。

在一般的 shell 环境下，我们将使用 `source venv/bin/activate` 来启用这个 venv。

完成以上操作后，你就进入了当前目录下 venv 文件夹对应的 Virtualenv。此时，你安装的 Python 包将会被安装在 venv 这个文件夹中，
这些包也只有在你 `source venv/bin/activate` 之后才可见，外部无法找到这些包。通过 `deactivate` 可以退出 Virtualenv，
回到之前的环境中。

这样，就实现了程序间依赖的隔离。

### Python 的版本

正如我们之前所讲，Python 不是一个新的编程语言。
现在的 Python，最新的版本已到 3.8。
实际上还在使用中的 Python，主要在 2.17、3.5——3.8 这个区间内。

Python 2 到 3 某种程度上讲不是变革，实际上 Python 2 和 3 基本可以看作两个不同的编程语言。
在这个升级中，一方面众多底层语法都发生了改变，使得从 2 到 3 的迁移相当麻烦。
另一方面，由于 Python 2 的盛行，程序 `python` 普遍指向 `python2`。
因此当 Python 3 出现时，为了有效区分两者，调用解释器时我们需要用 `python3` 这一指令。
尽管在某些平台（例如 Arch 系 Linux）上，`python` 己经指向 `python3`，
但考虑到 Ubuntu、CentOS、Debian 等发行版上 `python` 仍指向 `python2`，
显式地指定一个版本是更明智的选择。

实际上，Python 2 已在 2020 年初正式宣告停止维护。
现在如果我们要使用 Python，最好使用 3 版本者。

而在 3 版本中，3.5 将在今年年底 EOL（end of life），因此实际上选用 Python 3.6 及以上者更佳。

### Python 的其他实现

Python 作为一门编程语言，官方的实现是 CPython，我们一般使用的、成为事实标准的就是这个。
CPython 中的 C 是指此解释器底层是用 C 实现。

相应的，Python 还有其他的一些实现：

- JPython：将 Python 编译到 JVM 字节码，由 JVM 来运行；
- pypy：相较于 CPython，实现了 JIT（just in time），性能极大地提升；
- Cython：引入了额外的语法和严密的类型系统，性能也有很大提升；
- Numba：将 Python 编译到机器码，从而直接运行，性能也不错。

视情况使用不同的 Python 实现能够很大程度地提升性能。
但如果你不确定自己的意向，且性能需求不大，使用官方的 CPython 是明智之选。

## 总结与拓展

在 Linux 下，大多编程语言都会提供适合命令行的、足够方便的运行方案，
往往也带有配套的工具如编译器、调试器、代码格式化工具等。
善于运用这些工具，能够极大地提升你的开发效率，支持你完成自己的项目。

在附加内容中，我们将再收集一些编程语言的开发方案，并给出简述，以作参考。
