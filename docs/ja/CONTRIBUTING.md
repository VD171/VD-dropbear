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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · 日本語 · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# VD Dropbearへの貢献

関心をお寄せいただきありがとうございます。これはrootを手渡す、小さくセキュリティに敏感なプロジェクトです。そのため変更はその点を念頭に置いてレビューされます。

## リポジトリの構成

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## ビルド

バイナリは、**upstreamの [mkj/dropbear](https://github.com/mkj/dropbear)** に `patches/` 内のパッチを加えたものからCIが生成します。ローカルでビルドするにはAndroid NDKが必要です：

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

パッチセットは意図的に最小限で監査可能に保たれています：中立／設定可能なアイデンティティ文字列、`authorized_keys` とパスワードファイルの設定駆動のパス、Androidの `openpty` 修正、そしてランタイム設定。新しいパッチは小さく、文書化し、PRで正当化してください。

## プルリクエスト

- 1つのPRにつき論理的な変更は1つ；動機とセキュリティへの影響を説明してください。
- 既存のシェルスタイルに合わせてください（POSIX `sh` / Android `mksh`；bashism禁止）。
- どのファイルにも短いSPDXヘッダがあります - それを保ってください。
- 実際にユーザーから見える変更については、[`CHANGELOG.md`](../../CHANGELOG.md) の `[Unreleased]` を更新してください。
- PRを提出することで、あなたの貢献をプロジェクトの [Apache-2.0](../../LICENSE) ライセンスの下で提供することに同意したものとみなされます。

## 翻訳

READMEとドキュメントは多くの言語で維持されています（`README.<lang>.md`）。英語が真実の源であり、翻訳はそれに従います。翻訳を改善したり言語を追加したりする場合は、構造とセクションのアンカーを英語版と同一に保ってください。

## バグとセキュリティ問題の報告

バグと機能要望にはissueテンプレートを使ってください。デバイスを危険にさらしうるものについては、[`SECURITY.md`](SECURITY.md) に従い、公開のissueを開く代わりに非公開で報告してください。
