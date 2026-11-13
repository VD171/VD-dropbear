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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · فارسی · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# سیاست امنیتی

## تنها چیزی که باید درک کنید

VD Dropbear یک سرور SSH را راه‌اندازی می‌کند، و **هر اتصالی که با موفقیت احراز هویت شود، یک شل root دریافت
می‌کند**. بنابراین امنیت دستگاه شما برابر است با امنیت پیکربندی و اعتبارنامه‌های این سرور. لطفاً:

- **کلیدهای عمومی را به رمزهای عبور ترجیح دهید.** ورود با رمز عبور به‌طور پیش‌فرض خاموش است.
- اگر ناچار به استفاده از رمز عبور هستید، یک رمز قوی انتخاب کنید - WebUI یک حداقل را الزامی می‌کند و تنها
  یک هش را ذخیره می‌کند.
- **پورت را در معرض اینترنت عمومی قرار ندهید.** به loopback یا یک LAN مورداعتماد باند کنید، یا از طریق یک
  VPN / تونل به آن برسید.
- **مصالحهٔ BFU** را درک کنید: فعال‌کردن شروع پیش از بازگشایی، host key و اعتبارنامه‌ها را روی فضای
  ذخیره‌سازی رمزنگاری‌شده با دستگاه قرار می‌دهد که پیش از بازگشایی دستگاه خواندنی است. آن را خاموش بگذارید
  مگر اینکه به SSH پیش از بازگشایی نیاز داشته باشید.
- هدایت را خاموش نگه دارید مگر اینکه به آن نیاز داشته باشید (به‌طور پیش‌فرض خاموش است).

## کاری که VD Dropbear برای کمک انجام می‌دهد

- یک بنر نسخهٔ خنثی و بی‌اطلاع تا اسکنرهای شبکه نتوانند سرور و نسخهٔ دقیق را شناسایی کنند.
- اعتبارنامه‌ها به‌طور پیش‌فرض روی فضای رمزنگاری‌شده با اعتبارنامه (فقط پس از بازگشایی شما رمزگشایی می‌شود).
- بدون تله‌متری، بدون تماس‌های شبکه‌ای از خودش، بدون تحلیل‌گری. کاملاً روی دستگاه شما اجرا می‌شود.

## نسخه‌های پشتیبانی‌شده

اصلاحات امنیتی روی آخرین نسخه قرار می‌گیرند. باینری سرور از Dropbear upstream پیروی می‌کند؛ نسخه‌های امنیتی
upstream به‌محض اینکه CI آن‌ها را بردارد، دوباره ساخته و عرضه می‌شوند.

## گزارش یک آسیب‌پذیری

لطفاً مسائل امنیتی را خصوصی گزارش دهید، نه در یک مسئلهٔ عمومی:

- **ایمیل:** vd.priv8@pm.me
- **تلگرام:** [@VD_Priv8](https://t.me/VD_Priv8)

نسخه، یک توصیف و (در حالت ایده‌آل) یک روش بازتولید را بگنجانید. یک تأییدیه دریافت خواهید کرد، و ما یک اصلاح
و زمان‌بندی افشا را با شما هماهنگ خواهیم کرد. برای آسیب‌پذیری‌های خودِ Dropbear، لطفاً به upstream نیز در
<https://matt.ucc.asn.au/dropbear/> گزارش دهید.
