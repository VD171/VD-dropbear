<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Architecture.

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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · Русский · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Архитектура

VD Dropbear является модулем KernelSU / APatch / Magisk, который запускает ровно один SSH-демон Dropbear,
полностью управляемый конфигурацией. Ничто в SSH-сервере не зашито жёстко под одно устройство; всё
специфичное является конфигурацией времени выполнения или секретом.

## Составные части

- `module/common/vddropbear.sh`: основная библиотека: загрузка конфигурации (с безопасными
  встроенными значениями по умолчанию), определение хранилища секретов, обеспечение наличия ключа
  хоста, построение вектора аргументов Dropbear и управление единственным экземпляром демона
  (start / stop / status / restart).
- `module/service.sh`: точка входа при загрузке. Соблюдает политику запуска BFU/AFU; в режиме AFU
  ожидает разблокировки хранилища, зашифрованного учётными данными, не задерживая загрузку.
- `module/action.sh`: кнопка **Action** менеджера: (пере)запуск демона. Она никогда не читает stdin и
  отделяет демон в отдельную сессию, поэтому менеджер не зависает.
- `module/common/vddb-webui.sh` + `module/webroot/index.html`: бэкенд и страница WebUI.
- `patches/`: небольшие, поддающиеся аудиту патчи, применяемые к апстрим-Dropbear при сборке.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml`: сборка.

## Жизненный цикл демона (единственный экземпляр)

`vddb_start` загружает конфигурацию, останавливает любой работающий экземпляр, обеспечивает наличие
ключа хоста, а затем порождает один демон. Бинарник поставляется как `vddropbear`, поэтому имя его
процесса в точности совпадает с `pgrep -x` (в андроидном `mksh` нет `exec -a`). Он запускается через
`setsid`, благодаря чему отделяется от группы процессов вызывающего: именно это не даёт кнопке Action
менеджера блокироваться.

## Хранилище секретов (CE против DE, BFU против AFU)

Настройки не являются секретом и находятся в хранилище, зашифрованном на уровне устройства
(`/data/adb/vddropbear`), читаемом при загрузке. Секреты (ключ хоста, `authorized_keys`, хеши паролей)
по умолчанию попадают в хранилище, **зашифрованное учётными данными** (`/data/misc_ce/0/vddropbear`),
которое разблокируется только после аутентификации пользователя. Включение `START_IN_BFU` переносит
секреты в хранилище, зашифрованное на уровне устройства, чтобы демон мог работать до первой
разблокировки, ценой того, что эти секреты становятся читаемыми раньше. Модуль на каждом этапе загрузки
вычисляет, какое хранилище использовать.

## Набор патчей

SSH-сервер остаётся апстрим-Dropbear; наши изменения представляют собой несколько поддающихся проверке патчей (см.
[patches/README.md](../../patches/README.md)):

- нейтральный, настраиваемый во время выполнения баннер идентификации;
- `authorized_keys`, читаемые из пути, заданного в окружении (чтобы ключи находились в хранилище секретов);
- аутентификация по паролю по файлу с хешем PBKDF2 вместо системного `crypt()`/shadow, которого в
  Android нет (см. [BUILDING.md](../BUILDING.md)).

## WebUI

Статическая страница в WebUI менеджера (KernelSU / APatch / WebUI-X). Она управляет
`module/common/vddb-webui.sh` через мост `ksu.exec`: статус, start/stop/restart, чтение/запись
конфигурации и управление ключами и парольными учётными записями. Все данные проходят через мост в
кодировке base64, поэтому шелл их никогда не интерпретирует; хеши паролей вычисляются в браузере с
помощью WebCrypto, поэтому пароль в открытом виде никогда не покидает страницу.
