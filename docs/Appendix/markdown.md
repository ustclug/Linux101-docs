# Markdown 使用教程

Markdown 是一种轻量级的标记语言，可用于在纯文本文档中添加格式化元素。Markdown 由 John Gruber 于 2004 年创建，如今已成为世界上最受欢迎的标记语言之一。Linux 101 也是基于 Markdown 编写的。

???+ question "为什么推荐使用 Markdown？"

    当你可以通过按下界面中的按钮来设置文本格式时，为什么还要使用 Markdown 来书写呢？使用 Markdown 而不是 Word 类编辑器的原因有：

    - **Markdown 无处不在。** Stack Overflow、CSDN、掘金、简书、GitBook、有道云笔记、V2EX、光谷社区等。主流的代码托管平台，如 GitHub、GitLab、BitBucket、Coding、Gitee 等等，都支持 Markdown 语法，很多开源项目的 README、开发文档、帮助文档、Wiki 等都用 Markdown 写作。

    - **Markdown 是纯文本可移植的。** 几乎可以使用任何应用程序打开包含 Markdown 格式的文本文件。如果你不喜欢当前使用的 Markdown 应用程序了，则可以将 Markdown 文件导入另一个 Markdown 应用程序中。这与 Microsoft Word 等文字处理应用程序形成了鲜明的对比，Microsoft Word 将你的内容锁定在专有文件格式中。

    - **Markdown 是独立于平台的。** 你可以在运行任何操作系统的任何设备上创建 Markdown 格式的文本。

    - **Markdown 能适应未来的变化。** 即使你正在使用的应用程序将来会在某个时候不能使用了，你仍然可以使用文本编辑器读取 Markdown 格式的文本。当涉及需要无限期保存的书籍、大学论文和其他里程碑式的文件时，这是一个重要的考虑因素。

使用 Markdown 与使用 Word 类编辑器不同。在 Word 之类的应用程序中，我们通过单击按钮以设置文本的格式，并且更改的效果立即可见。而 Markdown 与此不同，当你在编写 Markdown 格式的文件时，需要在文本中添加 Markdown 语法，以指示哪些单词和短语看起来应该有所不同。

例如，要表示标题，只须在短语前面添加一个井号 `#` 即可；或者要加粗一个短语，只须在短语前后各加两个星号 `*` 即可（例如，**this text is bold**）。你可能需要一段时间才能习惯 Markdown 语法，尤其是如果已经习惯了所见即所得的文本编辑程序。

接下来，我们将简单介绍 Markdown 中的部分语法知识。

## Markdown 常用语法

### 标题

Markdown 通过在行首插入 1 到 6 个 `#` 实现标题效果，分别对应 1 到 6 级标题。

!!! example "Markdown 的标题"

    ```markdown
    # this is H1
    ## this is H2
    ###### this is H6
    ```

    <h1>this is H1</h1>
    <h2>this is H2</h2>
    <h6>this is H6</h6>

### 段落

Markdown 使用空白行将一行或多行文本进行分隔，从而实现段落的效果。

!!! example "Markdown 的段落"

    ```markdown
    中国科学技术大学是中国科学院所属的一所以前沿科学和高新技术为主，兼有医学、特色管理和人文学科的理工科大学。

    学校现有 31 个学院（学部），含 8 个科教融合学院；设有苏州高等研究院、上海研究院、北京研究院、先进技术研究院、
    国际金融研究院、附属第一医院（安徽省立医院）。
    ```

    中国科学技术大学是中国科学院所属的一所以前沿科学和高新技术为主，兼有医学、特色管理和人文学科的理工科大学。

    学校现有 31 个学院（学部），含 8 个科教融合学院；设有苏州高等研究院、上海研究院、北京研究院、先进技术研究院、国际金融研究院、附属第一医院（安徽省立医院）。

注意：请**不要**用空格（spaces）或制表符（tabs）缩进段落。

### 字体

Markdown 使用星号 `*` 和下划线 `_` 作为标记强调字词的符号，你可以随意选择喜欢的样式，但用什么符号开启标签，就要用什么符号结束。

!!! example "Markdown 的字体"

    **这是加粗**（`**这是加粗**`）

    __这也是加粗__（`__这也是加粗__`）

    *这是倾斜*（`*这是倾斜*`）

    _这也是倾斜_（`_这也是倾斜_`）

    ***这是加粗倾斜***（`***这是加粗倾斜***`）

    ~~这是加删除线~~（`~~这是加删除线~~`）

注意：强调也可以直接插在文字中间，但是如果你的 \* 和 \_ 两边都有空白的话，它们就只会被当成普通的符号。如果要在文字前后直接插入普通的星号或底线，你可以用反斜线 `\`。例如：USTC_VLAB（`USTC\_VLAB`）

### 列表

Markdown 支持有序列表和无序列表。无序列表使用星号 `*`、加号 `+` 或是减号 `-` 作为列表标记，符号与内容之间需要存在一个空格。

!!! example "Markdown 无序列表"

    ```markdown
    - 列表内容
    + 列表内容
    * 列表内容
    ```

    - 列表内容
    + 列表内容
    * 列表内容

有序列表则使用数字接着一个英文句点作为标记，序号跟内容之间要有空格。

!!! tip "例子：Markdown 有序列表"

    ```markdown
    1. 列表内容
    2. 列表内容
    3. 列表内容
    ```

    1. 列表内容
    2. 列表内容
    3. 列表内容

列表可以嵌套，只需要加上正确的缩进即可。

!!! example "Markdown 列表嵌套"

    ```markdown
    1. First item
    2. Second item
    3. Third item
        - Indented item
        - Indented item
    4. Fourth item
    ```

    1. First item
    2. Second item
    3. Third item
        - Indented item
        - Indented item
    4. Fourth item

### 引用

Markdown 通过在引用的文字前加 `>` 实现引用。引用的区块内也可以使用其他的 Markdown 语法，包括标题、列表、代码区块等。

!!! example "Markdown 的引用"

    ```markdown
    > - Revenue was off the chart.
    > - Profits were higher than ever.
    >
    > *Everything* is going according to **plan**.
    ```

    > - Revenue was off the chart.
    > - Profits were higher than ever.
    >
    > *Everything* is going according to **plan**.

### 代码

在 Markdown 中加入代码块有两种方式：

1. 缩进 4 个空格或是 1 个制表符；
2. **推荐**：使用三个反引号 ` ``` ` 包裹起来，且两边的反引号单独占一行。

!!! example "Markdown 代码块"

    ````markdown
    这是一个普通段落

    ```
    这是一个代码块。
    ```
    ````

    这是一个普通段落

    ```
    这是一个代码块
    ```

除了代码块，Markdown 还支持使用一个反引号 `` ` `` 包裹的句内代码。例如：`int i`（`` `int i` ``）。

### 图片

Markdown 使用一种和链接很相似的语法来标记图片，看起来像是：

```markdown
![Alt pic](/path/to/img.jpg)

![Alt pic](/path/to/img.jpg "Optional title")
```

???+ info "图片的路径问题"

    如何选择图片的路径呢？如果使用本地路径插入本地图片，这样就不灵活不好分享，本地图片的路径更改或丢失都会造成 md 文档无法找到图片；如果插入网络图片，则非常依赖网络，本地图片还需要先上传到服务器上再插入。

    目前常见的解决方法是：将本地图片上传到 GitHub，或者在当前文档同目录或仓库根目录下新建 src 或 figs 文件夹，将需要引用的图片上传至其中，在文档中使用相对路径引用即可。例如，下面这张图片就位于 `/Ch01/images` 目录下。

    ![Image title](../Ch01/images/LUG@USTC-Logo.png){ width="300" }

受篇幅所限，我们仅介绍 Markdown 的一些常用语法，想要了解更多语法知识的同学可以自行查找有关资料。

## Markdown 编辑器

我们推荐使用 [Typora](https://typoraio.cn/) 进行 Markdown 的编写，也可以使用 VSCode 配置 Markdown 插件进行编写。下面是一些推荐的 VSCode 插件：

- [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)（`yzhang.markdown-all-in-one`）
- [Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced)（`shd101wyy.markdown-preview-enhanced`）
- [Markdown Preview GitHub Styling](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-preview-github-styles)（`bierner.markdown-preview-github-styles`）

你可以根据需要进行安装。

## 参考资料

- [Markdown 官方教程](https://markdown.com.cn/)
- [知乎：使用 vscode 开始 Markdown 写作之旅](https://zhuanlan.zhihu.com/p/56943330/)
- [USTC OSH-2023 课程主页](https://osh-2023.github.io/lab0/markdown/)
