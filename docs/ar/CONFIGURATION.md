<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../CONFIGURATION.md) · العربية · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# الإعدادات

تقيم الإعدادات في `/data/adb/vddropbear/config` (تُبذَر من `module/common/config.default` عند أول
إقلاع). تحرّر **WebUI** هذا الملف نيابةً عنك؛ ويمكنك أيضاً تحريره يدوياً. يُحمَّل كصدفة (shell)، لذا
استخدم `KEY=value` دون مسافات حول `=`. الإعدادات ليست سرّية وتقيم على التخزين المشفَّر بالجهاز؛ أما
الأسرار (مفاتيح المضيف والمفاتيح المصرَّح بها وبصمات كلمات المرور) فتقيم في مخزن الأسرار، لا هنا أبداً.

طبّق التغييرات بإعادة تشغيل الخادم الخفي (يقوم زر **Save & restart** في WebUI بذلك).

## عام

| المفتاح | الافتراضي | المعنى |
|-----|---------|---------|
| `ENABLED` | `1` | تشغيل الخادم الخفي عند الإقلاع. القيمة `0` تعطّله كلياً. |
| `START_IN_BFU` | `0` | `0`: البدء فقط بعد أول فتح (AFU)؛ تبقى الأسرار على التخزين المشفَّر ببيانات الاعتماد (CE). `1`: البدء أيضاً قبل أول فتح (BFU)؛ تنتقل الأسرار إلى التخزين المشفَّر بالجهاز (DE)، وتصبح قابلة للقراءة قبل الفتح. |
| `PORT` | `2222` | منفذ الاستماع الافتراضي (يمكن لمنافذ كل ربط تجاوزه في `LISTEN_ADDRESSES`). |

## الاستماع / الروابط (قابلة للتركيب)

أي تركيبة مسموح بها؛ وتُدمَج الروابط المختارة. إذا مسحت كل شيء، يربط VD Dropbear الاسترجاع المحلي
بدلاً من كل واجهة.

| المفتاح | الافتراضي | المعنى |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | الاستماع على `127.0.0.1` / `::1` فقط. |
| `LISTEN_ALL` | `0` | الاستماع على كل واجهة (`0.0.0.0` / `::`)؛ يُعرّض الجهاز. |
| `LISTEN_IPV4` | `1` | تضمين روابط IPv4. |
| `LISTEN_IPV6` | `1` | تضمين روابط IPv6. |
| `LISTEN_ADDRESSES` | `""` | روابط محدَّدة إضافية، مفصولة بفواصل: `addr` (يستخدم `PORT`) أو `addr:port`، IPv4 أو IPv6. |

## الهوية

| المفتاح | الافتراضي | المعنى |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | إرسال لافتة هوية SSH محايدة كي لا تستطيع الماسحات تحديد بصمة الخادم/الإصدار بدقة. |
| `IDENT_STRING` | `""` | سلسلة هوية مخصَّصة. القيمة الفارغة تستخدم الافتراضي المحايد المدمج. |

## المصادقة

يُشغَّل تسجيل الدخول بالحساب الذي تُصادِق به: **جذر (root)** افتراضيًا، أو حساب أقل امتيازًا (`shell`، `system`). المفاتيح هي الافتراضي؛ وكلمات المرور اختيارية.

| المفتاح | الافتراضي | المعنى |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | السماح بتسجيل الدخول بالمفتاح العام (يقرأ المفاتيح المصرَّح بها في مخزن الأسرار). |
| `PASSWORD_AUTH` | `0` | السماح بتسجيل الدخول بكلمة المرور. عند الإيقاف، يُشغَّل الخادم الخفي مع تعطيل مصادقة كلمة المرور. |
| `MAX_AUTH_TRIES` | `3` | الحد الأقصى لمحاولات المصادقة لكل اتصال. |

## الجلسة / البيئة

| المفتاح | الافتراضي | المعنى |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | الصدفة الخاصة بالجلسة. القيمة الفارغة تستخدم افتراضي الحساب. |
| `HOME_DIR` | `""` | قيمة `HOME` للجلسة. القيمة الفارغة تستخدم دليل الوحدة. |
| `EXTRA_ENV` | `""` | بيئة إضافية، `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | قطع الاتصال بعد N ثانية من الخمول. القيمة `0` تعطّل ذلك. |
| `KEEPALIVE` | `0` | إرسال نبضة إبقاء كل N ثانية. القيمة `0` تعطّل ذلك. |
| `RECEIVE_WINDOW` | `""` | حجم نافذة الاستقبال في Dropbear. القيمة الفارغة تستخدم الافتراضي. |

## إعادة التوجيه (معطّلة افتراضياً)

| المفتاح | الافتراضي | المعنى |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | السماح بإعادة توجيه المنفذ المحلي (`-L`). |
| `ALLOW_REMOTE_FORWARD` | `0` | السماح بإعادة توجيه المنفذ البعيد (`-R`). |
| `GATEWAY_PORTS` | `0` | السماح للمنافذ البعيدة المُعاد توجيهها بالربط على كل الواجهات. |

## مفتاح المضيف

| المفتاح | الافتراضي | المعنى |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | نوع مفتاح المضيف: `ed25519` أو `rsa` أو `ecdsa`. يُولَّد عند أول تشغيل في مخزن الأسرار. |

## مخزن الأسرار

لا يُضبَط هنا، يُحدَّد من `START_IN_BFU`:

- **AFU (الافتراضي):** `/data/misc_ce/0/vddropbear/secret`: مشفَّر ببيانات الاعتماد، متاح فقط بعد أن
  تفتح الجهاز.
- **BFU:** `/data/adb/vddropbear/secret`: مشفَّر بالجهاز، قابل للقراءة قبل أول فتح.

يحتوي على مفتاح المضيف و`authorized_keys` وملف بصمات `passwd`. انظر
[BUILDING.md](../BUILDING.md) لمعرفة صيغة بصمة كلمة المرور.
