<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../id/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · Svenska · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Arkitektur

VD Dropbear är en KernelSU- / APatch- / Magisk-modul som kör exakt en Dropbear SSH-daemon, helt styrd
av konfiguration. Ingenting i SSH-servern är hårdkodat till en viss enhet, allt specifikt är
körtidskonfiguration eller en hemlighet.

## Delar

- `module/common/vddropbear.sh`: kärnbiblioteket: läser in konfigurationen (med säkra inbyggda
  standardvärden), löser upp hemlighetslagret, säkerställer en värdnyckel, bygger Dropbears
  argumentvektor och hanterar en enda daemon-instans (start / stopp / status / omstart).
- `module/service.sh`: uppstartsingång. Följer BFU/AFU-startpolicyn, i AFU-läge väntar den på att det
  credential-encrypted lagret ska låsas upp utan att bromsa uppstarten.
- `module/action.sh`: hanterarens **Action**-knapp: (åter)starta daemonen. Den läser aldrig stdin och
  kopplar loss daemonen till sin egen session, så hanteraren hänger sig inte.
- `module/common/vddb-webui.sh` + `module/webroot/index.html`: WebUI:ns backend och sida.
- `patches/`: små, granskningsbara patchar som appliceras på upstream Dropbear vid byggtid.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/release.yml`: bygget.

## Daemonens livscykel (en instans)

`vddb_start` läser in konfigurationen, stoppar varje körande instans, säkerställer att en värdnyckel
finns och startar sedan en daemon. Binären levereras som `vddropbear`, så dess processnamn matchar
`pgrep -x` exakt (Androids `mksh` saknar `exec -a`). Den startas med `setsid` så att den kopplas loss
från anroparens processgrupp: det är det som gör att hanterarens Action inte blockerar.

`setsid` täckte aldrig cgroups, och den luckan var en riktig regression: Action-knappen och WebUI körs
inuti hanterarappen, så en daemon som startats från endera ärvde appens freezer cgroup
(`/apps/uid_<uid>/pid_<pid>`). Androids `CachedAppOptimizer` fryser den cgroup så snart den cachar
appen, och daemonen fryses med den medan den fortfarande håller sin lyssnande socket. TCP-anslutningar
fortsätter att slutföras eftersom backloggen bor i kärnan, men ingenting anropar `accept()`, så
klienter hänger sig vid "Connection established ... Local version string" utan fel på någondera sidan,
och `/proc/<pid>/wchan` visar `do_freezer_trap` i stället för `do_select`. `vddb_escape_freezer`
flyttar nu det spawnande skalet till root-cgroup (som freezern aldrig rör) före forken, så att
daemonen ärver denna exit. Det är en no-op vid uppstart (redan på `/`) och på plattformar utan
freezer, "förenkla" inte spawnen tillbaka till ett naket `setsid`.

## Hemlighetslagret (CE kontra DE, BFU kontra AFU)

Inställningar är inte hemliga och ligger på device-encrypted lagring (`/data/adb/vddropbear`), läsbar
vid uppstart. Hemligheter (värdnyckel, `authorized_keys`, lösenordshashar) hamnar som standard på
**credential-encrypted** lagring (`/data/misc_ce/0/vddropbear`), som bara låses upp efter att
användaren autentiserat sig. Att slå på `START_IN_BFU` flyttar hemligheterna till device-encrypted
lagring så att daemonen kan köra före första upplåsningen, till priset av att dessa hemligheter blir
läsbara tidigare. Modulen räknar ut vilket lager som ska användas i varje uppstartssteg.

## Patchuppsättningen

SSH-servern förblir upstream Dropbear, våra ändringar är ett fåtal granskningsbara patchar (se
[patches/README.md](../../patches/README.md)):

- en neutral, körtidskonfigurerbar identitetsbanner;
- `authorized_keys` läses från en sökväg satt via miljön (så att nycklar ligger i hemlighetslagret);
- lösenordsautentisering mot en PBKDF2-hashfil i stället för systemets `crypt()`/shadow, som Android
  saknar (se [BUILDING.md](../BUILDING.md)).

## WebUI:n

En statisk sida i hanterarens WebUI (KernelSU / APatch / WebUI-X). Den driver
`module/common/vddb-webui.sh` genom `ksu.exec`-bryggan: status, start/stopp/omstart, läsning/skrivning
av konfiguration och hantering av nycklar och lösenordskonton. All data passerar bryggan
base64-kodad, så skalet tolkar den aldrig, lösenordshashar beräknas i webbläsaren med WebCrypto, så det
klartextlösenordet lämnar aldrig sidan.

<!-- doc-footer -->

---

> _Denna dokumentation genererades med Claude (Anthropic) och underhålls av VD171. Rättelser och förbättringar välkomnas, se [CONTRIBUTING.md](CONTRIBUTING.md)._
