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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · Svenska · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Användarguide

VD Dropbear ger din root-enhet en privat SSH-server. Den här guiden tar dig från installation till en
fungerande anslutning, inklusive filöverföring och läget före första upplåsning (BFU).

> **En inloggning ger som standard ett fullständigt root-skal.** Föredra nycklar framför lösenord, bind bara till
> nätverk du litar på, och exponera aldrig porten mot det öppna internet utan skäl.

## 1. Installera

Flasha modulens zip i **KernelSU**-, **APatch**- eller **Magisk**-hanteraren (eller från ett skal med
`ksud module install` / `apd module install`), öppna sedan modulens **WebUI**.

## 2. Lägg till en nyckel (rekommenderas)

I WebUI:n, under **Authorized keys**, klistra in din publika nyckel (`ssh-ed25519 AAAA... you@host`) och
tryck på **Add key**. Nycklar är standard och det säkraste sättet in.

Så här genererar du en nyckel på din dator, om du inte har någon:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Eller ange ett lösenord

Lösenordsinloggning är av som standard (en inloggning är som standard root, så nycklar är att föredra). För att
aktivera den, slå på **Password login** i inställningarna, ange sedan under **Password accounts** ett
lösenord för inloggningsanvändaren. Hashen beräknas i din webbläsare med PBKDF2; själva lösenordet
lämnar aldrig sidan.

## 4. Välj en port och var du vill lyssna

Under **Settings**, ange **Port** och välj bindningarna. Som standard lyssnar VD Dropbear bara på
**loopback**; för att nå den från ditt LAN eller ett VPN, aktivera de gränssnitt du vill ha. Undvik
**Listen on all interfaces** om du inte förstår exponeringen.

Tryck på **Save & restart** för att tillämpa, och sedan **Start** om den inte redan körs.

## 5. Anslut

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` och `rsync` är medföljande, så SFTP, `sshfs`, GUI-klienter och säkerhetskopior
fungerar alla över samma anslutning.

## 6. Före första upplåsning (BFU)

Som standard startar daemonen först **efter** att du har låst upp enheten en gång (AFU), eftersom dess
hemligheter ligger på credential-encrypted lagring. Om du behöver SSH **före** första upplåsningen
(till exempel för att låsa upp en enhet på distans efter en omstart) slå på **Start before first
unlock (BFU)**. Hemligheterna flyttas då till device-encrypted lagring, som är läsbar före upplåsning:
en medveten, dokumenterad avvägning. Se [Säkerhetsmodell](#) i README.

## 7. Styra daemonen

- **WebUI:** Start / Stopp / Omstart, och status i realtid (körning, PID, port, läge, värdnyckelns fingeravtryck).
- **Hanterarens Action-knapp:** (åter)startar daemonen.
- Den startar också automatiskt vid uppstart (om du inte inaktiverar den).

## Felsökning

- **Den startar inte.** Kontrollera `/data/adb/vddropbear/state/daemon.log`. Se till att **Enabled** är
  på och att en värdnyckel kunde genereras.
- **Nyckel avvisad.** Bekräfta att raden med den publika nyckeln är exakt som din klient erbjuder den,
  och att användarnamnet du loggar in som är ett som systemet kan slå upp (vanligtvis `root`).
- **Kan inte ansluta från en annan dator.** Du är troligen fortfarande bunden endast till loopback.
  Aktivera det gränssnitt du behöver och starta om.
- **SFTP/scp misslyckas men skalet fungerar.** Se till att den medföljande `sftp-server` levererades
  för din ABI; WebUI:ns status visar den upptäckta ABI:n.
