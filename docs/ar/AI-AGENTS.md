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

> **Languages:** [English](../AI-AGENTS.md) · العربية · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# عملاء الذكاء الاصطناعي على جهازك

نقطة اتصال SSH دائمة تحوّل هاتفك إلى شيء يستطيع **عميل ذكاء اصطناعي مستقل تشغيله مباشرة**. أي عميل
قادر على التحكم في صدفة (shell) أو اتصال SSH (مثل Claude Code أو aider أو سكربت يعمل بنموذج لغوي
ضمن الحلقة أو أتمتتك الخاصة) يحصل على جلسة جذر (root) حقيقية على الجهاز، عبر الشبكة، دون وصلة USB
ودون أي من رايات تصحيح الأخطاء الفاضحة لنفسها في ADB.

تتوسّع هذه الصفحة في الفكرة التي عُرضت في ملف README.

## لماذا SSH وليس ADB للعملاء

يعلن ADB عن نفسه: القيمتان `adb_enabled` و`development_settings_enabled` قابلتان للقراءة من الجميع،
ويُسجَّل الاتصال، ولا توجد طريقة مدعومة لإخفاء أن تصحيح الأخطاء مُفعَّل (أو كان مُفعَّلاً). أي عميل
يعمل عبر ADB يترك هذا الأثر على الجهاز ليقرأه أي تطبيق أو حزمة SDK لمكافحة الاحتيال. أما VD Dropbear
فهو البديل الخاص: تسجيل دخول SSH عادي، ببيانات اعتماد تتحكم بها أنت ولافتة لا تكشف شيئاً.

## ما الذي يستطيع العميل فعله

عبر اتصال واحد، يرى العميل صدفة عادية شبيهة بلينكس ويستطيع:

- قراءة الملفات وتحريرها، وتبديل الإعدادات، وإدارة الوحدات والحزم والخدمات؛
- فرز السجلات، وسحب المخرجات، وتشغيل التشخيص أو التحليل الجنائي عند الطلب؛
- نقل الملفات ومزامنتها في الاتجاهين عبر `scp` / `sftp` / `rsync`: النسخ الاحتياطي والترحيل والتهيئة؛
- إدارة أسطول كامل من الأجهزة المروَّتة من مكان واحد، كلٌّ منها يُوصَل بمفتاحه الخاص.

ولأن المشروع مبني ليكون **ملائماً للذكاء الاصطناعي** (ملف إعدادات موثَّق، و[عقد بيئة تشغيل](../../patches/README.md)
صريح، ومسارات متوقَّعة وحالة بنص صريح)، يستطيع العميل اكتشاف كيفية استخدامه دون تخمين.

## كيف تفعل ذلك بأمان

هذا جذر (root)، فتعامل معه كجذر:

- امنح العميل **بيانات اعتماد خاصة به**، لا بيانات اعتمادك الشخصية، ووجِّهه إلى حساب أقل امتيازًا (`shell`) إن أردت الحدّ من نطاق وصوله؛
- اقصُر الربط على الشبكات التي تثق بها: الاسترجاع المحلي (loopback) أو شبكة VPN بدلاً من الإنترنت المفتوح
  (انظر [الإعدادات](CONFIGURATION.md))؛
- أبقِ مصادقة كلمة المرور معطَّلة؛ فالمفتاح قابل للإبطال ولا يُكتَب أبداً؛
- يمكنك إبطال مفتاح أو إيقاف الخادم الخفي (daemon) في أي وقت من WebUI؛
- تذكَّر أن الاتصال الافتراضي هو جلسة جذر كاملة: امنح العميل فقط النطاق الذي يحتاجه.

## إعداد بالحد الأدنى

1. أنشئ زوج مفاتيح خاصاً بالعميل وحده.
2. أضف مفتاحه العام في WebUI (**Authorized keys**).
3. اربط على الاسترجاع المحلي أو شبكة VPN فقط، على منفذ غير افتراضي.
4. وجِّه إعداد SSH الخاص بالعميل إلى الجهاز ودعه يعمل.
