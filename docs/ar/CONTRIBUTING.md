<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../CONTRIBUTING.md) · العربية · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# المساهمة في VD Dropbear

شكراً لاهتمامك. هذا مشروع صغير حسّاس أمنياً (فهو يمنح صلاحية الجذر)، لذا تُراجَع التغييرات مع وضع ذلك
في الحسبان.

## بنية المستودع

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## البناء

يُنتَج الملف الثنائي عبر CI من **[mkj/dropbear](https://github.com/mkj/dropbear) الأصلي** بالإضافة إلى
التصحيحات الموجودة في `patches/`. وللبناء محلياً تحتاج إلى Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

مجموعة التصحيحات مُصمَّمة عمداً لتكون بالحد الأدنى وقابلة للتدقيق: سلسلة هوية محايدة/قابلة للضبط،
ومسارات تُحدَّد عبر الإعدادات لـ `authorized_keys` وملف كلمة المرور، وإصلاح `openpty` الخاص بأندرويد،
وإعداد وقت التشغيل. من فضلك أبقِ التصحيحات الجديدة صغيرة وموثَّقة ومبرَّرة في الـ PR.

## طلبات الدمج

- تغيير منطقي واحد لكل PR؛ واوصف الدافع والأثر الأمني.
- التزم بأسلوب الصدفة القائم (POSIX `sh` / Android `mksh`؛ دون bashisms).
- كل ملف يحمل ترويسة SPDX قصيرة - أبقِها.
- حدّث [`CHANGELOG.md`](../../CHANGELOG.md) تحت `[Unreleased]` عند أي تغيير حقيقي يراه المستخدم.
- بتقديمك PR فإنك توافق على ترخيص مساهمتك بموجب رخصة [Apache-2.0](../../LICENSE) الخاصة بالمشروع.

## الترجمات

يُصان ملف README والوثائق بعدة لغات (`README.<lang>.md`). الإنجليزية هي المصدر الموثوق؛ والترجمات
تتبعها. إذا حسّنت ترجمة أو أضفت لغة، فأبقِ البنية ومراسي الأقسام مطابقة للنسخة الإنجليزية.

## الإبلاغ عن العلل والمشكلات الأمنية

استخدم قوالب المشكلات للعلل وطلبات الميزات. وبالنسبة لأي شيء قد يُعرّض جهازاً للخطر، اتّبع
[`SECURITY.md`](SECURITY.md) وأبلِغ بسرّية بدلاً من فتح مشكلة علنية.
