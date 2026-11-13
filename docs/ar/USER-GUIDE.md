<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../USER-GUIDE.md) · العربية · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# دليل المستخدم

يمنح VD Dropbear جهازك المروَّت خادم SSH خاصاً. يأخذك هذا الدليل من التثبيت إلى اتصال عامل، بما في
ذلك نقل الملفات ووضع ما-قبل-أول-فتح (BFU).

> **كل اتصال مُصادَق عليه يحصل على صدفة جذر (root).** فضّل المفاتيح على كلمات المرور، واربط فقط على
> الشبكات التي تثق بها، ولا تُعرّض المنفذ للإنترنت المفتوح دون سبب أبداً.

## 1. التثبيت

ثبّت ملف zip الخاص بالوحدة في مدير **KernelSU** أو **APatch** أو **Magisk** (أو من صدفة باستخدام
`ksud module install` / `apd module install`)، ثم افتح **WebUI** الخاصة بالوحدة.

## 2. أضف مفتاحاً (مُستحسَن)

في WebUI، تحت **Authorized keys**، الصق مفتاحك العام (`ssh-ed25519 AAAA... you@host`) واضغط
**Add key**. المفاتيح هي الافتراضي وأأمن طريقة للدخول.

لإنشاء مفتاح على حاسوبك، إن لم يكن لديك واحد:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. أو عيّن كلمة مرور

تسجيل الدخول بكلمة المرور معطَّل افتراضياً (كل تسجيل دخول هو جذر، لذا تُفضَّل المفاتيح). ولتفعيله،
فعّل **Password login** في الإعدادات، ثم تحت **Password accounts** عيّن كلمة مرور لمستخدم تسجيل
الدخول. تُحسَب البصمة في متصفحك باستخدام PBKDF2؛ ولا تغادر كلمة المرور نفسها الصفحة أبداً.

## 4. اختر منفذاً ومكان الاستماع

تحت **Settings**، عيّن **Port** واختر الروابط. افتراضياً يستمع VD Dropbear على **الاسترجاع المحلي**
فقط؛ وللوصول إليه من شبكتك المحلية أو VPN، فعّل الواجهات التي تريدها. تجنّب
**Listen on all interfaces** ما لم تفهم مدى التعرُّض.

اضغط **Save & restart** للتطبيق، ثم **Start** إن لم يكن يعمل بالفعل.

## 5. اتصل

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server` و`scp` و`rsync` مُضمَّنة، لذا تعمل SFTP و`sshfs` وعملاء الواجهة الرسومية والنسخ
الاحتياطي جميعها عبر الاتصال نفسه.

## 6. قبل أول فتح (BFU)

افتراضياً لا يبدأ الخادم الخفي إلا **بعد** أن تفتح الجهاز مرة واحدة (AFU)، لأن أسراره تقيم على التخزين
المشفَّر ببيانات الاعتماد. إذا احتجت إلى SSH **قبل** أول فتح - مثلاً لفتح جهاز عن بُعد بعد إعادة
التشغيل - فعّل **Start before first unlock (BFU)**. حينها تنتقل الأسرار إلى التخزين المشفَّر بالجهاز،
وهو قابل للقراءة قبل الفتح: مقايضة متعمَّدة وموثَّقة. انظر [نموذج الأمان](#) في README.

## 7. التحكم في الخادم الخفي

- **WebUI:** التشغيل / الإيقاف / إعادة التشغيل، والحالة الحية (قيد التشغيل، PID، المنفذ، الوضع، بصمة مفتاح المضيف).
- **زر Action في المدير:** يعيد تشغيل الخادم الخفي.
- كما يبدأ تلقائياً عند الإقلاع (ما لم تعطّله).

## استكشاف الأخطاء وإصلاحها

- **لا يبدأ.** تحقق من `/data/adb/vddropbear/state/daemon.log`. تأكد أن **Enabled** مُفعَّل وأنه
  أمكن توليد مفتاح مضيف.
- **رُفِض المفتاح.** تأكد أن سطر المفتاح العام مطابق تماماً لما يقدّمه عميلك، وأن مستخدم تسجيل الدخول
  حساب يتعرّف عليه النظام (عادةً `root`).
- **تعذّر الاتصال من جهاز آخر.** على الأرجح ما زلت مربوطاً على الاسترجاع المحلي فقط - فعّل الواجهة
  التي تحتاجها وأعد التشغيل.
- **تفشل SFTP/scp لكن الصدفة تعمل.** تأكد أن `sftp-server` المُضمَّن قد شُحِن لمعمارية ABI الخاصة بك؛
  تعرض حالة WebUI الـ ABI المكتشَفة.
