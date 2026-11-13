<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Configuration reference.

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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · ไทย · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# การกำหนดค่า

การตั้งค่าอยู่ใน `/data/adb/vddropbear/config` (สร้างขึ้นจาก `module/common/config.default` เมื่อบูตครั้งแรก)
**WebUI** แก้ไขไฟล์นี้ให้คุณ; คุณสามารถแก้ไขด้วยมือได้เช่นกัน ไฟล์นี้ถูก source เป็นเชลล์ ดังนั้นให้ใช้
`KEY=value` โดยไม่มีช่องว่างรอบ ๆ `=` การตั้งค่าไม่ใช่ความลับและอยู่บนที่เก็บแบบ device-encrypted;
ความลับ (host key, authorized keys, แฮชรหัสผ่าน) อยู่ในที่เก็บความลับ ไม่ใช่ที่นี่

นำการเปลี่ยนแปลงไปใช้โดยการเริ่ม daemon ใหม่ (ปุ่ม **Save & restart** ของ WebUI ทำสิ่งนี้ให้)

## ทั่วไป

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | เริ่ม daemon เมื่อบูต `0` ปิดการใช้งานทั้งหมด |
| `START_IN_BFU` | `0` | `0`: เริ่มหลังการปลดล็อกครั้งแรกเท่านั้น (AFU); ความลับยังคงอยู่บนที่เก็บแบบ credential-encrypted (CE) `1`: เริ่มก่อนการปลดล็อกครั้งแรกด้วย (BFU); ความลับย้ายไปยังที่เก็บแบบ device-encrypted (DE) ซึ่งอ่านได้ก่อนปลดล็อก |
| `PORT` | `2222` | พอร์ตที่ฟังเริ่มต้น (พอร์ตต่อการ bind สามารถแทนที่ได้ใน `LISTEN_ADDRESSES`) |

## การฟัง / การ bind (ประกอบกันได้)

อนุญาตให้ใช้ชุดค่าผสมใดก็ได้; การ bind ที่เลือกจะถูกรวมเข้าด้วยกัน หากคุณล้างทุกอย่าง VD Dropbear
จะ bind loopback แทนที่จะเป็นทุกอินเทอร์เฟซ

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | ฟังเฉพาะบน `127.0.0.1` / `::1` เท่านั้น |
| `LISTEN_ALL` | `0` | ฟังบนทุกอินเทอร์เฟซ (`0.0.0.0` / `::`) - เปิดเผยอุปกรณ์ |
| `LISTEN_IPV4` | `1` | รวมการ bind แบบ IPv4 |
| `LISTEN_IPV6` | `1` | รวมการ bind แบบ IPv6 |
| `LISTEN_ADDRESSES` | `""` | การ bind เฉพาะเพิ่มเติม คั่นด้วยจุลภาค: `addr` (ใช้ `PORT`) หรือ `addr:port` ทั้ง IPv4 หรือ IPv6 |

## การระบุตัวตน

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | ส่งแบนเนอร์ระบุตัวตน SSH ที่เป็นกลาง เพื่อให้ตัวสแกนไม่สามารถทำ fingerprint เซิร์ฟเวอร์/เวอร์ชันที่แน่นอนได้ |
| `IDENT_STRING` | `""` | สตริงระบุตัวตนแบบกำหนดเอง ค่าว่างจะใช้ค่าเริ่มต้นในตัวที่เป็นกลาง |

## การยืนยันตัวตน

การเข้าสู่ระบบที่ยืนยันตัวตนทุกครั้งเป็น **root** คีย์เป็นค่าเริ่มต้น; รหัสผ่านเป็นแบบเลือกเปิดเอง

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | อนุญาตการเข้าสู่ระบบด้วยคีย์สาธารณะ (อ่าน authorized keys ในที่เก็บความลับ) |
| `PASSWORD_AUTH` | `0` | อนุญาตการเข้าสู่ระบบด้วยรหัสผ่าน เมื่อปิด daemon จะถูกเริ่มโดยปิดการยืนยันตัวตนด้วยรหัสผ่าน |
| `MAX_AUTH_TRIES` | `3` | จำนวนครั้งสูงสุดของการพยายามยืนยันตัวตนต่อการเชื่อมต่อหนึ่งครั้ง |
| `LOGIN_USER` | `root` | บัญชีที่จะเข้าสู่ระบบ ต้องเป็นบัญชีที่ระบบแปลงชื่อได้ (โดยทั่วไปคือ `root`) |

## เซสชัน / สภาพแวดล้อม

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | เชลล์สำหรับเซสชัน ค่าว่างจะใช้ค่าเริ่มต้นของบัญชี |
| `HOME_DIR` | `""` | `HOME` สำหรับเซสชัน ค่าว่างจะใช้ไดเรกทอรีของโมดูล |
| `EXTRA_ENV` | `""` | สภาพแวดล้อมเพิ่มเติม `K=V;K2=V2` |
| `IDLE_TIMEOUT` | `0` | ตัดการเชื่อมต่อหลังจากไม่มีกิจกรรม N วินาที `0` ปิดการใช้งาน |
| `KEEPALIVE` | `0` | ส่ง keepalive ทุก N วินาที `0` ปิดการใช้งาน |
| `RECEIVE_WINDOW` | `""` | ขนาดหน้าต่างรับข้อมูลของ Dropbear ค่าว่างจะใช้ค่าเริ่มต้น |

## การส่งต่อ (ปิดโดยค่าเริ่มต้น)

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | อนุญาตการส่งต่อพอร์ตแบบโลคัล (`-L`) |
| `ALLOW_REMOTE_FORWARD` | `0` | อนุญาตการส่งต่อพอร์ตแบบรีโมต (`-R`) |
| `GATEWAY_PORTS` | `0` | ให้พอร์ตรีโมตที่ส่งต่อ bind กับทุกอินเทอร์เฟซ |

## Host key

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | ชนิดของ host key: `ed25519`, `rsa` หรือ `ecdsa` สร้างขึ้นเมื่อเริ่มครั้งแรกลงในที่เก็บความลับ |

## ที่เก็บความลับ

ไม่ได้กำหนดค่าที่นี่ - ถูกระบุจาก `START_IN_BFU`:

- **AFU (ค่าเริ่มต้น):** `/data/misc_ce/0/vddropbear/secret` - credential-encrypted ใช้งานได้หลังจากที่
  คุณปลดล็อกอุปกรณ์แล้วเท่านั้น
- **BFU:** `/data/adb/vddropbear/secret` - device-encrypted อ่านได้ก่อนการปลดล็อกครั้งแรก

มันเก็บ host key, `authorized_keys` และไฟล์แฮช `passwd` ดู
[BUILDING.md](../BUILDING.md) สำหรับรูปแบบแฮชรหัสผ่าน
