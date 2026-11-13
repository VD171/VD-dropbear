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

> **Languages:** [English](../ARCHITECTURE.md) · العربية · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# البنية

VD Dropbear هو وحدة KernelSU / APatch / Magisk تشغّل خادم Dropbear SSH واحداً بالضبط، مُدار بالكامل
عبر الإعدادات. لا شيء في خادم SSH مُثبَّت مسبقاً لجهاز بعينه؛ فكل ما هو خاص إما إعداد وقت تشغيل أو سر.

## المكوّنات

- `module/common/vddropbear.sh` - المكتبة الأساسية: تحميل الإعدادات (مع قيم افتراضية مدمجة آمنة)،
  وتحديد مخزن الأسرار، وضمان وجود مفتاح مضيف، وبناء متجه وسائط Dropbear، وإدارة نسخة واحدة من الخادم
  الخفي (تشغيل / إيقاف / حالة / إعادة تشغيل).
- `module/service.sh` - مدخل الإقلاع. يحترم سياسة بدء التشغيل BFU/AFU؛ وفي وضع AFU ينتظر فتح التخزين
  المشفَّر ببيانات الاعتماد دون تعطيل الإقلاع.
- `module/action.sh` - زر **Action** في المدير: (إعادة) تشغيل الخادم الخفي. لا يقرأ stdin أبداً
  ويفصل الخادم الخفي إلى جلسته الخاصة، فلا يتجمّد المدير.
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - الواجهة الخلفية لـ WebUI وصفحتها.
- `patches/` - تصحيحات صغيرة قابلة للتدقيق تُطبَّق على Dropbear الأصلي وقت البناء.
- `scripts/build.sh` و`scripts/build-bundles.sh` و`.github/workflows/build.yml` - عملية البناء.

## دورة حياة الخادم الخفي (نسخة واحدة)

يحمّل `vddb_start` الإعدادات، ويوقف أي نسخة قيد التشغيل، ويضمن وجود مفتاح مضيف، ثم يطلق خادماً خفياً
واحداً. يُشحَن الملف الثنائي باسم `vddropbear`، فيطابق اسم عمليته `pgrep -x` تماماً (لا يملك `mksh`
في أندرويد الخيار `exec -a`). يُطلَق بـ `setsid` كي ينفصل عن مجموعة عمليات المُستدعي - وهذا ما يمنع
زر Action في المدير من التوقف.

## مخزن الأسرار (CE مقابل DE، BFU مقابل AFU)

الإعدادات ليست سرّية وتقيم على التخزين المشفَّر بالجهاز (`/data/adb/vddropbear`)، وهي قابلة للقراءة
عند الإقلاع. أما الأسرار - مفتاح المضيف و`authorized_keys` وبصمات كلمات المرور - فتكون افتراضياً على
التخزين **المشفَّر ببيانات الاعتماد** (`/data/misc_ce/0/vddropbear`)، الذي لا يُفتَح إلا بعد مصادقة
المستخدم. تفعيل `START_IN_BFU` ينقل الأسرار إلى التخزين المشفَّر بالجهاز كي يستطيع الخادم الخفي العمل
قبل أول فتح، على حساب أن تصبح تلك الأسرار قابلة للقراءة في وقت أبكر. تحسب الوحدة أي مخزن تستخدم في كل
مرحلة من مراحل الإقلاع.

## مجموعة التصحيحات

يبقى خادم SSH هو Dropbear الأصلي؛ وتغييراتنا ليست سوى بضعة تصحيحات قابلة للمراجعة (انظر
[patches/README.md](../../patches/README.md)):

- لافتة هوية محايدة قابلة للضبط وقت التشغيل؛
- قراءة `authorized_keys` من مسار يُحدَّد عبر البيئة (كي تقيم المفاتيح في مخزن الأسرار)؛
- مصادقة كلمة المرور مقابل ملف بصمات PBKDF2 بدلاً من `crypt()`/shadow في النظام، وهو ما يفتقر إليه
  أندرويد (انظر [BUILDING.md](../BUILDING.md)).

## واجهة WebUI

صفحة ثابتة ضمن WebUI الخاص بالمدير (KernelSU / APatch / WebUI-X). تقود
`module/common/vddb-webui.sh` عبر جسر `ksu.exec`: الحالة، والتشغيل/الإيقاف/إعادة التشغيل،
وقراءة/كتابة الإعدادات، وإدارة المفاتيح وحسابات كلمات المرور. تعبر كل البيانات الجسر مُرمَّزة بـ
base64، فلا تفسّرها الصدفة أبداً؛ وتُحسَب بصمات كلمات المرور في المتصفح باستخدام WebCrypto، فلا تغادر
كلمة المرور الصريحة الصفحة أبداً.
