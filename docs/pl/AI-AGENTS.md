<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   AI agents on your device.

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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · Polski · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# Agenci AI na Twoim urządzeniu

Stale dostępny punkt końcowy SSH zamienia Twój telefon w coś, czym **autonomiczny agent AI może
sterować bezpośrednio**. Każdy agent potrafiący obsłużyć powłokę lub połączenie SSH (Claude Code,
aider, skrypt z LLM w pętli, Twoja własna automatyzacja) otrzymuje prawdziwą sesję roota na
urządzeniu, przez sieć, bez przewodu USB i bez żadnej z ujawniających się flag debugowania ADB.

Ta strona rozwija ideę przedstawioną w pliku README.

## Dlaczego SSH, a nie ADB, dla agentów

ADB sam się zdradza: `adb_enabled` i `development_settings_enabled` są czytelne dla wszystkich,
połączenie jest rejestrowane i nie ma żadnego wspieranego sposobu, by ukryć, że debugowanie jest (lub
było) włączone. Agent pracujący przez ADB zostawia na urządzeniu ślad, który może odczytać dowolna
aplikacja lub SDK antyfraudowe. VD Dropbear jest prywatną alternatywą: zwykłym logowaniem SSH, z
poświadczeniami, które kontrolujesz, i bannerem, który nie zdradza niczego.

## Co może zrobić agent

W ramach jednego połączenia agent widzi zwykłą powłokę w stylu Linuksa i może:

- odczytywać i edytować pliki, zmieniać ustawienia oraz zarządzać modułami, pakietami i usługami;
- segregować logi, pobierać artefakty i uruchamiać diagnostykę lub analizę śledczą na żądanie;
- przenosić i synchronizować pliki w obie strony przez `scp` / `sftp` / `rsync`: kopie zapasowe, migracje, provisioning;
- sterować całą flotą zrootowanych urządzeń z jednego miejsca, przy czym każde jest dostępne za pomocą własnego klucza.

Ponieważ projekt został zbudowany tak, aby był **przyjazny dla AI** (udokumentowany plik
konfiguracyjny, jawny [kontrakt środowiska](../../patches/README.md) uruchomieniowego, przewidywalne
ścieżki i status w zwykłym tekście) agent może sam odkryć, jak z niego korzystać, bez zgadywania.

## Jak robić to bezpiecznie

To jest root, więc traktuj go jak roota:

- przydziel agentowi jego **własne poświadczenie**, a nie swoje osobiste, i skieruj go na konto o niższych uprawnieniach (`shell`), jeśli chcesz ograniczyć jego zasięg;
- ogranicz powiązania do sieci, którym ufasz: loopback lub VPN zamiast otwartego Internetu
  (zobacz [Konfiguracja](CONFIGURATION.md));
- pozostaw uwierzytelnianie hasłem wyłączone; klucz można odwołać i nigdy się go nie wpisuje;
- w każdej chwili możesz odwołać klucz lub zatrzymać demona z poziomu WebUI;
- pamiętaj, że domyślne połączenie to pełna sesja roota. Daj agentowi tylko taki zasięg, jakiego potrzebuje.

## Minimalna konfiguracja

1. Wygeneruj parę kluczy przeznaczoną wyłącznie dla agenta.
2. Dodaj jego klucz publiczny w WebUI (**Authorized keys**).
3. Powiąż tylko z loopbackiem lub swoim VPN, na porcie innym niż domyślny.
4. Skieruj konfigurację SSH agenta na urządzenie i pozwól mu pracować.
