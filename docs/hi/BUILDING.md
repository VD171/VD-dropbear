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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · हिन्दी · [Bahasa Indonesia](../in/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# VD Dropbear बनाना

VD Dropbear **[Dropbear](https://github.com/mkj/dropbear) upstream** ([`UPSTREAM_VERSION`](../UPSTREAM_VERSION)
में पिन किया गया टैग) के साथ [`patches/`](../patches/) में मौजूद छोटा, ऑडिट-योग्य पैच सेट भेजता है। CI इसे
बनाता है; आप इसे स्थानीय रूप से पुनः उत्पन्न कर सकते हैं।

## त्वरित शुरुआत

```sh
# एक बार: एक Android NDK (r27 या नया)
export NDK=/path/to/android-ndk

# हर ABI बनाएँ (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# या तेज़ी से दोहराने के लिए केवल एक
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` पिन किए गए upstream टैग को क्लोन करता है, `patches/*.patch` और `localoptions.h` लागू करता
है, फिर `vddropbear` और `dropbearkey` को `module/bin/<abi>/` में क्रॉस-कंपाइल करता है। आउटपुट एक **डायनामिक**
ELF है (`file` बताता है `dynamically linked, interpreter /system/bin/linker64 … for Android 24`), जो उस
bionic libc से लिंक है जो हर Android डिवाइस में पहले से है। libtomcrypt बाइनरी के अंदर एम्बेडेड रहता है; केवल C
लाइब्रेरी डायनामिक है। देखें [डायनामिक, static-PIE नहीं](#डयनमक-static-pie-नह)।

बाइनरी **कमिट नहीं की जातीं**; उन्हें हर टैग पर CI बनाता है और रिलीज़ के साथ संलग्न करता है। देखें
[`.gitignore`](../.gitignore)।

---

## crypt()/libcrypto की कहानी (पासवर्ड ऑथ को असली मेहनत क्यों लगी)

Dropbear का पासवर्ड प्रमाणीकरण `crypt()` और `/etc/shadow` वाले एक सामान्य Unix होस्ट के लिए लिखा गया है।
Android के पास **इनमें से कोई नहीं** है, और यह बिल्ड से तीन अलग-अलग जगहों पर टकराता है। यह खंड उनमें से हर एक
का दस्तावेज़ीकरण करता है, क्योंकि यह ठीक उसी तरह की चीज़ है जिसे फिर से खोजना कष्टदायक होता है। यह सब पैच
[`0003-password-file.patch`](../patches/0003-password-file.patch) संभालता है; नीचे कुछ भी रनटाइम पर संयोग पर
नहीं छोड़ा गया।

### 1. bionic में कोई उपयोगी `crypt()` नहीं है

Android की C लाइब्रेरी (bionic) न `crypt()`, न `crypt_r()`, न ही कोई shadow डेटाबेस देती है। NDK कोई
`<crypt.h>` उजागर नहीं करता। इसलिए Dropbear का मानक पासवर्ड पथ, जो `crypt(password, salt)` को कॉल करता है और
`/etc/shadow` से तुलना करता है, Android पर न तो बनाया जा सकता है और न ही चलाया जा सकता है। लिंक करने के लिए कोई
`libcrypt` भी नहीं है, और केवल एक पासवर्ड हैश के लिए OpenSSL का `libcrypto` खींचना एक स्टैटिक बाइनरी के लिए एक
बड़ी, भारी निर्भरता होगी।

**हमारा उत्तर:** `crypt()` का बिल्कुल उपयोग न करना। पासवर्ड ऑथ प्रस्तुत पासवर्ड को एक हैश फ़ाइल
(`DROPBEAR_PASSWD_FILE`) के विरुद्ध **PBKDF2-HMAC-SHA256** से सत्यापित करता है, जो एक सार्वजनिक, मानक,
साल्टेड, पुनरावृत्त KDF है। फ़ाइल प्रारूप [`patches/README.md`](../patches/README.md) में प्रलेखित है।

### 2. `sysoptions.h` में कंपाइल-टाइम गार्ड

किसी भी कोड के चलने से पहले ही, Dropbear बिल्ड करने से इनकार कर देता है:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

`HAVE_CRYPT` के अपरिभाषित होने (bionic पर हमेशा) और पासवर्ड ऑथ के सक्षम होने पर, यह एक कठोर `#error` है।
चूँकि हमारा सत्यापनकर्ता `crypt()` को कभी कॉल नहीं करता, पैच `0003` **इस गार्ड को हटा देता है**। (यह «कम से कम
एक ऑथ विधि सक्षम होनी चाहिए» जाँच को अछूता छोड़ देता है।)

### 3. libtomcrypt का जाल: PBKDF2 कंपाइल में *बाहर* हो जाता है

Dropbear एक छँटा हुआ **libtomcrypt** एम्बेड करता है, जिसमें PBKDF2 *वास्तव में* है (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`)। स्पष्ट समाधान उसे कॉल करना है। यह काम नहीं करता, दो परस्पर प्रबल कारणों से:

- **प्रोटोटाइप छिपा है।** `pkcs_5_alg2` केवल `tomcrypt_pkcs.h` में `#ifdef LTC_PKCS_5` के भीतर घोषित है।
  Dropbear की *अपनी* स्रोत फ़ाइलें `LTC_PKCS_5` परिभाषित के साथ कंपाइल नहीं होतीं, इसलिए घोषणा अदृश्य है और
  कंपाइलर *implicit function declaration* के साथ विफल होता है।
- **प्रतीक मौजूद नहीं है।** और बुरा यह कि `pkcs_5_alg2` का *बॉडी* स्वयं भी `#ifdef LTC_PKCS_5` के पीछे है।
  Dropbear का libtomcrypt बिल्ड इसे परिभाषित नहीं करता, इसलिए `pkcs_5_2.o` एक **खाली ऑब्जेक्ट** में कंपाइल
  होता है: यह `libtomcrypt.a` में है, पर इसमें कोई `pkcs_5_alg2` प्रतीक नहीं है। लिंक
  `undefined symbol: pkcs_5_alg2` के साथ विफल होता है।

आप इसे स्वयं देख सकते हैं:

```sh
# ऑब्जेक्ट मौजूद है पर खाली है (कोई T pkcs_5_alg2 नहीं):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> केवल एक डेटा मार्कर, कोई pkcs_5_alg2 नहीं

# इसके विपरीत, HMAC पूरी तरह कंपाइल है (Dropbear इसे SSH MACs के लिए उपयोग करता है):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> hmac_memory को परिभाषित करता है
```

**हमारा उत्तर:** उन प्रिमिटिव्स पर स्वयं PBKDF2 बनाना जिन्हें Dropbear *वास्तव में* कंपाइल करता है।
`hmac_memory` और पंजीकृत `sha256` हैश दोनों मौजूद और लिंक-योग्य हैं, इसलिए पैच `0003` PBKDF2-HMAC-SHA256 को
सीधे लागू करता है (RFC 2898; एक एकल 32-बाइट आउटपुट ब्लॉक, क्योंकि SHA-256 के लिए `dkLen == hLen`)। हम
`hmac_memory` को स्वयं घोषित करते हैं (वही छिपे प्रोटोटाइप की समस्या जो ऊपर है) और ऑब्जेक्ट लिंक के समय
`libtomcrypt.a` से खींचा जाता है। परिणाम मानक PBKDF2 है और इसलिए इंटरऑपरेबल है: WebUI ब्राउज़र के **WebCrypto**
`deriveBits` से जो हैश गणना करता है वह बाइट-दर-बाइट उसी के समान है जो सर्वर गणना करता है, जिसे तीसरी, स्वतंत्र
कार्यान्वयन के रूप में Python के `hashlib.pbkdf2_hmac` के विरुद्ध सत्यापित किया गया।

> **संक्षेप में:** Android आपको कोई `crypt()` नहीं देता, और Dropbear का एम्बेडेड PBKDF2 कुछ भी नहीं में कंपाइल
> होता है। पासवर्ड ऑथ यहाँ libtomcrypt के HMAC पर शून्य से बना एक PBKDF2-HMAC-SHA256 है, जिसमें crypt() बिल्ड
> गार्ड हटा दिया गया है। कोई OpenSSL/`libcrypto` नहीं, कोई ऑब्फ़स्केशन नहीं, कोई सिस्टम shadow नहीं।

---

## डायनामिक, static-PIE नहीं

बाइनरी **डायनामिक** हैं (`/system/bin/linker64` के ज़रिए सिस्टम bionic से लिंक्ड), स्टैटिक नहीं। यह मायने रखता
है, और यह कठिन तरीके से सीखा गया, **एक असली डिवाइस पर**, CI में नहीं:

- एक **static-PIE** बिल्ड *ठीक दिखता* है (`file` एक साफ़ `static-pie executable` बताता है) और बिना त्रुटि
  लिंक होता है, पर **डिवाइस पर चलते ही SIGSEGV कर देता है** (एक arm64 Android 16 फ़ोन पर सत्यापित, exit 139,
  कोई उपयोगी tombstone नहीं)। Android पर स्टैटिक एक्ज़ीक्यूटेबल नाज़ुक हैं; भरोसेमंद रूप एक सामान्य डायनामिक
  बाइनरी है, जो हर स्थापित Android dropbear के भेजे जाने का तरीका भी है।
- एक **स्टैटिक, non-PIE** बिल्ड शुरू ही नहीं होता: bionic इसे
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic` के साथ अस्वीकार करता है।
- तो बिल्ड **डायनामिक** है (`STATIC=1` के बिना `make`; `-pie`), केवल bionic libc से लिंक करते हुए, जो हर
  डिवाइस पर मौजूद है। libtomcrypt अब भी बाइनरी में स्थैतिक रूप से एम्बेडेड है, इसलिए भेजने के लिए कोई अतिरिक्त
  लाइब्रेरी नहीं है।

परीक्षण का सबक: **`qemu-aarch64` (qemu-user) यहाँ एक मान्य smoke test नहीं है** (यह भी इन बाइनरियों पर segfault
करता है), और न ही एक सफल compile+link है। **बाइनरी को एक असली arm64 Android डिवाइस पर चलाएँ।** (इसे ठीक इसी तरह सत्यापित किया गया: daemon को एक जीवित डिवाइस पर एक वैकल्पिक
पोर्ट पर लॉन्च किया गया और पासवर्ड लॉगिन के सफल होने की पुष्टि हुई, जबकि ग़लत पासवर्ड अस्वीकृत हुआ।)

## कोई `-E` फ़्लैग नहीं

सर्वर `--disable-syslog` के साथ बनाया जाता है, इसलिए यह हमेशा stderr में लॉग करता है और upstream का `-E`
विकल्प («log to stderr») इस बाइनरी में **मौजूद नहीं** है; इसे पास करने पर `Invalid option -E` प्रिंट होता है और
daemon कभी शुरू नहीं होता। इसलिए मॉड्यूल का आर्गुमेंट-बिल्डर `-E` पास नहीं करता।

## openpty

इंटरैक्टिव PTY सत्र `openpty()` का उपयोग करते हैं। bionic इसे `<pty.h>` में घोषित करता है, और Dropbear का
क्रॉस-`configure` इसे NDK के साथ पहचानता है (`HAVE_OPENPTY` सेट होता है, `HAVE_PTY_H 1`), इसलिए **किसी पैच की
ज़रूरत नहीं**; PTYs तुरंत काम करते हैं। (exec, SFTP, rsync और पोर्ट-फ़ॉरवर्डिंग जैसे ग़ैर-इंटरैक्टिव उपयोग वैसे
भी इस पर निर्भर नहीं हैं।)

## एम्बेडेड टूल: sftp-server, scp, rsync

`scripts/build-bundles.sh` फ़ाइल-ट्रांसफ़र टूल को डायनामिक बाइनरी के रूप में `module/bin/<abi>/` में
क्रॉस-कंपाइल करता है। CI इसे `build.sh` के ठीक बाद चलाता है।

- **rsync** (एम्बेडेड popt + zlib के साथ) तब साफ़ कंपाइल होता है जब आप इसके configure को बता देते हैं कि bionic
  में `lutimes` नहीं है (`ac_cv_func_lutimes=no`)।
- **sftp-server** और **scp** **OpenSSH portable** से आते हैं, `--without-openssl` के साथ बनाए गए (इन दोनों के
  लिए OpenSSH की अंतर्निहित क्रिप्टो पर्याप्त है), एक छोटे स्टैटिक **zlib** के साथ जिसे यह स्क्रिप्ट पहले बनाती
  है।

Android पर OpenSSH ऊपर की crypt() कहानी जितना ही नख़रैल है, क्योंकि इसका `configure` क्रॉस-कंपाइल करते समय कई
libc फ़ंक्शनों को ग़लत पहचानता है। स्क्रिप्ट इस सुधार को कोड करती है; अभिलेख के लिए, टुकड़े ये हैं:

1. **उन फ़ंक्शनों का एक कैश seed जो bionic में नहीं हैं** पर configure सोचता है कि हैं, ताकि उनके बजाय compat
   संस्करण कंपाइल हों: `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`, `explicit_bzero`।
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** इनके बिना, OpenSSH का `defines.h`
   `#define __sentinel__` (खाली) करता है, जो फिर `<unistd.h>` में bionic के अपने
   `__attribute__((__sentinel__(1)))` को बिगाड़ देता है और हर कंपाइल `expected ')'` के साथ विफल होता है।
3. **एक `explicit_bzero` compat जो `memset` का उपयोग करता है।** bionic का `bzero` एक फ़ंक्शन-जैसा मैक्रो है
   (असली प्रतीक नहीं), इसलिए OpenSSH का डिफ़ॉल्ट compat, जो `&bzero` को फ़ंक्शन पॉइंटर के रूप में लेता है,
   कंपाइल नहीं होता। bionic में अपना `explicit_bzero` नहीं है।
4. **compat लाइब्रेरी से `xcrypt.o` और `getrrsetbyname.o` हटाना।** `xcrypt.c` बिना शर्त
   `getpwent()`/`crypt()` को कॉल करता है (bionic में कोई नहीं), और `getrrsetbyname.c` resolver की आंतरिक
   चीज़ों का उपयोग करता है जो bionic उजागर नहीं करता। इनमें से किसी का भी `sftp-server` या `scp` उपयोग नहीं
   करता।
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` (1) के फ़ंक्शनों का दर्पण-प्रतिबिंब है: bionic इसे
   API 24 में *घोषित* नहीं करता, इसलिए OpenSSH अपना compat कंपाइल करता है, पर **प्रतीक** तो `libc.a` में मौजूद
   है, इसलिए दोनों लिंक पर टकराते हैं। डुप्लिकेट की अनुमति देना bionic वाला लेता है, जो ठीक है।
6. **`pwcopy()` में `pw_gecos` को NULL से बचाना।** bionic का `getpwuid()` एक `NULL` `pw_gecos` लौटाता है
   (Android कोई GECOS फ़ील्ड नहीं रखता)। OpenSSH का `pwcopy()` `pw_passwd` को `NULL` से बचाता है पर
   `pw_gecos` को नहीं, इसलिए `sftp-server` `xstrdup(NULL)` तक पहुँचता है और शुरुआत में, उसी क्षण जब कोई सत्र
   खुलता है, SIGSEGV करता है। (`scp` विरासती प्रोटोकॉल पर `pwcopy` को कभी कॉल नहीं करता, इसीलिए वह काम करता था
   जबकि SFTP नहीं।) बिल्ड `pwcopy()` को पैच करके `pw_gecos` को `""` में समाहित करता है।

पिन किए गए संस्करण `scripts/build-bundles.sh` के शीर्ष पर हैं (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`)।

## एक एकल ABI को हाथ से पुनः उत्पन्न करना

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

> _यह दस्तावेज़ Claude (Anthropic) से तैयार किया गया है और इसे VD171 द्वारा अनुरक्षित किया जाता है। सुधार और संशोधन का स्वागत है; देखें [CONTRIBUTING.md](CONTRIBUTING.md)।_
