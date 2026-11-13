<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   AI agents on your device.

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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · 日本語 · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# デバイス上のAIエージェント

常駐するSSHエンドポイントは、あなたのスマートフォンを **自律型AIエージェントが直接操作できる** 存在に変えます。シェルやSSH接続を扱えるエージェントであれば - Claude Code、aider、LLMを組み込んだスクリプト、あなた自身の自動化処理など - USBテザリングも、ADBのように自らを露出させるデバッグフラグも使わずに、ネットワーク経由でデバイス上の本物のrootセッションを手に入れられます。

このページはREADMEで紹介した考え方をさらに掘り下げます。

## エージェントにADBではなくSSHを使う理由

ADBは自らの存在を公言します。`adb_enabled` と `development_settings_enabled` は誰からでも読み取れ、接続はログに残り、デバッグが有効である（または有効だった）ことを隠す正式な手段はありません。ADB経由で作業するエージェントは、どんなアプリや不正検知SDKにも読み取られるその痕跡をデバイスに残します。VD Dropbearはそのプライベートな代替手段です - 普通のSSHログインで、認証情報はあなたが管理し、バナーは何も明かしません。

## エージェントにできること

ひとつの接続を通じて、エージェントは普通のLinuxライクなシェルを見て、次のことができます：

- ファイルの読み書きや編集、設定の切り替え、モジュール・パッケージ・サービスの管理；
- ログの切り分け、成果物の取得、必要に応じた診断やフォレンジックの実行；
- `scp` / `sftp` / `rsync` による双方向のファイル移動・同期 - バックアップ、移行、プロビジョニング；
- それぞれが専用の鍵で到達できる、root化デバイスの群れ全体を一箇所から操作。

このプロジェクトは **AIフレンドリー** に作られているため - 文書化された設定ファイル、明示的なランタイムの [env contract](../../patches/README.md)、予測可能なパス、プレーンテキストのステータス - エージェントは当て推量なしに使い方を把握できます。

## 安全に行うために

これはrootなので、rootとして扱ってください：

- エージェントには、あなた個人のものではなく **専用のユーザーと鍵** を与える；
- バインドは信頼できるネットワークに限定する - オープンなインターネットではなく、ループバックやVPN（[Configuration](CONFIGURATION.md) を参照）；
- パスワード認証は無効のままにする；鍵は失効させられ、入力されることもない；
- WebUIからいつでも鍵を失効させたり、デーモンを停止したりできる；
- どの接続も完全なrootセッションであることを忘れずに - エージェントには必要な範囲だけを与える。

## 最小限のセットアップ

1. エージェント専用の鍵ペアを生成する。
2. WebUIでその公開鍵を追加する（**Authorized keys**）。
3. 既定とは異なるポートで、ループバックまたはVPNのみにバインドする。
4. エージェントのSSH設定をデバイスに向け、作業させる。
