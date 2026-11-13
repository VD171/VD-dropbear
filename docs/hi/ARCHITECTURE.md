<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · हिन्दी · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# आर्किटेक्चर

VD Dropbear एक KernelSU / APatch / Magisk मॉड्यूल है जो ठीक एक Dropbear SSH डेमॉन चलाता है, और यह पूरी
तरह कॉन्फ़िगरेशन से संचालित होता है। SSH सर्वर का कुछ भी किसी एक डिवाइस के लिए हार्ड-कोड नहीं है; जो कुछ
भी विशिष्ट है वह रनटाइम कॉन्फ़िग या कोई सीक्रेट है।

## हिस्से

- `module/common/vddropbear.sh` - मूल लाइब्रेरी: कॉन्फ़िग लोड करना (सुरक्षित बिल्ट-इन डिफ़ॉल्ट के साथ),
  सीक्रेट स्टोर तय करना, एक होस्ट कुंजी सुनिश्चित करना, Dropbear का आर्ग्युमेंट वेक्टर बनाना, और एक अकेले
  डेमॉन इंस्टेंस का प्रबंधन (start / stop / status / restart)।
- `module/service.sh` - बूट प्रवेश। BFU/AFU स्टार्ट नीति का पालन करता है; AFU मोड में यह बूट को अटकाए बिना
  क्रेडेंशियल-एन्क्रिप्टेड स्टोरेज के अनलॉक होने का इंतज़ार करता है।
- `module/action.sh` - मैनेजर का **Action** बटन: डेमॉन को (फिर से) चालू करना। यह कभी stdin नहीं पढ़ता
  और डेमॉन को उसके अपने सत्र में अलग कर देता है, ताकि मैनेजर अटके नहीं।
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - WebUI बैकएंड और पृष्ठ।
- `patches/` - बिल्ड के समय अपस्ट्रीम Dropbear पर लागू किए गए छोटे, ऑडिट-योग्य पैच।
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - बिल्ड।

## डेमॉन जीवनचक्र (एकल इंस्टेंस)

`vddb_start` कॉन्फ़िग लोड करता है, किसी भी चल रहे इंस्टेंस को रोकता है, एक होस्ट कुंजी के मौजूद होने को
सुनिश्चित करता है, फिर एक डेमॉन शुरू करता है। बाइनरी को `vddropbear` के रूप में भेजा जाता है, इसलिए उसका
प्रोसेस नाम `pgrep -x` से बिल्कुल मेल खाता है (Android के `mksh` में `exec -a` नहीं है)। इसे `setsid` के
साथ चलाया जाता है ताकि यह कॉलर के प्रोसेस समूह से अलग हो जाए - यही बात मैनेजर के Action को ब्लॉक होने से
बचाती है।

## सीक्रेट स्टोर (CE बनाम DE, BFU बनाम AFU)

सेटिंग्स सीक्रेट नहीं हैं और डिवाइस-एन्क्रिप्टेड स्टोरेज (`/data/adb/vddropbear`) पर रहती हैं, जो बूट पर
पठनीय है। सीक्रेट - होस्ट कुंजी, `authorized_keys`, पासवर्ड हैश - डिफ़ॉल्ट रूप से **क्रेडेंशियल-एन्क्रिप्टेड**
स्टोरेज (`/data/misc_ce/0/vddropbear`) पर रहते हैं, जो उपयोगकर्ता के प्रमाणित होने के बाद ही अनलॉक होता
है। `START_IN_BFU` चालू करने से सीक्रेट डिवाइस-एन्क्रिप्टेड स्टोरेज में चले जाते हैं ताकि डेमॉन पहले अनलॉक
से पहले चल सके, पर इसकी क़ीमत यह है कि वे सीक्रेट पहले ही पठनीय हो जाते हैं। मॉड्यूल हर बूट चरण पर यह गणना
करता है कि कौन-सा स्टोर उपयोग करना है।

## पैच सेट

SSH सर्वर अपस्ट्रीम Dropbear ही रहता है; हमारे बदलाव कुछ समीक्षा-योग्य पैच हैं (देखें
[patches/README.md](../../patches/README.md)):

- एक तटस्थ, रनटाइम पर कॉन्फ़िगर किया जा सकने वाला पहचान बैनर;
- `authorized_keys` को एक एनवायरनमेंट में सेट किए गए पथ से पढ़ा जाता है (ताकि कुंजियाँ सीक्रेट स्टोर में रहें);
- सिस्टम के `crypt()`/shadow के बजाय एक PBKDF2 हैश फ़ाइल के विरुद्ध पासवर्ड प्रमाणीकरण, क्योंकि Android में
  वह नहीं होता (देखें [BUILDING.md](../BUILDING.md))।

## WebUI

मैनेजर के WebUI (KernelSU / APatch / WebUI-X) में एक स्थैतिक पृष्ठ। यह `ksu.exec` ब्रिज के ज़रिए
`module/common/vddb-webui.sh` को संचालित करता है: स्थिति, start/stop/restart, कॉन्फ़िग पढ़ना/लिखना, और
कुंजियों तथा पासवर्ड खातों का प्रबंधन। सारा डेटा ब्रिज को base64-एन्कोडेड पार करता है, इसलिए शेल कभी उसकी
व्याख्या नहीं करता; पासवर्ड हैश ब्राउज़र में WebCrypto के साथ गणना किए जाते हैं, इसलिए स्पष्ट-पाठ पासवर्ड
कभी पृष्ठ से बाहर नहीं जाता।
