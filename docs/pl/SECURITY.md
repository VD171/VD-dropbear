<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Security policy.

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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · Polski · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Polityka bezpieczeństwa

## Jedna rzecz, którą trzeba zrozumieć

VD Dropbear uruchamia serwer SSH, a **każde połączenie, które pomyślnie się uwierzytelni, otrzymuje
powłokę roota**. Bezpieczeństwo Twojego urządzenia jest więc równe bezpieczeństwu konfiguracji i
poświadczeń tego serwera. Prosimy:

- **Preferuj klucze publiczne zamiast haseł.** Logowanie hasłem jest domyślnie wyłączone.
- Jeśli musisz użyć hasła, użyj silnego - WebUI wymusza minimum i przechowuje wyłącznie hash.
- **Nie wystawiaj portu do publicznego Internetu.** Powiąż się z loopbackiem lub zaufaną siecią LAN,
  albo docieraj do niego przez VPN / tunel.
- Zrozum **kompromis BFU**: włączenie uruchamiania przed odblokowaniem umieszcza klucz hosta i
  poświadczenia w magazynie szyfrowanym na poziomie urządzenia, czytelnym, zanim urządzenie zostanie
  odblokowane. Pozostaw to wyłączone, chyba że potrzebujesz SSH przed odblokowaniem.
- Trzymaj przekierowywanie wyłączone, chyba że go potrzebujesz (domyślnie jest wyłączone).

## Co VD Dropbear robi, aby pomóc

- Neutralny, nic nie mówiący banner wersji, aby skanery sieciowe nie mogły rozpoznać dokładnego serwera
  i wersji.
- Poświadczenia domyślnie w magazynie szyfrowanym poświadczeniami (odszyfrowywane dopiero po odblokowaniu).
- Brak telemetrii, brak własnych połączeń sieciowych, brak analityki. Działa w całości na Twoim urządzeniu.

## Wspierane wersje

Poprawki bezpieczeństwa trafiają do najnowszego wydania. Plik binarny serwera śledzi oryginalnego
Dropbeara; wydania bezpieczeństwa upstreamu są przebudowywane i dostarczane, gdy tylko CI je podchwyci.

## Zgłaszanie podatności

Prosimy zgłaszać problemy bezpieczeństwa prywatnie, a nie w publicznym zgłoszeniu:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Podaj wersję, opis oraz (najlepiej) sposób odtworzenia. Otrzymasz potwierdzenie, a my uzgodnimy z Tobą
poprawkę oraz harmonogram ujawnienia. W przypadku podatności w samym Dropbearze prosimy zgłosić je także
do upstreamu pod adresem <https://matt.ucc.asn.au/dropbear/>.
