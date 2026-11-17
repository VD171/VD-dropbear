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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · فارسی · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../in/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# ساخت VD Dropbear

‏VD Dropbear نسخهٔ **[Dropbear](https://github.com/mkj/dropbear) اصلی (upstream)** را (تگ پین‌شده در
[`UPSTREAM_VERSION`](../UPSTREAM_VERSION)) به‌همراه مجموعهٔ کوچک و قابل‌ممیزی وصله‌ها در
[`patches/`](../patches/) عرضه می‌کند. CI آن را می‌سازد؛ می‌توانید آن را به‌صورت محلی بازتولید کنید.

## شروع سریع

```sh
# یک‌بار: یک Android NDK (نسخهٔ r27 یا جدیدتر)
export NDK=/path/to/android-ndk

# هر ABI را بساز (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# یا فقط یکی، برای تکرار سریع
ABIS="arm64-v8a" ./scripts/build.sh
```

‏`scripts/build.sh` تگ upstream پین‌شده را کلون می‌کند، `patches/*.patch` و `localoptions.h` را اعمال
می‌کند، سپس `vddropbear` و `dropbearkey` را به‌صورت متقاطع به `module/bin/<abi>/` کامپایل می‌کند. خروجی یک
ELF **پویا** است (`file` گزارش می‌دهد `dynamically linked, interpreter /system/bin/linker64 … for Android
24`)، که به libc bionic که هر دستگاه اندرویدی از پیش دارد لینک شده است. libtomcrypt درون باینری جاسازی
می‌ماند؛ تنها کتابخانهٔ C پویاست. ببینید [پویا، نه static-PIE](#پویا-نه-static-pie).

باینری‌ها **کامیت نمی‌شوند**؛ در هر تگ توسط CI ساخته و به ریلیز پیوست می‌شوند. ببینید
[`.gitignore`](../.gitignore).

---

## داستان crypt()/libcrypto (چرا احراز هویت با گذرواژه کار واقعی می‌طلبید)

احراز هویت با گذرواژهٔ Dropbear برای یک میزبان یونیکس معمولی با `crypt()` و `/etc/shadow` نوشته شده است.
اندروید **هیچ‌کدام را ندارد**، و این در سه جای جداگانه با ساخت تداخل می‌کند. این بخش هر یک از آن‌ها را
مستند می‌کند، زیرا دقیقاً از آن نوع چیزهایی است که کشف دوبارهٔ آن دردناک است. همهٔ این‌ها را وصلهٔ
[`0003-password-file.patch`](../patches/0003-password-file.patch) مدیریت می‌کند؛ هیچ‌چیزِ زیر در زمان اجرا
به شانس واگذار نشده است.

### ۱. bionic یک `crypt()` قابل‌استفاده ندارد

کتابخانهٔ C اندروید (bionic) نه `crypt()`، نه `crypt_r()` و نه یک پایگاه‌دادهٔ shadow را فراهم می‌کند. NDK
هیچ `<crypt.h>` را در دسترس نمی‌گذارد. پس مسیر استاندارد گذرواژهٔ Dropbear، که `crypt(password, salt)` را
فرا می‌خواند و با `/etc/shadow` مقایسه می‌کند، به‌سادگی روی اندروید نه قابل ساخت است و نه قابل اجرا.
همچنین هیچ `libcrypt` برای لینک‌شدن وجود ندارد، و کشیدن `libcrypto` از OpenSSL فقط برای یک هش گذرواژه
وابستگی بزرگ و ناجوری برای یک باینری ایستا خواهد بود.

**پاسخ ما:** اصلاً از `crypt()` استفاده نکنیم. احراز هویت با گذرواژه، گذرواژهٔ ارائه‌شده را با
**PBKDF2-HMAC-SHA256** در برابر یک فایل هش (`DROPBEAR_PASSWD_FILE`) راستی‌آزمایی می‌کند؛ یک KDF عمومی،
استاندارد، نمک‌دار و تکرارشونده. قالب فایل در [`patches/README.md`](../patches/README.md) مستند شده است.

### ۲. نگهبان زمان کامپایل در `sysoptions.h`

حتی پیش از آنکه هیچ کدی اجرا شود، Dropbear از ساخت سر باز می‌زند:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

با تعریف‌نشدن `HAVE_CRYPT` (همیشه، روی bionic) و فعال‌بودن احراز هویت با گذرواژه، این یک `#error` سخت است.
چون راستی‌آزمای ما هرگز `crypt()` را فرا نمی‌خواند، وصلهٔ `0003` **این نگهبان را حذف می‌کند**. (بررسی
«دست‌کم یک روش احراز هویت باید فعال باشد» را دست‌نخورده باقی می‌گذارد.)

### ۳. تلهٔ libtomcrypt: PBKDF2 در *کامپایل* بیرون گذاشته می‌شود

‏Dropbear یک **libtomcrypt** پیراسته را جاسازی می‌کند که *واقعاً* شامل PBKDF2 است (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). راه‌حل بدیهی فراخواندن آن است. کار نمی‌کند، به دو دلیلِ هم‌افزا:

- **پروتوتایپ پنهان است.** `pkcs_5_alg2` تنها درون `#ifdef LTC_PKCS_5` در `tomcrypt_pkcs.h` اعلام شده است.
  فایل‌های منبعِ *خودِ* Dropbear با تعریفِ `LTC_PKCS_5` کامپایل نمی‌شوند، پس اعلان نامرئی است و کامپایلر با
  خطای *implicit function declaration* شکست می‌خورد.
- **نماد وجود ندارد.** بدتر آنکه خودِ *بدنهٔ* `pkcs_5_alg2` هم پشت `#ifdef LTC_PKCS_5` است. ساختِ
  libtomcrypt در Dropbear آن را تعریف نمی‌کند، پس `pkcs_5_2.o` به یک **شیء خالی** کامپایل می‌شود: در
  `libtomcrypt.a` هست، اما هیچ نماد `pkcs_5_alg2` ندارد. لینک با `undefined symbol: pkcs_5_alg2` شکست
  می‌خورد.

می‌توانید خودتان این را ببینید:

```sh
# شیء وجود دارد اما خالی است (بدون T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> فقط یک نشانگر داده، بدون pkcs_5_alg2

# در مقابل، HMAC به‌طور کامل کامپایل شده است (Dropbear از آن برای MACهای SSH استفاده می‌کند):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> hmac_memory را تعریف می‌کند
```

**پاسخ ما:** ساختِ خودِ PBKDF2 روی ابتداییاتی که Dropbear *واقعاً* کامپایل می‌کند. هم `hmac_memory` و هم
هشِ ثبت‌شدهٔ `sha256` موجود و قابل‌لینک‌اند، پس وصلهٔ `0003` مستقیماً PBKDF2-HMAC-SHA256 را پیاده‌سازی
می‌کند (RFC 2898؛ یک بلوک خروجی ۳۲ بایتی، چون `dkLen == hLen` برای SHA-256). ما خودمان `hmac_memory` را
اعلام می‌کنیم (همان مشکل پروتوتایپ پنهانِ بالا) و شیء هنگام لینک از `libtomcrypt.a` کشیده می‌شود. نتیجه
PBKDF2 استاندارد و در نتیجه قابل‌تعامل است: هشی که WebUI با **WebCrypto** `deriveBits` مرورگر محاسبه
می‌کند، بایت‌به‌بایت با آنچه سرور محاسبه می‌کند یکسان است، و در برابر `hashlib.pbkdf2_hmac` پایتون به‌عنوان
یک پیاده‌سازی سومِ مستقل راستی‌آزمایی شده است.

> **خلاصه:** اندروید هیچ `crypt()` به شما نمی‌دهد، و PBKDF2 جاسازی‌شدهٔ Dropbear به هیچ کامپایل می‌شود.
> احراز هویت با گذرواژه اینجا یک PBKDF2-HMAC-SHA256 از پایه روی HMAC از libtomcrypt است، با حذف نگهبان
> ساختِ crypt(). بدون OpenSSL/`libcrypto`، بدون مبهم‌سازی، بدون shadow سیستمی.

---

## پویا، نه static-PIE

باینری‌ها **پویا** هستند (از طریق `/system/bin/linker64` به bionic سیستم لینک شده‌اند)، نه ایستا. این مهم
است، و به سختی آموخته شد، **روی یک دستگاه واقعی**، نه در CI:

- یک ساختِ **static-PIE** *به‌ظاهر* خوب است (`file` یک `static-pie executable` تمیز گزارش می‌دهد) و بدون
  خطا لینک می‌شود، اما **در همان لحظه که روی دستگاه اجرا می‌شود SIGSEGV می‌دهد** (روی یک گوشیِ arm64 با
  Android 16 راستی‌آزمایی شد، exit 139، بدون tombstone مفید). فایل‌های اجراییِ ایستا روی اندروید شکننده‌اند؛
  شکل قابل‌اعتماد یک باینری پویایِ معمولی است، که همان شیوهٔ عرضهٔ هر dropbear جاافتادهٔ اندروید هم هست.
- یک ساختِ **ایستای غیر PIE** حتی شروع نمی‌شود: bionic آن را با
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic` رد می‌کند.
- پس ساخت **پویا** است (`make` بدون `STATIC=1`؛ `-pie`)، که تنها libc bionic را لینک می‌کند که روی هر
  دستگاهی حاضر است. libtomcrypt همچنان به‌صورت ایستا درون باینری جاسازی است، پس هیچ کتابخانهٔ اضافی برای
  عرضه وجود ندارد.

درس برای آزمون: **`qemu-aarch64` (qemu-user) اینجا یک smoke test معتبر نیست** (آن هم روی این باینری‌ها
segfault می‌دهد)، و یک کامپایل+لینکِ موفق هم نیست. **باینری را روی یک دستگاه واقعیِ arm64 اندروید اجرا
کنید.** (این دقیقاً به همین روش راستی‌آزمایی شد: daemon روی یک
پورت جایگزین روی یک دستگاه زنده راه‌اندازی شد و ورود با گذرواژه موفق تأیید شد، در حالی که گذرواژهٔ اشتباه
رد شد.)

## بدون پرچم `-E`

سرور با `--disable-syslog` ساخته می‌شود، پس همیشه در stderr لاگ می‌گیرد و گزینهٔ upstream به نام `-E`
(«log to stderr») در این باینری **وجود ندارد**؛ دادنِ آن `Invalid option -E` چاپ می‌کند و daemon هرگز
آغاز نمی‌شود. از این رو سازندهٔ آرگومان‌های ماژول `-E` را پاس نمی‌دهد.

## openpty

نشست‌های تعاملی PTY از `openpty()` استفاده می‌کنند. bionic آن را در `<pty.h>` اعلام می‌کند، و `configure`
متقاطع Dropbear آن را با NDK تشخیص می‌دهد (`HAVE_OPENPTY` تنظیم می‌شود، `HAVE_PTY_H 1`)، پس **هیچ وصله‌ای
لازم نیست**؛ PTYها بی‌درنگ کار می‌کنند. (استفادهٔ غیرتعاملی مانند exec، SFTP، rsync و فورواردِ پورت به‌هر‌حال
به آن وابسته نیست.)

## ابزارهای جاسازی‌شده: sftp-server، scp، rsync

‏`scripts/build-bundles.sh` ابزارهای انتقال فایل را به‌صورت باینری‌های پویا به `module/bin/<abi>/` به‌طور
متقاطع کامپایل می‌کند. CI آن را درست پس از `build.sh` اجرا می‌کند.

- **rsync** (با popt + zlib جاسازی‌شده) به‌محض اینکه به `configure` آن بگویید bionic فاقد `lutimes` است
  (`ac_cv_func_lutimes=no`) تمیز کامپایل می‌شود.
- **sftp-server** و **scp** از **OpenSSH portable** می‌آیند، ساخته‌شده با `--without-openssl` (رمزنگاری
  داخلی OpenSSH برای این دو کافی است)، با یک **zlib** ایستای کوچک که این اسکریپت ابتدا آن را می‌سازد.

‏OpenSSH روی اندروید به‌اندازهٔ داستان crypt() بالا نُک‌و‌مُک است، چون `configure` آن هنگام کامپایل متقاطع
چند تابع libc را اشتباه تشخیص می‌دهد. اسکریپت این اصلاح را کدگذاری می‌کند؛ برای ثبت، اجزا این‌هاست:

۱. **یک seed کش از توابعی که bionic ندارد** اما configure گمان می‌کند دارد، تا به‌جای آن‌ها نسخه‌های compat
   کامپایل شوند: `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
۲. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** بدون آن‌ها، `defines.h` در OpenSSH
   دستور `#define __sentinel__` (خالی) را می‌زند، که سپس `__attribute__((__sentinel__(1)))` خودِ bionic
   را در `<unistd.h>` خراب می‌کند و هر کامپایل با `expected ')'` شکست می‌خورد.
۳. **یک compat برای `explicit_bzero` که از `memset` استفاده می‌کند.** `bzero` در bionic یک ماکرو
   تابع‌مانند است (نه یک نماد واقعی)، پس compat پیش‌فرض OpenSSH که `&bzero` را به‌عنوان اشاره‌گر تابع
   می‌گیرد کامپایل نمی‌شود. bionic یک `explicit_bzero` از آنِ خود ندارد.
۴. **کنارگذاشتن `xcrypt.o` و `getrrsetbyname.o`** از کتابخانهٔ compat. `xcrypt.c` بدون شرط
   `getpwent()`/`crypt()` را فرا می‌خواند (bionic هیچ‌کدام را ندارد)، و `getrrsetbyname.c` از درونیات
   resolver استفاده می‌کند که bionic در دسترس نمی‌گذارد. هیچ‌کدام توسط `sftp-server` یا `scp` استفاده
   نمی‌شوند.
۵. **`-Wl,--allow-multiple-definition`.** `reallocarray` تصویر آینه‌ایِ توابع بندِ (۱) است: bionic آن را
   در API 24 *اعلام نمی‌کند*، پس OpenSSH compat خودش را کامپایل می‌کند، اما **نماد** به‌هرحال در `libc.a`
   وجود دارد، پس این دو هنگام لینک تصادم می‌کنند. اجازه‌دادن به تکرار نسخهٔ bionic را برمی‌گزیند، که خوب
   است.
۶. **محافظت `pw_gecos` در برابر NULL در `pwcopy()`.** `getpwuid()` در bionic یک `pw_gecos` برابر `NULL`
   برمی‌گرداند (اندروید فیلد GECOS نگه نمی‌دارد). `pwcopy()` در OpenSSH `pw_passwd` را در برابر `NULL`
   محافظت می‌کند اما نه `pw_gecos` را، پس `sftp-server` به `xstrdup(NULL)` می‌رسد و هنگام آغاز، در همان
   لحظه که نشستی باز می‌شود، SIGSEGV می‌دهد. (`scp` روی پروتکل قدیمی هرگز `pwcopy` را فرا نمی‌خواند، و
   برای همین کار می‌کرد در حالی که SFTP نمی‌کرد.) ساخت `pwcopy()` را وصله می‌زند تا `pw_gecos` را به `""`
   هم‌پوشان کند.

نسخه‌های پین‌شده در بالای `scripts/build-bundles.sh` قرار دارند (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## بازتولید یک ABI به‌صورت دستی

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

> _این مستندات با Claude (Anthropic) تولید شده و توسط VD171 نگهداری می‌شود. اصلاحات و بهبودها خوش‌آمد است؛ به [CONTRIBUTING.md](CONTRIBUTING.md) مراجعه کنید._
