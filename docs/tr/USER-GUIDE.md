<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   User guide.

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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · Türkçe · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Kullanıcı kılavuzu

VD Dropbear, root'lu cihazınıza özel bir SSH sunucusu verir. Bu kılavuz, dosya aktarımı ve ilk kilit
açılışı öncesi (BFU) modu dahil olmak üzere sizi kurulumdan çalışan bir bağlantıya götürür.

> **Kimlik doğrulanmış her bağlantı bir root kabuğu alır.** Parolalar yerine anahtarları tercih edin,
> yalnızca güvendiğiniz ağlara bağlayın ve bağlantı noktasını bir neden olmadan asla açık internete
> açmayın.

## 1. Kur

Modül zip'ini **KernelSU**, **APatch** veya **Magisk** yöneticisinde flaşlayın (veya bir kabuktan
`ksud module install` / `apd module install` ile), sonra modülün **WebUI**'sini açın.

## 2. Bir anahtar ekle (önerilir)

WebUI'de, **Authorized keys** altında, genel anahtarınızı (`ssh-ed25519 AAAA... you@host`) yapıştırın ve
**Add key**'e basın. Anahtarlar varsayılandır ve en güvenli giriş yoludur.

Yoksa, bilgisayarınızda bir anahtar oluşturmak için:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Ya da bir parola belirle

Parolayla oturum açma varsayılan olarak kapalıdır (her oturum açma root'tur, bu yüzden anahtarlar
tercih edilir). Etkinleştirmek için ayarlarda **Password login**'i açın, sonra **Password accounts**
altında oturum açma kullanıcısı için bir parola belirleyin. Karma, tarayıcınızda PBKDF2 ile hesaplanır;
parolanın kendisi asla sayfadan çıkmaz.

## 4. Bir bağlantı noktası ve nerede dinleneceğini seç

**Settings** altında, **Port**'u ayarlayın ve bağlamaları seçin. Varsayılan olarak VD Dropbear yalnızca
**loopback** üzerinde dinler; ona LAN'ınızdan veya bir VPN'den erişmek için istediğiniz arabirimleri
etkinleştirin. Maruziyeti anlamadıkça **Listen on all interfaces**'ten kaçının.

Uygulamak için **Save & restart**'a basın, sonra zaten çalışmıyorsa **Start**'a basın.

## 5. Bağlan

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` ve `rsync` paket içinde gelir, böylece SFTP, `sshfs`, GUI istemcileri ve
yedeklemeler aynı bağlantı üzerinden çalışır.

## 6. İlk kilit açılışından önce (BFU)

Varsayılan olarak daemon, sırları credential-encrypted depoda bulunduğu için yalnızca cihazın kilidini
bir kez açtıktan **sonra** başlar (AFU). İlk kilit açılışından **önce** SSH'ye ihtiyacınız varsa
(örneğin bir yeniden başlatmadan sonra bir cihazın kilidini uzaktan açmak için) **Start before first
unlock (BFU)**'yu açın. Sırlar o zaman, kilit açılmadan önce okunabilen device-encrypted depoya taşınır:
bilinçli, belgelenmiş bir takas. README'deki [Güvenlik modeli](#) bölümüne bakın.

## 7. Daemon'u denetleme

- **WebUI:** Başlat / Durdur / Yeniden başlat ve canlı durum (çalışıyor, PID, bağlantı noktası, mod, host key parmak izi).
- **Yönetici Action düğmesi:** daemon'u (yeniden) başlatır.
- Ayrıca önyüklemede otomatik olarak başlar (siz devre dışı bırakmadıkça).

## Sorun giderme

- **Başlamıyor.** `/data/adb/vddropbear/state/daemon.log`'u kontrol edin. **Enabled**'ın açık
  olduğundan ve bir host key oluşturulabildiğinden emin olun.
- **Anahtar reddedildi.** Genel anahtar satırının istemcinizin sunduğu gibi tam olarak aynı olduğunu ve
  oturum açma kullanıcısının sistemin çözümleyebileceği biri olduğunu (genellikle `root`) doğrulayın.
- **Başka bir makineden bağlanamıyorum.** Muhtemelen hâlâ yalnızca loopback'e bağlısınız. İhtiyacınız
  olan arabirimi etkinleştirin ve yeniden başlatın.
- **SFTP/scp başarısız oluyor ama kabuk çalışıyor.** Paket içindeki `sftp-server`'ın ABI'niz için
  gönderildiğinden emin olun; WebUI durumu algılanan ABI'yi gösterir.
