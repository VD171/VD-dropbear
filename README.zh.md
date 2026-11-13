<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.

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

<p align="center">
  <img src="module/webroot/assets/logo-wordmark.svg" alt="VD Dropbear" width="540">
</p>

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-1a7f37" alt="License"></a>
  <img src="https://img.shields.io/badge/KernelSU-%E2%9C%94-635bff" alt="KernelSU">
  <img src="https://img.shields.io/badge/APatch-%E2%9C%94-ff7043" alt="APatch">
  <img src="https://img.shields.io/badge/Magisk-%E2%9C%94-00af9c" alt="Magisk">
  <a href="https://github.com/VD171/VD-dropbear/stargazers"><img src="https://img.shields.io/github/stars/VD171/VD-dropbear?color=d29922" alt="Stars"></a>
  <a href="https://github.com/VD171/VD-dropbear/releases"><img src="https://img.shields.io/github/v/release/VD171/VD-dropbear?color=1a7f37" alt="Release"></a>
</p>

**一个独立、完全可配置的 [Dropbear](https://matt.ucc.asn.au/dropbear/) SSH 服务器**，以 KernelSU /
APatch / Magisk 模块的形式打包。它独立启动，不依赖任何其他模块。

> ⚠️ **每一个通过身份验证的连接都会得到一个 ROOT shell。** 请把它当作设备的钥匙来对待：优先使用公钥而非
> 密码，并让端口远离公网。

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## 为什么

Android 内置的、在自己手机上获得 shell 的方式是 ADB（USB 调试），而开启它既具侵入性又会暴露自己。
`adb_enabled` 和 `development_settings_enabled` 是所有程序都可读取的设置：任何应用、SDK 或反欺诈 /
RASP 库都能读到它们，连接会被记录，而且没有受支持的办法可以隐藏 ADB 正在开启、或曾经开启过。即便在一台
原厂、未 root 的手机上，这种暴露也如影随形：要想获得 shell，你就不得不昭告天下。

VD Dropbear 是私密的替代方案。在已 root 的设备上，它为你提供一个真正的 SSH 服务器：通过网络访问的 root
shell、SFTP 和 rsync，没有 `adb_enabled` 这一破绽，没有 USB 调试标志，版本横幅什么也不透露，而且凭据由
你掌控。你的访问权始终属于你自己，而不是一面全局可读、设备上任何东西都能读到的「我正在被调试」的旗帜。

## 功能

- **始终只有一个守护进程。** 它在开机时以及通过管理器的 **Action** 按钮启动，你随时都可以在 WebUI 中
  **启动 / 停止 / 重启**它；绝不会有超过一个实例。
- **一切皆可配置**，在 WebUI 中（或 `/data/adb/vddropbear/config`）：
  - 端口，以及绑定到 loopback / 全部 / IPv4 / IPv6 / 指定地址
  - **在首次解锁前启动（BFU）还是仅在其后启动（AFU）**，一个开关搞定
  - 公钥和/或密码身份验证，最大验证尝试次数
  - 登录用户、shell、`HOME`、额外的环境变量
  - 空闲超时、keepalive、接收窗口
  - 本地 / 远程端口转发和 gateway 端口（默认全部**关闭**）
  - 主机密钥类型（ed25519 / rsa / ecdsa）
- **隐藏的版本横幅。** SSH 协议要求必须有*一个*横幅，因此无法将其移除，但 VD Dropbear 将其替换为一条毫无
  信息量的横幅，这样扫描器就无法指纹识别出确切的服务器或版本，从而对其发动针对已知版本的攻击。
- **以合理方式存储机密**（见[安全模型](#security-model)）。
- **自带你自己的凭据。** 添加 `user + key` 和 `user + password` 组合；WebUI 会强制要求最低密码强度，并且
  绝不以明文存储密码。
- **内置文件传输与同步。** 该套件附带 `sftp-server`、`scp` 和 `rsync`，因此 SFTP、sshfs、图形界面客户端和
  备份都能在同一个连接上运行。
- **兼容每一款设备和模拟器。** `arm64-v8a`、`armeabi-v7a`、`x86`、`x86_64`。

## 你设备上的 AI 智能体

一个常驻的 SSH 端点，会把你的手机变成**自主 AI 智能体可以直接操作**的东西。任何能够驱动 shell 或 SSH
连接的智能体（Claude Code、aider、循环中带有 LLM 的脚本、你自己的自动化）都能通过网络在设备上获得一个
真正的 root 会话，无需 USB 连线，也没有 ADB 那些会暴露自己的调试标志。智能体看到的是一个普通的类 Linux
shell，并且可以：

- 读取和编辑文件、切换设置，以及管理模块、软件包和服务；
- 梳理日志、拉取产物，并按需运行诊断或取证；
- 通过 `scp` / `sftp` / `rsync` 双向移动和同步文件，用于备份、迁移或初始配置；
- 从同一个地方驱动整支已 root 的设备机群，每一台都可用各自的密钥访问。

由于本项目在构建时就力求**对 AI 友好**（一个有文档的配置文件、一份明确的运行时[环境契约](patches/README.md)、
可预测的路径以及纯文本的状态），智能体无需靠猜就能弄清如何使用它。

> **这是 root，所以请把它当作 root 来对待。** 每一个通过身份验证的连接都以 root 身份落地（见下方警告）。
> 当你把访问权交给某个智能体时，为它配一个**专用的用户和密钥**，把绑定限制在你信任的网络内（loopback 或
> VPN，而非开放的互联网），让密码验证保持关闭，并记住你随时都能在 WebUI 中吊销某个密钥或停止守护进程。

## 安装

在 KernelSU、APatch 或 Magisk 管理器中刷入模块 zip（或在命令行用 `ksud module install` /
`apd module install`），打开模块的 **WebUI** 以设置端口并添加你的密钥，然后重启（或按 **Action** 立即启动它）。

## 安全模型

### 机密存放在哪里：BFU 对比 AFU

`/data/adb` 是**设备加密（DE）**存储：它在用户解锁手机*之前*就被解密（首次解锁前，Before First Unlock），
所以那里的任何东西在解锁前都是可读的。`/data/misc_ce` 则是**凭据加密（CE）**存储：Android 会一直保持其加密
状态，直到用户解锁（首次解锁后，After First Unlock）。

- **AFU 模式（默认，`START_IN_BFU=0`）：** 守护进程等待解锁，然后从 CE 存储读取其主机密钥、`authorized_keys`
  和密码哈希。保护程度最高；SSH 仅在设备自开机以来至少解锁过一次之后才能工作。
- **BFU 模式（`START_IN_BFU=1`）：** 守护进程在解锁前就启动，以便你能提前通过 SSH 连入（例如远程解锁设备）。
  此时它的机密存放在 DE 存储上，在解锁前可读，这是一种有意为之且有文档记录的取舍。只有在你确实需要解锁前
  SSH 时才启用它。

我们有意**不**在 CE 之上叠加我们自己的加密：它已经用用户的凭据加密过了，而再套一层密码就需要一把必须存放在
某处的密钥（放在 DE 上会被暴露；从用户凭据派生它则不过是在重新实现一遍 CE）。那只会带来虚假的安全感，而非真正
的保护。

### 密码

密码登录**默认关闭**，因为每一次登录都是 root，而密钥要安全得多。当你确实要设置密码时，WebUI 会强制要求最低
强度，并且只存储一个哈希，绝不存明文。

## 构建

服务器二进制文件由 CI 从**上游 [mkj/dropbear](https://github.com/mkj/dropbear)** 构建，带有一小套可审计的
补丁（见 [`patches/`](patches/)）：一个中性/可配置的身份字符串、为 `authorized_keys` 和密码文件提供的由
配置驱动的路径，以及用于交互式 PTY 的 Android `openpty` 修复。一个计划任务工作流会跟踪上游并重新构建，使
模块保持最新。见 [`.github/workflows/`](.github/workflows/) 和 [`CONTRIBUTING.md`](CONTRIBUTING.md)。

## 文档

<!-- vd-docs -->
完整文档位于 [wiki](https://github.com/VD171/VD-dropbear/wiki) 以及 [`docs/`](docs/) 目录下。
<!-- /vd-docs -->

## 另见

同一作者的姊妹项目：

- **[VDInfos](https://github.com/VD171/VD-Infos)**：一个设备方法调试器，通过每一种能读取某一项的方法去读取它，并将结果并排对比。
- **[VDGoogle](https://github.com/VD171/VD-Google)**：你的 Google 服务（RCS、Wallet、Play Integrity 证明），在你的设备上离线读取。
- **[VDBackup](https://github.com/VD171/VD-Backup)**：以 root 身份对应用和数据进行完整备份与恢复，全程由 WebUI 驱动。
- **[COPG-VD](https://github.com/VD171/COPG-VD)**：一个全局的设备指纹和 build 伪装工具。

## 联系方式

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram：** @VD_Priv8 https://t.me/VD_Priv8
* **频道：** @Priv8_VD https://t.me/Priv8_VD
* **Discord：** @VD.Priv8 https://discord.com/users/1296831918989639721
* **邮箱：** vd.priv8@pm.me
* **XDA-Developers：** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA 主题：** _(占位符，将在首次公开发布时添加)_
* **GitHub：** @VD171 https://github.com/VD171

## 许可证

VD Dropbear 自身的代码采用 **Apache-2.0**，见 [LICENSE](LICENSE)。该模块还捆绑了第三方二进制文件：
[Dropbear](https://matt.ucc.asn.au/dropbear/)（MIT 风格）、OpenSSH 的 `sftp-server` 和 `scp`（BSD），
以及 `rsync`（GPL-3.0），各自遵循其自身的许可证；见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)，
其中包括我们如何为 rsync 遵守 GPL。我们的 Apache-2.0 代码不受影响（GPL 二进制文件只是聚合在一起，并未链接）。

## 商标

VD Dropbear 是一个独立的非官方项目，不隶属于任何第三方，也未获其背书。「Android」是 Google LLC 的商标；
「SSH」是 SSH Communications Security 的注册商标。VD Dropbear 完全在你的设备上运行。

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
