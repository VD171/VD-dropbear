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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · ไทย · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# คู่มือผู้ใช้

VD Dropbear มอบ SSH server แบบส่วนตัวให้อุปกรณ์ที่ root ของคุณ คู่มือนี้จะพาคุณตั้งแต่การติดตั้งไปจนถึง
การเชื่อมต่อที่ใช้งานได้ รวมถึงการถ่ายโอนไฟล์และโหมดก่อนการปลดล็อกครั้งแรก (BFU)

> **การเข้าสู่ระบบจะได้ root shell เต็มรูปแบบโดยค่าเริ่มต้น** เลือกใช้คีย์มากกว่ารหัสผ่าน bind เฉพาะกับ
> เครือข่ายที่คุณไว้วางใจเท่านั้น และอย่าเปิดเผยพอร์ตสู่อินเทอร์เน็ตแบบเปิดโดยไม่มีเหตุผล

## 1. ติดตั้ง

แฟลช zip ของโมดูลในตัวจัดการ **KernelSU**, **APatch** หรือ **Magisk** (หรือจากเชลล์ด้วย
`ksud module install` / `apd module install`) จากนั้นเปิด **WebUI** ของโมดูล

## 2. เพิ่มคีย์ (แนะนำ)

ใน WebUI ภายใต้ **Authorized keys** ให้วางคีย์สาธารณะของคุณ (`ssh-ed25519 AAAA... you@host`) แล้วกด
**Add key** คีย์เป็นค่าเริ่มต้นและเป็นวิธีเข้าที่ปลอดภัยที่สุด

วิธีสร้างคีย์บนคอมพิวเตอร์ของคุณ หากคุณยังไม่มี:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. หรือตั้งรหัสผ่าน

การเข้าสู่ระบบด้วยรหัสผ่านปิดอยู่โดยค่าเริ่มต้น (การเข้าสู่ระบบเป็น root โดยค่าเริ่มต้น ดังนั้นจึงนิยมใช้คีย์มากกว่า)
หากต้องการเปิดใช้งาน ให้เปิด **Password login** ในการตั้งค่า จากนั้นภายใต้ **Password accounts**
ให้ตั้งรหัสผ่านสำหรับผู้ใช้ที่เข้าสู่ระบบ แฮชถูกคำนวณในเบราว์เซอร์ของคุณด้วย PBKDF2;
ตัวรหัสผ่านเองไม่เคยออกจากหน้านี้

## 4. เลือกพอร์ตและตำแหน่งที่จะฟัง

ภายใต้ **Settings** ให้ตั้ง **Port** และเลือกการ bind โดยค่าเริ่มต้น VD Dropbear จะฟังเฉพาะบน
**loopback** เท่านั้น; หากต้องการเข้าถึงมันจาก LAN หรือ VPN ของคุณ ให้เปิดใช้งานอินเทอร์เฟซที่คุณต้องการ
หลีกเลี่ยง **Listen on all interfaces** เว้นแต่คุณเข้าใจการเปิดเผยนั้น

กด **Save & restart** เพื่อนำไปใช้ จากนั้น **Start** หากยังไม่ได้ทำงานอยู่

## 5. เชื่อมต่อ

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` และ `rsync` ถูกรวมมาให้ ดังนั้น SFTP, `sshfs`, ไคลเอนต์แบบ GUI และการสำรองข้อมูล
ทั้งหมดจึงทำงานได้ผ่านการเชื่อมต่อเดียวกัน

## 6. ก่อนการปลดล็อกครั้งแรก (BFU)

โดยค่าเริ่มต้น daemon จะเริ่มเฉพาะ **หลังจาก** ที่คุณปลดล็อกอุปกรณ์หนึ่งครั้ง (AFU) เท่านั้น
เพราะความลับของมันอยู่บนที่เก็บแบบ credential-encrypted หากคุณต้องการ SSH **ก่อน** การปลดล็อกครั้งแรก
(เช่น เพื่อปลดล็อกอุปกรณ์จากระยะไกลหลังรีบูต) ให้เปิด **Start before first unlock (BFU)** จากนั้นความลับ
จะย้ายไปยังที่เก็บแบบ device-encrypted ซึ่งอ่านได้ก่อนปลดล็อก: เป็นการแลกเปลี่ยนที่จงใจและมีเอกสารประกอบ ดู
[โมเดลความปลอดภัย](#) ใน README

## 7. การควบคุม daemon

- **WebUI:** Start / Stop / Restart และสถานะแบบเรียลไทม์ (กำลังทำงาน, PID, พอร์ต, โหมด, fingerprint ของ host key)
- **ปุ่ม Action ของตัวจัดการ:** (เริ่มใหม่) daemon
- มันยังเริ่มอัตโนมัติเมื่อบูตด้วย (เว้นแต่คุณจะปิดการใช้งาน)

## การแก้ไขปัญหา

- **มันไม่เริ่มทำงาน** ตรวจสอบ `/data/adb/vddropbear/state/daemon.log` ให้แน่ใจว่า **Enabled** เปิดอยู่
  และสามารถสร้าง host key ได้
- **คีย์ถูกปฏิเสธ** ยืนยันว่าบรรทัดคีย์สาธารณะตรงกับที่ไคลเอนต์ของคุณเสนอพอดี และชื่อผู้ใช้ที่คุณเข้าสู่ระบบ
  เป็นผู้ใช้ที่ระบบแปลงชื่อได้ (โดยทั่วไปคือ `root`)
- **เชื่อมต่อจากเครื่องอื่นไม่ได้** คุณอาจยังคง bind กับ loopback เท่านั้น เปิดใช้งานอินเทอร์เฟซ
  ที่คุณต้องการแล้วเริ่มใหม่
- **SFTP/scp ล้มเหลวแต่เชลล์ทำงานได้** ให้แน่ใจว่า `sftp-server` ที่รวมมาถูกส่งมอบสำหรับ ABI ของคุณ;
  สถานะใน WebUI แสดง ABI ที่ตรวจพบ
