<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Configuration reference.

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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · Türkçe · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Yapılandırma

Ayarlar `/data/adb/vddropbear/config` içinde bulunur (ilk önyüklemede `module/common/config.default`
dosyasından oluşturulur). **WebUI** bu dosyayı sizin için düzenler; elle de düzenleyebilirsiniz. Kabuk
olarak source edilir, bu yüzden `=` çevresinde boşluk olmadan `KEY=value` kullanın. Ayarlar sır
değildir ve device-encrypted depoda bulunur; sırlar (host key'ler, authorized key'ler, parola
karmaları) sır deposunda bulunur, asla burada değil.

Değişiklikleri daemon'u yeniden başlatarak uygulayın (WebUI'nin **Save & restart**'ı bunu yapar).

## Genel

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | Daemon'u önyüklemede başlat. `0` onu tamamen devre dışı bırakır. |
| `START_IN_BFU` | `0` | `0`: yalnızca ilk kilit açılışından sonra başlat (AFU); sırlar credential-encrypted (CE) depoda kalır. `1`: ilk kilit açılışından önce de başlat (BFU); sırlar device-encrypted (DE) depoya taşınır, kilit açılmadan önce okunabilir. |
| `PORT` | `2222` | Varsayılan dinleme bağlantı noktası (bağlama başına bağlantı noktaları bunu `LISTEN_ADDRESSES` içinde geçersiz kılabilir). |

## Dinleme / bağlamalar (birleştirilebilir)

Herhangi bir kombinasyona izin verilir; seçilen bağlamalar birleştirilir. Her şeyi temizlerseniz, VD
Dropbear her arabirim yerine loopback'e bağlanır.

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Yalnızca `127.0.0.1` / `::1` üzerinde dinle. |
| `LISTEN_ALL` | `0` | Her arabirimde dinle (`0.0.0.0` / `::`) - cihazı açığa çıkarır. |
| `LISTEN_IPV4` | `1` | IPv4 bağlamalarını dahil et. |
| `LISTEN_IPV6` | `1` | IPv6 bağlamalarını dahil et. |
| `LISTEN_ADDRESSES` | `""` | Ek belirli bağlamalar, virgülle ayrılmış: `addr` (`PORT` kullanır) veya `addr:port`, IPv4 ya da IPv6. |

## Kimlik

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Tarayıcıların tam sunucu/sürümü parmak izleyememesi için nötr bir SSH kimlik banner'ı gönder. |
| `IDENT_STRING` | `""` | Özel bir kimlik dizesi. Boş bırakılırsa nötr yerleşik varsayılan kullanılır. |

## Kimlik doğrulama

Her kimlik doğrulanmış oturum açma **root**'tur. Anahtarlar varsayılandır; parolalar isteğe bağlıdır.

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Genel anahtarla oturum açmaya izin ver (sır deposundaki authorized key'leri okur). |
| `PASSWORD_AUTH` | `0` | Parolayla oturum açmaya izin ver. Kapalıyken daemon, parola kimlik doğrulaması devre dışı olarak başlatılır. |
| `MAX_AUTH_TRIES` | `3` | Bağlantı başına en fazla kimlik doğrulama denemesi. |
| `LOGIN_USER` | `root` | Oturum açılacak hesap. Sistemin çözümleyebileceği bir hesap olmalı (genellikle `root`). |

## Oturum / ortam

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Oturumun kabuğu. Boş bırakılırsa hesabın varsayılanı kullanılır. |
| `HOME_DIR` | `""` | Oturum için `HOME`. Boş bırakılırsa modül dizini kullanılır. |
| `EXTRA_ENV` | `""` | Ek ortam, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | N saniye boşta kaldıktan sonra bağlantıyı kes. `0` devre dışı bırakır. |
| `KEEPALIVE` | `0` | Her N saniyede bir keepalive gönder. `0` devre dışı bırakır. |
| `RECEIVE_WINDOW` | `""` | Dropbear alım penceresi boyutu. Boş bırakılırsa varsayılan kullanılır. |

## Yönlendirme (varsayılan olarak kapalı)

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Yerel (`-L`) bağlantı noktası yönlendirmesine izin ver. |
| `ALLOW_REMOTE_FORWARD` | `0` | Uzak (`-R`) bağlantı noktası yönlendirmesine izin ver. |
| `GATEWAY_PORTS` | `0` | Yönlendirilen uzak bağlantı noktalarının tüm arabirimlere bağlanmasına izin ver. |

## Host key

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Host key türü: `ed25519`, `rsa` veya `ecdsa`. İlk başlatmada sır deposuna oluşturulur. |

## Sır deposu

Burada yapılandırılmaz - `START_IN_BFU`'dan çözümlenir:

- **AFU (varsayılan):** `/data/misc_ce/0/vddropbear/secret` - credential-encrypted, yalnızca cihazın
  kilidini açtıktan sonra kullanılabilir.
- **BFU:** `/data/adb/vddropbear/secret` - device-encrypted, ilk kilit açılışından önce okunabilir.

Host key'i, `authorized_keys`'i ve `passwd` karma dosyasını barındırır. Parola karma biçimi için bkz.
[BUILDING.md](../BUILDING.md).
