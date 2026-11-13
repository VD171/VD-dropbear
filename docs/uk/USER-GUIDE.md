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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · Українська · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Посібник користувача

VD Dropbear надає вашому root-пристрою приватний SSH-сервер. Цей посібник проведе вас від встановлення
до робочого з'єднання, включно з передаванням файлів і режимом before-first-unlock (BFU).

> **Кожне автентифіковане з'єднання отримує root-оболонку.** Віддавайте перевагу ключам, а не паролям,
> прив'язуйтеся лише до мереж, яким довіряєте, і ніколи не відкривайте порт у відкритий Інтернет без
> причини.

## 1. Встановлення

Прошийте zip модуля в менеджері **KernelSU**, **APatch** чи **Magisk** (або з оболонки через
`ksud module install` / `apd module install`), потім відкрийте **WebUI** модуля.

## 2. Додайте ключ (рекомендовано)

У WebUI, у розділі **Authorized keys**, вставте свій публічний ключ (`ssh-ed25519 AAAA... you@host`) і
натисніть **Add key**. Ключі - це варіант за замовчуванням і найбезпечніший спосіб входу.

Щоб згенерувати ключ на комп'ютері, якщо у вас його немає:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Або встановіть пароль

Вхід за паролем вимкнено за замовчуванням (кожен вхід - це root, тож перевага надається ключам). Щоб
увімкнути його, увімкніть **Password login** у налаштуваннях, потім у розділі **Password accounts**
задайте пароль для користувача входу. Хеш обчислюється у вашому браузері за допомогою PBKDF2; сам
пароль ніколи не залишає сторінку.

## 4. Виберіть порт і де прослуховувати

У **Settings** задайте **Port** і виберіть прив'язки. За замовчуванням VD Dropbear прослуховує лише
**loopback**; щоб дістатися до нього з вашої LAN чи VPN, увімкніть потрібні інтерфейси. Уникайте
**Listen on all interfaces**, якщо не розумієте пов'язаних ризиків.

Натисніть **Save & restart**, щоб застосувати, потім **Start**, якщо він ще не запущений.

## 5. Підключення

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` і `rsync` входять до комплекту, тож SFTP, `sshfs`, GUI-клієнти та резервні копії
працюють через те саме з'єднання.

## 6. Before first unlock (BFU)

За замовчуванням демон запускається лише **після** того, як ви один раз розблокуєте пристрій (AFU),
оскільки його секрети зберігаються в credential-encrypted сховищі. Якщо вам потрібен SSH **до** першого
розблокування - наприклад, щоб розблокувати пристрій віддалено після перезавантаження - увімкніть
**Start before first unlock (BFU)**. Секрети тоді переходять у device-encrypted сховище, доступне до
розблокування: навмисний, задокументований компроміс. Див. [Модель безпеки](#) у README.

## 7. Керування демоном

- **WebUI:** Start / Stop / Restart та стан у реальному часі (працює, PID, порт, режим, відбиток host
  key).
- **Кнопка Action у менеджері:** (пере)запускає демон.
- Він також запускається автоматично під час завантаження (якщо ви це не вимкнете).

## Усунення несправностей

- **Не запускається.** Перевірте `/data/adb/vddropbear/state/daemon.log`. Переконайтеся, що **Enabled**
  увімкнено і що host key вдалося згенерувати.
- **Ключ відхилено.** Переконайтеся, що рядок публічного ключа точно такий, як пропонує ваш клієнт, і
  що користувач входу - такий, якого система розпізнає (зазвичай `root`).
- **Не вдається підключитися з іншої машини.** Імовірно, ви все ще прив'язані лише до loopback -
  увімкніть потрібний інтерфейс і перезапустіть.
- **SFTP/scp не працює, а оболонка працює.** Переконайтеся, що комплектний `sftp-server` постачено для
  вашого ABI; стан WebUI показує виявлений ABI.
