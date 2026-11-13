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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · Polski · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Przewodnik użytkownika

VD Dropbear daje Twojemu zrootowanemu urządzeniu prywatny serwer SSH. Ten przewodnik przeprowadzi Cię
od instalacji do działającego połączenia, w tym transferu plików i trybu przed pierwszym odblokowaniem
(BFU).

> **Logowanie domyślnie daje pełną powłokę roota.** Preferuj klucze zamiast haseł, wiąż się
> tylko z sieciami, którym ufasz, i nigdy bez powodu nie wystawiaj portu do otwartego Internetu.

## 1. Instalacja

Wgraj zip modułu w menedżerze **KernelSU**, **APatch** lub **Magisk** (albo z powłoki poleceniem
`ksud module install` / `apd module install`), a następnie otwórz **WebUI** modułu.

## 2. Dodaj klucz (zalecane)

W WebUI, w sekcji **Authorized keys**, wklej swój klucz publiczny (`ssh-ed25519 AAAA... you@host`)
i naciśnij **Add key**. Klucze są domyślne i stanowią najbezpieczniejszą drogę wejścia.

Aby wygenerować klucz na swoim komputerze, jeśli go nie masz:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Albo ustaw hasło

Logowanie hasłem jest domyślnie wyłączone (logowanie domyślnie to root, więc klucze są preferowane). Aby je
włączyć, włącz **Password login** w ustawieniach, a następnie w sekcji **Password accounts** ustaw hasło
dla użytkownika logowania. Hash jest obliczany w Twojej przeglądarce za pomocą PBKDF2; samo hasło nigdy
nie opuszcza strony.

## 4. Wybierz port i gdzie nasłuchiwać

W sekcji **Settings** ustaw **Port** i wybierz powiązania. Domyślnie VD Dropbear nasłuchuje tylko na
**loopbacku**; aby dotrzeć do niego z sieci LAN lub VPN, włącz interfejsy, których potrzebujesz. Unikaj
opcji **Listen on all interfaces**, chyba że rozumiesz związane z tym narażenie.

Naciśnij **Save & restart**, aby zastosować zmiany, a następnie **Start**, jeśli jeszcze
nie działa.

## 5. Połącz się

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` i `rsync` są dołączone, więc SFTP, `sshfs`, klienci graficzni i kopie zapasowe
działają przez to samo połączenie.

## 6. Przed pierwszym odblokowaniem (BFU)

Domyślnie demon uruchamia się dopiero **po** jednokrotnym odblokowaniu urządzenia (AFU), ponieważ jego
sekrety znajdują się w magazynie szyfrowanym poświadczeniami. Jeśli potrzebujesz SSH **przed** pierwszym
odblokowaniem (na przykład po to, by zdalnie odblokować urządzenie po restarcie) włącz **Start before
first unlock (BFU)**. Sekrety trafiają wtedy do magazynu szyfrowanego na poziomie urządzenia,
który jest czytelny przed odblokowaniem: to celowy, udokumentowany kompromis. Zobacz
[Model bezpieczeństwa](#) w README.

## 7. Sterowanie demonem

- **WebUI:** Start / Stop / Restart oraz status na żywo (działa, PID, port, tryb,
  odcisk klucza hosta).
- **Przycisk Action menedżera:** (ponownie) uruchamia demona.
- Uruchamia się także automatycznie przy starcie (chyba że to wyłączysz).

## Rozwiązywanie problemów

- **Nie chce się uruchomić.** Sprawdź `/data/adb/vddropbear/state/daemon.log`. Upewnij się, że opcja
  **Enabled** jest aktywna i że klucz hosta mógł zostać wygenerowany.
- **Klucz odrzucony.** Potwierdź, że linia klucza publicznego jest dokładnie taka, jaką oferuje Twój
  klient, oraz że nazwa użytkownika, pod którą się logujesz, jest tą, którą system rozpoznaje (zwykle `root`).
- **Nie można połączyć się z innego komputera.** Prawdopodobnie wciąż jesteś powiązany tylko z
  loopbackiem. Włącz potrzebny interfejs i uruchom ponownie.
- **SFTP/scp zawodzi, ale powłoka działa.** Upewnij się, że dołączony `sftp-server` został dostarczony
  dla Twojego ABI; status WebUI pokazuje wykryte ABI.
