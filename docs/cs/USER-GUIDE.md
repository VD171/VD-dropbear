<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · Čeština · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Uživatelská příručka

VD Dropbear dává tvému rootnutému zařízení soukromý server SSH. Tato příručka tě provede od instalace
po funkční spojení, včetně přenosu souborů a režimu před prvním odemčením (BFU).

> **Každé ověřené spojení dostane root shell.** Upřednostňuj klíče před hesly, naváž jen na sítě,
> kterým důvěřuješ, a nikdy nevystavuj port do otevřeného internetu bez důvodu.

## 1. Instalace

Nahraj zip modulu ve správci **KernelSU**, **APatch** nebo **Magisk** (nebo z shellu pomocí
`ksud module install` / `apd module install`) a poté otevři **WebUI** modulu.

## 2. Přidej klíč (doporučeno)

Ve WebUI pod **Authorized keys** vlož svůj veřejný klíč (`ssh-ed25519 AAAA... you@host`) a stiskni
**Add key**. Klíče jsou výchozí a nejbezpečnější způsob vstupu.

Pokud na svém počítači žádný nemáš, klíč vygeneruješ takto:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Nebo nastav heslo

Přihlášení heslem je ve výchozím stavu vypnuté (každé přihlášení je root, takže se upřednostňují
klíče). Chceš-li jej zapnout, zapni v nastavení **Password login** a poté pod **Password accounts**
nastav heslo pro přihlašovacího uživatele. Otisk se počítá v tvém prohlížeči pomocí PBKDF2; samotné
heslo nikdy stránku neopustí.

## 4. Zvol port a kde naslouchat

Pod **Settings** nastav **Port** a vyber vazby. VD Dropbear ve výchozím stavu naslouchá jen na
**loopbacku**; abys k němu dosáhl ze své LAN nebo VPN, povol rozhraní, která chceš. Vyhni se
**Listen on all interfaces**, pokud nerozumíš tomu, co tím vystavuješ.

Stiskni **Save & restart** pro uplatnění a poté **Start**, pokud už neběží.

## 5. Připoj se

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` a `rsync` jsou přibaleny, takže SFTP, `sshfs`, grafičtí klienti i zálohy fungují
přes totéž spojení.

## 6. Před prvním odemčením (BFU)

Ve výchozím stavu démon startuje až **poté**, co jednou odemkneš zařízení (AFU), protože jeho
tajemství leží na úložišti šifrovaném přihlašovacími údaji. Pokud potřebuješ SSH **před** prvním
odemčením - například abys zařízení po restartu odemkl na dálku - zapni
**Start before first unlock (BFU)**. Tajemství se pak přesunou na úložiště šifrované zařízením,
čitelné před odemčením: záměrný, zdokumentovaný kompromis. Viz [Bezpečnostní model](#) v README.

## 7. Ovládání démona

- **WebUI:** Start / Stop / Restart a živý stav (běží, PID, port, režim, otisk hostitelského klíče).
- **Tlačítko Action ve správci:** (znovu)spustí démona.
- Startuje také automaticky při bootu (pokud jej nevypneš).

## Řešení potíží

- **Nechce nastartovat.** Zkontroluj `/data/adb/vddropbear/state/daemon.log`. Ujisti se, že je
  **Enabled** zapnuto a že se podařilo vygenerovat hostitelský klíč.
- **Klíč odmítnut.** Ověř, že řádek veřejného klíče je přesně takový, jaký nabízí tvůj klient, a že
  je přihlašovací uživatel takový, jaký systém rozpozná (obvykle `root`).
- **Nejde se připojit z jiného stroje.** Nejspíš jsi stále navázán jen na loopback - povol potřebné
  rozhraní a restartuj.
- **SFTP/scp selhává, ale shell funguje.** Ujisti se, že přibalený `sftp-server` byl dodán pro tvou
  ABI; stav ve WebUI ukazuje zjištěnou ABI.
