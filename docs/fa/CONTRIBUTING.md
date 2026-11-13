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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · فارسی · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# مشارکت در VD Dropbear

از علاقهٔ شما سپاسگزاریم. این یک پروژهٔ کوچک و حساس به امنیت است (دسترسی root را واگذار می‌کند)، پس تغییرات
با در نظر گرفتن همین نکته بازبینی می‌شوند.

## چیدمان مخزن

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## ساخت

باینری توسط CI از **[mkj/dropbear](https://github.com/mkj/dropbear) upstream** به‌علاوهٔ وصله‌های موجود در
`patches/` تولید می‌شود. برای ساخت محلی به Android NDK نیاز دارید:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

مجموعهٔ وصله‌ها عمداً حداقلی و قابل‌ممیزی است: یک رشتهٔ هویت خنثی/قابل‌پیکربندی، مسیرهای هدایت‌شده با
پیکربندی برای `authorized_keys` و فایل رمز عبور، اصلاح `openpty` اندروید، و پیکربندی در زمان اجرا. لطفاً
وصله‌های جدید را کوچک، مستند و توجیه‌شده در PR نگه دارید.

## Pull requestها

- یک تغییر منطقی در هر PR؛ انگیزه و تأثیر امنیتی را شرح دهید.
- سبک شل موجود را رعایت کنید (POSIX `sh` / `mksh` اندروید؛ بدون bashism).
- هر فایل یک سربرگ کوتاه SPDX دارد - آن را نگه دارید.
- [`CHANGELOG.md`](../../CHANGELOG.md) را زیر `[Unreleased]` برای هر تغییر واقعی و قابل‌مشاهده برای کاربر به‌روز کنید.
- با ارسال یک PR موافقت می‌کنید که مشارکت خود را تحت مجوز [Apache-2.0](../../LICENSE) پروژه منتشر کنید.

## ترجمه‌ها

README و مستندات در زبان‌های بسیاری نگهداری می‌شوند (`README.<lang>.md`). انگلیسی منبع حقیقت است؛ ترجمه‌ها
از آن پیروی می‌کنند. اگر ترجمه‌ای را بهبود دادید یا زبانی افزودید، ساختار و لنگرهای بخش را عیناً مانند
نسخهٔ انگلیسی نگه دارید.

## گزارش باگ‌ها و مسائل امنیتی

برای باگ‌ها و درخواست‌های ویژگی از قالب‌های مسئله استفاده کنید. برای هر چیزی که می‌تواند یک دستگاه را به
خطر بیندازد، از [`SECURITY.md`](SECURITY.md) پیروی کنید و به‌جای گشودن یک مسئلهٔ عمومی، آن را خصوصی گزارش
دهید.
