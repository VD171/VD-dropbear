<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Contributing guide.

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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · Polski · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Współtworzenie VD Dropbear

Dziękujemy za zainteresowanie. To mały projekt wrażliwy na kwestie bezpieczeństwa (rozdaje roota),
więc zmiany są przeglądane z tym na uwadze.

## Układ repozytorium

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Budowanie

Plik binarny jest tworzony przez CI z **oryginalnego [mkj/dropbear](https://github.com/mkj/dropbear)**
plus łatki w `patches/`. Do lokalnego budowania potrzebujesz Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Zestaw łatek jest celowo minimalny i audytowalny: neutralny/konfigurowalny ciąg tożsamości, oparte na
konfiguracji ścieżki do `authorized_keys` i pliku hasła, poprawka `openpty` dla Androida oraz
konfiguracja uruchomieniowa. Prosimy, aby nowe łatki były małe, udokumentowane i uzasadnione w PR.

## Pull requesty

- Jedna logiczna zmiana na PR; opisz motywację i wpływ na bezpieczeństwo.
- Trzymaj się istniejącego stylu powłoki (POSIX `sh` / Android `mksh`; bez bashizmów).
- Każdy plik ma krótki nagłówek SPDX - zachowaj go.
- Zaktualizuj [`CHANGELOG.md`](../../CHANGELOG.md) w sekcji `[Unreleased]` przy każdej realnej, widocznej dla użytkownika zmianie.
- Przesyłając PR, zgadzasz się na licencjonowanie swojego wkładu na licencji projektu [Apache-2.0](../../LICENSE).

## Tłumaczenia

README i dokumentacja są utrzymywane w wielu językach (`README.<lang>.md`). Angielski jest źródłem
prawdy; tłumaczenia za nim podążają. Jeśli poprawiasz tłumaczenie lub dodajesz język, zachowaj strukturę
i kotwice sekcji identyczne jak w wersji angielskiej.

## Zgłaszanie błędów i problemów bezpieczeństwa

Do zgłaszania błędów i propozycji funkcji używaj szablonów zgłoszeń. W przypadku czegokolwiek, co mogłoby
narazić urządzenie, postępuj zgodnie z [`SECURITY.md`](SECURITY.md) i zgłoś to prywatnie, zamiast
otwierać publiczne zgłoszenie.
