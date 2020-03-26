# 拓展阅读

!!! failure "本文目前尚未完稿，存在诸多未尽章节且未经审阅，不是正式版本。"

## Android/Linux {#android-linux}

## 关闭 SELinux {#close-seLinux}

读者在使用 Fedora、CentOS、Scientific Linux、RHEL 等系统时，可能会遇到这样的错误：

* SELinux is preventing XXXX from read access on the file YYYY.

这是因为有一个叫做 SELinux 的安全增强组件阻止了一些有潜在风险的操作。

SELinux 的全称是 Security-Enhanced Linux，起初是为了弥补 Linux 下没有强制访问控制（Mandatory Access Control, MAC）的缺憾，但是 SELinux 的设置相当繁复，由于默认设置不可能尽善尽美，一些配置上的小问题可能会影响用户的正常使用，而初学者没有足够的技能去调试 SELinux 策略。因此在初学时，可以暂且关闭 SELinux，在掌握足够的技能后再启用它。

??? tip "AppArmor"

    在 Debian、Ubuntu 系发行版中，默认使用的是称作 AppArmor 的同类组件。与 SELinux 相比，AppArmor 更简单一些，且一般不会对用户的正常使用造成困扰。

SELinux 有 3 种工作模式：

1. `enforcing`：SELinux 根据安全策略，积极阻止有潜在风险的操作。
2. `permissive`：SELinux 仅记录会被阻止的操作在日志中，但不做任何事。
3. `disabled`：SELinux 被彻底禁用，日志也不记录。

因此，只需将 SELinux 置于 `permissive` 或 `disabled` 状态即可。

使用 `sestatus` 命令查看 SELinux 状态：

```
$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      31
```

使用 `setenforce 0` **临时** 改变 SELinux 状态到 `permissive`，这个状态在重启后将恢复为配置文件指定的默认值。

```
# setenforce 0
```

修改 SELinux 的配置文件可以永久改变 SELinux 的工作状态。

1. 使用 root 权限编辑 `/etc/selinux/config` 文件；
2. 将 `SELINUX=enforcing` 中的 `enforcing` 改为 `disabled` 或 `permissive`。

编辑完成后，使用 `sestatus` 可以看到修改效果：

```
[...]
Current mode:                   permissive  # <-
Mode from config file:          permissive  # <- 或 disabled
[...]
```

## 适用于 Linux 的 Windows 子系统 {#wsl}
