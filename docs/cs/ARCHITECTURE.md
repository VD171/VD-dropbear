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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · Čeština · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Architektura

VD Dropbear je modul pro KernelSU / APatch / Magisk, který spouští přesně jeden démon Dropbear SSH,
řízený výhradně konfigurací. Na serveru SSH není nic napevno svázáno s jedním zařízením; vše
specifické je buď běhová konfigurace, nebo tajemství.

## Součásti

- `module/common/vddropbear.sh` - základní knihovna: načte konfiguraci (s bezpečnými vestavěnými
  výchozími hodnotami), určí úložiště tajemství, zajistí hostitelský klíč, sestaví vektor argumentů
  Dropbearu a spravuje jedinou instanci démona (start / stop / stav / restart).
- `module/service.sh` - vstupní bod při startu. Respektuje politiku spuštění BFU/AFU; v režimu AFU
  čeká na odemčení úložiště šifrovaného přihlašovacími údaji, aniž by blokoval start.
- `module/action.sh` - tlačítko **Action** ve správci: (znovu)spustí démona. Nikdy nečte stdin
  a odpojí démona do vlastní relace, takže se správce nezasekne.
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - backend WebUI a jeho stránka.
- `patches/` - malé, auditovatelné záplaty aplikované na upstreamový Dropbear při sestavení.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - sestavení.

## Životní cyklus démona (jediná instance)

`vddb_start` načte konfiguraci, zastaví případnou běžící instanci, zajistí existenci hostitelského
klíče a poté spustí jednoho démona. Binárka se dodává jako `vddropbear`, takže název jejího procesu
přesně odpovídá `pgrep -x` (Android `mksh` nemá `exec -a`). Spouští se přes `setsid`, aby se odpojila
od skupiny procesů volajícího - právě to brání tomu, aby se tlačítko Action ve správci zablokovalo.

## Úložiště tajemství (CE vs DE, BFU vs AFU)

Nastavení nejsou tajná a leží na úložišti šifrovaném zařízením (`/data/adb/vddropbear`), čitelném při
startu. Tajemství - hostitelský klíč, `authorized_keys`, otisky hesel - jsou ve výchozím nastavení na
úložišti **šifrovaném přihlašovacími údaji** (`/data/misc_ce/0/vddropbear`), které se odemkne až po
ověření uživatele. Zapnutí `START_IN_BFU` přesune tajemství na úložiště šifrované zařízením, aby mohl
démon běžet před prvním odemčením, za cenu toho, že jsou tato tajemství čitelná dříve. Modul při každé
fázi startu určí, které úložiště použít.

## Sada záplat

Server SSH zůstává upstreamovým Dropbearem; naše změny jsou jen několik přezkoumatelných záplat (viz
[patches/README.md](../../patches/README.md)):

- neutrální banner identity konfigurovatelný za běhu;
- `authorized_keys` čtené z cesty nastavené prostředím (aby klíče ležely v úložišti tajemství);
- ověřování heslem proti souboru otisků PBKDF2 místo systémového `crypt()`/shadow, který Androidu
  chybí (viz [BUILDING.md](../BUILDING.md)).

## WebUI

Statická stránka ve WebUI správce (KernelSU / APatch / WebUI-X). Řídí
`module/common/vddb-webui.sh` přes most `ksu.exec`: stav, start/stop/restart, čtení/zápis konfigurace
a správu klíčů a účtů s heslem. Všechna data procházejí mostem zakódovaná v base64, takže je shell
nikdy neinterpretuje; otisky hesel se počítají v prohlížeči pomocí WebCrypto, takže heslo v čitelné
podobě nikdy stránku neopustí.
