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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../in/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · ไทย · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# การสร้าง VD Dropbear

VD Dropbear ส่งมอบ **[Dropbear](https://github.com/mkj/dropbear) upstream** (แท็กที่ปักหมุดใน
[`UPSTREAM_VERSION`](../UPSTREAM_VERSION)) พร้อมชุดแพตช์เล็กๆ ที่ตรวจสอบได้ใน [`patches/`](../patches/)
CI สร้างมัน คุณสามารถทำซ้ำได้ในเครื่องของคุณ

## เริ่มต้นอย่างรวดเร็ว

```sh
# ครั้งเดียว: Android NDK (r27 หรือใหม่กว่า)
export NDK=/path/to/android-ndk

# สร้างทุก ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# หรือเพียงหนึ่งตัว เพื่อวนซ้ำอย่างรวดเร็ว
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` โคลนแท็ก upstream ที่ปักหมุด นำ `patches/*.patch` และ `localoptions.h` มาใช้ แล้ว
คอมไพล์ข้าม `vddropbear` และ `dropbearkey` ไปยัง `module/bin/<abi>/` เอาต์พุตเป็น ELF แบบ **ไดนามิก**
(`file` รายงานว่า `dynamically linked, interpreter /system/bin/linker64 … for Android 24`) ซึ่งลิงก์กับ
bionic libc ที่ทุกอุปกรณ์ Android มีอยู่แล้ว libtomcrypt ยังคงฝังอยู่ภายในไบนารี มีเพียงไลบรารี C เท่านั้น
ที่เป็นไดนามิก ดู [ไดนามิก ไม่ใช่ static-PIE](#ไดนามก-ไมใช-static-pie)

ไบนารี **ไม่ถูกคอมมิต** ถูกสร้างโดย CI ในทุกแท็กและแนบไปกับรีลีส ดู [`.gitignore`](../.gitignore)

---

## เรื่องราวของ crypt()/libcrypto (เหตุใดการยืนยันตัวตนด้วยรหัสผ่านจึงต้องใช้งานจริง)

การยืนยันตัวตนด้วยรหัสผ่านของ Dropbear เขียนขึ้นสำหรับโฮสต์ Unix ปกติที่มี `crypt()` และ `/etc/shadow`
Android **ไม่มีทั้งสองอย่าง** และนั่นปะทะกับการสร้างในสามจุดแยกกัน หัวข้อนี้บันทึกแต่ละจุดไว้ เพราะมันเป็น
สิ่งที่เจ็บปวดเวลาต้องมาค้นพบใหม่อย่างแท้จริง ทั้งหมดนี้จัดการโดยแพตช์
[`0003-password-file.patch`](../patches/0003-password-file.patch) ไม่มีสิ่งใดด้านล่างถูกปล่อยให้เป็นเรื่อง
ของโชคในเวลารันไทม์

### 1. bionic ไม่มี `crypt()` ที่ใช้งานได้

ไลบรารี C ของ Android (bionic) ไม่มี `crypt()`, `crypt_r()` หรือฐานข้อมูล shadow NDK ไม่เปิดเผย
`<crypt.h>` ใดๆ ดังนั้นเส้นทางรหัสผ่านมาตรฐานของ Dropbear ที่เรียก `crypt(password, salt)` และเทียบกับ
`/etc/shadow` จึงไม่สามารถสร้างหรือรันบน Android ได้เลย อีกทั้งไม่มี `libcrypt` ให้ลิงก์ และการดึง
`libcrypto` ของ OpenSSL มาเพียงเพื่อแฮชรหัสผ่านก็จะเป็นการพึ่งพาขนาดใหญ่และเทอะทะสำหรับไบนารีแบบสแตติก

**คำตอบของเรา:** ไม่ใช้ `crypt()` เลย การยืนยันตัวตนด้วยรหัสผ่านตรวจสอบรหัสผ่านที่ให้มาด้วย
**PBKDF2-HMAC-SHA256** เทียบกับไฟล์แฮช (`DROPBEAR_PASSWD_FILE`) ซึ่งเป็น KDF ที่เปิดเผย เป็นมาตรฐาน มีเกลือ
และวนซ้ำ รูปแบบไฟล์มีบันทึกไว้ใน [`patches/README.md`](../patches/README.md)

### 2. ตัวป้องกันเวลาคอมไพล์ใน `sysoptions.h`

ก่อนที่โค้ดใดจะทำงานด้วยซ้ำ Dropbear ปฏิเสธที่จะสร้าง:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

เมื่อ `HAVE_CRYPT` ไม่ถูกนิยาม (เสมอ บน bionic) และเปิดการยืนยันตัวตนด้วยรหัสผ่าน นี่คือ `#error` ที่
เด็ดขาด เนื่องจากตัวตรวจสอบของเราไม่เคยเรียก `crypt()` แพตช์ `0003` จึง **ลบตัวป้องกันนี้ออก** (โดยคงการ
ตรวจสอบ «ต้องเปิดใช้งานวิธีการยืนยันตัวตนอย่างน้อยหนึ่งวิธี» ไว้ไม่แตะต้อง)

### 3. กับดักของ libtomcrypt: PBKDF2 ถูกคอมไพล์ *ออกไป*

Dropbear ฝัง **libtomcrypt** แบบตัดทอน ซึ่ง *มี* PBKDF2 อยู่จริง (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`) การแก้ที่เห็นได้ชัดคือเรียกใช้มัน มันไม่ทำงาน ด้วยสองเหตุผลที่เสริมกัน:

- **โปรโตไทป์ถูกซ่อน** `pkcs_5_alg2` ถูกประกาศเฉพาะภายใน `#ifdef LTC_PKCS_5` ใน `tomcrypt_pkcs.h` ไฟล์ซอ
  ร์ส *ของ* Dropbear เองไม่ได้คอมไพล์โดยนิยาม `LTC_PKCS_5` ดังนั้นการประกาศจึงมองไม่เห็น และคอมไพเลอร์
  ล้มเหลวด้วย *implicit function declaration*
- **สัญลักษณ์ไม่มีอยู่** แย่กว่านั้น *ตัวบอดี* ของ `pkcs_5_alg2` เองก็อยู่หลัง `#ifdef LTC_PKCS_5` การสร้าง
  libtomcrypt ของ Dropbear ไม่ได้นิยามมัน ดังนั้น `pkcs_5_2.o` จึงคอมไพล์เป็น **อ็อบเจกต์ว่าง**: มันอยู่ใน
  `libtomcrypt.a` แต่ไม่มีสัญลักษณ์ `pkcs_5_alg2` เลย การลิงก์ล้มเหลวด้วย `undefined symbol: pkcs_5_alg2`

คุณเห็นสิ่งนี้ได้ด้วยตนเอง:

```sh
# อ็อบเจกต์มีอยู่แต่ว่าง (ไม่มี T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> มีเพียงเครื่องหมายข้อมูล ไม่มี pkcs_5_alg2

# ในทางกลับกัน HMAC ถูกคอมไพล์เต็มที่ (Dropbear ใช้สำหรับ MAC ของ SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> นิยาม hmac_memory
```

**คำตอบของเรา:** สร้าง PBKDF2 ด้วยตนเองบนไพรมิทีฟที่ Dropbear *คอมไพล์* จริง ทั้ง `hmac_memory` และแฮช
`sha256` ที่ลงทะเบียนไว้ต่างก็มีอยู่และลิงก์ได้ ดังนั้นแพตช์ `0003` จึงใช้งาน PBKDF2-HMAC-SHA256 โดยตรง
(RFC 2898; บล็อกเอาต์พุต 32 ไบต์เพียงบล็อกเดียว เพราะ `dkLen == hLen` สำหรับ SHA-256) เราประกาศ
`hmac_memory` เอง (ปัญหาโปรโตไทป์ซ่อนเดียวกับด้านบน) และอ็อบเจกต์ถูกดึงจาก `libtomcrypt.a` ตอนลิงก์ ผลลัพธ์
คือ PBKDF2 มาตรฐานและจึงทำงานร่วมกันได้: แฮชที่ WebUI คำนวณด้วย **WebCrypto** `deriveBits` ของเบราว์เซอร์
เหมือนกันทีละไบต์กับที่เซิร์ฟเวอร์คำนวณ ตรวจสอบเทียบกับ `hashlib.pbkdf2_hmac` ของ Python ในฐานะการใช้งานที่
สามที่เป็นอิสระ

> **โดยสรุป:** Android ไม่ให้ `crypt()` ใดๆ แก่คุณ และ PBKDF2 ที่ฝังของ Dropbear ก็ถูกคอมไพล์เป็นศูนย์
> การยืนยันตัวตนด้วยรหัสผ่านที่นี่คือ PBKDF2-HMAC-SHA256 ที่สร้างจากศูนย์บน HMAC ของ libtomcrypt โดยนำตัว
> ป้องกันการสร้าง crypt() ออก ไม่มี OpenSSL/`libcrypto` ไม่มีการทำให้สับสน ไม่มี shadow ของระบบ

---

## ไดนามิก ไม่ใช่ static-PIE

ไบนารีเป็นแบบ **ไดนามิก** (ลิงก์กับ bionic ของระบบผ่าน `/system/bin/linker64`) ไม่ใช่สแตติก สิ่งนี้สำคัญ
และได้เรียนรู้มาด้วยวิธียากลำบาก **บนอุปกรณ์จริง** ไม่ใช่ใน CI:

- การสร้าง **static-PIE** *ดู* เหมือนไม่มีปัญหา (`file` รายงาน `static-pie executable` ที่สะอาด) และลิงก์
  โดยไม่มีข้อผิดพลาด แต่ **เกิด SIGSEGV ในทันทีที่มันรันบนอุปกรณ์** (ตรวจสอบบนโทรศัพท์ arm64 Android 16,
  exit 139, ไม่มี tombstone ที่เป็นประโยชน์) ไฟล์ปฏิบัติการสแตติกบน Android เปราะบาง รูปแบบที่เชื่อถือได้คือ
  ไบนารีไดนามิกปกติ ซึ่งก็เป็นวิธีที่ dropbear สำหรับ Android ที่ตั้งมั่นทุกตัวถูกส่งมอบเช่นกัน
- การสร้าง **สแตติก ไม่ใช่ PIE** ไม่แม้แต่จะเริ่มทำงาน: bionic ปฏิเสธมันด้วย
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`
- ดังนั้นการสร้างจึงเป็น **ไดนามิก** (`make` โดยไม่มี `STATIC=1`; `-pie`) โดยลิงก์เฉพาะ bionic libc ที่มีอยู่
  บนทุกอุปกรณ์ libtomcrypt ยังคงฝังแบบสแตติกในไบนารี จึงไม่มีไลบรารีเพิ่มเติมที่ต้องส่งมอบ

บทเรียนสำหรับการทดสอบ: **`qemu-aarch64` (qemu-user) ไม่ใช่ smoke test ที่ถูกต้อง** ที่นี่ (มันก็ segfault
บนไบนารีเหล่านี้) และ compile+link ที่สำเร็จก็ไม่ใช่เช่นกัน **รันไบนารีบนอุปกรณ์ Android arm64 จริง** (สิ่งนี้ได้รับการตรวจสอบด้วยวิธีนี้พอดี: เปิดดีมอนบนพอร์ตสำรองบนอุปกรณ์ที่ใช้งานจริง และ
ยืนยันว่าการเข้าสู่ระบบด้วยรหัสผ่านสำเร็จ ขณะที่รหัสผ่านผิดถูกปฏิเสธ)

## ไม่มีแฟล็ก `-E`

เซิร์ฟเวอร์ถูกสร้างด้วย `--disable-syslog` จึงบันทึกไปยัง stderr เสมอ และตัวเลือก `-E` ของ upstream («log to
stderr») **ไม่มีอยู่** ในไบนารีนี้ การส่งมันจะพิมพ์ `Invalid option -E` และดีมอนจะไม่เริ่มทำงานเลย ดังนั้น
ตัวสร้างอาร์กิวเมนต์ของโมดูลจึงไม่ส่ง `-E`

## openpty

เซสชัน PTY แบบโต้ตอบใช้ `openpty()` bionic ประกาศมันใน `<pty.h>` และ `configure` แบบข้ามของ Dropbear
ตรวจพบมันด้วย NDK (`HAVE_OPENPTY` ถูกตั้ง, `HAVE_PTY_H 1`) ดังนั้น **ไม่ต้องใช้แพตช์ใดๆ** PTY ทำงานได้ทันที
(การใช้งานแบบไม่โต้ตอบ เช่น exec, SFTP, rsync และการส่งต่อพอร์ต อย่างไรก็ไม่ขึ้นกับมัน)

## เครื่องมือที่ฝัง: sftp-server, scp, rsync

`scripts/build-bundles.sh` คอมไพล์ข้ามเครื่องมือถ่ายโอนไฟล์เป็นไบนารีไดนามิกไปยัง `module/bin/<abi>/`
CI รันมันทันทีหลัง `build.sh`

- **rsync** (พร้อม popt + zlib ที่ฝัง) คอมไพล์อย่างสะอาดทันทีที่คุณบอก configure ของมันว่า bionic ไม่มี
  `lutimes` (`ac_cv_func_lutimes=no`)
- **sftp-server** และ **scp** มาจาก **OpenSSH portable** สร้างด้วย `--without-openssl` (คริปโตในตัวของ
  OpenSSH เพียงพอสำหรับสองตัวนี้) พร้อม **zlib** สแตติกเล็กๆ ที่สคริปต์นี้สร้างก่อน

OpenSSH บน Android จุกจิกพอๆ กับเรื่องราวของ crypt() ด้านบน เพราะ `configure` ของมันตรวจพบฟังก์ชัน libc
หลายตัวผิดพลาดเมื่อคอมไพล์ข้าม สคริปต์เข้ารหัสการแก้ไขไว้ เพื่อเป็นบันทึก ชิ้นส่วนต่างๆ มีดังนี้:

1. **seed แคชของฟังก์ชันที่ bionic ขาด** แต่ configure คิดว่ามี เพื่อให้เวอร์ชัน compat ถูกคอมไพล์แทน:
   `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`, `explicit_bzero`
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`** หากไม่มีสิ่งเหล่านี้ `defines.h` ของ
   OpenSSH จะทำ `#define __sentinel__` (ว่าง) ซึ่งจากนั้นทำให้ `__attribute__((__sentinel__(1)))` ของ
   bionic เองใน `<unistd.h>` เสียหาย และทุกการคอมไพล์ล้มเหลวด้วย `expected ')'`
3. **compat ของ `explicit_bzero` ที่ใช้ `memset`** `bzero` ของ bionic เป็นแมโครคล้ายฟังก์ชัน (ไม่ใช่
   สัญลักษณ์จริง) ดังนั้น compat เริ่มต้นของ OpenSSH ที่รับ `&bzero` เป็นตัวชี้ฟังก์ชันจึงคอมไพล์ไม่ได้
   bionic ไม่มี `explicit_bzero` ของตัวเอง
4. **การทิ้ง `xcrypt.o` และ `getrrsetbyname.o`** จากไลบรารี compat `xcrypt.c` เรียก `getpwent()`/`crypt()`
   แบบไม่มีเงื่อนไข (bionic ไม่มีทั้งคู่) และ `getrrsetbyname.c` ใช้ภายในของ resolver ที่ bionic ไม่เปิดเผย
   ทั้งคู่ไม่ถูกใช้โดย `sftp-server` หรือ `scp`
5. **`-Wl,--allow-multiple-definition`** `reallocarray` เป็นภาพสะท้อนของฟังก์ชันในข้อ (1): bionic ไม่ได้
   *ประกาศ* มันใน API 24 ดังนั้น OpenSSH จึงคอมไพล์ compat ของตัวเอง แต่ **สัญลักษณ์** นั้นมีอยู่จริงใน
   `libc.a` ดังนั้นทั้งคู่จึงชนกันตอนลิงก์ การอนุญาตให้ซ้ำจะเลือกของ bionic ซึ่งไม่เป็นไร
6. **การป้องกัน `pw_gecos` จาก NULL ใน `pwcopy()`** `getpwuid()` ของ bionic คืนค่า `pw_gecos` เป็น `NULL`
   (Android ไม่เก็บฟิลด์ GECOS) `pwcopy()` ของ OpenSSH ป้องกัน `pw_passwd` จาก `NULL` แต่ไม่ป้องกัน
   `pw_gecos` ดังนั้น `sftp-server` จึงไปถึง `xstrdup(NULL)` และ SIGSEGV ตอนเริ่มต้น ในทันทีที่เซสชันเปิดขึ้น
   (`scp` ผ่านโปรโตคอลเก่าไม่เคยเรียก `pwcopy` จึงเป็นเหตุผลที่มันทำงานได้ขณะที่ SFTP ไม่ได้) การสร้างแพตช์
   `pwcopy()` เพื่อรวม `pw_gecos` ให้เป็น `""`

เวอร์ชันที่ปักหมุดอยู่ด้านบนของ `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`)

## การทำซ้ำ ABI เดียวด้วยมือ

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

> _เอกสารนี้สร้างขึ้นด้วย Claude (Anthropic) และดูแลโดย VD171 ยินดีรับการแก้ไขและการปรับปรุง ดู [CONTRIBUTING.md](CONTRIBUTING.md)_
