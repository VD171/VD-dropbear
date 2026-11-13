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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · 日本語 · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# ユーザーガイド

VD Dropbearは、root化したデバイスにプライベートなSSHサーバーを提供します。このガイドは、インストールから、ファイル転送や最初のアンロック前（BFU）モードを含む、動作する接続までを案内します。

> **ログインは既定で完全なrootシェルになります。** パスワードより鍵を優先し、信頼できるネットワークにのみバインドし、理由なくポートをオープンなインターネットに露出させないでください。

## 1. インストール

**KernelSU**、**APatch**、または **Magisk** のマネージャでモジュールのzipをフラッシュし（あるいはシェルから `ksud module install` / `apd module install` で）、続いてモジュールの **WebUI** を開きます。

## 2. 鍵を追加する（推奨）

WebUIの **Authorized keys** で、公開鍵（`ssh-ed25519 AAAA... you@host`）を貼り付け、**Add key** を押します。鍵が既定で、最も安全な入り口です。

まだ鍵を持っていない場合、コンピュータ上で鍵を生成するには：

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. またはパスワードを設定する

パスワードログインは既定で無効です（ログインは既定でrootなので、鍵が推奨されます）。有効にするには、設定で **Password login** をオンにし、続いて **Password accounts** でログインユーザーのパスワードを設定します。ハッシュはブラウザ内でPBKDF2を使って計算され、パスワードそのものがページを離れることはありません。

## 4. ポートとリッスン先を選ぶ

**Settings** で **Port** を設定し、バインドを選びます。既定ではVD Dropbearは **loopback** のみでリッスンします；LANやVPNから到達するには、使いたいインターフェースを有効にします。露出を理解していない限り、**Listen on all interfaces** は避けてください。

適用するには **Save & restart** を押し、まだ動作していなければ **Start** を押します。

## 5. 接続する

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`、`scp`、`rsync` が同梱されているため、SFTP、`sshfs`、GUIクライアント、バックアップがすべて同じ接続で動作します。

## 6. 最初のアンロック前（BFU）

既定では、デーモンはデバイスを一度アンロックした **あと**（AFU）にのみ起動します。シークレットが認証情報暗号化ストレージに置かれているためです。最初のアンロック **前** にSSHが必要な場合（たとえば再起動後にデバイスをリモートでアンロックするため）には、**Start before first unlock (BFU)** をオンにします。するとシークレットはデバイス暗号化ストレージへ移り、アンロック前に読み取れるようになります：意図的で、文書化されたトレードオフです。READMEの [Security model](#) を参照してください。

## 7. デーモンの制御

- **WebUI：** Start / Stop / Restart、そしてライブステータス（動作状況、PID、ポート、モード、ホスト鍵のフィンガープリント）。
- **マネージャのActionボタン：** デーモンを（再）起動します。
- 起動時にも自動的に開始します（無効にしていない限り）。

## トラブルシューティング

- **起動しない。** `/data/adb/vddropbear/state/daemon.log` を確認してください。**Enabled** がオンで、ホスト鍵が生成できたことを確かめてください。
- **鍵が拒否される。** 公開鍵の行がクライアントが提示するものと完全に一致していること、そしてログインに使うユーザー名がシステムの解決できるもの（通常は `root`）であることを確認してください。
- **別のマシンから接続できない。** おそらくまだループバックのみにバインドされています。必要なインターフェースを有効にして再起動してください。
- **SFTP/scpは失敗するがシェルは動く。** 同梱の `sftp-server` があなたのABI向けに配布されているか確認してください；WebUIのステータスに検出されたABIが表示されます。
