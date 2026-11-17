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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../in/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · Українська · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Збірка VD Dropbear

VD Dropbear постачає **[Dropbear](https://github.com/mkj/dropbear) upstream** (тег, закріплений у
[`UPSTREAM_VERSION`](../UPSTREAM_VERSION)) плюс невеликий набір патчів, який можна перевірити, у
[`patches/`](../patches/). CI його збирає; ви можете відтворити це локально.

## Швидкий старт

```sh
# один раз: Android NDK (r27 або новіший)
export NDK=/path/to/android-ndk

# зібрати кожен ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# або лише один, щоб швидко ітерувати
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` клонує закріплений upstream-тег, застосовує `patches/*.patch` і `localoptions.h`, а
потім крос-компілює `vddropbear` і `dropbearkey` до `module/bin/<abi>/`. Результат це **динамічний** ELF
(`file` повідомляє `dynamically linked, interpreter /system/bin/linker64 … for Android 24`), злінкований
із libc bionic, яку вже має кожен пристрій Android. libtomcrypt лишається вбудованим у бінарник;
динамічною є лише бібліотека C. Див. [Динамічний, не static-PIE](#динамічний-не-static-pie).

Бінарники **не комітяться**; їх збирає CI на кожен тег і прикріплює до релізу. Див.
[`.gitignore`](../.gitignore).

---

## Історія crypt()/libcrypto (чому автентифікація за паролем потребувала справжньої роботи)

Автентифікацію за паролем у Dropbear написано для звичайного Unix-хоста з `crypt()` та `/etc/shadow`.
Android **не має жодного з них**, і це стикається зі збіркою у трьох окремих місцях. Цей розділ
документує кожне з них, бо це саме той тип речей, який боляче відкривати заново. Усе це обробляє патч
[`0003-password-file.patch`](../patches/0003-password-file.patch); ніщо нижче не лишено на волю випадку
під час виконання.

### 1. bionic не має придатного `crypt()`

Бібліотека C в Android (bionic) не надає ані `crypt()`, ані `crypt_r()`, ані бази shadow. NDK не
експонує жодного `<crypt.h>`. Тож стандартний шлях пароля в Dropbear, який викликає `crypt(password,
salt)` і порівнює з `/etc/shadow`, просто неможливо зібрати чи запустити на Android. Немає також жодної
`libcrypt` для лінкування, а тягнути `libcrypto` з OpenSSL лише заради хешу пароля було б великою,
незручною залежністю для статичного бінарника.

**Наша відповідь:** взагалі не використовувати `crypt()`. Автентифікація за паролем перевіряє наданий
пароль за допомогою **PBKDF2-HMAC-SHA256** проти файлу хешів (`DROPBEAR_PASSWD_FILE`), публічної,
стандартної, із сіллю, ітеративної KDF. Формат файлу задокументовано в
[`patches/README.md`](../patches/README.md).

### 2. захист часу компіляції в `sysoptions.h`

Ще до того, як виконається будь-який код, Dropbear відмовляється збиратися:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

З невизначеним `HAVE_CRYPT` (завжди, на bionic) і ввімкненою автентифікацією за паролем це жорсткий
`#error`. Оскільки наш верифікатор ніколи не викликає `crypt()`, патч `0003` **видаляє цей захист**.
(Він лишає недоторканою перевірку «має бути ввімкнено щонайменше один метод автентифікації».)

### 3. пастка libtomcrypt: PBKDF2 вирізається при *компіляції*

Dropbear вбудовує урізаний **libtomcrypt**, який *справді* містить PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). Очевидне виправлення це викликати його. Воно не працює, з двох причин, що
накладаються:

- **Прототип прихований.** `pkcs_5_alg2` оголошено лише всередині `#ifdef LTC_PKCS_5` у
  `tomcrypt_pkcs.h`. *Власні* файли джерел Dropbear не компілюються з визначеним `LTC_PKCS_5`, тож
  оголошення невидиме, і компілятор падає з *implicit function declaration*.
- **Символ не існує.** Гірше, саме *тіло* `pkcs_5_alg2` теж за `#ifdef LTC_PKCS_5`. Збірка libtomcrypt у
  Dropbear його не визначає, тож `pkcs_5_2.o` компілюється в **порожній об'єкт**: він у `libtomcrypt.a`,
  але не містить символу `pkcs_5_alg2`. Лінкування падає з `undefined symbol: pkcs_5_alg2`.

Ви можете переконатися в цьому самі:

```sh
# об'єкт існує, але порожній (немає T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> лише маркер даних, немає pkcs_5_alg2

# HMAC, навпаки, скомпільовано повністю (Dropbear використовує його для MAC у SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> визначає hmac_memory
```

**Наша відповідь:** зібрати PBKDF2 самостійно поверх примітивів, які Dropbear *справді* компілює.
`hmac_memory` і зареєстрований хеш `sha256` обидва присутні й лінкуються, тож патч `0003` реалізує
PBKDF2-HMAC-SHA256 напряму (RFC 2898; один 32-байтовий вихідний блок, бо `dkLen == hLen` для SHA-256).
Ми оголошуємо `hmac_memory` самі (та сама проблема прихованого прототипу, що й вище), і об'єкт
витягується з `libtomcrypt.a` під час лінкування. Результат це стандартний PBKDF2, а отже сумісний: хеш,
який WebUI обчислює за допомогою **WebCrypto** `deriveBits` браузера, побайтово ідентичний тому, що
обчислює сервер, перевірено проти `hashlib.pbkdf2_hmac` з Python як третьої, незалежної реалізації.

> **Коротко:** Android не дає вам жодного `crypt()`, а вбудований PBKDF2 Dropbear компілюється в ніщо.
> Автентифікація за паролем тут це PBKDF2-HMAC-SHA256 з нуля поверх HMAC із libtomcrypt, з видаленим
> захистом збірки crypt(). Без OpenSSL/`libcrypto`, без обфускації, без системного shadow.

---

## Динамічний, не static-PIE

Бінарники **динамічні** (злінковані із системним bionic через `/system/bin/linker64`), не статичні. Це
має значення, і це було засвоєно важким шляхом, **на реальному пристрої**, а не в CI:

- Збірка **static-PIE** *виглядає* нормально (`file` повідомляє чистий `static-pie executable`) і
  лінкується без помилки, але **дає SIGSEGV у ту саму мить, коли запускається на пристрої** (перевірено
  на телефоні arm64 з Android 16, exit 139, без корисного tombstone). Статичні виконувані файли на
  Android крихкі; надійна форма це звичайний динамічний бінарник, і саме так постачається кожен усталений
  dropbear для Android.
- Збірка **статична, non-PIE** навіть не запускається: bionic відхиляє її з
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Тож збірка **динамічна** (`make` без `STATIC=1`; `-pie`), лінкуючи лише libc bionic, присутню на
  кожному пристрої. libtomcrypt досі статично вбудований у бінарник, тож немає жодної додаткової
  бібліотеки для постачання.

Урок для тестування: **`qemu-aarch64` (qemu-user) тут не є коректним smoke-тестом** (він теж падає з
segfault на цих бінарниках), як і успішна компіляція+лінкування. **Запускайте бінарник на реальному
пристрої arm64 Android.** (Це було перевірено саме так:
демон було запущено на альтернативному порту на живому пристрої, а вхід за паролем підтверджено як
успішний, з відхиленим хибним паролем.)

## Немає прапорця `-E`

Сервер зібрано з `--disable-syslog`, тож він завжди логує в stderr, а upstream-опція `-E` ("log to
stderr") **не існує** в цьому бінарнику; її передача друкує `Invalid option -E`, і демон ніколи не
запускається. Тому будівник аргументів модуля не передає `-E`.

## openpty

Інтерактивні сесії PTY використовують `openpty()`. bionic оголошує його в `<pty.h>`, а крос-`configure`
Dropbear виявляє його за допомогою NDK (`HAVE_OPENPTY` встановлюється, `HAVE_PTY_H 1`), тож **жодного
патча не потрібно**; PTY працюють одразу. (Неінтерактивне використання, як-от exec, SFTP, rsync і
переадресація портів, від нього все одно не залежить.)

## Вбудовані інструменти: sftp-server, scp, rsync

`scripts/build-bundles.sh` крос-компілює інструменти передавання файлів як динамічні бінарники до
`module/bin/<abi>/`. CI запускає його одразу після `build.sh`.

- **rsync** (із вбудованими popt + zlib) компілюється чисто, щойно ви скажете його configure, що bionic
  не має `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** і **scp** походять з **OpenSSH portable**, зібраних з `--without-openssl` (вбудованої
  криптографії OpenSSH достатньо для цих двох), з малим статичним **zlib**, який цей скрипт збирає
  першим.

OpenSSH на Android такий самий примхливий, як історія crypt() вище, бо його `configure` неправильно
визначає кілька функцій libc при крос-компіляції. Скрипт кодує виправлення; для протоколу, частини такі:

1. **Seed кешу функцій, яких bracує bionic**, але configure гадає, що має їх, щоб натомість компілювалися
   compat-версії: `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Без них `defines.h` OpenSSH
   робить `#define __sentinel__` (порожньо), що потім псує власний `__attribute__((__sentinel__(1)))`
   bionic у `<unistd.h>`, і кожна компіляція падає з `expected ')'`.
3. **compat `explicit_bzero`, що використовує `memset`.** `bzero` bionic це функціеподібний макрос (не
   справжній символ), тож стандартний compat OpenSSH, що бере `&bzero` як вказівник на функцію, не
   компілюється. bionic не має власного `explicit_bzero`.
4. **Відкидання `xcrypt.o` і `getrrsetbyname.o`** з бібліотеки compat. `xcrypt.c` безумовно викликає
   `getpwent()`/`crypt()` (bionic не має жодного), а `getrrsetbyname.c` використовує внутрішні частини
   резолвера, які bionic не експонує. Жодне з них не використовує `sftp-server` чи `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` це дзеркальне відображення функцій з (1):
   bionic не *оголошує* її в API 24, тож OpenSSH компілює власний compat, але **символ** таки є в
   `libc.a`, тож обидва стикаються при лінкуванні. Дозвіл дубліката бере варіант bionic, що нормально.
6. **Захист `pw_gecos` від NULL у `pwcopy()`.** `getpwuid()` bionic повертає `NULL`-овий `pw_gecos`
   (Android не веде поле GECOS). `pwcopy()` OpenSSH захищає `pw_passwd` від `NULL`, але не `pw_gecos`,
   тож `sftp-server` доходить до `xstrdup(NULL)` і дає SIGSEGV при старті, у ту мить, коли відкривається
   сесія. (`scp` через застарілий протокол ніколи не викликає `pwcopy`, тому він працював, поки SFTP
   ні.) Збірка патчить `pwcopy()`, щоб звести `pw_gecos` до `""`.

Закріплені версії є вгорі `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Відтворення одного ABI вручну

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

> _Ця документація створена за допомогою Claude (Anthropic) і підтримується VD171. Виправлення та покращення вітаються; див. [CONTRIBUTING.md](CONTRIBUTING.md)._
