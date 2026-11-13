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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../SECURITY.md) · العربية · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# سياسة الأمان

## الأمر الوحيد الذي يجب فهمه

يشغّل VD Dropbear خادم SSH، و**كل اتصال يُصادَق عليه بنجاح يحصل على صدفة جذر (root)**. ولذلك فإن أمان
جهازك يساوي أمان إعدادات هذا الخادم وبيانات اعتماده. من فضلك:

- **فضّل المفاتيح العامة على كلمات المرور.** تسجيل الدخول بكلمة المرور معطَّل افتراضياً.
- إذا اضطررت لاستخدام كلمة مرور، فاستخدم واحدة قوية - تفرض WebUI حداً أدنى وتخزّن البصمة فقط.
- **لا تُعرّض المنفذ للإنترنت العام.** اربط على الاسترجاع المحلي أو شبكة محلية موثوقة، أو صِل إليه
  عبر VPN / نفق.
- افهم **مقايضة BFU**: تفعيل البدء-قبل-الفتح يضع مفتاح المضيف وبيانات الاعتماد على التخزين المشفَّر
  بالجهاز، وهي قابلة للقراءة قبل فتح الجهاز. اتركه معطَّلاً ما لم تحتج إلى SSH قبل الفتح.
- أبقِ إعادة التوجيه معطَّلة ما لم تحتج إليها (وهي معطَّلة افتراضياً).

## ما الذي يفعله VD Dropbear للمساعدة

- لافتة إصدار محايدة لا تكشف معلومات كي لا تستطيع ماسحات الشبكة تحديد بصمة الخادم والإصدار بدقة.
- بيانات الاعتماد على التخزين المشفَّر ببيانات الاعتماد افتراضياً (لا تُفَكّ إلا بعد أن تفتح الجهاز).
- لا قياس عن بُعد، ولا اتصالات شبكية خاصة به، ولا تحليلات. يعمل بالكامل على جهازك.

## الإصدارات المدعومة

تصل إصلاحات الأمان إلى أحدث إصدار. يتتبّع الملف الثنائي للخادم Dropbear الأصلي؛ وتُعاد بناء إصدارات
الأمان من المصدر الأصلي وتُشحَن فور أن يلتقطها CI.

## الإبلاغ عن ثغرة

من فضلك أبلِغ عن المشكلات الأمنية بسرّية، لا في مشكلة علنية:

- **البريد الإلكتروني:** vd.priv8@pm.me
- **تيليجرام:** [@VD_Priv8](https://t.me/VD_Priv8)

ضمِّن الإصدار ووصفاً و(يُفضَّل) طريقة لإعادة إنتاج المشكلة. ستحصل على إقرار بالاستلام، وسننسّق معك
إصلاحاً وجدولاً زمنياً للإفصاح. أما الثغرات في Dropbear نفسه، فيُرجى الإبلاغ عنها أيضاً لدى المصدر
الأصلي على <https://matt.ucc.asn.au/dropbear/>.
