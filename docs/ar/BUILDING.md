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

> **Languages:** [English](../BUILDING.md) · العربية · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# بناء VD Dropbear

يوفّر VD Dropbear نسخة **[Dropbear](https://github.com/mkj/dropbear) الأصلية (upstream)** (الوسم المثبّت في
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION)) إضافة إلى مجموعة الرقع الصغيرة القابلة للتدقيق في
[`patches/`](../../patches/). يبنيه الـ CI؛ ويمكنك إعادة إنتاجه محليًا.

## بداية سريعة

```sh
# مرة واحدة: Android NDK (الإصدار r27 أو أحدث)
export NDK=/path/to/android-ndk

# ابنِ كل ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# أو واحدًا فقط، للتكرار السريع
ABIS="arm64-v8a" ./scripts/build.sh
```

يستنسخ `scripts/build.sh` وسم upstream المثبّت، ويطبّق `patches/*.patch` و`localoptions.h`، ثم يترجم
تقاطعيًا `vddropbear` و`dropbearkey` إلى `module/bin/<abi>/`. الناتج هو ELF **ديناميكي** (يبلّغ `file` عن
`dynamically linked, interpreter /system/bin/linker64 … for Android 24`)، مرتبط بـ libc bionic التي
يملكها كل جهاز Android بالفعل. يبقى libtomcrypt مُضمَّنًا داخل الملف الثنائي؛ مكتبة C وحدها ديناميكية. انظر
[ديناميكي، وليس static-PIE](#ديناميكي-وليس-static-pie).

الملفات الثنائية **لا تُودع (commit)**؛ يبنيها الـ CI عند كل وسم ويُرفقها بالإصدار. انظر
[`.gitignore`](../../.gitignore).

---

## قصة crypt()/libcrypto (لماذا احتاجت مصادقة كلمة المرور عملًا حقيقيًا)

كُتبت مصادقة كلمة المرور في Dropbear لمضيف Unix اعتيادي فيه `crypt()` و`/etc/shadow`. ولا يملك Android
**أيًّا منهما**، وهذا يصطدم بالبناء في ثلاثة مواضع منفصلة. يوثّق هذا القسم كلًّا منها، لأنه بالضبط من النوع
المؤلم عند إعادة اكتشافه. كل ذلك تتولّاه الرقعة
[`0003-password-file.patch`](../../patches/0003-password-file.patch)؛ ولا شيء مما يلي متروك للصدفة وقت
التشغيل.

### 1. لا تملك bionic دالة `crypt()` صالحة للاستخدام

مكتبة C في Android (bionic) لا توفّر `crypt()` ولا `crypt_r()` ولا قاعدة بيانات shadow. ولا يكشف الـ NDK
أيّ `<crypt.h>`. لذا فمسار كلمة المرور القياسي في Dropbear، الذي يستدعي `crypt(password, salt)` ويقارن مع
`/etc/shadow`، لا يمكن ببساطة بناؤه ولا تشغيله على Android. كما لا يوجد `libcrypt` للربط معها، وجلب
`libcrypto` من OpenSSL لمجرد تجزئة كلمة مرور سيكون اعتمادًا كبيرًا وثقيلًا لملف ثنائي ساكن.

**جوابنا:** عدم استخدام `crypt()` إطلاقًا. تتحقق مصادقة كلمة المرور من كلمة المرور المقدَّمة باستخدام
**PBKDF2-HMAC-SHA256** مقابل ملف تجزئة (`DROPBEAR_PASSWD_FILE`)، وهو دالة اشتقاق مفاتيح (KDF) عامة
وقياسية ومملّحة ومتكرّرة. صيغة الملف موثّقة في [`patches/README.md`](../../patches/README.md).

### 2. حارس وقت الترجمة في `sysoptions.h`

حتى قبل أن يعمل أي كود، يرفض Dropbear البناء:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

مع كون `HAVE_CRYPT` غير معرّف (دائمًا، على bionic) ومصادقة كلمة المرور مفعّلة، يكون هذا `#error` صارمًا.
ولأن مُحقِّقنا لا يستدعي `crypt()` أبدًا، فإن الرقعة `0003` **تُزيل هذا الحارس**. (وتترك دون مساس فحص «يجب
تفعيل طريقة مصادقة واحدة على الأقل».)

### 3. فخّ libtomcrypt: يُترجَم PBKDF2 *خارجًا*

يُضمّن Dropbear نسخة مقلّمة من **libtomcrypt**، تحتوي *فعلًا* على PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). الحل البديهي هو استدعاؤه. لكنه لا يعمل، لسببين متضافرين:

- **النموذج الأولي مخفي.** يُصرَّح عن `pkcs_5_alg2` فقط داخل `#ifdef LTC_PKCS_5` في `tomcrypt_pkcs.h`. ولا
  تُترجَم ملفات مصدر Dropbear *الخاصة* مع تعريف `LTC_PKCS_5`، فيكون التصريح غير مرئي ويفشل المترجم بخطأ
  *implicit function declaration*.
- **الرمز غير موجود.** والأسوأ أن *جسم* `pkcs_5_alg2` نفسه خلف `#ifdef LTC_PKCS_5`. وبناء libtomcrypt في
  Dropbear لا يعرّفه، فيُترجَم `pkcs_5_2.o` إلى **كائن فارغ**: هو موجود في `libtomcrypt.a`، لكنه لا يحتوي
  أي رمز `pkcs_5_alg2`. يفشل الربط بـ `undefined symbol: pkcs_5_alg2`.

يمكنك رؤية ذلك بنفسك:

```sh
# الكائن موجود لكنه فارغ (لا يوجد T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> مجرد علامة بيانات، لا pkcs_5_alg2

# أما HMAC فمترجَم بالكامل (يستخدمه Dropbear لرموز MAC في SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> يعرّف hmac_memory
```

**جوابنا:** بناء PBKDF2 بأنفسنا فوق البدائيات التي *يترجمها* Dropbear فعلًا. كل من `hmac_memory` وتجزئة
`sha256` المسجّلة موجودان وقابلان للربط، لذا تنفّذ الرقعة `0003` خوارزمية PBKDF2-HMAC-SHA256 مباشرة (RFC
2898؛ كتلة خرج واحدة بحجم 32 بايت، لأن `dkLen == hLen` لـ SHA-256). نصرّح عن `hmac_memory` بأنفسنا (نفس
مشكلة النموذج الأولي المخفي أعلاه) ويُسحب الكائن من `libtomcrypt.a` عند الربط. والنتيجة هي PBKDF2 قياسي
وبالتالي قابل للتشغيل البيني: التجزئة التي تحسبها الـ WebUI عبر **WebCrypto** `deriveBits` في المتصفح
مطابقة بايتًا ببايت لما يحسبه الخادم، وقد جرى التحقق مقابل `hashlib.pbkdf2_hmac` في Python كتنفيذ ثالث
مستقل.

> **باختصار:** لا يمنحك Android أي `crypt()`، وPBKDF2 المُضمَّن في Dropbear يُترجَم إلى لا شيء. ومصادقة
> كلمة المرور هنا هي PBKDF2-HMAC-SHA256 من الصفر فوق HMAC الخاص بـ libtomcrypt، مع إزالة حارس بناء
> crypt(). بلا OpenSSL/`libcrypto`، بلا تعمية، بلا shadow للنظام.

---

## ديناميكي، وليس static-PIE

الملفات الثنائية **ديناميكية** (مرتبطة بـ bionic النظام عبر `/system/bin/linker64`)، وليست ساكنة. وهذا
مهم، وقد تعلّمناه بالطريقة الصعبة، **على جهاز حقيقي**، لا في الـ CI:

- بناء **static-PIE** *يبدو* سليمًا (يبلّغ `file` عن `static-pie executable` نظيف) ويرتبط دون خطأ، لكنه
  **يُحدِث SIGSEGV في اللحظة التي يعمل فيها على الجهاز** (تحقّقنا على هاتف arm64 بنظام Android 16، exit
  139، دون tombstone مفيد). الملفات التنفيذية الساكنة على Android هشّة؛ والصيغة الموثوقة هي ملف ثنائي
  ديناميكي عادي، وهو أيضًا أسلوب شحن كل dropbear راسخ على Android.
- بناء **ساكن غير PIE** لا يبدأ أصلًا: ترفضه bionic بـ
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- لذا فالبناء **ديناميكي** (`make` بلا `STATIC=1`؛ `-pie`)، يربط فقط libc bionic الموجودة على كل جهاز.
  ويظل libtomcrypt مُضمَّنًا سكونيًا داخل الملف الثنائي، فلا توجد مكتبة إضافية للشحن.

درس للاختبار: **`qemu-aarch64` (qemu-user) ليس اختبار دخان صالحًا** هنا (فهو أيضًا يُحدِث segfault على هذه
الملفات)، ولا الترجمة+الربط الناجحان. **شغّل الملف الثنائي على جهاز Android arm64 حقيقي.** (جرى التحقق من هذا بهذه الطريقة بالضبط: أُطلق الـ daemon على منفذ بديل على جهاز
حيّ وتأكّد نجاح تسجيل الدخول بكلمة المرور، مع رفض كلمة مرور خاطئة.)

## لا راية `-E`

يُبنى الخادم بـ `--disable-syslog`، فيسجّل دائمًا إلى stderr، وخيار upstream المسمّى `-E` («log to stderr»)
**غير موجود** في هذا الملف الثنائي؛ وتمريره يطبع `Invalid option -E` ولا يبدأ الـ daemon أبدًا. لذا فإن
بانيَ وسائط الوحدة لا يمرّر `-E`.

## openpty

تستخدم جلسات PTY التفاعلية `openpty()`. تصرّح bionic عنه في `<pty.h>`، ويكتشفه `configure` التقاطعي لـ
Dropbear مع الـ NDK (يُضبط `HAVE_OPENPTY`، و`HAVE_PTY_H 1`)، لذا **لا حاجة لأي رقعة**؛ تعمل الـ PTY فورًا.
(والاستخدام غير التفاعلي مثل exec وSFTP وrsync وتوجيه المنافذ لا يعتمد عليها على أي حال.)

## الأدوات المُضمَّنة: sftp-server وscp وrsync

يترجم `scripts/build-bundles.sh` تقاطعيًا أدوات نقل الملفات كملفات ثنائية ديناميكية إلى `module/bin/<abi>/`.
يشغّله الـ CI مباشرة بعد `build.sh`.

- **rsync** (مع popt + zlib مُضمَّنين) يُترجَم نظيفًا بمجرد أن تُخبر `configure` الخاص به أن bionic لا تملك
  `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** و**scp** يأتيان من **OpenSSH portable**، مبنيّين بـ `--without-openssl` (التعمية
  المدمجة في OpenSSH تكفي لهذين)، مع **zlib** ساكن صغير يبنيه هذا السكربت أولًا.

OpenSSH على Android صعب المراس مثل قصة crypt() أعلاه، لأن `configure` الخاص به يكتشف عدة دوال libc بشكل
خاطئ عند الترجمة التقاطعية. يُرمِّز السكربت الإصلاح؛ وللتوثيق، القطع هي:

1. **بذرة ذاكرة مؤقتة لدوال تفتقر إليها bionic** لكن configure يظنّ أنها موجودة، ليُترجَم بدلًا منها نسخ
   compat: `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** بدونهما يفعل `defines.h` الخاص بـ
   OpenSSH `#define __sentinel__` (فارغ)، مما يُفسد بعدها `__attribute__((__sentinel__(1)))` الخاص بـ
   bionic في `<unistd.h>` وتفشل كل ترجمة بـ `expected ')'`.
3. **بديل `explicit_bzero` يستخدم `memset`.** إن `bzero` في bionic ماكرو شبيه بدالة (لا رمز حقيقي)، لذا
   فإن بديل OpenSSH الافتراضي، الذي يأخذ `&bzero` كمؤشّر دالة، لا يُترجَم. ولا تملك bionic `explicit_bzero`
   خاصًا بها.
4. **إسقاط `xcrypt.o` و`getrrsetbyname.o`** من مكتبة compat. يستدعي `xcrypt.c` دالتَي
   `getpwent()`/`crypt()` دون شرط (bionic لا تملك أيًّا منهما)، ويستخدم `getrrsetbyname.c` بنى داخلية في
   الـ resolver لا تكشفها bionic. ولا يستخدم أيًّا منهما `sftp-server` ولا `scp`.
5. **`-Wl,--allow-multiple-definition`.** إن `reallocarray` هو الصورة المرآتية للدوال في (1): لا
   *تُصرّح* bionic عنه في API 24، فيُترجِم OpenSSH بديله الخاص، لكن **الرمز** موجود فعلًا في `libc.a`،
   فيتصادمان عند الربط. والسماح بالتكرار يأخذ نسخة bionic، وهذا جيّد.
6. **حماية `pw_gecos` من NULL في `pwcopy()`.** تُرجِع `getpwuid()` في bionic قيمة `pw_gecos` تساوي `NULL`
   (لا يحتفظ Android بحقل GECOS). ويحمي `pwcopy()` في OpenSSH الحقل `pw_passwd` من `NULL` لكن ليس
   `pw_gecos`، فيصل `sftp-server` إلى `xstrdup(NULL)` ويُحدِث SIGSEGV عند البدء، في اللحظة التي تُفتح فيها
   جلسة. (`scp` عبر البروتوكول القديم لا يستدعي `pwcopy` أبدًا، ولهذا كان يعمل بينما لم يعمل SFTP.) يرقّع
   البناء `pwcopy()` لدمج `pw_gecos` إلى `""`.

توجد الإصدارات المثبّتة في أعلى `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## إعادة إنتاج ABI واحد يدويًا

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

> _تم إنشاء هذا التوثيق باستخدام Claude (Anthropic) ويتولى صيانته VD171. التصحيحات والتحسينات مرحّب بها؛ راجع [CONTRIBUTING.md](CONTRIBUTING.md)._
