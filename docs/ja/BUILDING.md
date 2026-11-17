<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Building the binaries, and the Android crypto/crypt() story.

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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · 日本語 · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# VD Dropbear のビルド

VD Dropbear は **[Dropbear](https://github.com/mkj/dropbear) upstream**（[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION)
でピン留めされたタグ）に、[`patches/`](../../patches/) にある小さく監査可能なパッチ群を加えて提供します。CI
がこれをビルドします。ローカルで再現できます。

## クイックスタート

```sh
# 一度だけ: Android NDK（r27 以降）
export NDK=/path/to/android-ndk

# すべての ABI をビルド (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# あるいは素早く反復するため一つだけ
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` はピン留めされた upstream タグをクローンし、`patches/*.patch` と `localoptions.h`
を適用して、`vddropbear` と `dropbearkey` を `module/bin/<abi>/` へクロスコンパイルします。出力は
**動的な** ELF で（`file` は `dynamically linked, interpreter /system/bin/linker64 … for Android 24`
と報告します）、すべての Android 端末がすでに持つ bionic libc にリンクされます。libtomcrypt はバイナ
リ内に埋め込まれたままで、動的なのは C ライブラリだけです。[動的、static-PIE ではない](#動的static-pie-ではない)
を参照してください。

バイナリは **コミットされません**。タグごとに CI がビルドし、リリースに添付します。
[`.gitignore`](../../.gitignore) を参照してください。

---

## crypt()/libcrypto の話（なぜパスワード認証に本当の作業が必要だったか）

Dropbear のパスワード認証は、`crypt()` と `/etc/shadow` を備えた通常の Unix ホスト向けに書かれていま
す。Android には **どちらもありません**。これはビルドと三つの別々の箇所で衝突します。本節はそのそれぞ
れを記録します。まさに再発見するのが苦痛な類いのものだからです。これらはすべてパッチ
[`0003-password-file.patch`](../../patches/0003-password-file.patch) が処理し、以下の何ひとつ実行時に運任
せにしていません。

### 1. bionic には使える `crypt()` がない

Android の C ライブラリ（bionic）は `crypt()` も `crypt_r()` も shadow データベースも提供しません。NDK
は `<crypt.h>` を一切公開しません。したがって `crypt(password, salt)` を呼び `/etc/shadow` と比較する
Dropbear の標準パスワード経路は、Android ではそもそもビルドも実行もできません。リンクする `libcrypt`
もなく、パスワードハッシュのためだけに OpenSSL の `libcrypto` を引き込むのは、静的バイナリにとって大き
く不格好な依存になります。

**私たちの答え:** `crypt()` をまったく使わないことです。パスワード認証は、提示されたパスワードを
**PBKDF2-HMAC-SHA256** でハッシュファイル（`DROPBEAR_PASSWD_FILE`）に対して検証します。これは公開・標
準・ソルト付き・反復の KDF です。ファイル形式は [`patches/README.md`](../../patches/README.md) に記載して
います。

### 2. `sysoptions.h` のコンパイル時ガード

コードが動く前からして、Dropbear はビルドを拒否します:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

`HAVE_CRYPT` が未定義（bionic では常に）でパスワード認証が有効だと、これは強い `#error` です。私たち
の検証器は `crypt()` を決して呼ばないので、パッチ `0003` は **このガードを削除します**。（「少なくとも
一つの認証方式が有効でなければならない」という検査はそのまま残します。）

### 3. libtomcrypt の罠: PBKDF2 がコンパイルで *外に* される

Dropbear は切り詰めた **libtomcrypt** を埋め込んでおり、そこには PBKDF2 が *実際に* 含まれています
（`pkcs_5_alg2`, `src/misc/pkcs5/pkcs_5_2.c`）。当然の修正はそれを呼ぶことです。それは動きません。重な
り合う二つの理由からです:

- **プロトタイプが隠れている。** `pkcs_5_alg2` は `tomcrypt_pkcs.h` 内の `#ifdef LTC_PKCS_5` の中でしか
  宣言されません。Dropbear *自身の* ソースファイルは `LTC_PKCS_5` を定義してコンパイルされないため、宣
  言は不可視で、コンパイラは *implicit function declaration* で失敗します。
- **シンボルが存在しない。** さらに悪いことに、`pkcs_5_alg2` の *本体* 自体も `#ifdef LTC_PKCS_5` の後
  ろにあります。Dropbear の libtomcrypt ビルドはそれを定義しないので、`pkcs_5_2.o` は **空のオブジェク
  ト** にコンパイルされます。`libtomcrypt.a` の中にはありますが、`pkcs_5_alg2` シンボルを含みません。
  リンクは `undefined symbol: pkcs_5_alg2` で失敗します。

自分で確認できます:

```sh
# オブジェクトは存在するが空（T pkcs_5_alg2 がない）:
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> データマーカーのみ、pkcs_5_alg2 なし

# 対照的に HMAC は完全にコンパイルされている（Dropbear は SSH の MAC に使う）:
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> hmac_memory を定義
```

**私たちの答え:** Dropbear が *実際に* コンパイルするプリミティブの上に PBKDF2 を自分で構築することで
す。`hmac_memory` と登録済みの `sha256` ハッシュはどちらも存在しリンク可能なので、パッチ `0003` は
PBKDF2-HMAC-SHA256 を直接実装します（RFC 2898。SHA-256 では `dkLen == hLen` なので、32 バイトの出力ブ
ロック一つ）。`hmac_memory` を自分で宣言し（上と同じ隠れプロトタイプの問題）、オブジェクトはリンク時に
`libtomcrypt.a` から引き出されます。結果は標準の PBKDF2 であり、したがって相互運用可能です。WebUI がブ
ラウザの **WebCrypto** `deriveBits` で計算するハッシュは、サーバーが計算するものとバイト単位で一致し、
第三の独立実装として Python の `hashlib.pbkdf2_hmac` に対して検証されています。

> **要するに:** Android は `crypt()` を何も与えず、Dropbear の埋め込み PBKDF2 は無に等しくコンパイルさ
> れます。ここでのパスワード認証は libtomcrypt の HMAC の上にゼロから作った PBKDF2-HMAC-SHA256 で、
> crypt() のビルドガードは除去されています。OpenSSL/`libcrypto` なし、難読化なし、システムの shadow な
> し。

---

## 動的、static-PIE ではない

バイナリは **動的** です（`/system/bin/linker64` 経由でシステムの bionic にリンク）。静的ではありませ
ん。これは重要で、CI ではなく **実機で** 苦労して学びました:

- **static-PIE** ビルドは一見問題なく見え（`file` はきれいな `static-pie executable` を報告）、エラーな
  くリンクしますが、**端末で実行した瞬間に SIGSEGV します**（arm64 の Android 16 端末で確認、exit 139、
  有用な tombstone なし）。Android の静的実行ファイルは脆く、信頼できる形は通常の動的バイナリです。これ
  は定着したすべての Android 版 dropbear の配布形態でもあります。
- **静的・非 PIE** ビルドは起動すらしません。bionic が
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic` で拒否します。
- したがってビルドは **動的** です（`STATIC=1` なしの `make`; `-pie`）。あらゆる端末に存在する bionic
  libc だけをリンクします。libtomcrypt は今も静的にバイナリへ埋め込まれるので、配布する追加ライブラリは
  ありません。

テストの教訓: **`qemu-aarch64`（qemu-user）はここでは有効なスモークテストではありません**（これらのバ
イナリでも segfault します）。コンパイル+リンクの成功も同様です。**実機の arm64 Android 端末でバイナ
リを実行してください。** （これはまさにこの方法で検証しました。デ
ーモンを稼働中の端末の代替ポートで起動し、パスワードログインの成功を確認し、誤ったパスワードは拒否され
ました。）

## `-E` フラグはない

サーバーは `--disable-syslog` でビルドされるため常に stderr へログ出力し、upstream の `-E`（「log to
stderr」）オプションはこのバイナリに **存在しません**。渡すと `Invalid option -E` が出力され、デーモン
は決して起動しません。そのためモジュールの引数ビルダーは `-E` を渡しません。

## openpty

対話的な PTY セッションは `openpty()` を使います。bionic は `<pty.h>` でそれを宣言し、Dropbear のクロス
`configure` は NDK でそれを検出します（`HAVE_OPENPTY` が設定され、`HAVE_PTY_H 1`）。そのため **パッチは
不要** で、PTY はそのまま動きます。（exec、SFTP、rsync、ポートフォワーディングのような非対話的な用途は
どのみちそれに依存しません。）

## 同梱ツール: sftp-server, scp, rsync

`scripts/build-bundles.sh` はファイル転送ツールを動的バイナリとして `module/bin/<abi>/` へクロスコンパ
イルします。CI は `build.sh` の直後にそれを実行します。

- **rsync**（同梱の popt + zlib 付き）は、configure に bionic は `lutimes` を持たないと伝えれば
  （`ac_cv_func_lutimes=no`）きれいにコンパイルされます。
- **sftp-server** と **scp** は **OpenSSH portable** 由来で、`--without-openssl` でビルドされ（この二つ
  には OpenSSH 内蔵の暗号で十分）、このスクリプトが最初にビルドする小さな静的 **zlib** を伴います。

Android 上の OpenSSH は上の crypt() の話と同じくらい扱いにくいです。クロスコンパイル時に `configure`
がいくつかの libc 関数を誤検出するからです。スクリプトはその修正を符号化しています。記録として、その断
片は次のとおりです:

1. **bionic に欠けているが configure があると思い込む関数のキャッシュ seed**。代わりに compat 版がコン
   パイルされるようにします: `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`。
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`。** これらがないと OpenSSH の
   `defines.h` が `#define __sentinel__`（空）を行い、すると `<unistd.h>` にある bionic 自身の
   `__attribute__((__sentinel__(1)))` を壊し、すべてのコンパイルが `expected ')'` で失敗します。
3. **`memset` を使う `explicit_bzero` の compat。** bionic の `bzero` は関数風マクロ（本物のシンボルで
   はない）なので、`&bzero` を関数ポインタとして取る OpenSSH の既定の compat はコンパイルできません。
   bionic には自前の `explicit_bzero` がありません。
4. **compat ライブラリから `xcrypt.o` と `getrrsetbyname.o` を除外。** `xcrypt.c` は無条件に
   `getpwent()`/`crypt()` を呼び（bionic にはどちらもない）、`getrrsetbyname.c` は bionic が公開しない
   resolver の内部を使います。どちらも `sftp-server` や `scp` は使いません。
5. **`-Wl,--allow-multiple-definition`。** `reallocarray` は (1) の関数群の鏡像です。bionic は API 24
   でそれを *宣言しない* ので OpenSSH は自前の compat をコンパイルしますが、**シンボル** は `libc.a` に
   確かに存在するので、二つはリンク時に衝突します。重複を許すと bionic のものが採られ、それで問題ありま
   せん。
6. **`pwcopy()` で `pw_gecos` を NULL から守る。** bionic の `getpwuid()` は `NULL` の `pw_gecos` を返し
   ます（Android は GECOS フィールドを保持しません）。OpenSSH の `pwcopy()` は `pw_passwd` を `NULL` か
   ら守りますが `pw_gecos` は守らないので、`sftp-server` は `xstrdup(NULL)` に達し、セッションが開いた瞬
   間、起動時に SIGSEGV します。（`scp` はレガシープロトコルでは `pwcopy` を決して呼ばないので、SFTP が
   動かない一方で動いていました。）ビルドは `pwcopy()` にパッチを当てて `pw_gecos` を `""` へ畳み込みま
   す。

ピン留めされたバージョンは `scripts/build-bundles.sh` の先頭にあります（`ZLIB_VERSION`,
`RSYNC_VERSION`, `OPENSSH_VERSION`）。

## 単一の ABI を手で再現する

```sh
git clone --depth 1 --branch "$(cat UPSTREAM_VERSION)" https://github.com/mkj/dropbear /tmp/db
cp patches/localoptions.h /tmp/db/localoptions.h
for p in patches/*.patch; do patch -p1 -d /tmp/db < "$p"; done
cd /tmp/db
TC="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
./configure --host=aarch64-linux-android --disable-zlib --disable-syslog \
    CC="$TC/aarch64-linux-android24-clang"
make PROGRAMS="dropbear dropbearkey" -j"$(nproc)"
file ./dropbear   # -> dynamically linked, interpreter /system/bin/linker64, for Android 24
```

<!-- doc-footer -->

---

> _このドキュメントは Claude (Anthropic) で生成され、VD171 によって保守されています。修正や改善を歓迎します。[CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。_
