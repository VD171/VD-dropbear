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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · Українська · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Політика безпеки

## Головне, що треба зрозуміти

VD Dropbear запускає SSH-сервер, і **кожне з'єднання, яке успішно проходить автентифікацію, отримує
root-оболонку**. Тому безпека вашого пристрою дорівнює безпеці конфігурації та облікових даних цього
сервера. Будь ласка:

- **Віддавайте перевагу публічним ключам, а не паролям.** Вхід за паролем вимкнено за замовчуванням.
- Якщо вам доводиться використовувати пароль, використовуйте надійний - WebUI вимагає мінімум і
  зберігає лише хеш.
- **Не відкривайте порт у публічний Інтернет.** Прив'язуйтеся до loopback чи довіреної LAN або
  отримуйте доступ через VPN / тунель.
- Усвідомте **компроміс BFU**: увімкнення запуску до розблокування розміщує host key та облікові дані
  в device-encrypted сховищі, доступному до розблокування пристрою. Лишайте його вимкненим, якщо вам
  не потрібен SSH до розблокування.
- Тримайте переадресацію вимкненою, доки вона вам не потрібна (за замовчуванням вона вимкнена).

## Чим допомагає VD Dropbear

- Нейтральний, неінформативний банер версії, щоб мережеві сканери не могли визначити точний сервер і
  версію.
- Облікові дані в credential-encrypted сховищі за замовчуванням (розшифровуються лише після
  розблокування).
- Жодної телеметрії, жодних власних мережевих викликів, жодної аналітики. Він працює цілком на вашому
  пристрої.

## Підтримувані версії

Виправлення безпеки потрапляють у найновіший випуск. Бінарний файл сервера слідкує за upstream-версією
Dropbear; upstream-випуски з виправленнями безпеки перезбираються й постачаються, щойно їх підхоплює
CI.

## Повідомлення про вразливість

Будь ласка, повідомляйте про проблеми безпеки приватно, а не в публічній issue:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Вкажіть версію, опис і (бажано) відтворення. Ви отримаєте підтвердження, і ми узгодимо з вами
виправлення та графік розкриття. Про вразливості в самому Dropbear також повідомляйте upstream за
адресою <https://matt.ucc.asn.au/dropbear/>.
