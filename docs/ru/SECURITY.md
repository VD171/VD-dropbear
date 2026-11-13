<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · Русский · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Политика безопасности

## Единственное, что нужно понять

VD Dropbear запускает SSH-сервер, и **каждое соединение, которое успешно проходит аутентификацию,
получает root-шелл**. Таким образом, безопасность вашего устройства равна безопасности конфигурации и
учётных данных этого сервера. Пожалуйста:

- **Предпочитайте публичные ключи паролям.** Вход по паролю выключен по умолчанию.
- Если вам всё же нужен пароль, используйте надёжный. WebUI требует минимальную длину и хранит только хеш.
- **Не открывайте порт в публичный Интернет.** Привязывайтесь к loopback или доверенной LAN, либо
  обращайтесь к нему через VPN / туннель.
- Поймите **компромисс BFU**: включение запуска до разблокировки помещает ключ хоста и учётные данные
  в хранилище, зашифрованное на уровне устройства, читаемое до того, как устройство разблокировано.
  Оставьте это выключенным, если только вам не нужен SSH до разблокировки.
- Держите проброс выключенным, если он вам не нужен (по умолчанию он выключен).

## Что VD Dropbear делает, чтобы помочь

- Нейтральный, неинформативный баннер версии, чтобы сетевые сканеры не могли определить точный сервер и
  версию.
- Учётные данные по умолчанию в хранилище, зашифрованном учётными данными (расшифровываются только после разблокировки).
- Никакой телеметрии, никаких собственных сетевых обращений, никакой аналитики. Он работает целиком на вашем устройстве.

## Поддерживаемые версии

Исправления безопасности выходят в последнем релизе. Бинарник сервера следует за апстрим-Dropbear;
релизы безопасности апстрима пересобираются и поставляются, как только их подхватывает CI.

## Сообщение об уязвимости

Пожалуйста, сообщайте о проблемах безопасности в частном порядке, а не в публичной issue:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Укажите версию, описание и (в идеале) способ воспроизведения. Вы получите подтверждение, и мы
согласуем с вами исправление и сроки раскрытия. Об уязвимостях в самом Dropbear, пожалуйста, сообщайте
также в апстрим по адресу <https://matt.ucc.asn.au/dropbear/>.
