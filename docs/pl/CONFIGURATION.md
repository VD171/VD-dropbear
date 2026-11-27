<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../id/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · Polski · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Konfiguracja

Ustawienia znajdują się w `/data/adb/vddropbear/config` (zasiewane z `module/common/config.default`
przy pierwszym rozruchu). **WebUI** edytuje ten plik za Ciebie, możesz też edytować go ręcznie. Jest
on wczytywany jako skrypt powłoki, więc używaj `KEY=value` bez spacji wokół `=`. Ustawienia nie są
sekretem i znajdują się w magazynie szyfrowanym na poziomie urządzenia, sekrety (klucze hosta,
autoryzowane klucze, hashe haseł) znajdują się w magazynie sekretów, nigdy tutaj.

Zastosuj zmiany, uruchamiając demona ponownie (robi to opcja **Save & restart** w WebUI).

## Ogólne

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | Uruchom demona przy starcie. `0` całkowicie go wyłącza. |
| `START_IN_BFU` | `0` | `0`: uruchamiaj dopiero po pierwszym odblokowaniu (AFU), sekrety pozostają w magazynie szyfrowanym poświadczeniami (CE). `1`: uruchamiaj także przed pierwszym odblokowaniem (BFU), sekrety trafiają do magazynu szyfrowanego na poziomie urządzenia (DE), czytelnego przed odblokowaniem. |
| `PORT` | `2222` | Domyślny port nasłuchu (porty dla poszczególnych powiązań mogą go nadpisać w `LISTEN_ADDRESSES`). |

## Nasłuch / powiązania (składalne)

Dozwolona jest dowolna kombinacja, wybrane powiązania są łączone. Jeśli wyczyścisz wszystko, VD
Dropbear powiąże się z loopbackiem zamiast z każdym interfejsem.

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Nasłuchuj tylko na `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Nasłuchuj na każdym interfejsie (`0.0.0.0` / `::`), naraża urządzenie. |
| `LISTEN_IPV4` | `1` | Uwzględnij powiązania IPv4. |
| `LISTEN_IPV6` | `1` | Uwzględnij powiązania IPv6. |
| `LISTEN_ADDRESSES` | `""` | Dodatkowe konkretne powiązania, oddzielone przecinkami: `addr` (używa `PORT`) lub `addr:port`, IPv4 lub IPv6. |

> **SSH przez USB (bez wifi, bez ADB).** Włącz w telefonie **tethering USB** i dodaj jego adres USB (zwykle `192.168.42.129`) do `LISTEN_ADDRESSES`, z wyłączonym `LISTEN_ALL`. Demon jest wtedy osiągalny tylko przez kabel, co przy dużych transferach jest zwykle szybsze i stabilniejsze niż bezprzewodowo.

## Tożsamość

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Wysyłaj neutralny banner tożsamości SSH, aby skanery nie mogły rozpoznać dokładnego serwera/wersji. |
| `IDENT_STRING` | `""` | Niestandardowy ciąg tożsamości. Pusta wartość używa neutralnego, wbudowanego domyślnego. |

## Uwierzytelnianie

Logowanie działa na koncie, którym się uwierzytelniasz: domyślnie **root** lub konto o niższych uprawnieniach (`shell`, `system`). Klucze są domyślne, hasła są opcjonalne.

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Zezwól na logowanie kluczem publicznym (odczytuje autoryzowane klucze w magazynie sekretów). |
| `PASSWORD_AUTH` | `0` | Zezwól na logowanie hasłem. Gdy wyłączone, demon jest uruchamiany z wyłączonym uwierzytelnianiem hasłem. |
| `MAX_AUTH_TRIES` | `3` | Maksymalna liczba prób uwierzytelnienia na połączenie. |

## Sesja / środowisko

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Powłoka logowania (ścieżka bezwzględna). Pusta wartość używa domyślnej dla konta. |
| `HOME_DIR` | `/data/adb` | `HOME` i katalog startowy sesji (ścieżka bezwzględna). Pusta wartość używa katalogu domowego roota (`/`). |
| `EXTRA_ENV` | `""` | Dodatkowe środowisko, `K=V;K2=V2` (wymaga włączonego `PASS_ENV`). |
| `IDLE_TIMEOUT` | `0` | Rozłącz po N sekundach bezczynności. `0` wyłącza. |
| `KEEPALIVE` | `0` | Wysyłaj keepalive co N sekund. `0` wyłącza. |
| `RECEIVE_WINDOW` | `""` | Rozmiar okna odbioru Dropbeara. Pusta wartość używa domyślnego. |

## Przekierowywanie (domyślnie wyłączone)

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Zezwól na lokalne (`-L`) przekierowywanie portów. |
| `ALLOW_REMOTE_FORWARD` | `0` | Zezwól na zdalne (`-R`) przekierowywanie portów. |
| `GATEWAY_PORTS` | `0` | Pozwól przekierowanym zdalnym portom wiązać się ze wszystkimi interfejsami. |

## Klucz hosta

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Typ klucza hosta: `ed25519` lub `ecdsa`. Generowany przy pierwszym uruchomieniu do magazynu sekretów. |

> **RSA został usunięty jako typ klucza hosta**: jego przestarzałe podpisy `ssh-rsa` (SHA-1) są niebezpieczne, a `ed25519` i `ECDSA` są nowoczesne, znacznie silniejsze i szybsze.

## Magazyn sekretów

Nie konfigurowany tutaj, ustalany na podstawie `START_IN_BFU`:

- **AFU (domyślnie):** `/data/misc_ce/0/vddropbear/secret`: szyfrowany poświadczeniami, dostępny
  dopiero po odblokowaniu urządzenia.
- **BFU:** `/data/adb/vddropbear/secret`: szyfrowany na poziomie urządzenia, czytelny przed pierwszym odblokowaniem.

Przechowuje klucz hosta, `authorized_keys` oraz plik z hashem `passwd`. Format hashu hasła opisuje
[BUILDING.md](../BUILDING.md).

<!-- doc-footer -->

---

> _Ta dokumentacja została wygenerowana za pomocą Claude (Anthropic) i jest utrzymywana przez VD171. Poprawki i ulepszenia są mile widziane, zobacz [CONTRIBUTING.md](CONTRIBUTING.md)._
