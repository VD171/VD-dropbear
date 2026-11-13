<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.

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

<p align="center">
  <img src="module/webroot/assets/logo-wordmark.svg" alt="VD Dropbear" width="540">
</p>

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-1a7f37" alt="License"></a>
  <img src="https://img.shields.io/badge/KernelSU-%E2%9C%94-635bff" alt="KernelSU">
  <img src="https://img.shields.io/badge/APatch-%E2%9C%94-ff7043" alt="APatch">
  <img src="https://img.shields.io/badge/Magisk-%E2%9C%94-00af9c" alt="Magisk">
  <a href="https://github.com/VD171/VD-dropbear/stargazers"><img src="https://img.shields.io/github/stars/VD171/VD-dropbear?color=d29922" alt="Stars"></a>
  <a href="https://github.com/VD171/VD-dropbear/releases"><img src="https://img.shields.io/github/v/release/VD171/VD-dropbear?color=1a7f37" alt="Release"></a>
</p>

**خادم SSH مستقل وقابل للتهيئة بالكامل يعتمد على [Dropbear](https://matt.ucc.asn.au/dropbear/)**،
معبّأ كوحدة لـ KernelSU / APatch / Magisk. يعمل بمفرده ولا يعتمد على أي وحدة أخرى.

> ⚠️ **يمنح تسجيل الدخول افتراضيًا صدفة ROOT كاملة.** تعامل مع هذا كأنه مفاتيح الجهاز:
> فضّل المفاتيح العامة على كلمات المرور، وأبقِ المنفذ بعيدًا عن شبكة الإنترنت العامة.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## لماذا

الطريقة المدمجة في أندرويد للحصول على صدفة على هاتفك هي ADB (تصحيح أخطاء USB)، وتفعيلها أمرٌ
تطفّلي ويكشفك. فالإعدادان `adb_enabled` و`development_settings_enabled` قابلان للقراءة من أي تطبيق،
فأي تطبيق أو SDK أو مكتبة لمكافحة الاحتيال / RASP يستطيع قراءتهما، والاتصال يُسجَّل، ولا توجد طريقة
مدعومة لإخفاء أن ADB مُفعَّل، أو أنه كان مُفعَّلًا يومًا ما. هذا الكشف يلاحقك حتى على هاتف أصلي غير مروّت:
لكي تحصل على صدفة، عليك أن تُعلن عن ذلك.

VD Dropbear هو البديل الخاص. على جهاز مروّت يمنحك خادم SSH حقيقيًا: صدفة root، وSFTP وrsync عبر
الشبكة، دون أثر `adb_enabled`، ودون علم تصحيح أخطاء USB، وببانر إصدار لا يكشف شيئًا، وببيانات اعتماد
تتحكم بها أنت. يبقى وصولك ملكًا لك، بدلًا من علم "أنا تحت التصحيح" القابل للقراءة عالميًا والذي يستطيع
أي شيء على الجهاز قراءته.

## المميزات

- **داعم واحد، دائمًا.** يبدأ عند الإقلاع ومن زر **Action** في المدير، ويمكنك **تشغيله / إيقافه /
  إعادة تشغيله** من واجهة الويب في أي وقت؛ لا أكثر من نسخة واحدة أبدًا.
- **كل شيء قابل للتهيئة** من واجهة الويب (أو `/data/adb/vddropbear/config`):
  - المنفذ، والربط بـ loopback / الكل / IPv4 / IPv6 / عناوين محددة
  - **البدء قبل فتح القفل الأول (BFU) أو بعده فقط (AFU)**، مفتاح تبديل واحد
  - مصادقة بالمفتاح العام و/أو بكلمة المرور، والحد الأقصى لمحاولات المصادقة
  - صدفة تسجيل الدخول، و`HOME`، ومتغيرات بيئة إضافية
  - مهلة الخمول، وإبقاء الاتصال حيًا، ونافذة الاستقبال
  - إعادة توجيه المنافذ المحلية / البعيدة ومنافذ البوابة (كلها **معطّلة** افتراضيًا)
  - نوع مفتاح المضيف (ed25519 / rsa / ecdsa)
- **بانر إصدار مخفي.** يتطلب بروتوكول SSH وجود بانر *ما*، فلا يمكن إزالته، لكن VD Dropbear
  يستبدله ببانر عديم الفائدة لكي لا تستطيع الماسحات تحديد بصمة الخادم أو الإصدار بدقة وتوجيه
  الهجمات المعروفة لذلك الإصدار نحوه.
- **الأسرار مُخزَّنة بحكمة** (راجع [نموذج الأمان](#security-model)).
- **أحضر بيانات اعتمادك الخاصة.** أضف مفاتيح مُصرَّحًا بها وحسابات بكلمة مرور. يعمل تسجيل الدخول بصفة
  الحساب الذي تصادق به: **root** افتراضيًا، أو حساب أندرويد ذي صلاحيات أقل (`shell`، `system`). تفرض واجهة
  الويب حدًا أدنى لقوة كلمة المرور ولا تخزّن كلمة مرور بنص صريح أبدًا.
- **نقل الملفات والمزامنة مدمجان.** تتضمن الحزمة `sftp-server` و`scp` و`rsync`، فيعمل SFTP
  وsshfs وعملاء الواجهة الرسومية والنسخ الاحتياطي جميعها عبر الاتصال نفسه.
- **كل جهاز ومحاكٍ.** `arm64-v8a` و`armeabi-v7a` و`x86` و`x86_64`.

## وكلاء الذكاء الاصطناعي على جهازك

نقطة وصول SSH دائمة تحوّل هاتفك إلى شيء يستطيع **وكيل ذكاء اصطناعي مستقل تشغيله مباشرة**. أي وكيل
يستطيع قيادة صدفة أو اتصال SSH (Claude Code أو aider أو سكربت يعمل بحلقة LLM أو أتمتتك الخاصة)
يحصل على جلسة root حقيقية على الجهاز، عبر الشبكة، دون وصلة USB ودون أي من أعلام التصحيح الكاشفة
الخاصة بـ ADB. يرى الوكيل صدفة عادية شبيهة بلينكس ويستطيع:

- قراءة الملفات وتحريرها، وتبديل الإعدادات، وإدارة الوحدات والحزم والخدمات؛
- فرز السجلات، وسحب القطع الأثرية، وتشغيل التشخيصات أو التحليل الجنائي عند الطلب؛
- نقل الملفات ومزامنتها في الاتجاهين عبر `scp` / `sftp` / `rsync`، للنسخ الاحتياطي أو الترحيل أو التجهيز؛
- قيادة أسطول كامل من الأجهزة المروّتة من مكان واحد، كل جهاز يُوصَل إليه بمفتاحه الخاص.

ولأن المشروع مبني ليكون **صديقًا للذكاء الاصطناعي** (ملف تهيئة موثّق، و[عقد بيئة](patches/README.md)
صريح وقت التشغيل، ومسارات يمكن التنبؤ بها، وحالة بنص صريح)، يستطيع أي وكيل اكتشاف كيفية استخدامه
دون تخمين.

> **root افتراضيًا، فعامله كـ root.** يصل تسجيل الدخول الافتراضي كـ root، ويمكنك أيضًا تسجيل الدخول
> بحساب ذي صلاحيات أقل (`shell`، `system`)؛ راجع التحذير أدناه. عندما تمنح
> وصولًا لوكيل، أعطه بيانات اعتماد خاصة به (لا مفتاحك الشخصي)، ووجّهه إلى حساب ذي صلاحيات أقل مثل
> `shell` إذا أردت الحد من نطاق وصوله، وحصر الربط بالشبكات التي تثق بها (loopback أو VPN
> بدلًا من الإنترنت المفتوح)، وأبقِ مصادقة كلمة المرور معطّلة، وتذكّر أنه يمكنك إبطال مفتاح أو إيقاف
> الداعم في أي وقت من واجهة الويب.

## التثبيت

افلش ملف zip الخاص بالوحدة في مدير KernelSU أو APatch أو Magisk (أو من سطر الأوامر عبر
`ksud module install` / `apd module install`)، ثم افتح **واجهة الويب** للوحدة لضبط المنفذ وإضافة
مفاتيحك، ثم أعد الإقلاع (أو اضغط **Action** لتشغيلها الآن).

## نموذج الأمان

### أين تعيش الأسرار: BFU مقابل AFU

`/data/adb` هو تخزين **مُشفَّر على مستوى الجهاز (DE)**: يُفكّ تشفيره *قبل* أن يفتح المستخدم قفل الهاتف
(قبل فتح القفل الأول)، فأي شيء هناك قابل للقراءة قبل فتح القفل. أما `/data/misc_ce` فهو **مُشفَّر على
مستوى بيانات الاعتماد (CE)**: يبقيه أندرويد مُشفَّرًا حتى يفتح المستخدم القفل (بعد فتح القفل الأول).

- **وضع AFU (افتراضي، `START_IN_BFU=0`):** ينتظر الداعم فتح القفل ثم يقرأ مفتاح المضيف الخاص به
  و`authorized_keys` وتجزئات كلمات المرور من تخزين CE. حماية قصوى؛ يعمل SSH فقط بعد فتح قفل الجهاز
  مرة واحدة منذ الإقلاع.
- **وضع BFU (`START_IN_BFU=1`):** يبدأ الداعم قبل فتح القفل لكي تتمكن من الاتصال بـ SSH مبكرًا (مثلًا،
  لفتح قفل الجهاز عن بُعد). عندها تعيش أسراره على تخزين DE وتصبح قابلة للقراءة قبل فتح القفل، وهي
  مقايضة متعمَّدة وموثَّقة. فعّله فقط إذا كنت بحاجة إلى SSH قبل فتح القفل.

نحن **لا** نضيف عمدًا تشفيرنا الخاص فوق CE: فهو مُشفَّر بالفعل ببيانات اعتماد المستخدم، وإضافة طبقة
تشفير أخرى ستحتاج مفتاحًا يجب أن يعيش في مكان ما (على DE سيكون مكشوفًا؛ واشتقاقه من بيانات اعتماد
المستخدم ما هو إلا إعادة تنفيذ لـ CE). ذلك يمنح شعورًا زائفًا بالأمان، لا حماية حقيقية.

### كلمات المرور

تسجيل الدخول بكلمة المرور **معطّل افتراضيًا**، لأن تسجيل الدخول هو root افتراضيًا والمفاتيح أكثر أمانًا بكثير.
وعندما تضبط كلمة مرور، تفرض واجهة الويب حدًا أدنى للقوة وتخزّن تجزئة فقط، لا نصًا صريحًا أبدًا.

## البناء

يُبنى الملف الثنائي للخادم عبر CI من **مصدر [mkj/dropbear](https://github.com/mkj/dropbear)** مع
مجموعة تعديلات صغيرة قابلة للتدقيق (راجع [`patches/`](patches/)): سلسلة هوية محايدة/قابلة للتهيئة،
ومسارات مدفوعة بالتهيئة لـ `authorized_keys` وملف كلمة المرور، وإصلاح `openpty` الخاص بأندرويد لأجهزة
PTY التفاعلية. يتتبع سير عمل مجدول المصدر ويعيد البناء، فتبقى الوحدة محدَّثة. راجع
[`.github/workflows/`](.github/workflows/) و[`CONTRIBUTING.md`](CONTRIBUTING.md).

## التوثيق

<!-- vd-docs -->
التوثيق الكامل موجود في [الويكي](https://github.com/VD171/VD-dropbear/wiki) وتحت
[`docs/`](docs/).
<!-- /vd-docs -->

## انظر أيضًا

مشاريع شقيقة للمؤلف نفسه:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: مصحّح طرق للجهاز يقرأ كل عنصر عبر كل طريقة قادرة على قراءته ويقارنها جنبًا إلى جنب.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: خدمات Google الخاصة بك (RCS وWallet وتصديقات Play Integrity)، تُقرأ على جهازك دون إنترنت.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: نسخ احتياطي واستعادة كاملان للتطبيقات والبيانات كـ root، يُدار بالكامل من واجهة ويب.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: مزيّف عالمي لبصمة الجهاز ومعلومات البناء.

## جهات الاتصال

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** <https://xdaforums.com/t/VD-Dropbear.4808524/>
* **GitHub:** @VD171 https://github.com/VD171

## الترخيص

كود VD Dropbear الخاص هو **Apache-2.0**؛ راجع [LICENSE](LICENSE). تحزم الوحدة أيضًا ملفات ثنائية
من أطراف خارجية: [Dropbear](https://matt.ucc.asn.au/dropbear/) (بأسلوب MIT)، و`sftp-server`
و`scp` من OpenSSH (BSD)، و`rsync` (GPL-3.0)، كلٌّ تحت ترخيصه الخاص؛ راجع
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)، بما في ذلك كيفية امتثالنا لرخصة GPL الخاصة بـ rsync.
كودنا بترخيص Apache-2.0 غير متأثر (الملف الثنائي بترخيص GPL مُجمَّع فقط، وليس مرتبطًا).

## العلامات التجارية

VD Dropbear مشروع مستقل وغير رسمي، وغير مرتبط بأي طرف خارجي أو معتمد منه. "Android" علامة تجارية
لشركة Google LLC؛ و"SSH" علامة تجارية مسجّلة لشركة SSH Communications Security. يعمل VD Dropbear
بالكامل على جهازك.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
