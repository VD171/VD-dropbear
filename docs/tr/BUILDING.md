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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · Türkçe · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# VD Dropbear derleme

VD Dropbear, **[Dropbear](https://github.com/mkj/dropbear) upstream**'ini
([`UPSTREAM_VERSION`](../../UPSTREAM_VERSION) içinde sabitlenen etiket) ve [`patches/`](../../patches/)
içindeki küçük, denetlenebilir yama setini sunar. CI onu derler, yerelde yeniden üretebilirsiniz.

## Hızlı başlangıç

```sh
# bir kez: bir Android NDK (r27 veya daha yeni)
export NDK=/path/to/android-ndk

# her ABI'yi derle (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# ya da hızlı yinelemek için sadece birini
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` sabitlenen upstream etiketini klonlar, `patches/*.patch` ve `localoptions.h`'yi
uygular, sonra `vddropbear` ve `dropbearkey`'i `module/bin/<abi>/` içine çapraz derler. Çıktı
**dinamik** bir ELF'tir (`file` şunu bildirir: `dynamically linked, interpreter /system/bin/linker64 …
for Android 24`), her Android cihazın zaten sahip olduğu bionic libc'ye bağlanmış. libtomcrypt ikili
dosyanın içinde gömülü kalır, yalnızca C kütüphanesi dinamiktir. Bkz. [Dinamik, static-PIE değil](#dinamik-static-pie-değil).

İkili dosyalar **commit edilmez**, her etikette CI tarafından derlenir ve sürüme eklenir. Bkz.
[`.gitignore`](../../.gitignore).

---

## crypt()/libcrypto hikâyesi (parola kimlik doğrulaması neden gerçek emek istedi)

Dropbear'ın parola kimlik doğrulaması, `crypt()` ve `/etc/shadow` olan normal bir Unix ana makinesi için
yazılmıştır. Android'de **ikisi de yoktur** ve bu, derlemeyle üç ayrı yerde çakışır. Bu bölüm her birini
belgeler, çünkü tam da yeniden keşfetmesi acı veren türden bir şeydir. Hepsi
[`0003-password-file.patch`](../../patches/0003-password-file.patch) yaması tarafından ele alınır;
aşağıdaki hiçbir şey çalışma zamanında şansa bırakılmaz.

### 1. bionic'te kullanılabilir bir `crypt()` yok

Android'in C kütüphanesi (bionic) ne `crypt()`, ne `crypt_r()`, ne de bir shadow veritabanı sağlar. NDK
hiçbir `<crypt.h>` sunmaz. Dolayısıyla Dropbear'ın `crypt(password, salt)` çağıran ve `/etc/shadow` ile
karşılaştıran standart parola yolu Android'de ne derlenebilir ne de çalıştırılabilir. Bağlanacak bir
`libcrypt` de yoktur ve yalnızca bir parola özeti için OpenSSL'in `libcrypto`'sunu içeri çekmek, statik
bir ikili için büyük, hantal bir bağımlılık olurdu.

**Yanıtımız:** `crypt()`'i hiç kullanmamak. Parola kimlik doğrulaması, sunulan parolayı bir özet dosyası
(`DROPBEAR_PASSWD_FILE`) karşısında **PBKDF2-HMAC-SHA256** ile doğrular, bu açık, standart, tuzlu,
yinelemeli bir KDF'dir. Dosya biçimi [`patches/README.md`](../../patches/README.md) içinde belgelenmiştir.

### 2. `sysoptions.h` içindeki derleme zamanı koruması

Herhangi bir kod çalışmadan önce bile Dropbear derlemeyi reddeder:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

`HAVE_CRYPT` tanımsızken (bionic'te her zaman) ve parola kimlik doğrulaması etkinken bu, sert bir
`#error`'dur. Doğrulayıcımız `crypt()`'i asla çağırmadığından, `0003` yaması **bu korumayı kaldırır**.
(«En az bir kimlik doğrulama yöntemi etkin olmalı» denetimini dokunulmadan bırakır.)

### 3. libtomcrypt tuzağı: PBKDF2 derlemeyle *dışarı* alınır

Dropbear, PBKDF2'yi *gerçekten* içeren kırpılmış bir **libtomcrypt** gömer (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). Bariz çözüm onu çağırmaktır. Bu, birbirini pekiştiren iki nedenle işe
yaramaz:

- **Prototip gizlidir.** `pkcs_5_alg2` yalnızca `tomcrypt_pkcs.h` içinde `#ifdef LTC_PKCS_5` içinde
  bildirilir. Dropbear'ın *kendi* kaynak dosyaları `LTC_PKCS_5` tanımlı olarak derlenmez, bu yüzden
  bildirim görünmez ve derleyici *implicit function declaration* hatası verir.
- **Sembol yoktur.** Daha kötüsü, `pkcs_5_alg2`'nin *gövdesi* de `#ifdef LTC_PKCS_5` arkasındadır.
  Dropbear'ın libtomcrypt derlemesi onu tanımlamaz, bu yüzden `pkcs_5_2.o` **boş bir nesneye** derlenir:
  `libtomcrypt.a` içindedir ama hiçbir `pkcs_5_alg2` sembolü içermez. Bağlama
  `undefined symbol: pkcs_5_alg2` ile başarısız olur.

Bunu kendiniz görebilirsiniz:

```sh
# nesne var ama boş (T pkcs_5_alg2 yok):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> yalnızca bir veri işaretçisi, pkcs_5_alg2 yok

# HMAC ise tam derlenmiştir (Dropbear onu SSH MAC'leri için kullanır):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> hmac_memory tanımlar
```

**Yanıtımız:** PBKDF2'yi Dropbear'ın *gerçekten* derlediği ilkeller üzerine kendimiz inşa etmek.
`hmac_memory` ve kayıtlı `sha256` özeti ikisi de mevcut ve bağlanabilir, bu yüzden `0003` yaması
PBKDF2-HMAC-SHA256'yı doğrudan uygular (RFC 2898; tek bir 32 baytlık çıktı bloğu, çünkü SHA-256 için
`dkLen == hLen`). `hmac_memory`'yi kendimiz bildiririz (yukarıdakiyle aynı gizli prototip sorunu) ve
nesne bağlama anında `libtomcrypt.a`'dan çekilir. Sonuç standart PBKDF2'dir ve dolayısıyla
birlikte çalışabilirdir: WebUI'nin tarayıcının **WebCrypto** `deriveBits`'iyle hesapladığı özet,
sunucunun hesapladığıyla bayt bayt aynıdır, üçüncü, bağımsız bir uygulama olarak Python'ın
`hashlib.pbkdf2_hmac`'ine karşı doğrulanmıştır.

> **Kısacası:** Android size hiçbir `crypt()` vermez ve Dropbear'ın gömülü PBKDF2'si hiçliğe derlenir.
> Buradaki parola kimlik doğrulaması, crypt() derleme koruması kaldırılmış olarak libtomcrypt'in HMAC'i
> üzerine sıfırdan bir PBKDF2-HMAC-SHA256'dır. OpenSSL/`libcrypto` yok, gizleme yok, sistem shadow'u yok.

---

## Dinamik, static-PIE değil

İkili dosyalar **dinamiktir** (`/system/bin/linker64` üzerinden sistem bionic'ine bağlı), statik değil.
Bu önemlidir ve zor yoldan öğrenildi, **gerçek bir cihazda**, CI'da değil:

- **static-PIE** bir derleme *iyi görünür* (`file` temiz bir `static-pie executable` bildirir) ve hatasız
  bağlanır, ama **cihazda çalıştığı anda SIGSEGV verir** (bir arm64 Android 16 telefonunda doğrulandı,
  exit 139, kullanışlı tombstone yok). Android'de statik yürütülebilirler kırılgandır, güvenilir biçim
  normal dinamik bir ikilidir ki bu, yerleşik her Android dropbear'ının da dağıtılma biçimidir.
- **statik, non-PIE** bir derleme başlamaz bile: bionic onu şununla reddeder:
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Yani derleme **dinamiktir** (`STATIC=1` olmadan `make`; `-pie`), yalnızca her cihazda bulunan bionic
  libc'ye bağlanır. libtomcrypt hâlâ ikiliye statik olarak gömülüdür, bu yüzden dağıtılacak ekstra bir
  kütüphane yoktur.

Test için ders: **`qemu-aarch64` (qemu-user) burada geçerli bir smoke test değildir** (o da bu ikililerde
segfault verir), başarılı bir derleme+bağlama da değildir. **İkiliyi gerçek bir arm64 Android cihazında
çalıştırın.** (Bu tam olarak şöyle doğrulandı: daemon, canlı bir cihazda
alternatif bir portta başlatıldı ve bir parola girişinin başarılı olduğu, yanlış bir parolanın
reddedildiği doğrulandı.)

## `-E` bayrağı yok

Sunucu `--disable-syslog` ile derlenir, bu yüzden her zaman stderr'e kaydeder ve upstream'in `-E`
seçeneği ("log to stderr") bu ikilide **yoktur**, onu geçmek `Invalid option -E` yazdırır ve daemon asla
başlamaz. Bu yüzden modülün argüman oluşturucusu `-E`'yi geçmez.

## openpty

Etkileşimli PTY oturumları `openpty()` kullanır. bionic onu `<pty.h>` içinde bildirir ve Dropbear'ın
çapraz `configure`'u onu NDK ile algılar (`HAVE_OPENPTY` ayarlanır, `HAVE_PTY_H 1`), bu yüzden **hiçbir
yama gerekmez**, PTY'ler hemen çalışır. (exec, SFTP, rsync ve port yönlendirme gibi etkileşimsiz kullanım
zaten ona bağlı değildir.)

## Gömülü araçlar: sftp-server, scp, rsync

`scripts/build-bundles.sh` dosya aktarım araçlarını `module/bin/<abi>/` içine dinamik ikililer olarak
çapraz derler. CI onu `build.sh`'den hemen sonra çalıştırır.

- **rsync** (gömülü popt + zlib ile), configure'una bionic'te `lutimes` olmadığını söyler söylemez temiz
  derlenir (`ac_cv_func_lutimes=no`).
- **sftp-server** ve **scp**, `--without-openssl` ile derlenen **OpenSSH portable**'dan gelir (OpenSSH'in
  yerleşik kriptosu bu ikisi için yeterlidir), bu betiğin önce derlediği küçük, statik bir **zlib** ile.

Android'de OpenSSH, yukarıdaki crypt() hikâyesi kadar müşküldür, çünkü `configure`'u çapraz derlerken
birkaç libc işlevini yanlış algılar. Betik düzeltmeyi kodlar, kayıt için parçalar şunlardır:

1. **bionic'te eksik olan ama configure'un var sandığı işlevlerin bir önbellek seed'i**, böylece onların
   yerine compat sürümleri derlenir: `recallocarray`, `close_range`, `getentropy`, `getrandom`,
   `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Bunlar olmadan OpenSSH'in
   `defines.h`'si `#define __sentinel__` (boş) yapar, bu da sonra bionic'in `<unistd.h>` içindeki kendi
   `__attribute__((__sentinel__(1)))`'ini bozar ve her derleme `expected ')'` ile başarısız olur.
3. **`memset` kullanan bir `explicit_bzero` compat'ı.** bionic'in `bzero`'su işlev benzeri bir makrodur
   (gerçek bir sembol değil), bu yüzden OpenSSH'in `&bzero`'yu işlev işaretçisi olarak alan varsayılan
   compat'ı derlenmez. bionic'in kendi `explicit_bzero`'su yoktur.
4. **compat kütüphanesinden `xcrypt.o` ve `getrrsetbyname.o`'yu düşürmek.** `xcrypt.c`,
   `getpwent()`/`crypt()`'i koşulsuz çağırır (bionic'te ikisi de yok) ve `getrrsetbyname.c`, bionic'in
   açığa çıkarmadığı resolver iç yapılarını kullanır. İkisi de `sftp-server` veya `scp` tarafından
   kullanılmaz.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray`, (1)'deki işlevlerin ayna görüntüsüdür: bionic
   onu API 24'te *bildirmez*, bu yüzden OpenSSH kendi compat'ını derler, ama **sembol** `libc.a` içinde
   gerçekten vardır, bu yüzden ikisi bağlama anında çakışır. Yinelemeye izin vermek bionic'inkini alır,
   ki bu sorun değildir.
6. **`pwcopy()` içinde `pw_gecos`'u NULL'a karşı korumak.** bionic'in `getpwuid()`'i `NULL` bir
   `pw_gecos` döndürür (Android bir GECOS alanı tutmaz). OpenSSH'in `pwcopy()`'si `pw_passwd`'ı `NULL`'a
   karşı korur ama `pw_gecos`'u korumaz, bu yüzden `sftp-server`, bir oturum açıldığı anda başlangıçta
   `xstrdup(NULL)`'a ulaşır ve SIGSEGV verir. (`scp`, eski protokol üzerinden `pwcopy`'yi asla çağırmaz,
   bu yüzden SFTP çalışmazken o çalışıyordu.) Derleme, `pw_gecos`'u `""`'ye birleştirmek için `pwcopy()`'yi
   yamalar.

Sabitlenmiş sürümler `scripts/build-bundles.sh`'in en üstündedir (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Tek bir ABI'yi elle yeniden üretme

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

> _Bu belgeler Claude (Anthropic) ile oluşturulmuş olup VD171 tarafından yürütülmektedir. Düzeltmeler ve iyileştirmeler memnuniyetle karşılanır, bkz. [CONTRIBUTING.md](CONTRIBUTING.md)._
