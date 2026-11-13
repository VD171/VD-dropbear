<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · فارسی · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# معماری

VD Dropbear یک ماژول KernelSU / APatch / Magisk است که دقیقاً یک دیمون SSH Dropbear را اجرا می‌کند و
کاملاً با پیکربندی هدایت می‌شود. هیچ چیزِ سرور SSH برای یک دستگاه خاص در کد ثابت نشده است؛ هر چیز خاصی یا
پیکربندی زمان اجرا است یا یک راز.

## اجزا

- `module/common/vddropbear.sh`، کتابخانهٔ هسته‌ای: بارگذاری پیکربندی (با مقادیر پیش‌فرض داخلی و ایمن)،
  یافتن انبار راز، تضمین وجود یک host key، ساختن بردار آرگومان‌های Dropbear و مدیریت یک نمونهٔ واحد از دیمون
  (start / stop / status / restart).
- `module/service.sh`: نقطهٔ ورود در بوت. سیاست شروع BFU/AFU را رعایت می‌کند؛ در حالت AFU منتظر می‌ماند تا
  فضای ذخیره‌سازی رمزنگاری‌شده با اعتبارنامه باز شود، بدون اینکه بوت را متوقف کند.
- `module/action.sh`، دکمهٔ **Action** مدیر: دیمون را (دوباره) راه‌اندازی می‌کند. هرگز stdin را نمی‌خواند و
  دیمون را به نشست خودش جدا می‌کند، بنابراین مدیر معلق نمی‌ماند.
- `module/common/vddb-webui.sh` + `module/webroot/index.html`: بک‌اند و صفحهٔ WebUI.
- `patches/`: وصله‌های کوچک و قابل‌ممیزی که در زمان ساخت روی Dropbear upstream اعمال می‌شوند.
- `scripts/build.sh`، `scripts/build-bundles.sh`، `.github/workflows/build.yml`: ساخت.

## چرخهٔ عمر دیمون (نمونهٔ واحد)

`vddb_start` پیکربندی را بارگذاری می‌کند، هر نمونهٔ در حال اجرا را متوقف می‌کند، وجود یک host key را تضمین
می‌کند و سپس یک دیمون واحد را به‌راه می‌اندازد. باینری با نام `vddropbear` عرضه می‌شود، بنابراین نام
فرایندش دقیقاً با `pgrep -x` مطابقت دارد (`mksh` اندروید `exec -a` ندارد). با `setsid` راه‌اندازی می‌شود تا
از گروه فرایند فراخوان جدا شود: همین است که Action مدیر را از مسدودشدن باز می‌دارد.

## انبار راز (CE در برابر DE، BFU در برابر AFU)

تنظیمات راز نیستند و روی فضای ذخیره‌سازی رمزنگاری‌شده با دستگاه (`/data/adb/vddropbear`) قرار دارند که در
بوت خواندنی است. رازها (host key، `authorized_keys`، هش‌های رمز عبور) به‌طور پیش‌فرض روی فضای
**رمزنگاری‌شده با اعتبارنامه** (`/data/misc_ce/0/vddropbear`) قرار دارند که فقط پس از احراز هویت کاربر باز
می‌شود. روشن‌کردن `START_IN_BFU` رازها را به فضای ذخیره‌سازی رمزنگاری‌شده با دستگاه منتقل می‌کند تا دیمون
بتواند پیش از نخستین بازگشایی اجرا شود، به بهای اینکه آن رازها زودتر خواندنی می‌شوند. ماژول در هر مرحله از
بوت محاسبه می‌کند که از کدام انبار استفاده کند.

## مجموعهٔ وصله‌ها

سرور SSH همان Dropbear upstream می‌ماند؛ تغییرات ما تنها چند وصلهٔ قابل‌بازبینی است (نگاه کنید به
[patches/README.md](../../patches/README.md)):

- یک بنر هویت خنثی و قابل‌پیکربندی در زمان اجرا؛
- `authorized_keys` که از مسیری تعیین‌شده با محیط خوانده می‌شود (تا کلیدها در انبار راز قرار گیرند)؛
- احراز هویت با رمز عبور در برابر یک فایل هش PBKDF2 به‌جای `crypt()`/shadow سیستم که اندروید فاقد آن است
  (نگاه کنید به [BUILDING.md](../BUILDING.md)).

## WebUI

یک صفحهٔ ایستا در WebUI مدیر (KernelSU / APatch / WebUI-X). این صفحه `module/common/vddb-webui.sh` را از
طریق پل `ksu.exec` هدایت می‌کند: وضعیت، start/stop/restart، خواندن/نوشتن پیکربندی و مدیریت کلیدها و
حساب‌های رمز عبور. همهٔ داده‌ها به‌صورت کدگذاری‌شده با base64 از پل عبور می‌کنند، بنابراین شل هرگز آن‌ها را
تفسیر نمی‌کند؛ هش‌های رمز عبور در مرورگر با WebCrypto محاسبه می‌شوند، پس رمز عبور به‌صورت متن روشن هرگز صفحه
را ترک نمی‌کند.
