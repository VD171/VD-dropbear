<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · हिन्दी · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# VD Dropbear में योगदान

आपकी रुचि के लिए धन्यवाद। यह एक छोटी, सुरक्षा-संवेदनशील परियोजना है (यह root प्रदान करती है), इसलिए
बदलावों की समीक्षा उसी दृष्टि से की जाती है।

## रिपॉज़िटरी का ढाँचा

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## बिल्डिंग

बाइनरी को CI द्वारा **अपस्ट्रीम [mkj/dropbear](https://github.com/mkj/dropbear)** और `patches/` के
पैच से बनाया जाता है। स्थानीय रूप से बिल्ड करने के लिए आपको Android NDK चाहिए:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

पैच सेट जानबूझकर न्यूनतम और ऑडिट-योग्य है: एक तटस्थ/कॉन्फ़िगर करने योग्य पहचान स्ट्रिंग,
`authorized_keys` और पासवर्ड फ़ाइल के लिए कॉन्फ़िग-संचालित पथ, Android का `openpty` फ़िक्स, और रनटाइम
कॉन्फ़िगरेशन। कृपया नए पैच छोटे, प्रलेखित, और PR में उचित-ठहराए हुए रखें।

## Pull requests

- प्रति PR एक तार्किक बदलाव; प्रेरणा और सुरक्षा प्रभाव का वर्णन करें।
- मौजूदा शेल शैली से मेल खाएँ (POSIX `sh` / Android `mksh`; कोई bashism नहीं)।
- हर फ़ाइल में एक छोटा SPDX हेडर होता है। उसे बनाए रखें।
- किसी भी असली, उपयोगकर्ता-दृश्य बदलाव के लिए [`CHANGELOG.md`](../../CHANGELOG.md) को `[Unreleased]` के अंतर्गत अद्यतन करें।
- PR जमा करके आप अपने योगदान को परियोजना के [Apache-2.0](../../LICENSE) लाइसेंस के तहत लाइसेंस देने पर सहमत होते हैं।

## अनुवाद

README और docs कई भाषाओं में बनाए रखे जाते हैं (`README.<lang>.md`)। अंग्रेज़ी सत्य का स्रोत है;
अनुवाद उसका अनुसरण करते हैं। यदि आप किसी अनुवाद को बेहतर बनाते हैं या कोई भाषा जोड़ते हैं, तो ढाँचे और
अनुभाग एंकर को अंग्रेज़ी संस्करण के समान रखें।

## बग और सुरक्षा समस्याओं की सूचना देना

बग और फ़ीचर अनुरोधों के लिए issue टेम्पलेट का उपयोग करें। ऐसी किसी भी चीज़ के लिए जो किसी डिवाइस को खतरे
में डाल सकती है, [`SECURITY.md`](SECURITY.md) का पालन करें और सार्वजनिक issue खोलने के बजाय निजी तौर पर
सूचना दें।
