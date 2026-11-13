<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Security policy.

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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · Türkçe · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Güvenlik Politikası

## Anlaşılması gereken tek şey

VD Dropbear bir SSH sunucusu başlatır ve **başarıyla kimlik doğrulayan her bağlantı bir root kabuğu
alır**. Dolayısıyla cihazınızın güvenliği, bu sunucunun yapılandırmasının ve kimlik bilgilerinin
güvenliğine eşittir. Lütfen:

- **Parolalar yerine genel anahtarları tercih edin.** Parolayla oturum açma varsayılan olarak kapalıdır.
- Parola kullanmanız gerekiyorsa güçlü bir parola kullanın. WebUI bir asgari değer dayatır ve yalnızca bir karma saklar.
- **Bağlantı noktasını kamuya açık internete açmayın.** Loopback'e veya güvenilir bir LAN'a bağlayın
  ya da bir VPN / tünel üzerinden erişin.
- **BFU takasını** anlayın: kilit açılmadan başlatmayı etkinleştirmek, host key'i ve kimlik bilgilerini
  cihaz kilidi açılmadan önce okunabilen device-encrypted depoya yerleştirir. Kilit açılışı öncesi SSH'ye
  ihtiyacınız yoksa kapalı bırakın.
- İhtiyacınız olmadıkça yönlendirmeyi kapalı tutun (varsayılan olarak kapalıdır).

## VD Dropbear yardımcı olmak için neler yapar

- Ağ tarayıcılarının tam sunucu ve sürümü parmak izleyememesi için nötr, bilgi vermeyen bir sürüm
  banner'ı.
- Varsayılan olarak credential-encrypted depoda kimlik bilgileri (yalnızca kilidi açtıktan sonra şifresi çözülür).
- Telemetri yok, kendine ait ağ çağrıları yok, analitik yok. Tamamen cihazınızda çalışır.

## Desteklenen sürümler

Güvenlik düzeltmeleri en son sürüme iner. Sunucu ikilisi upstream Dropbear'ı izler; upstream güvenlik
sürümleri, CI onları aldığı anda yeniden derlenir ve gönderilir.

## Bir güvenlik açığını bildirme

Lütfen güvenlik sorunlarını kamuya açık bir sorun olarak değil, özel olarak bildirin:

- **E-posta:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Sürümü, bir açıklamayı ve (ideal olarak) bir yeniden üretim adımını ekleyin. Bir onay alacaksınız ve
sizinle bir düzeltme ve açıklama zaman çizelgesini koordine edeceğiz. Dropbear'ın kendisindeki güvenlik
açıkları için lütfen <https://matt.ucc.asn.au/dropbear/> adresinden upstream'e de bildirin.
