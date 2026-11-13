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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · فارسی · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# راهنمای کاربر

VD Dropbear به دستگاه روت‌شدهٔ شما یک سرور SSH خصوصی می‌دهد. این راهنما شما را از نصب تا یک اتصال کارآمد
می‌برد، از جمله انتقال فایل و حالت پیش از نخستین بازگشایی (BFU).

> **هر اتصال احرازهویت‌شده یک شل root می‌گیرد.** کلیدها را به رمزهای عبور ترجیح دهید، تنها به شبکه‌هایی که
> به آن‌ها اعتماد دارید باند کنید، و هرگز بدون دلیل پورت را در معرض اینترنت باز قرار ندهید.

## ۱. نصب

زیپ ماژول را در مدیر **KernelSU**، **APatch** یا **Magisk** فلش کنید (یا از یک شل با
`ksud module install` / `apd module install`)، سپس **WebUI** ماژول را باز کنید.

## ۲. افزودن یک کلید (توصیه‌شده)

در WebUI، زیر **Authorized keys**، کلید عمومی خود (`ssh-ed25519 AAAA... you@host`) را بچسبانید و
**Add key** را بزنید. کلیدها پیش‌فرض‌اند و امن‌ترین راه ورود.

برای ساختن یک کلید روی رایانهٔ خود، اگر ندارید:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## ۳. یا تنظیم یک رمز عبور

ورود با رمز عبور به‌طور پیش‌فرض خاموش است (هر ورود root است، پس کلیدها ترجیح داده می‌شوند). برای فعال‌کردن
آن، **Password login** را در تنظیمات روشن کنید، سپس زیر **Password accounts** برای کاربر ورود یک رمز عبور
تنظیم کنید. هش در مرورگر شما با PBKDF2 محاسبه می‌شود؛ خودِ رمز عبور هرگز صفحه را ترک نمی‌کند.

## ۴. انتخاب یک پورت و جایی برای گوش‌دادن

زیر **Settings**، **Port** را تنظیم کنید و باندها را انتخاب کنید. به‌طور پیش‌فرض VD Dropbear فقط روی
**loopback** گوش می‌دهد؛ برای رسیدن به آن از LAN یا یک VPN، رابط‌هایی را که می‌خواهید فعال کنید. از
**Listen on all interfaces** بپرهیزید مگر اینکه میزان در معرض دید قرار گرفتن را درک کنید.

برای اعمال، **Save & restart** را بزنید، سپس اگر از پیش در حال اجرا نیست **Start** را بزنید.

## ۵. اتصال

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`، `scp` و `rsync` به‌همراه عرضه می‌شوند، پس SFTP، `sshfs`، کلاینت‌های گرافیکی و پشتیبان‌گیری‌ها
همه روی همان اتصال کار می‌کنند.

## ۶. پیش از نخستین بازگشایی (BFU)

به‌طور پیش‌فرض دیمون فقط **پس از** اینکه دستگاه را یک بار باز کنید (AFU) راه‌اندازی می‌شود، چون رازهایش روی
فضای رمزنگاری‌شده با اعتبارنامه قرار دارند. اگر به SSH **پیش از** نخستین بازگشایی نیاز دارید - برای مثال
برای بازگشایی یک دستگاه از راه دور پس از یک ری‌استارت - **Start before first unlock (BFU)** را روشن کنید.
رازها آنگاه به فضای رمزنگاری‌شده با دستگاه منتقل می‌شوند که پیش از بازگشایی خواندنی است: یک مصالحهٔ عمدی و
مستند. به [مدل امنیتی](#) در README نگاه کنید.

## ۷. کنترل دیمون

- **WebUI:** Start / Stop / Restart، و وضعیت زنده (در حال اجرا، PID، پورت، حالت، اثر انگشت host key).
- **دکمهٔ Action مدیر:** دیمون را (دوباره) راه‌اندازی می‌کند.
- همچنین به‌طور خودکار در بوت راه‌اندازی می‌شود (مگر اینکه آن را غیرفعال کنید).

## عیب‌یابی

- **راه‌اندازی نمی‌شود.** `/data/adb/vddropbear/state/daemon.log` را بررسی کنید. مطمئن شوید **Enabled**
  روشن است و یک host key توانسته تولید شود.
- **کلید رد شد.** تأیید کنید که خط کلید عمومی دقیقاً همان است که کلاینت شما ارائه می‌دهد، و اینکه کاربر
  ورود حسابی است که سیستم آن را resolve می‌کند (معمولاً `root`).
- **نمی‌توانم از ماشینی دیگر متصل شوم.** احتمالاً هنوز فقط به loopback باند هستید - رابطی را که نیاز دارید
  فعال کنید و ری‌استارت کنید.
- **SFTP/scp شکست می‌خورد اما شل کار می‌کند.** مطمئن شوید `sftp-server` همراه، برای ABI شما عرضه شده است؛
  وضعیت WebUI، ABI شناسایی‌شده را نشان می‌دهد.
