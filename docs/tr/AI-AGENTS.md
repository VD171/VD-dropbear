<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   AI agents on your device.

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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · Türkçe · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# Cihazınızdaki yapay zeka ajanları

Sürekli açık bir SSH uç noktası, telefonunuzu **otonom bir yapay zeka ajanının doğrudan
işletebileceği** bir şeye dönüştürür. Bir kabuğu veya bir SSH bağlantısını sürebilen herhangi bir
ajan (Claude Code, aider, döngüde-LLM bulunan bir betik, kendi otomasyonunuz) cihazda, ağ
üzerinden, USB kablosu olmadan ve ADB'nin kendini ele veren hata ayıklama bayrakları olmadan gerçek
bir root oturumu elde eder.

Bu sayfa, README'de tanıtılan fikri genişletir.

## Ajanlar için neden ADB değil de SSH

ADB kendini ilan eder: `adb_enabled` ve `development_settings_enabled` herkes tarafından okunabilir,
bağlantı günlüğe kaydedilir ve hata ayıklamanın açık olduğunu (ya da olmuş olduğunu) gizlemenin
desteklenen bir yolu yoktur. ADB üzerinden çalışan bir ajan, bu izi cihazda herhangi bir uygulamanın
veya dolandırıcılık karşıtı SDK'nın okuyabileceği şekilde bırakır. VD Dropbear özel alternatiftir:
sizin denetlediğiniz kimlik bilgileriyle ve hiçbir şey açığa vurmayan bir banner ile sıradan bir SSH
oturum açması.

## Bir ajan neler yapabilir

Tek bir bağlantı üzerinden, bir ajan sıradan, Linux benzeri bir kabuk görür ve şunları yapabilir:

- dosyaları okuyup düzenleyebilir, ayarları değiştirebilir ve modülleri, paketleri ve hizmetleri yönetebilir;
- günlükleri ayıklayabilir, artefaktları çekebilir ve istek üzerine tanılama veya adli inceleme çalıştırabilir;
- dosyaları `scp` / `sftp` / `rsync` üzerinden her iki yönde taşıyıp eşitleyebilir: yedeklemeler, taşımalar, hazırlık;
- tek bir yerden, her biri kendi anahtarıyla erişilebilen bütün bir root cihaz filosunu sürebilir.

Proje **yapay zeka dostu** olacak şekilde inşa edildiği için (belgelenmiş bir yapılandırma dosyası,
açık bir çalışma zamanı [env sözleşmesi](../../patches/README.md), öngörülebilir yollar ve düz metin
durum bilgisi) bir ajan onu nasıl kullanacağını tahmin yürütmeden keşfedebilir.

## Bunu güvenli yapmak

Bu root'tur, o yüzden ona root gibi davranın:

- ajana kişisel olanınızı değil, kendi **kimlik bilgisini** verin ve erişimini sınırlamak istiyorsanız onu daha düşük ayrıcalıklı bir hesaba (`shell`) yönlendirin;
- bağlamaları güvendiğiniz ağlarla sınırlandırın: açık internet yerine loopback veya bir VPN
  (bkz. [Yapılandırma](CONFIGURATION.md));
- parola kimlik doğrulamasını kapalı tutun; bir anahtar geri alınabilir ve asla yazılmaz;
- bir anahtarı istediğiniz zaman WebUI'den geri alabilir veya daemon'u durdurabilirsiniz;
- varsayılan bir bağlantının tam bir root oturumu olduğunu unutmayın. Ajana yalnızca ihtiyaç duyduğu erişimi verin.

## Asgari bir kurulum

1. Yalnızca ajan için bir anahtar çifti oluşturun.
2. Genel anahtarını WebUI'de ekleyin (**Authorized keys**).
3. Yalnızca loopback'e veya VPN'inize, varsayılan olmayan bir bağlantı noktasında bağlayın.
4. Ajanın SSH yapılandırmasını cihaza yönlendirin ve çalışmasına izin verin.
