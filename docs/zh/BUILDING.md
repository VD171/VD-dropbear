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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · 中文

---

# 构建 VD Dropbear

VD Dropbear 交付 **[Dropbear](https://github.com/mkj/dropbear) 上游（upstream）**（固定在
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION) 中的标签），外加 [`patches/`](../../patches/) 中那套小而可审计的补
丁集。CI 会构建它；你可以在本地复现。

## 快速开始

```sh
# 一次性：一个 Android NDK（r27 或更新）
export NDK=/path/to/android-ndk

# 构建每个 ABI（arm64-v8a armeabi-v7a x86 x86_64）
./scripts/build.sh

# 或只构建一个，便于快速迭代
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` 克隆固定的上游标签，应用 `patches/*.patch` 和 `localoptions.h`，然后将 `vddropbear`
和 `dropbearkey` 交叉编译到 `module/bin/<abi>/`。输出是一个 **动态** ELF（`file` 报告
`dynamically linked, interpreter /system/bin/linker64 … for Android 24`），链接到每台 Android 设备都已
具备的 bionic libc。libtomcrypt 仍嵌入在二进制内部；只有 C 库是动态的。参见
[动态，而非 static-PIE](#动态而非-static-pie)。

二进制 **不被提交**；它们由 CI 在每个标签上构建并附加到发布。参见 [`.gitignore`](../../.gitignore)。

---

## crypt()/libcrypto 的故事（为什么密码认证需要真正的工作）

Dropbear 的密码认证是为具备 `crypt()` 和 `/etc/shadow` 的普通 Unix 主机编写的。Android **两者都没有**，
这在三个独立之处与构建相冲突。本节记录其中每一处，因为这正是那种重新发现起来令人痛苦的东西。这一切都由
补丁 [`0003-password-file.patch`](../../patches/0003-password-file.patch) 处理；以下内容在运行时没有任何一
项听天由命。

### 1. bionic 没有可用的 `crypt()`

Android 的 C 库（bionic）既不提供 `crypt()`，也不提供 `crypt_r()`，也没有 shadow 数据库。NDK 不暴露任何
`<crypt.h>`。因此 Dropbear 的标准密码路径（调用 `crypt(password, salt)` 并与 `/etc/shadow` 比较）在
Android 上根本无法构建或运行。也没有可链接的 `libcrypt`，而仅为一个密码哈希就拉入 OpenSSL 的 `libcrypto`
对一个静态二进制来说将是一个庞大而笨拙的依赖。

**我们的答案：** 根本不使用 `crypt()`。密码认证使用 **PBKDF2-HMAC-SHA256** 针对一个哈希文件
（`DROPBEAR_PASSWD_FILE`）来校验所提交的密码，这是一个公开、标准、加盐、迭代的 KDF。文件格式记录在
[`patches/README.md`](../../patches/README.md) 中。

### 2. `sysoptions.h` 中的编译期守卫

甚至在任何代码运行之前，Dropbear 就拒绝构建：

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

在 `HAVE_CRYPT` 未定义（在 bionic 上始终如此）且密码认证启用时，这是一个硬性 `#error`。由于我们的校验器
从不调用 `crypt()`，补丁 `0003` **移除了这个守卫**。（它保留「至少必须启用一种认证方式」的检查不动。）

### 3. libtomcrypt 的陷阱：PBKDF2 在编译中被*剔除*

Dropbear 嵌入了一个精简的 **libtomcrypt**，其中*确实*包含 PBKDF2（`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`）。显而易见的修复是调用它。它行不通，出于两个叠加的原因：

- **原型被隐藏。** `pkcs_5_alg2` 仅在 `tomcrypt_pkcs.h` 中的 `#ifdef LTC_PKCS_5` 内部声明。Dropbear *自己
  的* 源文件并非在定义了 `LTC_PKCS_5` 的情况下编译，所以声明不可见，编译器以 *implicit function
  declaration* 失败。
- **符号不存在。** 更糟的是，`pkcs_5_alg2` 的*函数体*本身也在 `#ifdef LTC_PKCS_5` 之后。Dropbear 的
  libtomcrypt 构建没有定义它，所以 `pkcs_5_2.o` 编译为一个 **空对象**：它在 `libtomcrypt.a` 中，却不包含
  任何 `pkcs_5_alg2` 符号。链接以 `undefined symbol: pkcs_5_alg2` 失败。

你可以自己看到这一点：

```sh
# 对象存在但为空（没有 T pkcs_5_alg2）：
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> 只有一个数据标记，没有 pkcs_5_alg2

# 相比之下，HMAC 被完整编译（Dropbear 用它来做 SSH 的 MAC）：
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> 定义 hmac_memory
```

**我们的答案：** 在 Dropbear *确实*编译的原语之上自行构建 PBKDF2。`hmac_memory` 和已注册的 `sha256` 哈
希两者都存在且可链接，所以补丁 `0003` 直接实现 PBKDF2-HMAC-SHA256（RFC 2898；单个 32 字节输出块，因为对
SHA-256 而言 `dkLen == hLen`）。我们自己声明 `hmac_memory`（与上文相同的隐藏原型问题），对象在链接时从
`libtomcrypt.a` 拉取。结果是标准的 PBKDF2，因而可互操作：WebUI 用浏览器的 **WebCrypto** `deriveBits` 计
算的哈希与服务器计算的逐字节一致，并针对 Python 的 `hashlib.pbkdf2_hmac` 作为第三个独立实现得到验证。

> **简言之：** Android 不给你任何 `crypt()`，而 Dropbear 嵌入的 PBKDF2 被编译为乌有。这里的密码认证是在
> libtomcrypt 的 HMAC 之上从零构建的 PBKDF2-HMAC-SHA256，并移除了 crypt() 构建守卫。没有
> OpenSSL/`libcrypto`，没有混淆，没有系统 shadow。

---

## 动态，而非 static-PIE

二进制是 **动态的**（通过 `/system/bin/linker64` 链接到系统的 bionic），而非静态的。这很重要，而且是**在
真实设备上**、而非在 CI 中艰难地学到的：

- 一个 **static-PIE** 构建*看起来*没问题（`file` 报告一个干净的 `static-pie executable`）且无错链接，但
  **一旦在设备上运行就 SIGSEGV**（在一台 arm64 Android 16 手机上验证，exit 139，没有有用的 tombstone）。
  Android 上的静态可执行文件很脆弱；可靠的形式是普通的动态二进制，这也是每一个成熟的 Android dropbear 的
  交付方式。
- 一个 **静态、非 PIE** 构建甚至无法启动：bionic 以
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic` 拒绝它。
- 所以构建是 **动态的**（不带 `STATIC=1` 的 `make`；`-pie`），只链接每台设备都有的 bionic libc。
  libtomcrypt 仍然静态嵌入在二进制中，所以没有额外的库需要交付。

测试的教训：**`qemu-aarch64`（qemu-user）在这里不是有效的冒烟测试**（它在这些二进制上也会 segfault），
一次成功的 compile+link 也不是。**在真实的 arm64 Android 设备上运行该二进制。**（这正是以这种方式验证的：在一台在用设备的备用端口上启动守护进程，确认密码登录成功，且错误密
码被拒绝。）

## 没有 `-E` 标志

服务器以 `--disable-syslog` 构建，所以它总是记录到 stderr，而上游的 `-E`（「log to stderr」）选项在此二进
制中 **不存在**；传入它会打印 `Invalid option -E` 且守护进程永不启动。因此模块的参数构建器不传入 `-E`。

## openpty

交互式 PTY 会话使用 `openpty()`。bionic 在 `<pty.h>` 中声明它，而 Dropbear 的交叉 `configure` 以 NDK 检测
到它（`HAVE_OPENPTY` 被设置，`HAVE_PTY_H 1`），所以 **无需任何补丁**；PTY 开箱即用。（像 exec、SFTP、
rsync 和端口转发这样的非交互式用法反正也不依赖它。）

## 内置工具：sftp-server、scp、rsync

`scripts/build-bundles.sh` 将文件传输工具作为动态二进制交叉编译到 `module/bin/<abi>/`。CI 在 `build.sh`
之后立即运行它。

- **rsync**（带内置的 popt + zlib）一旦你告诉它的 configure bionic 没有 `lutimes`
  （`ac_cv_func_lutimes=no`），就能干净地编译。
- **sftp-server** 和 **scp** 来自 **OpenSSH portable**，以 `--without-openssl` 构建（OpenSSH 内置的加密
  对这两者足够），并带有一个此脚本先行构建的小型静态 **zlib**。

Android 上的 OpenSSH 与上面的 crypt() 故事一样挑剔，因为它的 `configure` 在交叉编译时错误地检测了若干
libc 函数。脚本把修复编码其中；以作记录，各部分是：

1. **一组 bionic 缺失但 configure 以为存在的函数的缓存 seed**，以便改为编译 compat 版本：`recallocarray`,
   `close_range`, `getentropy`, `getrandom`, `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`,
   `futimes`, `lutimes`, `strtonum`, `pledge`, `explicit_bzero`。
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`。** 没有它们，OpenSSH 的 `defines.h`
   会做 `#define __sentinel__`（为空），这随后会破坏 `<unistd.h>` 中 bionic 自己的
   `__attribute__((__sentinel__(1)))`，使每次编译都以 `expected ')'` 失败。
3. **一个使用 `memset` 的 `explicit_bzero` compat。** bionic 的 `bzero` 是一个类函数宏（不是真正的符号），
   所以 OpenSSH 把 `&bzero` 当作函数指针的默认 compat 无法编译。bionic 没有自己的 `explicit_bzero`。
4. **从 compat 库中丢弃 `xcrypt.o` 和 `getrrsetbyname.o`。** `xcrypt.c` 无条件调用 `getpwent()`/`crypt()`
   （bionic 两者都没有），而 `getrrsetbyname.c` 使用 bionic 不暴露的 resolver 内部。两者都不被 `sftp-server`
   或 `scp` 使用。
5. **`-Wl,--allow-multiple-definition`。** `reallocarray` 是 (1) 中函数的镜像：bionic 在 API 24 不*声明*它，
   所以 OpenSSH 编译自己的 compat，但 **符号** 确实存在于 `libc.a` 中，所以两者在链接时冲突。允许重复会取
   bionic 的那个，这没问题。
6. **在 `pwcopy()` 中对 `pw_gecos` 做 NULL 保护。** bionic 的 `getpwuid()` 返回一个 `NULL` 的 `pw_gecos`
   （Android 不保留 GECOS 字段）。OpenSSH 的 `pwcopy()` 对 `pw_passwd` 做 `NULL` 保护却不对 `pw_gecos`，所
   以 `sftp-server` 到达 `xstrdup(NULL)` 并在启动时、会话打开的那一刻 SIGSEGV。（`scp` 在旧式协议下从不调用
   `pwcopy`，这就是为什么它能用而 SFTP 不能。）构建对 `pwcopy()` 打补丁，把 `pw_gecos` 合并为 `""`。

固定的版本位于 `scripts/build-bundles.sh` 的顶部（`ZLIB_VERSION`、`RSYNC_VERSION`、`OPENSSH_VERSION`）。

## 手动复现单个 ABI

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

> _本文档由 Claude (Anthropic) 生成，并由 VD171 维护。欢迎修正和改进；请参阅 [CONTRIBUTING.md](CONTRIBUTING.md)。_
