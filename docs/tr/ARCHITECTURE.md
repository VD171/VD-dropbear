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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · Türkçe · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Mimari

VD Dropbear, tamamen yapılandırmayla sürülen, tam olarak bir Dropbear SSH daemon'u çalıştıran bir
KernelSU / APatch / Magisk modülüdür. SSH sunucusuyla ilgili hiçbir şey tek bir cihaza sabit
kodlanmamıştır; özgül olan her şey çalışma zamanı yapılandırması veya bir sırdır.

## Parçalar

- `module/common/vddropbear.sh` - çekirdek kitaplık: yapılandırmayı yükler (güvenli yerleşik
  varsayılanlarla), sır deposunu çözümler, bir host key'in var olmasını sağlar, Dropbear argüman
  vektörünü oluşturur ve tek bir daemon örneğini yönetir (başlat / durdur / durum / yeniden başlat).
- `module/service.sh` - önyükleme girişi. BFU/AFU başlatma politikasına uyar; AFU modunda, önyüklemeyi
  tıkamadan credential-encrypted deposunun kilidinin açılmasını bekler.
- `module/action.sh` - yöneticinin **Action** düğmesi: daemon'u (yeniden) başlatır. Asla stdin okumaz
  ve daemon'u kendi oturumuna ayırır, böylece yönetici takılmaz.
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - WebUI arka ucu ve sayfası.
- `patches/` - derleme sırasında upstream Dropbear'a uygulanan küçük, denetlenebilir yamalar.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - derleme.

## Daemon yaşam döngüsü (tek örnek)

`vddb_start` yapılandırmayı yükler, çalışan her örneği durdurur, bir host key'in var olduğundan emin
olur, sonra tek bir daemon başlatır. İkili dosya `vddropbear` olarak gönderilir, böylece işlem adı
`pgrep -x` ile tam olarak eşleşir (Android'in `mksh` kabuğunda `exec -a` yoktur). `setsid` ile
başlatılır, böylece çağıranın işlem grubundan ayrılır - yöneticinin Action'ının bloke olmasını
engelleyen şey budur.

## Sır deposu (CE'ye karşı DE, BFU'ya karşı AFU)

Ayarlar sır değildir ve önyüklemede okunabilen device-encrypted depoda (`/data/adb/vddropbear`)
bulunur. Sırlar - host key, `authorized_keys`, parola karmaları - varsayılan olarak yalnızca kullanıcı
kimlik doğruladıktan sonra kilidi açılan **credential-encrypted** depoda
(`/data/misc_ce/0/vddropbear`) bulunur. `START_IN_BFU`'yu açmak, daemon'un ilk kilit açılışından önce
çalışabilmesi için sırları device-encrypted depoya taşır; bunun bedeli, o sırların daha erken
okunabilir olmasıdır. Modül, her önyükleme aşamasında hangi deponun kullanılacağını hesaplar.

## Yama kümesi

SSH sunucusu upstream Dropbear olarak kalır; değişikliklerimiz birkaç incelenebilir yamadır (bkz.
[patches/README.md](../../patches/README.md)):

- nötr, çalışma zamanında yapılandırılabilir bir kimlik banner'ı;
- ortamda ayarlanan bir yoldan okunan `authorized_keys` (böylece anahtarlar sır deposunda bulunur);
- Android'de bulunmayan sistem `crypt()`/shadow'u yerine bir PBKDF2 karma dosyasına karşı parola
  kimlik doğrulaması (bkz. [BUILDING.md](../BUILDING.md)).

## WebUI

Yöneticinin WebUI'sinde (KernelSU / APatch / WebUI-X) statik bir sayfa. `ksu.exec` köprüsü aracılığıyla
`module/common/vddb-webui.sh`'yi sürer: durum, başlat/durdur/yeniden başlat, yapılandırma
okuma/yazma ve anahtarların ve parola hesaplarının yönetimi. Tüm veriler köprüyü base64 kodlanmış
olarak geçer, böylece kabuk onu asla yorumlamaz; parola karmaları tarayıcıda WebCrypto ile hesaplanır,
böylece açık metin parola asla sayfadan çıkmaz.
