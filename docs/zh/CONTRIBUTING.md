<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Contributing guide.

   Copyright (C) 2026  VD171
   SPDX-License-Identifier: Apache-2.0

   Licensed under the Apache License, Version 2.0; you may obtain a copy at
   http://www.apache.org/licenses/LICENSE-2.0

   Site           : https://vd171.ru
   Site           : https://vd.priv8.ru
   Source         : https://github.com/VD171/VD-dropbear
   GitHub         : @VD171 https://github.com/VD171
   XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · 中文

---

# 为 VD Dropbear 做贡献

感谢你的关注。这是一个小而对安全敏感的项目（它会交出 root），因此改动会在这一前提下接受审阅。

## 仓库布局

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## 构建

二进制文件由 CI 从 **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** 加上 `patches/` 中的补丁生成。
要在本地构建，你需要 Android NDK：

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

补丁集被有意保持最小且可审计：一个中性/可配置的身份字符串、用于 `authorized_keys` 和密码文件的由配置驱动的路
径、Android 的 `openpty` 修复，以及运行时配置。请保持新补丁短小、带文档，并在 PR 中给出理由。

## Pull request

- 每个 PR 一处逻辑改动；描述动机和安全影响。
- 匹配现有的 shell 风格（POSIX `sh` / Android `mksh`；不使用 bashisms）。
- 每个文件都带有一个简短的 SPDX 头 - 请保留它。
- 对任何真实、对用户可见的改动，在 [`CHANGELOG.md`](../../CHANGELOG.md) 的 `[Unreleased]` 下进行更新。
- 提交 PR 即表示你同意按项目的 [Apache-2.0](../../LICENSE) 许可证授权你的贡献。

## 翻译

README 和文档以多种语言维护（`README.<lang>.md`）。英文是事实来源；译文随之而动。如果你改进某份译文或新增一种
语言，请保持结构和章节锚点与英文版本完全一致。

## 报告缺陷和安全问题

缺陷和功能请求请使用 issue 模板。对任何可能危及设备的问题，请遵循 [`SECURITY.md`](SECURITY.md)，私下报告，
而不是开一个公开 issue。
