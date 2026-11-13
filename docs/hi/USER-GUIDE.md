<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · हिन्दी · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# उपयोगकर्ता मार्गदर्शिका

VD Dropbear आपके रूट किए गए डिवाइस को एक निजी SSH सर्वर देता है। यह मार्गदर्शिका आपको इंस्टॉल से लेकर
एक काम करते कनेक्शन तक ले जाती है, जिसमें फ़ाइल स्थानांतरण और पहले-अनलॉक-से-पहले (BFU) मोड शामिल हैं।

> **हर प्रमाणित कनेक्शन को एक root शेल मिलता है।** पासवर्ड के बजाय कुंजियों को प्राथमिकता दें, केवल उन
> नेटवर्कों पर बाइंड करें जिन पर आप भरोसा करते हैं, और बिना किसी कारण पोर्ट को खुले इंटरनेट पर कभी उजागर न करें।

## 1. इंस्टॉल

मॉड्यूल zip को **KernelSU**, **APatch** या **Magisk** मैनेजर में फ़्लैश करें (या किसी शेल से
`ksud module install` / `apd module install` के साथ), फिर मॉड्यूल का **WebUI** खोलें।

## 2. एक कुंजी जोड़ें (अनुशंसित)

WebUI में, **Authorized keys** के अंतर्गत, अपनी सार्वजनिक कुंजी (`ssh-ed25519 AAAA... you@host`)
चिपकाएँ और **Add key** दबाएँ। कुंजियाँ डिफ़ॉल्ट हैं और अंदर आने का सबसे सुरक्षित तरीका।

अगर आपके पास कोई कुंजी नहीं है, तो उसे अपने कंप्यूटर पर बनाने के लिए:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. या एक पासवर्ड सेट करें

पासवर्ड लॉगिन डिफ़ॉल्ट रूप से बंद है (हर लॉगिन root होता है, इसलिए कुंजियाँ ही बेहतर हैं)। इसे सक्षम करने
के लिए, सेटिंग्स में **Password login** चालू करें, फिर **Password accounts** के अंतर्गत लॉगिन उपयोगकर्ता
के लिए एक पासवर्ड सेट करें। हैश आपके ब्राउज़र में PBKDF2 के साथ गणना किया जाता है; पासवर्ड स्वयं कभी
पृष्ठ से बाहर नहीं जाता।

## 4. एक पोर्ट और कहाँ सुनना है चुनें

**Settings** के अंतर्गत, **Port** सेट करें और बाइंड चुनें। डिफ़ॉल्ट रूप से VD Dropbear केवल **loopback**
पर सुनता है; इसे अपने LAN या किसी VPN से पहुँचने के लिए, जो इंटरफ़ेस आप चाहते हैं उन्हें सक्षम करें। जब
तक आप उस उजागरता को न समझें, **Listen on all interfaces** से बचें।

लागू करने के लिए **Save & restart** दबाएँ, फिर यदि यह पहले से चल नहीं रहा है तो **Start** दबाएँ।

## 5. कनेक्ट करें

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` और `rsync` साथ में बंडल हैं, इसलिए SFTP, `sshfs`, GUI क्लाइंट और बैकअप सभी उसी
कनेक्शन पर काम करते हैं।

## 6. पहले अनलॉक से पहले (BFU)

डिफ़ॉल्ट रूप से डेमॉन केवल तभी शुरू होता है जब आप डिवाइस को एक बार अनलॉक **कर लेते हैं** (AFU), क्योंकि
इसके सीक्रेट क्रेडेंशियल-एन्क्रिप्टेड स्टोरेज पर रहते हैं। यदि आपको पहले अनलॉक से **पहले** SSH चाहिए (
उदाहरण के लिए किसी रीबूट के बाद किसी डिवाइस को दूरस्थ रूप से अनलॉक करने के लिए), तो **Start before first
unlock (BFU)** चालू करें। तब सीक्रेट डिवाइस-एन्क्रिप्टेड स्टोरेज में चले जाते हैं, जो अनलॉक से पहले
पठनीय है: एक जानबूझकर किया गया, प्रलेखित समझौता। README में [Security model](#) देखें।

## 7. डेमॉन को नियंत्रित करना

- **WebUI:** Start / Stop / Restart, और लाइव स्थिति (चल रहा है, PID, पोर्ट, मोड, होस्ट-कुंजी फ़िंगरप्रिंट)।
- **Manager Action बटन:** डेमॉन को (फिर से) चालू करता है।
- यह बूट पर स्वतः भी शुरू होता है (जब तक आप इसे निष्क्रिय न करें)।

## समस्या निवारण

- **यह शुरू नहीं होगा।** `/data/adb/vddropbear/state/daemon.log` जाँचें। सुनिश्चित करें कि **Enabled**
  चालू है और एक होस्ट कुंजी उत्पन्न हो सकी।
- **कुंजी अस्वीकृत।** पुष्टि करें कि सार्वजनिक कुंजी की पंक्ति ठीक वैसी ही है जैसी आपका क्लाइंट प्रस्तुत
  करता है, और कि लॉगिन उपयोगकर्ता ऐसा है जिसे सिस्टम पहचान सके (आमतौर पर `root`)।
- **किसी दूसरी मशीन से कनेक्ट नहीं हो पा रहा।** आप शायद अब भी केवल loopback पर बाइंड हैं: जो इंटरफ़ेस
  आपको चाहिए उसे सक्षम करें और पुनः आरंभ करें।
- **SFTP/scp विफल होता है पर शेल काम करता है।** सुनिश्चित करें कि बंडल किया गया `sftp-server` आपके ABI
  के लिए भेजा गया था; WebUI स्थिति पहचाने गए ABI को दिखाती है।
