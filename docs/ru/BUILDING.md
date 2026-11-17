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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../in/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · Русский · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Сборка VD Dropbear

VD Dropbear поставляет **[Dropbear](https://github.com/mkj/dropbear) upstream** (тег, закреплённый в
[`UPSTREAM_VERSION`](../UPSTREAM_VERSION)) плюс небольшой проверяемый набор патчей в
[`patches/`](../patches/). CI собирает его; вы можете воспроизвести это локально.

## Быстрый старт

```sh
# один раз: Android NDK (r27 или новее)
export NDK=/path/to/android-ndk

# собрать каждый ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# или только один, чтобы итерировать быстро
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` клонирует закреплённый upstream-тег, применяет `patches/*.patch` и `localoptions.h`, а
затем кросс-компилирует `vddropbear` и `dropbearkey` в `module/bin/<abi>/`. Результат это
**динамический** ELF (`file` сообщает `dynamically linked, interpreter /system/bin/linker64 … for Android
24`), слинкованный с libc bionic, которая уже есть на каждом устройстве Android. libtomcrypt остаётся
встроенным в бинарник; динамической является только библиотека C. См. [Динамический, не static-PIE](#динамический-не-static-pie).

Бинарники **не коммитятся**; их собирает CI при каждом теге и прикрепляет к релизу. См.
[`.gitignore`](../.gitignore).

---

## История crypt()/libcrypto (почему аутентификация по паролю потребовала реальной работы)

Аутентификация по паролю в Dropbear написана для обычного Unix-хоста с `crypt()` и `/etc/shadow`. В
Android **нет ни того, ни другого**, и это сталкивается со сборкой в трёх отдельных местах. Этот раздел
документирует каждое из них, потому что это именно тот тип вещей, который больно открывать заново. Всё
это обрабатывает патч [`0003-password-file.patch`](../patches/0003-password-file.patch); ничто ниже не
оставлено на волю случая во время выполнения.

### 1. в bionic нет пригодного `crypt()`

Библиотека C в Android (bionic) не предоставляет ни `crypt()`, ни `crypt_r()`, ни базу shadow. NDK не
предоставляет никакого `<crypt.h>`. Поэтому стандартный путь пароля в Dropbear, который вызывает
`crypt(password, salt)` и сравнивает с `/etc/shadow`, просто невозможно собрать или запустить на Android.
Нет также никакой `libcrypt` для линковки, а тянуть `libcrypto` из OpenSSL только ради хеша пароля было
бы крупной, неуклюжей зависимостью для статического бинарника.

**Наш ответ:** вообще не использовать `crypt()`. Аутентификация по паролю проверяет предъявленный пароль
с помощью **PBKDF2-HMAC-SHA256** против файла хешей (`DROPBEAR_PASSWD_FILE`), публичной, стандартной, с
солью, итеративной KDF. Формат файла задокументирован в [`patches/README.md`](../patches/README.md).

### 2. защита на этапе компиляции в `sysoptions.h`

Ещё до того, как выполнится какой-либо код, Dropbear отказывается собираться:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

При неопределённом `HAVE_CRYPT` (всегда, на bionic) и включённой аутентификации по паролю это жёсткий
`#error`. Поскольку наш верификатор никогда не вызывает `crypt()`, патч `0003` **удаляет эту защиту**.
(Он оставляет нетронутой проверку «должен быть включён хотя бы один метод аутентификации».)

### 3. ловушка libtomcrypt: PBKDF2 вырезается при *компиляции*

Dropbear встраивает урезанный **libtomcrypt**, который *действительно* содержит PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). Очевидное решение это вызвать его. Оно не работает, по двум усиливающим
друг друга причинам:

- **Прототип скрыт.** `pkcs_5_alg2` объявлен только внутри `#ifdef LTC_PKCS_5` в `tomcrypt_pkcs.h`.
  *Собственные* исходные файлы Dropbear не компилируются с определённым `LTC_PKCS_5`, поэтому объявление
  невидимо, и компилятор падает с *implicit function declaration*.
- **Символа не существует.** Хуже того, само *тело* `pkcs_5_alg2` тоже находится за `#ifdef
  LTC_PKCS_5`. Сборка libtomcrypt в Dropbear его не определяет, поэтому `pkcs_5_2.o` компилируется в
  **пустой объект**: он есть в `libtomcrypt.a`, но не содержит символа `pkcs_5_alg2`. Линковка падает с
  `undefined symbol: pkcs_5_alg2`.

Вы можете убедиться в этом сами:

```sh
# объект существует, но пуст (нет T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> только маркер данных, нет pkcs_5_alg2

# HMAC, напротив, скомпилирован полностью (Dropbear использует его для MAC в SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> определяет hmac_memory
```

**Наш ответ:** собрать PBKDF2 самим поверх примитивов, которые Dropbear *действительно* компилирует.
`hmac_memory` и зарегистрированный хеш `sha256` оба присутствуют и линкуются, поэтому патч `0003`
реализует PBKDF2-HMAC-SHA256 напрямую (RFC 2898; один 32-байтовый выходной блок, поскольку `dkLen ==
hLen` для SHA-256). Мы объявляем `hmac_memory` сами (та же проблема скрытого прототипа, что и выше), и
объект вытягивается из `libtomcrypt.a` при линковке. Результат это стандартный PBKDF2, а значит
совместимый: хеш, который WebUI вычисляет с помощью **WebCrypto** `deriveBits` браузера, побайтово
идентичен тому, что вычисляет сервер, проверено против `hashlib.pbkdf2_hmac` из Python как третьей,
независимой реализации.

> **Коротко:** Android не даёт вам никакого `crypt()`, а встроенный PBKDF2 Dropbear компилируется в
> ничто. Аутентификация по паролю здесь это PBKDF2-HMAC-SHA256 с нуля поверх HMAC из libtomcrypt, с
> удалённой защитой сборки crypt(). Без OpenSSL/`libcrypto`, без обфускации, без системного shadow.

---

## Динамический, не static-PIE

Бинарники **динамические** (слинкованы с системным bionic через `/system/bin/linker64`), не статические.
Это важно, и это было усвоено трудным путём, **на реальном устройстве**, а не в CI:

- Сборка **static-PIE** *выглядит* нормально (`file` сообщает чистый `static-pie executable`) и линкуется
  без ошибок, но **выдаёт SIGSEGV в тот же миг, как запускается на устройстве** (проверено на телефоне
  arm64 с Android 16, exit 139, без полезного tombstone). Статические исполняемые файлы на Android
  хрупки; надёжная форма это обычный динамический бинарник, и именно так поставляется каждый устоявшийся
  dropbear для Android.
- Сборка **статическая, non-PIE** даже не запускается: bionic отклоняет её с
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Поэтому сборка **динамическая** (`make` без `STATIC=1`; `-pie`), линкующая только libc bionic,
  присутствующую на каждом устройстве. libtomcrypt по-прежнему статически встроен в бинарник, так что нет
  никакой дополнительной библиотеки для поставки.

Урок для тестирования: **`qemu-aarch64` (qemu-user) здесь не является корректным smoke-тестом** (он тоже
падает с segfault на этих бинарниках), как и успешная компиляция+линковка. **Запускайте бинарник на
реальном устройстве arm64 Android.** (Это было проверено именно так: демон был запущен на альтернативном порту на живом устройстве, и вход по паролю
был подтверждён как успешный, а неверный пароль отклонён.)

## Нет флага `-E`

Сервер собран с `--disable-syslog`, поэтому он всегда логирует в stderr, и upstream-опция `-E` ("log to
stderr") **отсутствует** в этом бинарнике; её передача печатает `Invalid option -E`, и демон никогда не
запускается. Поэтому построитель аргументов модуля не передаёт `-E`.

## openpty

Интерактивные сессии PTY используют `openpty()`. bionic объявляет его в `<pty.h>`, а кросс-`configure`
Dropbear обнаруживает его с помощью NDK (`HAVE_OPENPTY` устанавливается, `HAVE_PTY_H 1`), поэтому
**никакой патч не нужен**; PTY работают сразу. (Неинтерактивное использование вроде exec, SFTP, rsync и
проброса портов от него всё равно не зависит.)

## Встроенные инструменты: sftp-server, scp, rsync

`scripts/build-bundles.sh` кросс-компилирует инструменты передачи файлов как динамические бинарники в
`module/bin/<abi>/`. CI запускает его сразу после `build.sh`.

- **rsync** (со встроенными popt + zlib) компилируется чисто, как только вы сообщаете его configure, что
  в bionic нет `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** и **scp** берутся из **OpenSSH portable**, собранных с `--without-openssl` (встроенной
  криптографии OpenSSH достаточно для этих двух), с небольшим статическим **zlib**, который этот скрипт
  собирает первым.

OpenSSH на Android так же капризен, как история crypt() выше, потому что его `configure` неправильно
определяет несколько функций libc при кросс-компиляции. Скрипт кодирует исправление; для протокола,
части таковы:

1. **Seed кеша функций, которых нет в bionic**, но которые configure считает имеющимися, чтобы вместо
   них компилировались compat-версии: `recallocarray`, `close_range`, `getentropy`, `getrandom`,
   `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Без них `defines.h` OpenSSH делает
   `#define __sentinel__` (пусто), что затем портит собственный `__attribute__((__sentinel__(1)))`
   bionic в `<unistd.h>`, и каждая компиляция падает с `expected ')'`.
3. **compat `explicit_bzero`, использующий `memset`.** `bzero` в bionic это функциеподобный макрос (не
   настоящий символ), поэтому стандартный compat OpenSSH, берущий `&bzero` как указатель на функцию, не
   компилируется. В bionic нет собственного `explicit_bzero`.
4. **Отбрасывание `xcrypt.o` и `getrrsetbyname.o`** из библиотеки compat. `xcrypt.c` безусловно вызывает
   `getpwent()`/`crypt()` (в bionic нет ни того, ни другого), а `getrrsetbyname.c` использует внутренние
   части резолвера, которые bionic не предоставляет. Ни то, ни другое не используется `sftp-server` или
   `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` это зеркальное отражение функций из (1): bionic
   не *объявляет* её в API 24, поэтому OpenSSH компилирует собственный compat, но **символ** всё же есть
   в `libc.a`, так что при линковке они сталкиваются. Разрешение дубликата берёт вариант из bionic, что
   нормально.
6. **Защита `pw_gecos` от NULL в `pwcopy()`.** `getpwuid()` из bionic возвращает `NULL`-овый `pw_gecos`
   (Android не хранит поле GECOS). `pwcopy()` из OpenSSH защищает `pw_passwd` от `NULL`, но не
   `pw_gecos`, поэтому `sftp-server` доходит до `xstrdup(NULL)` и выдаёт SIGSEGV при старте, в тот миг,
   когда открывается сессия. (`scp` по устаревшему протоколу никогда не вызывает `pwcopy`, поэтому он
   работал, пока SFTP нет.) Сборка патчит `pwcopy()`, чтобы свести `pw_gecos` к `""`.

Закреплённые версии находятся вверху `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Воспроизведение одного ABI вручную

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

> _Эта документация создана с помощью Claude (Anthropic) и поддерживается VD171. Исправления и улучшения приветствуются; см. [CONTRIBUTING.md](CONTRIBUTING.md)._
