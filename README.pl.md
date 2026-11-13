<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.

   Copyright (C) 2026  VD171
   SPDX-License-Identifier: Apache-2.0

   Licensed under the Apache License, Version 2.0; you may obtain a copy at
   http://www.apache.org/licenses/LICENSE-2.0

   Site           : https://vd171.ru
   Site           : https://vd.priv8.ru
   Source         : https://github.com/VD171/VD-dropbear
   GitHub         : @VD171 https://github.com/VD171
   XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

<p align="center">
  <img src="module/webroot/assets/logo-wordmark.svg" alt="VD Dropbear" width="540">
</p>

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-1a7f37" alt="License"></a>
  <img src="https://img.shields.io/badge/KernelSU-%E2%9C%94-635bff" alt="KernelSU">
  <img src="https://img.shields.io/badge/APatch-%E2%9C%94-ff7043" alt="APatch">
  <img src="https://img.shields.io/badge/Magisk-%E2%9C%94-00af9c" alt="Magisk">
  <a href="https://github.com/VD171/VD-dropbear/stargazers"><img src="https://img.shields.io/github/stars/VD171/VD-dropbear?color=d29922" alt="Stars"></a>
  <a href="https://github.com/VD171/VD-dropbear/releases"><img src="https://img.shields.io/github/v/release/VD171/VD-dropbear?color=1a7f37" alt="Release"></a>
</p>

**Samodzielny, w pełni konfigurowalny serwer SSH [Dropbear](https://matt.ucc.asn.au/dropbear/)**,
dostarczany jako moduł KernelSU / APatch / Magisk. Uruchamia się samodzielnie i nie zależy od żadnego innego modułu.

> ⚠️ **Każde połączenie, które się uwierzytelni, otrzymuje powłokę ROOT.** Traktuj to jak klucze do
> urządzenia: preferuj klucze publiczne zamiast haseł i trzymaj port z dala od publicznego internetu.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Dlaczego

Wbudowany sposób Androida na uzyskanie powłoki we własnym telefonie to ADB (debugowanie USB), a jego
włączenie jest inwazyjne i zdradza użytkownika. `adb_enabled` i `development_settings_enabled` to ustawienia
odczytywalne przez wszystkich - każda aplikacja, SDK czy biblioteka antyfraudowa / RASP może je odczytać,
połączenie jest logowane, a nie ma wspieranego sposobu, aby ukryć, że ADB jest, lub kiedykolwiek było,
włączone. To ujawnienie towarzyszy ci nawet na fabrycznym, nierootowanym telefonie: aby uzyskać powłokę,
musisz to ogłosić.

VD Dropbear to prywatna alternatywa. Na zrootowanym urządzeniu daje prawdziwy serwer SSH - powłokę root,
SFTP i rsync przez sieć - bez śladu `adb_enabled`, bez flagi debugowania USB, z banerem wersji, który niczego
nie ujawnia, i z poświadczeniami, które kontrolujesz. Twój dostęp pozostaje twój, zamiast globalnie
odczytywalnej flagi „jestem debugowany", którą może przeczytać cokolwiek na urządzeniu.

## Funkcje

- **Jeden demon, zawsze.** Uruchamia się przy starcie systemu i z przycisku **Action** w menedżerze, a z
  poziomu WebUI możesz go w dowolnej chwili **uruchomić / zatrzymać / zrestartować**; nigdy więcej niż jedna instancja.
- **Wszystko jest konfigurowalne** z WebUI (lub `/data/adb/vddropbear/config`):
  - port oraz bind na loopback / all / IPv4 / IPv6 / konkretne adresy
  - **start przed pierwszym odblokowaniem (BFU) lub dopiero po nim (AFU)** - jeden przełącznik
  - uwierzytelnianie kluczem publicznym i/lub hasłem, maksymalna liczba prób uwierzytelnienia
  - użytkownik logowania, powłoka, `HOME`, dodatkowe environment
  - idle timeout, keepalive, receive window
  - lokalne / zdalne przekierowanie portów oraz gateway ports (wszystko domyślnie **wyłączone**)
  - typ host-key (ed25519 / rsa / ecdsa)
- **Ukryty baner wersji.** Protokół SSH wymaga *jakiegoś* banera, więc nie można go usunąć, ale VD Dropbear
  zastępuje go nieinformatywnym, dzięki czemu skanery nie mogą zidentyfikować dokładnego serwera ani wersji
  i wycelować w niego ataków na znane wersje.
- **Sekrety przechowywane rozsądnie** (zobacz [Model bezpieczeństwa](#security-model)).
- **Przynieś własne poświadczenia.** Dodawaj zestawy `user + key` oraz `user + password`; WebUI wymusza
  minimalną siłę hasła i nigdy nie przechowuje hasła jako zwykłego tekstu.
- **Wbudowany transfer i synchronizacja plików.** Pakiet zawiera `sftp-server`, `scp` i `rsync`, więc SFTP,
  sshfs, klienci graficzni oraz kopie zapasowe - wszystko działa przez to samo połączenie.
- **Każde urządzenie i emulator.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## Agenci AI na twoim urządzeniu

Stały punkt końcowy SSH zmienia twój telefon w coś, czym **autonomiczny agent AI może sterować bezpośrednio**.
Każdy agent potrafiący obsługiwać powłokę lub połączenie SSH - Claude Code, aider, skrypt z LLM w pętli, twoja
własna automatyzacja - otrzymuje prawdziwą sesję root na urządzeniu, przez sieć, bez kabla USB i bez żadnej z
samozdradzających flag debugowania ADB. Agent widzi normalną powłokę w stylu Linuksa i może:

- czytać i edytować pliki, przełączać ustawienia oraz zarządzać modułami, pakietami i usługami;
- segregować logi, pobierać artefakty i na żądanie uruchamiać diagnostykę lub analizę śledczą;
- przenosić i synchronizować pliki w obie strony przez `scp` / `sftp` / `rsync`, do kopii zapasowych, migracji lub provisioningu;
- sterować całą flotą zrootowanych urządzeń z jednego miejsca, przy czym każde jest osiągalne za pomocą własnego klucza.

Ponieważ projekt jest zbudowany tak, aby był **przyjazny dla AI** - udokumentowany plik konfiguracyjny, jawny
[kontrakt env](patches/README.md) środowiska uruchomieniowego, przewidywalne ścieżki i status w zwykłym tekście
- agent może odkryć sposób jego użycia bez zgadywania.

> **To jest root, więc traktuj to jak root.** Każde uwierzytelnione połączenie ląduje jako root (zobacz
> ostrzeżenie poniżej). Przekazując dostęp agentowi, daj mu **dedykowanego użytkownika i klucz**, ogranicz bindy
> do zaufanych sieci (loopback lub VPN zamiast otwartego internetu), pozostaw uwierzytelnianie hasłem wyłączone i
> pamiętaj, że w dowolnej chwili możesz z poziomu WebUI unieważnić klucz lub zatrzymać demona.

## Instalacja

Wgraj zip modułu w menedżerze KernelSU, APatch lub Magisk (albo z wiersza poleceń za pomocą
`ksud module install` / `apd module install`), otwórz **WebUI** modułu, aby ustawić port i dodać swoje klucze,
a następnie uruchom ponownie (lub naciśnij **Action**, aby uruchomić go teraz).

## Model bezpieczeństwa

### Gdzie żyją sekrety: BFU vs AFU

`/data/adb` to pamięć **device-encrypted (DE)**: jest odszyfrowywana *zanim* użytkownik odblokuje telefon
(Before First Unlock), więc wszystko, co się tam znajduje, jest odczytywalne przed odblokowaniem. `/data/misc_ce`
to **credential-encrypted (CE)**: Android utrzymuje ją zaszyfrowaną, dopóki użytkownik nie odblokuje (After First Unlock).

- **Tryb AFU (domyślny, `START_IN_BFU=0`):** demon czeka na odblokowanie i odczytuje swój host key,
  `authorized_keys` oraz hashe haseł z pamięci CE. Maksymalna ochrona; SSH działa dopiero po tym, jak urządzenie
  zostanie odblokowane co najmniej raz od uruchomienia.
- **Tryb BFU (`START_IN_BFU=1`):** demon startuje przed odblokowaniem, dzięki czemu możesz zalogować się przez SSH
  wcześnie (na przykład, aby zdalnie odblokować urządzenie). Jego sekrety znajdują się wtedy w pamięci DE i są
  odczytywalne przed odblokowaniem - to celowy i udokumentowany kompromis. Włączaj go tylko, jeśli potrzebujesz
  SSH przed odblokowaniem.

Celowo **nie** dodajemy własnego szyfrowania na wierzchu CE: jest już zaszyfrowane poświadczeniem użytkownika, a
nałożenie kolejnego szyfru wymagałoby klucza, który musiałby gdzieś się znajdować (na DE byłby ujawniony;
wyprowadzenie go z poświadczenia użytkownika to po prostu ponowna implementacja CE). To kupiłoby fałszywe poczucie
bezpieczeństwa, a nie prawdziwą ochronę.

### Hasła

Logowanie hasłem jest **domyślnie wyłączone**, ponieważ każde logowanie to root, a klucze są o wiele bezpieczniejsze.
Gdy jednak ustawisz hasło, WebUI wymusza minimalną siłę i przechowuje wyłącznie hash, nigdy zwykły tekst.

## Build

Binarka serwera jest budowana przez CI z **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** z niewielkim,
audytowalnym zestawem patchy (zobacz [`patches/`](patches/)): neutralny/konfigurowalny ciąg tożsamości, sterowane
konfiguracją ścieżki dla `authorized_keys` i pliku haseł oraz androidowa poprawka `openpty` dla interaktywnych PTY.
Zaplanowany workflow śledzi upstream i przebudowuje, dzięki czemu moduł pozostaje aktualny. Zobacz
[`.github/workflows/`](.github/workflows/) i [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Dokumentacja

<!-- vd-docs -->
Pełna dokumentacja znajduje się na [wiki](https://github.com/VD171/VD-dropbear/wiki) oraz w
[`docs/`](docs/).
<!-- /vd-docs -->

## Zobacz także

Siostrzane projekty tego samego autora:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: debugger metod urządzenia, który odczytuje każdy element każdą metodą zdolną go odczytać i porównuje je obok siebie.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: twoje usługi Google (RCS, Wallet, atestacje Play Integrity) odczytywane na twoim urządzeniu bez internetu.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: pełna kopia zapasowa i przywracanie aplikacji oraz danych jako root, sterowane w całości z WebUI.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: globalny spoofer fingerprintu urządzenia i build.

## Kontakt

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** _(placeholder - dodany przy pierwszym publicznym wydaniu)_
* **GitHub:** @VD171 https://github.com/VD171

## Licencja

Własny kod VD Dropbear jest na licencji **Apache-2.0** - zobacz [LICENSE](LICENSE). Moduł dołącza także binarki
osób trzecich - [Dropbear](https://matt.ucc.asn.au/dropbear/) (styl MIT), `sftp-server` i `scp` z OpenSSH (BSD)
oraz `rsync` (GPL-3.0) - każda na własnej licencji; zobacz [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), w tym
jak przestrzegamy GPL dla rsync. Nasz kod Apache-2.0 pozostaje nienaruszony (binarka GPL jest jedynie agregowana,
nie linkowana).

## Znaki towarowe

VD Dropbear to niezależny, nieoficjalny projekt, niezwiązany z żadną stroną trzecią ani przez nią nieaprobowany.
„Android" jest znakiem towarowym Google LLC; „SSH" jest zarejestrowanym znakiem towarowym SSH Communications
Security. VD Dropbear działa w całości na twoim urządzeniu.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
