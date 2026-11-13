<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · ไทย · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# สถาปัตยกรรม

VD Dropbear เป็นโมดูล KernelSU / APatch / Magisk ที่รัน Dropbear SSH daemon เพียงหนึ่งตัวเท่านั้น
โดยถูกขับเคลื่อนด้วยการกำหนดค่าทั้งหมด ไม่มีส่วนใดของ SSH server ที่ถูกฮาร์ดโค้ดไว้กับอุปกรณ์เครื่องใดเครื่องหนึ่ง
ทุกอย่างที่เฉพาะเจาะจงคือการกำหนดค่าขณะรันไทม์หรือเป็นความลับ

## ส่วนประกอบ

- `module/common/vddropbear.sh` - ไลบรารีแกนหลัก: โหลดการกำหนดค่า (พร้อมค่าเริ่มต้นในตัวที่ปลอดภัย)
  ระบุที่เก็บความลับ รับประกันว่ามี host key สร้าง argument vector ของ Dropbear
  และจัดการ daemon เพียงอินสแตนซ์เดียว (start / stop / status / restart)
- `module/service.sh` - จุดเริ่มต้นเมื่อบูต ทำตามนโยบายการเริ่ม BFU/AFU; ในโหมด AFU
  มันจะรอให้ที่เก็บแบบ credential-encrypted ปลดล็อกโดยไม่ทำให้การบูตค้าง
- `module/action.sh` - ปุ่ม **Action** ของตัวจัดการ: (เริ่มใหม่) daemon มันไม่อ่าน stdin เลย
  และแยก daemon ออกไปเป็นเซสชันของตัวเอง ดังนั้นตัวจัดการจึงไม่ค้าง
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - แบ็กเอนด์และหน้าของ WebUI
- `patches/` - แพตช์ขนาดเล็กที่ตรวจสอบได้ ซึ่งนำไปใช้กับ upstream Dropbear ขณะบิลด์
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - การบิลด์

## วงจรชีวิตของ daemon (อินสแตนซ์เดียว)

`vddb_start` โหลดการกำหนดค่า หยุดอินสแตนซ์ใดก็ตามที่กำลังรันอยู่ รับประกันว่ามี host key อยู่
จากนั้นจึงเรียก daemon ขึ้นมาหนึ่งตัว ไบนารีถูกส่งมาในชื่อ `vddropbear` ดังนั้นชื่อโปรเซสของมันจึงตรงกับ
`pgrep -x` พอดี (`mksh` ของ Android ไม่มี `exec -a`) มันถูกเรียกใช้ด้วย `setsid` เพื่อให้แยกออกจากกลุ่มโปรเซสของผู้เรียก -
นั่นคือสิ่งที่ทำให้ Action ของตัวจัดการไม่ถูกบล็อก

## ที่เก็บความลับ (CE กับ DE, BFU กับ AFU)

การตั้งค่าไม่ใช่ความลับและอยู่บนที่เก็บแบบ device-encrypted (`/data/adb/vddropbear`) ซึ่งอ่านได้ตอนบูต
ความลับ - host key, `authorized_keys`, แฮชรหัสผ่าน - โดยค่าเริ่มต้นจะอยู่บนที่เก็บแบบ **credential-encrypted**
(`/data/misc_ce/0/vddropbear`) ซึ่งจะปลดล็อกหลังจากผู้ใช้ยืนยันตัวตนแล้วเท่านั้น การเปิด `START_IN_BFU`
จะย้ายความลับไปยังที่เก็บแบบ device-encrypted เพื่อให้ daemon สามารถรันก่อนการปลดล็อกครั้งแรกได้
โดยแลกกับการที่ความลับเหล่านั้นอ่านได้เร็วขึ้น โมดูลจะคำนวณว่าจะใช้ที่เก็บใดในแต่ละขั้นตอนของการบูต

## ชุดแพตช์

SSH server ยังคงเป็น upstream Dropbear; การเปลี่ยนแปลงของเราเป็นแพตช์ที่ตรวจทานได้ไม่กี่รายการ (ดู
[patches/README.md](../../patches/README.md)):

- แบนเนอร์ระบุตัวตนที่เป็นกลางและกำหนดค่าได้ขณะรันไทม์;
- `authorized_keys` ที่อ่านจากเส้นทางที่กำหนดผ่านสภาพแวดล้อม (เพื่อให้คีย์อยู่ในที่เก็บความลับ);
- การยืนยันตัวตนด้วยรหัสผ่านโดยเทียบกับไฟล์แฮช PBKDF2 แทนที่จะเป็น `crypt()`/shadow ของระบบ ซึ่ง Android
  ไม่มี (ดู [BUILDING.md](../BUILDING.md))

## WebUI

หน้าแบบสแตติกใน WebUI ของตัวจัดการ (KernelSU / APatch / WebUI-X) มันขับเคลื่อน
`module/common/vddb-webui.sh` ผ่านบริดจ์ `ksu.exec`: สถานะ, start/stop/restart, การอ่าน/เขียนการกำหนดค่า
และการจัดการคีย์และบัญชีรหัสผ่าน ข้อมูลทั้งหมดข้ามบริดจ์ในรูปแบบ base64
ดังนั้นเชลล์จึงไม่เคยตีความมัน; แฮชรหัสผ่านถูกคำนวณในเบราว์เซอร์ด้วย WebCrypto
ดังนั้นรหัสผ่านแบบข้อความธรรมดาจึงไม่เคยออกจากหน้านี้
