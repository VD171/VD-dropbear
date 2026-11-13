<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Configuration reference.

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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · 中文

---

# 配置

设置存放在 `/data/adb/vddropbear/config` 中（首次启动时从 `module/common/config.default` 初始填充）。**WebUI**
会替你编辑这个文件；你也可以手动编辑它。它以 shell 方式被 source，因此请使用 `KEY=value`，`=` 两侧不留空格。设置
并非 secret，存放在 device-encrypted 存储中；secret（host keys、authorized keys、密码哈希）存放在 secret 存储中，
绝不在此处。

通过重启守护进程来应用更改（WebUI 的 **Save & restart** 会执行此操作）。

## 常规

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | 启动时运行守护进程。`0` 将其完全禁用。 |
| `START_IN_BFU` | `0` | `0`：仅在首次解锁后启动（AFU）；secret 保留在 credential-encrypted（CE）存储中。`1`：也在首次解锁前启动（BFU）；secret 移到 device-encrypted（DE）存储中，解锁前即可读取。 |
| `PORT` | `2222` | 默认监听端口（各绑定的端口可在 `LISTEN_ADDRESSES` 中覆盖它）。 |

## 监听 / 绑定（可组合）

允许任意组合；所选的绑定会被合并。如果你把全部清空，VD Dropbear 会绑定 loopback，而不是每个接口。

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | 仅监听 `127.0.0.1` / `::1`。 |
| `LISTEN_ALL` | `0` | 在每个接口上监听（`0.0.0.0` / `::`） - 会暴露设备。 |
| `LISTEN_IPV4` | `1` | 包含 IPv4 绑定。 |
| `LISTEN_IPV6` | `1` | 包含 IPv6 绑定。 |
| `LISTEN_ADDRESSES` | `""` | 额外的特定绑定，以逗号分隔：`addr`（使用 `PORT`）或 `addr:port`，IPv4 或 IPv6。 |

## 身份

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | 发送一个中性的 SSH 身份横幅，使扫描器无法指纹识别出确切的服务器/版本。 |
| `IDENT_STRING` | `""` | 自定义身份字符串。留空则使用中性的内置默认值。 |

## 认证

每一次通过认证的登录都是 **root**。密钥是默认方式；密码则需主动启用。

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | 允许公钥登录（读取 secret 存储中的 authorized keys）。 |
| `PASSWORD_AUTH` | `0` | 允许密码登录。关闭时，守护进程将在禁用密码认证的情况下启动。 |
| `MAX_AUTH_TRIES` | `3` | 每个连接的最大认证尝试次数。 |

## 会话 / 环境

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | 会话使用的 shell。留空则使用账户默认值。 |
| `HOME_DIR` | `""` | 会话的 `HOME`。留空则使用模块目录。 |
| `EXTRA_ENV` | `""` | 额外环境变量，`K=V;K2=V2`。 |
| `IDLE_TIMEOUT` | `0` | 空闲 N 秒后断开连接。`0` 表示禁用。 |
| `KEEPALIVE` | `0` | 每 N 秒发送一次 keepalive。`0` 表示禁用。 |
| `RECEIVE_WINDOW` | `""` | Dropbear 接收窗口大小。留空则使用默认值。 |

## 转发（默认关闭）

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | 允许本地（`-L`）端口转发。 |
| `ALLOW_REMOTE_FORWARD` | `0` | 允许远程（`-R`）端口转发。 |
| `GATEWAY_PORTS` | `0` | 允许被转发的远程端口绑定到所有接口。 |

## Host key

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | host key 类型：`ed25519`、`rsa` 或 `ecdsa`。首次启动时生成到 secret 存储中。 |

## secret 存储

此处不作配置 - 由 `START_IN_BFU` 决定：

- **AFU（默认）：** `/data/misc_ce/0/vddropbear/secret` - credential-encrypted，仅在你解锁设备后才可用。
- **BFU：** `/data/adb/vddropbear/secret` - device-encrypted，首次解锁前即可读取。

它保存 host key、`authorized_keys` 以及 `passwd` 哈希文件。密码哈希格式见
[BUILDING.md](../BUILDING.md)。
