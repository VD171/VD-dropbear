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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · 日本語 · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# 設定

設定は `/data/adb/vddropbear/config` に置かれます（初回起動時に `module/common/config.default` から生成されます）。**WebUI** がこのファイルを編集してくれますが、手で編集することもできます。シェルとして読み込まれるため、`KEY=value` の形式で、`=` の前後にスペースを入れないでください。設定はシークレットではなく、デバイス暗号化ストレージに置かれます；シークレット（ホスト鍵、authorized keys、パスワードハッシュ）はシークレットストアに置かれ、ここには決して置かれません。

変更はデーモンを再起動して適用します（WebUIの **Save & restart** がこれを行います）。

## 全般

| Key | Default | 意味 |
|-----|---------|---------|
| `ENABLED` | `1` | 起動時にデーモンを開始します。`0` で完全に無効化します。 |
| `START_IN_BFU` | `0` | `0`：最初のアンロック後（AFU）にのみ開始；シークレットは認証情報暗号化（CE）ストレージに留まります。`1`：最初のアンロック前（BFU）にも開始；シークレットはデバイス暗号化（DE）ストレージへ移り、アンロック前に読み取れます。 |
| `PORT` | `2222` | 既定のリッスンポート（`LISTEN_ADDRESSES` でバインドごとのポートが上書きできます）。 |

## リッスン / バインド（組み合わせ可能）

どの組み合わせも許可され、選択したバインドはマージされます。すべてをクリアした場合、VD Dropbearはすべてのインターフェースではなくループバックにバインドします。

| Key | Default | 意味 |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | `127.0.0.1` / `::1` のみでリッスンします。 |
| `LISTEN_ALL` | `0` | すべてのインターフェース（`0.0.0.0` / `::`）でリッスンします - デバイスを露出させます。 |
| `LISTEN_IPV4` | `1` | IPv4のバインドを含めます。 |
| `LISTEN_IPV6` | `1` | IPv6のバインドを含めます。 |
| `LISTEN_ADDRESSES` | `""` | 追加の具体的なバインド、カンマ区切り：`addr`（`PORT` を使用）または `addr:port`、IPv4またはIPv6。 |

## アイデンティティ

| Key | Default | 意味 |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | 中立なSSHアイデンティティバナーを送り、スキャナが正確なサーバー／バージョンをフィンガープリントできないようにします。 |
| `IDENT_STRING` | `""` | カスタムのアイデンティティ文字列。空の場合は中立な組み込みの既定値を使います。 |

## 認証

認証されたログインはすべて **root** です。鍵が既定で、パスワードはオプトインです。

| Key | Default | 意味 |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | 公開鍵ログインを許可します（シークレットストア内のauthorized keysを読み込みます）。 |
| `PASSWORD_AUTH` | `0` | パスワードログインを許可します。無効の場合、デーモンはパスワード認証を無効にして起動されます。 |
| `MAX_AUTH_TRIES` | `3` | 接続ごとの認証試行の最大回数。 |

## セッション / 環境

| Key | Default | 意味 |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | セッションのシェル。空の場合はアカウントの既定を使います。 |
| `HOME_DIR` | `""` | セッションの `HOME`。空の場合はモジュールディレクトリを使います。 |
| `EXTRA_ENV` | `""` | 追加の環境変数、`K=V;K2=V2`。 |
| `IDLE_TIMEOUT` | `0` | N秒アイドルで切断します。`0` で無効。 |
| `KEEPALIVE` | `0` | N秒ごとにkeepaliveを送ります。`0` で無効。 |
| `RECEIVE_WINDOW` | `""` | Dropbearの受信ウィンドウサイズ。空の場合は既定を使います。 |

## フォワーディング（既定で無効）

| Key | Default | 意味 |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | ローカル（`-L`）ポートフォワーディングを許可します。 |
| `ALLOW_REMOTE_FORWARD` | `0` | リモート（`-R`）ポートフォワーディングを許可します。 |
| `GATEWAY_PORTS` | `0` | フォワーディングされたリモートポートがすべてのインターフェースにバインドできるようにします。 |

## ホスト鍵

| Key | Default | 意味 |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | ホスト鍵の種類：`ed25519`、`rsa`、または `ecdsa`。初回起動時にシークレットストア内へ生成されます。 |

## シークレットストア

ここでは設定しません - `START_IN_BFU` から解決されます：

- **AFU（既定）：** `/data/misc_ce/0/vddropbear/secret` - 認証情報暗号化で、デバイスをアンロックしたあとにのみ利用できます。
- **BFU：** `/data/adb/vddropbear/secret` - デバイス暗号化で、最初のアンロック前に読み取れます。

ここにはホスト鍵、`authorized_keys`、`passwd` ハッシュファイルが入ります。パスワードハッシュの形式については [BUILDING.md](../BUILDING.md) を参照してください。
