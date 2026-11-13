<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · فارسی · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# پیکربندی

تنظیمات در `/data/adb/vddropbear/config` قرار دارند (در نخستین بوت از `module/common/config.default`
مقداردهی اولیه می‌شوند). **WebUI** این فایل را برای شما ویرایش می‌کند؛ می‌توانید آن را دستی هم ویرایش کنید.
این فایل به‌صورت شل source می‌شود، پس از `KEY=value` بدون فاصله در اطراف `=` استفاده کنید. تنظیمات راز
نیستند و روی فضای ذخیره‌سازی رمزنگاری‌شده با دستگاه قرار دارند؛ رازها (host keyها، کلیدهای مجاز، هش‌های رمز
عبور) در انبار راز قرار دارند، هرگز اینجا.

تغییرات را با راه‌اندازی دوبارهٔ دیمون اعمال کنید (**Save & restart** در WebUI همین کار را می‌کند).

## عمومی

| Key | Default | معنی |
|-----|---------|---------|
| `ENABLED` | `1` | دیمون را در بوت راه‌اندازی می‌کند. `0` آن را به‌کلی غیرفعال می‌کند. |
| `START_IN_BFU` | `0` | `0`: فقط پس از نخستین بازگشایی (AFU) راه‌اندازی می‌شود؛ رازها روی فضای رمزنگاری‌شده با اعتبارنامه (CE) می‌مانند. `1`: پیش از نخستین بازگشایی هم (BFU) راه‌اندازی می‌شود؛ رازها به فضای رمزنگاری‌شده با دستگاه (DE) منتقل می‌شوند که پیش از بازگشایی خواندنی است. |
| `PORT` | `2222` | پورت پیش‌فرض گوش‌دادن (پورت‌های هر باند می‌توانند آن را در `LISTEN_ADDRESSES` بازنویسی کنند). |

## گوش‌دادن / باندها (قابل‌ترکیب)

هر ترکیبی مجاز است؛ باندهای انتخاب‌شده ادغام می‌شوند. اگر همه را پاک کنید، VD Dropbear به‌جای هر رابط، به
loopback باند می‌شود.

| Key | Default | معنی |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | فقط روی `127.0.0.1` / `::1` گوش می‌دهد. |
| `LISTEN_ALL` | `0` | روی هر رابط (`0.0.0.0` / `::`) گوش می‌دهد - دستگاه را در معرض دید قرار می‌دهد. |
| `LISTEN_IPV4` | `1` | باندهای IPv4 را شامل می‌شود. |
| `LISTEN_IPV6` | `1` | باندهای IPv6 را شامل می‌شود. |
| `LISTEN_ADDRESSES` | `""` | باندهای خاص اضافی، جداشده با کاما: `addr` (از `PORT` استفاده می‌کند) یا `addr:port`، IPv4 یا IPv6. |

## هویت

| Key | Default | معنی |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | یک بنر هویت SSH خنثی می‌فرستد تا اسکنرها نتوانند سرور/نسخهٔ دقیق را شناسایی کنند. |
| `IDENT_STRING` | `""` | یک رشتهٔ هویت سفارشی. خالی، از مقدار خنثی پیش‌فرض داخلی استفاده می‌کند. |

## احراز هویت

هر ورود احرازهویت‌شده **root** است. کلیدها پیش‌فرض‌اند؛ رمزهای عبور اختیاری‌اند.

| Key | Default | معنی |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | ورود با کلید عمومی را مجاز می‌کند (کلیدهای مجاز را از انبار راز می‌خواند). |
| `PASSWORD_AUTH` | `0` | ورود با رمز عبور را مجاز می‌کند. وقتی خاموش باشد، دیمون با احراز هویت رمز عبورِ غیرفعال راه‌اندازی می‌شود. |
| `MAX_AUTH_TRIES` | `3` | بیشینهٔ تلاش‌های احراز هویت در هر اتصال. |

## نشست / محیط

| Key | Default | معنی |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | شل نشست. خالی، از پیش‌فرض حساب استفاده می‌کند. |
| `HOME_DIR` | `""` | `HOME` نشست. خالی، از دایرکتوری ماژول استفاده می‌کند. |
| `EXTRA_ENV` | `""` | محیط اضافی، `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | پس از N ثانیه بی‌کاری قطع می‌کند. `0` غیرفعال می‌کند. |
| `KEEPALIVE` | `0` | هر N ثانیه یک keepalive می‌فرستد. `0` غیرفعال می‌کند. |
| `RECEIVE_WINDOW` | `""` | اندازهٔ پنجرهٔ دریافت Dropbear. خالی، از مقدار پیش‌فرض استفاده می‌کند. |

## هدایت (به‌طور پیش‌فرض خاموش)

| Key | Default | معنی |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | هدایت پورت محلی (`-L`) را مجاز می‌کند. |
| `ALLOW_REMOTE_FORWARD` | `0` | هدایت پورت از راه دور (`-R`) را مجاز می‌کند. |
| `GATEWAY_PORTS` | `0` | اجازه می‌دهد پورت‌های راه دورِ هدایت‌شده به همهٔ رابط‌ها باند شوند. |

## Host key

| Key | Default | معنی |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | نوع host key: `ed25519`، `rsa` یا `ecdsa`. در نخستین راه‌اندازی درون انبار راز تولید می‌شود. |

## انبار راز

اینجا پیکربندی نمی‌شود - از `START_IN_BFU` تعیین می‌شود:

- **AFU (پیش‌فرض):** `/data/misc_ce/0/vddropbear/secret` - رمزنگاری‌شده با اعتبارنامه، فقط پس از اینکه
  دستگاه را باز کنید در دسترس است.
- **BFU:** `/data/adb/vddropbear/secret` - رمزنگاری‌شده با دستگاه، پیش از نخستین بازگشایی خواندنی است.

این انبار host key، `authorized_keys` و فایل هش `passwd` را نگه می‌دارد. برای قالب هش رمز عبور به
[BUILDING.md](../BUILDING.md) نگاه کنید.
