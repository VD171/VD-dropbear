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

KernelSU / APatch / Magisk モジュールとしてパッケージされた、**単体で動作し、完全に設定可能な
[Dropbear](https://matt.ucc.asn.au/dropbear/) SSH サーバー**です。単独で起動し、他のどのモジュールにも依存しません。

> ⚠️ **ログインはデフォルトで完全な ROOT シェルになります。** これをデバイスの鍵そのものと考えてください。
> パスワードよりも公開鍵を優先し、ポートを公開インターネットに晒さないようにしてください。

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## なぜ

Android が自分の端末上でシェルを得るための標準的な手段は ADB（USB デバッグ）ですが、それを有効にするのは
侵襲的で、自分自身を晒すことになります。`adb_enabled` と `development_settings_enabled` は誰からでも読める設定であり、
どんなアプリ・SDK・不正対策 / RASP ライブラリでも読み取れます。接続はログに残り、ADB が有効である、あるいはかつて
有効だったことを隠す正規の方法はありません。この露出は、root 化していない素の端末であってもついて回ります。シェルを
得るには、それを宣言しなければならないのです。

VD Dropbear はそのプライベートな代替です。root 化した端末では、本物の SSH サーバー（root シェル、ネットワーク越しの
SFTP と rsync）を提供します。`adb_enabled` の痕跡も、USB デバッグのフラグもなく、何も明かさないバージョンバナーと、
あなたが管理する認証情報を備えています。あなたのアクセスはあなたのものであり続けます。端末上の何もかもが読める、
グローバルに公開された「私はデバッグされています」というフラグではありません。

## 機能

- **デーモンは常にひとつ。** 起動時とマネージャーの **Action** ボタンから開始され、WebUI からいつでも
  **start / stop / restart** できます。インスタンスが 2 つ以上になることは決してありません。
- **すべてが WebUI から設定可能**（または `/data/adb/vddropbear/config`）:
  - ポート、および loopback / all / IPv4 / IPv6 / 特定アドレスへのバインド
  - **最初のアンロック前（BFU）に起動するか、その後にのみ（AFU）起動するか**、単一のトグル
  - 公開鍵認証および／またはパスワード認証、最大認証試行回数
  - ログインシェル、`HOME`、追加の environment
  - idle timeout、keepalive、receive window
  - ローカル／リモートのポートフォワーディングと gateway ports（すべてデフォルトで **オフ**）
  - host-key の種類（ed25519 / rsa / ecdsa）
- **バージョンバナーの隠蔽。** SSH プロトコルは *何らかの* バナーを要求するため削除はできませんが、VD Dropbear は
  情報を持たないものに差し替えます。そのためスキャナーは正確なサーバーやバージョンを特定できず、既知バージョンを
  狙った攻撃を向けることができません。
- **秘密情報は理にかなった形で保存**（[セキュリティモデル](#security-model)を参照）。
- **自分の認証情報を持ち込む。** 認可された鍵とパスワードアカウントを追加できます。ログインは認証に使ったアカウント
  として実行されます。デフォルトは **root** ですが、権限の低い Android アカウント（`shell`、`system`）でもログイン
  できます。WebUI はパスワードの最低強度を強制し、パスワードを平文で保存することは決してありません。
- **ファイル転送と同期を内蔵。** バンドルには `sftp-server`、`scp`、`rsync` が同梱されており、SFTP、sshfs、GUI
  クライアント、バックアップがすべて同じ接続上で動作します。
- **あらゆる端末とエミュレーター。** `arm64-v8a`、`armeabi-v7a`、`x86`、`x86_64`。

## 端末上の AI エージェント

常設の SSH エンドポイントは、あなたの端末を **自律型 AI エージェントが直接操作できる** ものに変えます。シェルや
SSH 接続を扱えるエージェント（Claude Code、aider、LLM を組み込んだスクリプト、あなた自身の自動化など）は、
ネットワーク越しに端末上の本物の root セッションを得ます。USB ケーブルも、ADB の自己露出するデバッグフラグも
不要です。エージェントには通常の Linux ライクなシェルが見え、次のことができます:

- ファイルの読み書き、設定の変更、モジュール・パッケージ・サービスの管理;
- ログのトリアージ、アーティファクトの取得、オンデマンドの診断やフォレンジックの実行;
- `scp` / `sftp` / `rsync` でファイルを双方向に移動・同期し、バックアップ・移行・プロビジョニングに利用;
- root 化した端末群の一群を一か所から操作し、それぞれを専用の鍵で到達可能にする。

このプロジェクトは **AI フレンドリー** に作られているため（ドキュメント化された設定ファイル、明示的なランタイム
[env 契約](patches/README.md)、予測可能なパス、平文のステータス）、エージェントは当て推量なしに使い方を見つけられます。

> **デフォルトで root なので、root として扱ってください。** デフォルトのログインは root として着地しますが、権限の低い
> アカウント（`shell`、`system`）でログインすることもできます（下の警告を参照）。エージェントにアクセスを渡すときは、
> （あなた個人の鍵ではなく）専用の認証情報を与え、到達範囲を絞りたい場合は `shell` のような権限の低いアカウントを指定し、
> バインドを信頼できるネットワーク（オープンな
> インターネットではなく loopback や VPN）に限定し、パスワード認証はオフのままにし、WebUI からいつでも鍵を失効させたり
> デーモンを停止したりできることを忘れないでください。

## インストール

KernelSU、APatch、または Magisk のマネージャーでモジュールの zip をフラッシュし（あるいはコマンドラインから
`ksud module install` / `apd module install`）、モジュールの **WebUI** を開いてポートを設定し鍵を追加してから、
再起動してください（または **Action** を押して今すぐ起動します）。

## セキュリティモデル

### 秘密情報の置き場所: BFU と AFU

`/data/adb` は **device-encrypted（DE）** ストレージです。ユーザーが端末をアンロックする *前* に復号されるため
（Before First Unlock）、そこにあるものはアンロック前でも読み取れます。`/data/misc_ce` は
**credential-encrypted（CE）** であり、Android はユーザーがアンロックするまで暗号化したままにします（After First Unlock）。

- **AFU モード（デフォルト、`START_IN_BFU=0`）:** デーモンはアンロックを待ってから、host key、
  `authorized_keys`、パスワードハッシュを CE ストレージから読み取ります。最大限の保護であり、SSH は端末が起動後に
  一度アンロックされてから初めて機能します。
- **BFU モード（`START_IN_BFU=1`）:** デーモンはアンロック前に起動するため、早い段階で SSH でログインできます
  （たとえば端末をリモートでアンロックするため）。その場合、秘密情報は DE ストレージに置かれアンロック前でも読み取れます。
  これは意図的で文書化されたトレードオフです。アンロック前の SSH が必要な場合にのみ有効にしてください。

私たちは CE の上に独自の暗号化を重ねることを **あえて行いません**。すでにユーザーの認証情報で暗号化されており、別の
暗号を重ねればどこかに置かざるを得ない鍵が必要になります（DE に置けば晒され、ユーザーの認証情報から導出するのは
CE を再実装するだけです）。それは偽りの安心感を買うだけで、本当の保護にはなりません。

### パスワード

パスワードログインは **デフォルトでオフ** です。ログインがデフォルトで root であり、鍵のほうがはるかに安全だからです。
パスワードを設定する場合、WebUI は最低強度を強制し、保存するのはハッシュのみで、平文は決して保存しません。

## ビルド

サーバーバイナリは **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** から CI によってビルドされ、
小さく監査可能なパッチ群が当てられています（[`patches/`](patches/)を参照）: 中立／設定可能なアイデンティティ文字列、
`authorized_keys` とパスワードファイルの設定駆動のパス、そして対話的 PTY のための Android 向け `openpty` 修正です。
スケジュールされた workflow が upstream を追跡して再ビルドするため、モジュールは常に最新に保たれます。
[`.github/workflows/`](.github/workflows/) と [`CONTRIBUTING.md`](CONTRIBUTING.md) を参照してください。

## ドキュメント

<!-- vd-docs -->
完全なドキュメントは [wiki](https://github.com/VD171/VD-dropbear/wiki) と [`docs/`](docs/) の下にあります。
<!-- /vd-docs -->

## 関連プロジェクト

同じ作者による姉妹プロジェクト:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: 各項目を、それを読み取れるあらゆる手法で読み取り、並べて比較する端末メソッドデバッガー。
- **[VDGoogle](https://github.com/VD171/VD-Google)**: RCS、Wallet、Play Integrity についてGoogleがあなたの端末に記録している内容を、完全に端末内で、インターネットなしで読み取ります。
- **[VDBackup](https://github.com/VD171/VD-Backup)**: root としてアプリとデータを丸ごとバックアップ・復元し、すべて WebUI から操作します。
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: 新しいフィンガープリントを一貫性のある整合的なプロファイルに変える端末スプーファーです。

## 連絡先

- https://vd171.ru
- https://vd.priv8.ru
- *Telegram:* @VD_Priv8 https://t.me/VD_Priv8
- *Channel:* @Priv8_VD https://t.me/Priv8_VD
- *Discord:* @VD.Priv8 https://discord.com/users/1296831918989639721
- *E-mail:* vd.priv8@pm.me
- *XDA-Developers:* @VD171 https://xdaforums.com/m/vd171.4699873/
- *XDA thread:* https://xdaforums.com/t/VD-Dropbear.4808524/
- *GitHub:* @VD171 https://github.com/VD171

## ライセンス

VD Dropbear 自身のコードは **Apache-2.0** です。[LICENSE](LICENSE) を参照してください。モジュールはサードパーティの
バイナリも同梱しています：[Dropbear](https://matt.ucc.asn.au/dropbear/)（MIT 系）、OpenSSH の `sftp-server` と
`scp`（BSD）、`rsync`（GPL-3.0）、それぞれが独自のライセンスの下にあります。[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)
を参照してください。rsync の GPL をどのように遵守しているかも含まれます。私たちの Apache-2.0 コードは影響を受けません
（GPL バイナリは単に集積されているだけで、リンクされてはいません）。

## 商標

VD Dropbear は独立した非公式のプロジェクトであり、いかなる第三者とも提携しておらず、その承認も受けていません。
「Android」は Google LLC の商標です。「SSH」は SSH Communications Security の登録商標です。VD Dropbear は完全に
あなたの端末上で動作します。

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
