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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · ไทย · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# เอเจนต์ AI บนอุปกรณ์ของคุณ

จุดเชื่อมต่อ SSH ที่เปิดอยู่ตลอดเวลาจะเปลี่ยนโทรศัพท์ของคุณให้เป็นสิ่งที่ **เอเจนต์ AI อัตโนมัติสามารถควบคุมได้โดยตรง**
เอเจนต์ใดก็ตามที่สามารถสั่งงานเชลล์หรือการเชื่อมต่อ SSH ได้ (Claude Code, aider, สคริปต์แบบ LLM-in-the-loop,
ระบบอัตโนมัติของคุณเอง) จะได้เซสชัน root จริงบนอุปกรณ์ผ่านเครือข่าย โดยไม่ต้องต่อสาย USB
และไม่มีแฟล็กดีบักที่เปิดเผยตัวเองของ ADB เลย

หน้านี้ขยายความแนวคิดที่แนะนำไว้ใน README

## ทำไมจึงใช้ SSH แทน ADB สำหรับเอเจนต์

ADB ประกาศตัวเอง: `adb_enabled` และ `development_settings_enabled` อ่านได้โดยทุกคน การเชื่อมต่อถูกบันทึกไว้
และไม่มีวิธีที่รองรับในการซ่อนว่าการดีบักกำลังเปิด (หรือเคยเปิด) อยู่ เอเจนต์ที่ทำงานผ่าน ADB
จะทิ้งร่องรอยนั้นไว้บนอุปกรณ์ให้แอปหรือ SDK ป้องกันการฉ้อโกงใด ๆ อ่านได้ VD Dropbear คือทางเลือกแบบส่วนตัว:
การเข้าสู่ระบบ SSH ตามปกติ ด้วยข้อมูลรับรองที่คุณควบคุมเอง และแบนเนอร์ที่ไม่เปิดเผยอะไรเลย

## เอเจนต์ทำอะไรได้บ้าง

ผ่านการเชื่อมต่อเพียงครั้งเดียว เอเจนต์จะเห็นเชลล์แบบ Linux ตามปกติ และสามารถ:

- อ่านและแก้ไขไฟล์ สลับการตั้งค่า และจัดการโมดูล แพ็กเกจ และบริการ;
- คัดกรองบันทึก ดึงอาร์ติแฟกต์ และเรียกใช้การวินิจฉัยหรือการตรวจพิสูจน์ตามต้องการ;
- ย้ายและซิงก์ไฟล์ได้ทั้งสองทิศทางผ่าน `scp` / `sftp` / `rsync`: การสำรองข้อมูล การย้ายข้อมูล การจัดเตรียม;
- ควบคุมอุปกรณ์ที่ root ทั้งฝูงจากที่เดียว โดยแต่ละเครื่องเข้าถึงได้ด้วยคีย์ของตัวเอง

เนื่องจากโครงการนี้ถูกสร้างให้ **เป็นมิตรกับ AI** (มีไฟล์การกำหนดค่าที่มีเอกสารประกอบ มี [สัญญา env](../../patches/README.md)
ขณะรันไทม์ที่ชัดเจน มีเส้นทางที่คาดเดาได้ และสถานะเป็นข้อความธรรมดา) เอเจนต์จึงสามารถค้นพบวิธีใช้งานได้โดยไม่ต้องเดา

## ทำอย่างปลอดภัย

นี่คือ root ดังนั้นจงปฏิบัติต่อมันอย่างที่ควรปฏิบัติต่อ root:

- มอบ **ผู้ใช้และคีย์เฉพาะ** ให้เอเจนต์ ไม่ใช่ของส่วนตัวของคุณ;
- จำกัดการ bind ไว้เฉพาะเครือข่ายที่คุณไว้วางใจ: loopback หรือ VPN แทนที่จะเป็นอินเทอร์เน็ตแบบเปิด
  (ดู [การกำหนดค่า](CONFIGURATION.md));
- ปิดการยืนยันตัวตนด้วยรหัสผ่านไว้ คีย์สามารถเพิกถอนได้และไม่ต้องพิมพ์;
- คุณสามารถเพิกถอนคีย์หรือหยุด daemon ได้ตลอดเวลาจาก WebUI;
- จำไว้ว่าทุกการเชื่อมต่อคือเซสชัน root เต็มรูปแบบ: มอบสิทธิ์การเข้าถึงให้เอเจนต์เท่าที่จำเป็นเท่านั้น

## การตั้งค่าขั้นต่ำ

1. สร้างคู่คีย์สำหรับเอเจนต์โดยเฉพาะ
2. เพิ่มคีย์สาธารณะของมันใน WebUI (**Authorized keys**)
3. bind เฉพาะกับ loopback หรือ VPN ของคุณเท่านั้น บนพอร์ตที่ไม่ใช่ค่าเริ่มต้น
4. ชี้การกำหนดค่า SSH ของเอเจนต์ไปที่อุปกรณ์แล้วปล่อยให้มันทำงาน
