<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · فارسی · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# عامل‌های هوش مصنوعی روی دستگاه شما

یک نقطهٔ پایانی SSH همیشه‌فعال، گوشی شما را به چیزی تبدیل می‌کند که یک **عامل هوش مصنوعی خودمختار می‌تواند
مستقیماً آن را به کار بگیرد**. هر عاملی که بتواند یک شل یا یک اتصال SSH را هدایت کند - Claude Code، aider،
یک اسکریپت با LLM در حلقه، یا خودکارسازی خودتان - یک نشست root واقعی روی دستگاه، از طریق شبکه، بدون کابل USB
و بدون هیچ‌کدام از پرچم‌های اشکال‌زدایی خودافشاگر ADB به دست می‌آورد.

این صفحه ایده‌ای را که در README معرفی شد بسط می‌دهد.

## چرا SSH و نه ADB برای عامل‌ها

ADB خودش را لو می‌دهد: `adb_enabled` و `development_settings_enabled` برای همه خواندنی‌اند، اتصال ثبت
می‌شود، و هیچ راه پشتیبانی‌شده‌ای برای پنهان‌کردن اینکه اشکال‌زدایی روشن است (یا بوده) وجود ندارد. عاملی که
از طریق ADB کار می‌کند، آن ردّ را روی دستگاه برای هر برنامه یا SDK ضدتقلبی که بخواهد بخواند، به‌جا می‌گذارد.
VD Dropbear جایگزین خصوصی است - یک ورود SSH معمولی، با اعتبارنامه‌هایی که شما کنترل می‌کنید و بنری که هیچ
چیزی فاش نمی‌کند.

## یک عامل چه کاری می‌تواند بکند

در طول یک اتصال، یک عامل یک شل معمولی شبیه لینوکس می‌بیند و می‌تواند:

- فایل‌ها را بخواند و ویرایش کند، تنظیمات را تغییر دهد و ماژول‌ها، بسته‌ها و سرویس‌ها را مدیریت کند؛
- گزارش‌ها را دسته‌بندی کند، آرتیفکت‌ها را بیرون بکشد و به‌محض نیاز تشخیص یا بررسی قانونی اجرا کند؛
- فایل‌ها را در هر دو جهت با `scp` / `sftp` / `rsync` جابه‌جا و همگام کند - پشتیبان‌گیری، مهاجرت، تدارک‌دهی؛
- یک ناوگان کامل از دستگاه‌های روت‌شده را از یک جا هدایت کند، که هرکدام با کلید خودش دست‌یافتنی است.

چون این پروژه برای **سازگاری با هوش مصنوعی** ساخته شده است - یک فایل پیکربندی مستندشده، یک
[قرارداد محیط](../../patches/README.md) صریح در زمان اجرا، مسیرهای قابل‌پیش‌بینی و وضعیت به‌صورت متن ساده -
یک عامل می‌تواند بدون حدس‌وگمان کشف کند که چگونه از آن استفاده کند.

## انجام ایمن آن

این root است، پس با آن مثل root رفتار کنید:

- به عامل یک **کاربر و کلید اختصاصی** بدهید، نه موارد شخصی خودتان؛
- باندها را به شبکه‌هایی که به آن‌ها اعتماد دارید محدود کنید - loopback یا یک VPN به‌جای اینترنت باز
  (نگاه کنید به [پیکربندی](CONFIGURATION.md))؛
- احراز هویت با رمز عبور را خاموش نگه دارید؛ یک کلید قابل‌ابطال است و هرگز تایپ نمی‌شود؛
- می‌توانید هر زمان که خواستید از WebUI یک کلید را باطل یا دیمون را متوقف کنید؛
- به یاد داشته باشید که هر اتصال یک نشست root کامل است - فقط همان دسترسی‌ای را که عامل نیاز دارد به او بدهید.

## یک راه‌اندازی حداقلی

1. یک جفت کلید فقط برای عامل بسازید.
2. کلید عمومی آن را در WebUI (**Authorized keys**) اضافه کنید.
3. فقط به loopback یا VPN خودتان، روی یک پورت غیرپیش‌فرض، باند کنید.
4. پیکربندی SSH عامل را به دستگاه اشاره دهید و بگذارید کارش را بکند.
