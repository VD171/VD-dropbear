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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · Русский · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Руководство пользователя

VD Dropbear даёт вашему root-устройству приватный SSH-сервер. Это руководство проведёт вас от установки
до работающего соединения, включая передачу файлов и режим до первой разблокировки (BFU).

> **Каждое аутентифицированное соединение получает root-шелл.** Предпочитайте ключи паролям,
> привязывайтесь только к сетям, которым доверяете, и никогда не открывайте порт в открытый Интернет без
> причины.

## 1. Установка

Прошейте zip модуля в менеджере **KernelSU**, **APatch** или **Magisk** (либо из шелла командой
`ksud module install` / `apd module install`), затем откройте **WebUI** модуля.

## 2. Добавьте ключ (рекомендуется)

В WebUI, в разделе **Authorized keys**, вставьте свой публичный ключ
(`ssh-ed25519 AAAA... you@host`) и нажмите **Add key**. Ключи используются по умолчанию и являются
самым безопасным способом входа.

Чтобы сгенерировать ключ на вашем компьютере, если у вас его нет:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Или задайте пароль

Вход по паролю выключен по умолчанию (каждый вход - это root, поэтому ключи предпочтительнее). Чтобы
включить его, включите **Password login** в настройках, затем в разделе **Password accounts**
задайте пароль для пользователя входа. Хеш вычисляется в вашем браузере с помощью PBKDF2; сам пароль
никогда не покидает страницу.

## 4. Выберите порт и где слушать

В разделе **Settings** задайте **Port** и выберите привязки. По умолчанию VD Dropbear слушает только
на **loopback**; чтобы обратиться к нему из вашей LAN или VPN, включите нужные интерфейсы. Избегайте
опции **Listen on all interfaces**, если не понимаете связанного с этим риска.

Нажмите **Save & restart**, чтобы применить, затем **Start**, если он ещё не работает.

## 5. Подключение

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` и `rsync` входят в комплект, поэтому SFTP, `sshfs`, GUI-клиенты и резервные копии
работают через одно и то же соединение.

## 6. До первой разблокировки (BFU)

По умолчанию демон запускается только **после** того, как вы один раз разблокируете устройство (AFU),
потому что его секреты находятся в хранилище, зашифрованном учётными данными. Если вам нужен SSH
**до** первой разблокировки - например, чтобы удалённо разблокировать устройство после перезагрузки -
включите **Start before first unlock (BFU)**. Секреты тогда перемещаются в хранилище,
зашифрованное на уровне устройства, которое читаемо до разблокировки: намеренный, задокументированный
компромисс. См. [Модель безопасности](#) в README.

## 7. Управление демоном

- **WebUI:** Start / Stop / Restart и статус в реальном времени (работает, PID, порт,
  режим, отпечаток ключа хоста).
- **Кнопка Action менеджера:** (пере)запускает демон.
- Он также запускается автоматически при загрузке (если вы это не отключите).

## Устранение неполадок

- **Не запускается.** Проверьте `/data/adb/vddropbear/state/daemon.log`. Убедитесь, что опция
  **Enabled** активна и что ключ хоста удалось сгенерировать.
- **Ключ отклонён.** Убедитесь, что строка публичного ключа в точности такая, какую предлагает ваш
  клиент, и что пользователь входа - это тот, которого система распознаёт (обычно `root`).
- **Не удаётся подключиться с другой машины.** Вероятно, вы всё ещё привязаны только к loopback -
  включите нужный интерфейс и перезапустите.
- **SFTP/scp не работает, а шелл работает.** Убедитесь, что входящий в комплект `sftp-server` был
  поставлен для вашего ABI; статус WebUI показывает обнаруженный ABI.
