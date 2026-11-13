<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Contributing guide.

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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · ไทย · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# การมีส่วนร่วมกับ VD Dropbear

ขอบคุณที่สนใจ นี่คือโครงการขนาดเล็กที่ไวต่อความปลอดภัย (มันแจกสิทธิ์ root) ดังนั้นการเปลี่ยนแปลงต่าง ๆ
จึงถูกตรวจทานโดยคำนึงถึงสิ่งนั้น

## โครงสร้างของที่เก็บโค้ด

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## การบิลด์

ไบนารีถูกสร้างโดย CI จาก **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** พร้อมกับแพตช์
ใน `patches/` หากต้องการบิลด์ในเครื่อง คุณต้องมี Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

ชุดแพตช์ถูกออกแบบให้มีขนาดน้อยที่สุดและตรวจสอบได้โดยเจตนา: สตริงระบุตัวตนที่เป็นกลาง/กำหนดค่าได้
เส้นทางที่ขับเคลื่อนด้วยการกำหนดค่าสำหรับ `authorized_keys` และไฟล์รหัสผ่าน การแก้ไข `openpty` ของ Android
และการกำหนดค่าขณะรันไทม์ โปรดทำให้แพตช์ใหม่มีขนาดเล็ก มีเอกสารประกอบ และมีเหตุผลรองรับใน PR

## Pull request

- หนึ่งการเปลี่ยนแปลงเชิงตรรกะต่อหนึ่ง PR; อธิบายแรงจูงใจและผลกระทบด้านความปลอดภัย
- ให้เข้ากับสไตล์เชลล์ที่มีอยู่ (POSIX `sh` / Android `mksh`; ห้ามใช้ bashism)
- ทุกไฟล์มีส่วนหัว SPDX สั้น ๆ เก็บมันไว้
- อัปเดต [`CHANGELOG.md`](../../CHANGELOG.md) ภายใต้ `[Unreleased]` สำหรับการเปลี่ยนแปลงจริงที่ผู้ใช้มองเห็นได้
- การส่ง PR ถือว่าคุณยอมรับที่จะอนุญาตให้ใช้สิทธิ์การมีส่วนร่วมของคุณภายใต้สัญญาอนุญาต [Apache-2.0](../../LICENSE) ของโครงการ

## การแปล

README และเอกสารต่าง ๆ ได้รับการดูแลในหลายภาษา (`README.<lang>.md`) ภาษาอังกฤษคือแหล่งความจริงหลัก;
การแปลเป็นไปตามนั้น หากคุณปรับปรุงการแปลหรือเพิ่มภาษา ให้คงโครงสร้างและ anchor ของแต่ละส่วน
ให้เหมือนกับเวอร์ชันภาษาอังกฤษ

## การรายงานบั๊กและปัญหาด้านความปลอดภัย

ใช้เทมเพลตประเด็นปัญหาสำหรับบั๊กและคำขอฟีเจอร์ สำหรับสิ่งใดก็ตามที่อาจทำให้อุปกรณ์ตกอยู่ในความเสี่ยง
ให้ทำตาม [`SECURITY.md`](SECURITY.md) และรายงานแบบส่วนตัวแทนที่จะเปิดประเด็นปัญหาสาธารณะ
