<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Architecture.

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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · 日本語 · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# アーキテクチャ

VD Dropbearは、ちょうど1つのDropbear SSHデーモンを実行するKernelSU / APatch / Magiskモジュールで、動作はすべて設定によって制御されます。SSHサーバーに関して特定のデバイスへハードコードされたものは何もなく、固有の要素はすべてランタイムの設定かシークレットです。

## 構成要素

- `module/common/vddropbear.sh` - 中核となるライブラリ：設定の読み込み（安全な組み込みの既定値付き）、シークレットストアの解決、ホスト鍵の確保、Dropbearの引数ベクタの構築、そして単一のデーモンインスタンスの管理（start / stop / status / restart）。
- `module/service.sh` - 起動エントリ。BFU/AFUの起動ポリシーを尊重し、AFUモードでは起動を止めることなく、認証情報で暗号化されたストレージのアンロックを待ちます。
- `module/action.sh` - マネージャの **Action** ボタン：デーモンを（再）起動します。stdinを一切読まず、デーモンを自身のセッションへ切り離すため、マネージャがハングしません。
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - WebUIのバックエンドとページ。
- `patches/` - ビルド時にupstreamのDropbearへ適用される、小さく監査可能なパッチ。
- `scripts/build.sh`、`scripts/build-bundles.sh`、`.github/workflows/build.yml` - ビルド。

## デーモンのライフサイクル（単一インスタンス）

`vddb_start` は設定を読み込み、実行中のインスタンスがあれば停止し、ホスト鍵の存在を確保したうえで、1つのデーモンを起動します。バイナリは `vddropbear` として配布されるため、そのプロセス名は `pgrep -x` と完全に一致します（Androidの `mksh` には `exec -a` がありません）。`setsid` で起動され、呼び出し元のプロセスグループから切り離されます - これがマネージャのActionをブロックさせない仕組みです。

## シークレットストア（CE対DE、BFU対AFU）

設定はシークレットではなく、デバイス暗号化ストレージ（`/data/adb/vddropbear`）に置かれ、起動時に読み取れます。シークレット - ホスト鍵、`authorized_keys`、パスワードハッシュ - は既定で **認証情報暗号化（credential-encrypted）** ストレージ（`/data/misc_ce/0/vddropbear`）に置かれ、これはユーザーが認証したあとにのみアンロックされます。`START_IN_BFU` を有効にするとシークレットはデバイス暗号化ストレージへ移り、デーモンは最初のアンロック前に実行できるようになりますが、その代わりにシークレットがより早い段階で読み取れるようになります。モジュールは各起動ステージでどのストアを使うかを計算します。

## パッチセット

SSHサーバーはupstreamのDropbearのままで、私たちの変更はレビュー可能ないくつかのパッチにとどめています（[patches/README.md](../../patches/README.md) を参照）：

- 中立で、ランタイムに設定可能なアイデンティティバナー；
- 環境変数で設定したパスから読み込む `authorized_keys`（これにより鍵はシークレットストアに置かれる）；
- Androidにはないシステムの `crypt()`/shadow の代わりに、PBKDF2ハッシュファイルに対して行うパスワード認証（[BUILDING.md](../BUILDING.md) を参照）。

## WebUI

マネージャのWebUI（KernelSU / APatch / WebUI-X）内の静的なページです。`ksu.exec` ブリッジを通じて `module/common/vddb-webui.sh` を駆動します：ステータス、start/stop/restart、設定の読み書き、鍵とパスワードアカウントの管理。すべてのデータはbase64エンコードされてブリッジを渡るため、シェルがそれを解釈することはありません；パスワードハッシュはブラウザ内でWebCryptoを使って計算されるため、平文のパスワードがページを離れることはありません。
