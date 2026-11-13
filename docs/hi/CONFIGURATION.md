<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · हिन्दी · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# कॉन्फ़िगरेशन

सेटिंग्स `/data/adb/vddropbear/config` में रहती हैं (पहले बूट पर `module/common/config.default` से
शुरू की जाती हैं)। **WebUI** यह फ़ाइल आपके लिए संपादित करता है; आप इसे हाथ से भी संपादित कर सकते हैं।
इसे शेल के रूप में सोर्स किया जाता है, इसलिए `=` के आसपास बिना स्पेस के `KEY=value` का उपयोग करें।
सेटिंग्स सीक्रेट नहीं हैं और डिवाइस-एन्क्रिप्टेड स्टोरेज पर रहती हैं; सीक्रेट (होस्ट कुंजियाँ, अधिकृत
कुंजियाँ, पासवर्ड हैश) सीक्रेट स्टोर में रहते हैं, यहाँ कभी नहीं।

बदलावों को लागू करने के लिए डेमॉन को पुनः आरंभ करें (WebUI का **Save & restart** यही करता है)।

## सामान्य

| Key | Default | अर्थ |
|-----|---------|---------|
| `ENABLED` | `1` | बूट पर डेमॉन शुरू करें। `0` इसे पूरी तरह निष्क्रिय कर देता है। |
| `START_IN_BFU` | `0` | `0`: केवल पहले अनलॉक के बाद शुरू करें (AFU); सीक्रेट क्रेडेंशियल-एन्क्रिप्टेड (CE) स्टोरेज पर रहते हैं। `1`: पहले अनलॉक से पहले भी शुरू करें (BFU); सीक्रेट डिवाइस-एन्क्रिप्टेड (DE) स्टोरेज में चले जाते हैं, जो अनलॉक से पहले पठनीय है। |
| `PORT` | `2222` | डिफ़ॉल्ट लिसनिंग पोर्ट (`LISTEN_ADDRESSES` में प्रति-बाइंड पोर्ट इसे अधिरोहित कर सकते हैं)। |

## लिसनिंग / बाइंड (संयोजन-योग्य)

कोई भी संयोजन स्वीकार्य है; चुने गए बाइंड मिला दिए जाते हैं। यदि आप सब कुछ हटा देते हैं, तो VD Dropbear
हर इंटरफ़ेस के बजाय loopback पर बाइंड करता है।

| Key | Default | अर्थ |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | केवल `127.0.0.1` / `::1` पर सुनें। |
| `LISTEN_ALL` | `0` | हर इंटरफ़ेस (`0.0.0.0` / `::`) पर सुनें; डिवाइस को उजागर करता है। |
| `LISTEN_IPV4` | `1` | IPv4 बाइंड शामिल करें। |
| `LISTEN_IPV6` | `1` | IPv6 बाइंड शामिल करें। |
| `LISTEN_ADDRESSES` | `""` | अतिरिक्त विशिष्ट बाइंड, अल्पविराम से अलग: `addr` (`PORT` का उपयोग करता है) या `addr:port`, IPv4 या IPv6। |

## पहचान

| Key | Default | अर्थ |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | एक तटस्थ SSH पहचान बैनर भेजें ताकि स्कैनर सटीक सर्वर/संस्करण की फ़िंगरप्रिंट न ले सकें। |
| `IDENT_STRING` | `""` | एक कस्टम पहचान स्ट्रिंग। खाली होने पर तटस्थ बिल्ट-इन डिफ़ॉल्ट का उपयोग होता है। |

## प्रमाणीकरण

हर प्रमाणित लॉगिन **root** होता है। कुंजियाँ डिफ़ॉल्ट हैं; पासवर्ड वैकल्पिक रूप से चालू किए जाते हैं।

| Key | Default | अर्थ |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | सार्वजनिक-कुंजी लॉगिन की अनुमति दें (सीक्रेट स्टोर में अधिकृत कुंजियाँ पढ़ता है)। |
| `PASSWORD_AUTH` | `0` | पासवर्ड लॉगिन की अनुमति दें। बंद होने पर, डेमॉन पासवर्ड प्रमाणीकरण निष्क्रिय करके शुरू किया जाता है। |
| `MAX_AUTH_TRIES` | `3` | प्रति कनेक्शन अधिकतम प्रमाणीकरण प्रयास। |

## सत्र / एनवायरनमेंट

| Key | Default | अर्थ |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | सत्र के लिए शेल। खाली होने पर खाते का डिफ़ॉल्ट उपयोग होता है। |
| `HOME_DIR` | `""` | सत्र के लिए `HOME`। खाली होने पर मॉड्यूल डायरेक्टरी का उपयोग होता है। |
| `EXTRA_ENV` | `""` | अतिरिक्त एनवायरनमेंट, `K=V;K2=V2`। |
| `IDLE_TIMEOUT` | `0` | N निष्क्रिय सेकंड के बाद डिस्कनेक्ट करें। `0` इसे निष्क्रिय करता है। |
| `KEEPALIVE` | `0` | हर N सेकंड पर एक keepalive भेजें। `0` इसे निष्क्रिय करता है। |
| `RECEIVE_WINDOW` | `""` | Dropbear की रिसीव विंडो आकार। खाली होने पर डिफ़ॉल्ट का उपयोग होता है। |

## फ़ॉरवर्डिंग (डिफ़ॉल्ट रूप से बंद)

| Key | Default | अर्थ |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | स्थानीय (`-L`) पोर्ट फ़ॉरवर्डिंग की अनुमति दें। |
| `ALLOW_REMOTE_FORWARD` | `0` | दूरस्थ (`-R`) पोर्ट फ़ॉरवर्डिंग की अनुमति दें। |
| `GATEWAY_PORTS` | `0` | फ़ॉरवर्ड किए गए दूरस्थ पोर्ट को सभी इंटरफ़ेस पर बाइंड होने दें। |

## होस्ट कुंजी

| Key | Default | अर्थ |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | होस्ट-कुंजी का प्रकार: `ed25519`, `rsa` या `ecdsa`। पहले स्टार्ट पर सीक्रेट स्टोर में उत्पन्न की जाती है। |

## सीक्रेट स्टोर

यहाँ कॉन्फ़िगर नहीं किया जाता, `START_IN_BFU` से तय होता है:

- **AFU (डिफ़ॉल्ट):** `/data/misc_ce/0/vddropbear/secret`: क्रेडेंशियल-एन्क्रिप्टेड, केवल तभी उपलब्ध जब
  आप डिवाइस अनलॉक करते हैं।
- **BFU:** `/data/adb/vddropbear/secret`: डिवाइस-एन्क्रिप्टेड, पहले अनलॉक से पहले पठनीय।

इसमें होस्ट कुंजी, `authorized_keys`, और `passwd` हैश फ़ाइल होती है। पासवर्ड हैश प्रारूप के लिए
[BUILDING.md](../BUILDING.md) देखें।
