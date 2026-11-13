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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · ไทย · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# นโยบายความปลอดภัย

## สิ่งหนึ่งที่ต้องเข้าใจ

VD Dropbear เริ่ม SSH server และ **ทุกการเชื่อมต่อที่ยืนยันตัวตนสำเร็จจะได้รับ root shell**
ความปลอดภัยของอุปกรณ์ของคุณจึงเท่ากับความปลอดภัยของการกำหนดค่าและข้อมูลรับรองของเซิร์ฟเวอร์นี้ โปรด:

- **เลือกใช้คีย์สาธารณะมากกว่ารหัสผ่าน** การเข้าสู่ระบบด้วยรหัสผ่านปิดอยู่โดยค่าเริ่มต้น
- หากคุณจำเป็นต้องใช้รหัสผ่าน ให้ใช้รหัสผ่านที่แข็งแรง - WebUI บังคับความยาวขั้นต่ำและเก็บเฉพาะแฮชเท่านั้น
- **อย่าเปิดเผยพอร์ตสู่อินเทอร์เน็ตสาธารณะ** ให้ bind กับ loopback หรือ LAN ที่เชื่อถือได้ หรือเข้าถึงมัน
  ผ่าน VPN / อุโมงค์
- ทำความเข้าใจ **การแลกเปลี่ยนของ BFU**: การเปิดใช้งานการเริ่มก่อนปลดล็อกจะวาง host key และข้อมูลรับรอง
  ไว้บนที่เก็บแบบ device-encrypted ซึ่งอ่านได้ก่อนปลดล็อกอุปกรณ์ ให้ปิดไว้เว้นแต่คุณต้องการ SSH
  ก่อนปลดล็อก
- ปิดการส่งต่อไว้เว้นแต่คุณต้องการใช้ (มันปิดอยู่โดยค่าเริ่มต้น)

## สิ่งที่ VD Dropbear ทำเพื่อช่วย

- แบนเนอร์เวอร์ชันที่เป็นกลางและไม่เปิดเผยข้อมูล เพื่อให้ตัวสแกนเครือข่ายไม่สามารถทำ fingerprint
  เซิร์ฟเวอร์และเวอร์ชันที่แน่นอนได้
- ข้อมูลรับรองอยู่บนที่เก็บแบบ credential-encrypted โดยค่าเริ่มต้น (ถอดรหัสหลังจากที่คุณปลดล็อกแล้วเท่านั้น)
- ไม่มีการเก็บข้อมูลการใช้งาน ไม่มีการเรียกเครือข่ายของตัวเอง ไม่มีการวิเคราะห์ มันทำงานทั้งหมดบนอุปกรณ์ของคุณ

## เวอร์ชันที่รองรับ

การแก้ไขด้านความปลอดภัยจะมาในรุ่นล่าสุด ไบนารีของเซิร์ฟเวอร์ติดตาม upstream Dropbear;
รุ่นแก้ไขความปลอดภัยของ upstream จะถูกบิลด์ใหม่และส่งมอบทันทีที่ CI รับมา

## การรายงานช่องโหว่

โปรดรายงานปัญหาด้านความปลอดภัยแบบส่วนตัว ไม่ใช่ในประเด็นปัญหาสาธารณะ:

- **อีเมล:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

ระบุเวอร์ชัน คำอธิบาย และ (ถ้าเป็นไปได้) วิธีการทำให้เกิดซ้ำ คุณจะได้รับการตอบรับ และเราจะประสานงาน
กำหนดเวลาสำหรับการแก้ไขและการเปิดเผยกับคุณ สำหรับช่องโหว่ใน Dropbear เอง
โปรดรายงานไปยัง upstream ที่ <https://matt.ucc.asn.au/dropbear/> ด้วย
