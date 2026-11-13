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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · Polski · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Architektura

VD Dropbear to moduł KernelSU / APatch / Magisk, który uruchamia dokładnie jednego demona SSH
Dropbear, sterowanego w całości konfiguracją. Nic w serwerze SSH nie jest zakodowane na stałe pod
jedno urządzenie; wszystko, co specyficzne, to konfiguracja uruchomieniowa lub sekret.

## Elementy

- `module/common/vddropbear.sh`: główna biblioteka: wczytanie konfiguracji (z bezpiecznymi
  wbudowanymi wartościami domyślnymi), ustalenie magazynu sekretów, zapewnienie klucza hosta, zbudowanie
  wektora argumentów Dropbeara i zarządzanie pojedynczą instancją demona (start / stop / status / restart).
- `module/service.sh`: punkt wejścia przy starcie. Respektuje politykę uruchamiania BFU/AFU; w trybie
  AFU czeka na odblokowanie magazynu szyfrowanego poświadczeniami, nie blokując rozruchu.
- `module/action.sh`: przycisk **Action** menedżera: (ponowne) uruchomienie demona. Nigdy nie czyta
  stdin i odłącza demona do jego własnej sesji, więc menedżer się nie zawiesza.
- `module/common/vddb-webui.sh` + `module/webroot/index.html`: backend i strona WebUI.
- `patches/`: małe, audytowalne łatki nakładane na oryginalny Dropbear w czasie budowania.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml`: proces budowania.

## Cykl życia demona (pojedyncza instancja)

`vddb_start` wczytuje konfigurację, zatrzymuje każdą działającą instancję, zapewnia istnienie klucza
hosta, a następnie uruchamia jednego demona. Plik binarny jest dostarczany jako `vddropbear`, więc jego
nazwa procesu dokładnie pasuje do `pgrep -x` (androidowy `mksh` nie ma `exec -a`). Jest uruchamiany
przez `setsid`, dzięki czemu odłącza się od grupy procesów wywołującego. I właśnie to sprawia, że
przycisk Action menedżera się nie blokuje.

## Magazyn sekretów (CE a DE, BFU a AFU)

Ustawienia nie są sekretem i znajdują się w magazynie szyfrowanym na poziomie urządzenia
(`/data/adb/vddropbear`), czytelnym przy starcie. Sekrety (klucz hosta, `authorized_keys`, hashe haseł)
domyślnie trafiają do magazynu **szyfrowanego poświadczeniami** (`/data/misc_ce/0/vddropbear`), który
odblokowuje się dopiero po uwierzytelnieniu użytkownika. Włączenie `START_IN_BFU` przenosi sekrety do
magazynu szyfrowanego na poziomie urządzenia, aby demon mógł działać przed pierwszym odblokowaniem,
kosztem tego, że te sekrety stają się czytelne wcześniej. Moduł na każdym etapie rozruchu wylicza,
którego magazynu użyć.

## Zestaw łatek

Serwer SSH pozostaje oryginalnym Dropbearem; nasze zmiany to kilka łatek do przejrzenia (zobacz
[patches/README.md](../../patches/README.md)):

- neutralny, konfigurowalny w czasie działania banner tożsamości;
- `authorized_keys` odczytywane ze ścieżki ustawionej w środowisku (aby klucze znajdowały się w magazynie sekretów);
- uwierzytelnianie hasłem względem pliku z hashem PBKDF2 zamiast systemowego `crypt()`/shadow, którego
  Androidowi brakuje (zobacz [BUILDING.md](../BUILDING.md)).

## WebUI

Statyczna strona w WebUI menedżera (KernelSU / APatch / WebUI-X). Steruje ona
`module/common/vddb-webui.sh` poprzez most `ksu.exec`: status, start/stop/restart, odczyt/zapis
konfiguracji oraz zarządzanie kluczami i kontami hasłowymi. Wszystkie dane przechodzą przez most
zakodowane w base64, więc powłoka nigdy ich nie interpretuje; hashe haseł są obliczane w przeglądarce za
pomocą WebCrypto, więc hasło w postaci jawnej nigdy nie opuszcza strony.
