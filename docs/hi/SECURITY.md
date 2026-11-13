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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · हिन्दी · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# सुरक्षा नीति

## समझने लायक एक बात

VD Dropbear एक SSH सर्वर शुरू करता है, और **हर कनेक्शन जो सफलतापूर्वक प्रमाणित होता है उसे एक root शेल
मिलता है**। इसलिए आपके डिवाइस की सुरक्षा इस सर्वर के कॉन्फ़िगरेशन और क्रेडेंशियल की सुरक्षा के बराबर होती
है। कृपया:

- **पासवर्ड के बजाय सार्वजनिक कुंजियों को प्राथमिकता दें।** पासवर्ड लॉगिन डिफ़ॉल्ट रूप से बंद है।
- यदि आपको पासवर्ड का उपयोग करना ही है, तो मज़बूत पासवर्ड का उपयोग करें - WebUI एक न्यूनतम लागू करता है और केवल एक हैश संग्रहीत करता है।
- **पोर्ट को सार्वजनिक इंटरनेट पर उजागर न करें।** loopback या किसी विश्वसनीय LAN पर बाइंड करें, या इसे
  किसी VPN / टनल के ज़रिए पहुँचें।
- **BFU समझौते** को समझें: स्टार्ट-बिफ़ोर-अनलॉक सक्षम करने से होस्ट कुंजी और क्रेडेंशियल डिवाइस-एन्क्रिप्टेड
  स्टोरेज पर रखे जाते हैं, जो डिवाइस के अनलॉक होने से पहले पठनीय होते हैं। जब तक आपको अनलॉक-से-पहले वाले SSH
  की ज़रूरत न हो, इसे बंद रखें।
- जब तक आपको ज़रूरत न हो, फ़ॉरवर्डिंग बंद रखें (यह डिफ़ॉल्ट रूप से बंद है)।

## VD Dropbear किस तरह मदद करता है

- एक तटस्थ, जानकारी न देने वाला संस्करण बैनर ताकि नेटवर्क स्कैनर सटीक सर्वर और संस्करण की फ़िंगरप्रिंट न
  ले सकें।
- क्रेडेंशियल डिफ़ॉल्ट रूप से क्रेडेंशियल-एन्क्रिप्टेड स्टोरेज पर (केवल आपके अनलॉक करने के बाद डिक्रिप्ट होते हैं)।
- कोई टेलीमेट्री नहीं, अपनी ओर से कोई नेटवर्क कॉल नहीं, कोई एनालिटिक्स नहीं। यह पूरी तरह आपके डिवाइस पर चलता है।

## समर्थित संस्करण

सुरक्षा फ़िक्स नवीनतम रिलीज़ पर आते हैं। सर्वर बाइनरी अपस्ट्रीम Dropbear का अनुसरण करती है; अपस्ट्रीम
सुरक्षा रिलीज़ को जैसे ही CI उठाता है, उन्हें फिर से बिल्ड करके भेज दिया जाता है।

## किसी भेद्यता की सूचना देना

कृपया सुरक्षा समस्याओं की सूचना निजी तौर पर दें, किसी सार्वजनिक issue में नहीं:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

संस्करण, एक विवरण, और (आदर्श रूप से) एक पुनरुत्पादन शामिल करें। आपको एक पावती मिलेगी, और हम आपके साथ
फ़िक्स और प्रकटीकरण की समय-सारिणी समन्वित करेंगे। Dropbear में ही मौजूद भेद्यताओं के लिए, कृपया
<https://matt.ucc.asn.au/dropbear/> पर अपस्ट्रीम भी सूचना दें।
