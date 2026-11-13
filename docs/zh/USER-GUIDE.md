<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   User guide.

   Copyright (C) 2026  VD171
   SPDX-License-Identifier: Apache-2.0

   Licensed under the Apache License, Version 2.0; you may obtain a copy at
   http://www.apache.org/licenses/LICENSE-2.0

   Site           : https://vd171.ru
   Site           : https://vd.priv8.ru
   Source         : https://github.com/VD171/VD-dropbear
   GitHub         : @VD171 https://github.com/VD171
   XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · 中文

---

# 用户指南

VD Dropbear 为你已 root 的设备提供一个私有的 SSH 服务器。本指南带你从安装走到一个可用的连接，包括文件传输和
首次解锁前（BFU）模式。

> **登录默认就是一个完整的 root shell。** 请优先使用密钥而非密码，只绑定到你信任的网络，并且没有理由
> 就绝不把端口暴露到开放的互联网。

## 1. 安装

在 **KernelSU**、**APatch** 或 **Magisk** 管理器中刷入模块的 zip（或在 shell 中用
`ksud module install` / `apd module install`），然后打开模块的 **WebUI**。

## 2. 添加一个密钥（推荐）

在 WebUI 的 **Authorized keys** 下，粘贴你的公钥（`ssh-ed25519 AAAA... you@host`）并按 **Add key**。密钥是默认
方式，也是最安全的进入途径。

如果你还没有密钥，可在你的电脑上生成一个：

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. 或者设置一个密码

密码登录默认关闭（登录默认就是 root，所以更推荐密钥）。要启用它，请在设置中打开 **Password login**，然后在
**Password accounts** 下为登录用户设置一个密码。哈希会在你的浏览器中用 PBKDF2 计算；密码本身从不离开页面。

## 4. 选择端口以及在哪里监听

在 **Settings** 下，设置 **Port** 并选择各个绑定。默认情况下 VD Dropbear 只在 **loopback** 上监听；要从你的 LAN
或 VPN 访问它，请启用你想要的接口。除非你了解其中的暴露风险，否则请避免 **Listen on all interfaces**。

按 **Save & restart** 以应用，如果它尚未运行则按 **Start**。

## 5. 连接

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`、`scp` 和 `rsync` 均已随附打包，因此 SFTP、`sshfs`、GUI 客户端和备份都能通过同一个连接工作。

## 6. 首次解锁前（BFU）

默认情况下，守护进程只在你解锁设备一次**之后**（AFU）才启动，因为它的 secret 存放在 credential-encrypted 存储
上。如果你需要在首次解锁**之前**使用 SSH（例如在重启后远程解锁一台设备）请打开
**Start before first unlock (BFU)**。于是这些 secret 会移到 device-encrypted 存储上，在解锁前即可读取：这是一个
有意的、有文档记录的权衡。参见 README 中的[安全模型](#)。

## 7. 控制守护进程

- **WebUI：** Start / Stop / Restart，以及实时状态（运行中、PID、端口、模式、host key 指纹）。
- **管理器 Action 按钮：**（重新）启动守护进程。
- 它也会在启动时自动运行（除非你将其禁用）。

## 故障排查

- **它无法启动。** 检查 `/data/adb/vddropbear/state/daemon.log`。确认 **Enabled** 已开启，并且 host key 能够被
  生成。
- **密钥被拒绝。** 确认公钥那一行与你的客户端所提供的完全一致，并且你用于登录的用户名是系统能够解析的（通常是 `root`）。
- **无法从另一台机器连接。** 你多半仍然只绑定到了 loopback，请启用你需要的接口并重启。
- **SFTP/scp 失败但 shell 正常。** 确认随附的 `sftp-server` 已为你的 ABI 发布；WebUI 状态会显示检测到的 ABI。
