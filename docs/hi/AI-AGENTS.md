<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · हिन्दी · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# आपके डिवाइस पर AI एजेंट

एक हमेशा चालू रहने वाला SSH एंडपॉइंट आपके फ़ोन को ऐसी चीज़ में बदल देता है जिसे **एक स्वायत्त AI एजेंट
सीधे चला सकता है**। कोई भी एजेंट जो शेल या SSH कनेक्शन चला सकता है (Claude Code, aider, कोई
LLM-इन-द-लूप स्क्रिप्ट, आपका अपना ऑटोमेशन) उसे नेटवर्क के ज़रिए डिवाइस पर एक असली root सत्र मिल जाता है,
बिना किसी USB केबल के और ADB के उन डिबग फ़्लैग के बिना जो खुद को उजागर कर देते हैं।

यह पृष्ठ README में प्रस्तुत विचार को विस्तार से समझाता है।

## एजेंट के लिए ADB नहीं, SSH क्यों

ADB खुद का ऐलान करता है: `adb_enabled` और `development_settings_enabled` सभी के लिए पठनीय होते हैं,
कनेक्शन लॉग होता है, और यह छिपाने का कोई समर्थित तरीका नहीं है कि डिबगिंग चालू है (या थी)। ADB के ज़रिए
काम करने वाला एजेंट डिवाइस पर वह निशान छोड़ जाता है जिसे कोई भी ऐप या एंटी-फ्रॉड SDK पढ़ सकता है। VD
Dropbear निजी विकल्प है: एक सामान्य SSH लॉगिन, जिसके क्रेडेंशियल आपके नियंत्रण में हैं और जिसका बैनर कुछ
भी उजागर नहीं करता।

## एक एजेंट क्या कर सकता है

एक ही कनेक्शन पर, एजेंट को एक सामान्य Linux जैसा शेल दिखता है और वह यह कर सकता है:

- फ़ाइलें पढ़ना और संपादित करना, सेटिंग्स बदलना, और मॉड्यूल, पैकेज तथा सेवाओं का प्रबंधन करना;
- लॉग की छानबीन करना, आर्टिफ़ैक्ट निकालना, और माँग पर डायग्नोस्टिक्स या फ़ोरेंसिक चलाना;
- `scp` / `sftp` / `rsync` के ज़रिए फ़ाइलें दोनों दिशाओं में ले जाना और सिंक करना: बैकअप, माइग्रेशन, प्रोविज़निंग;
- एक ही जगह से रूट किए गए डिवाइसों के पूरे बेड़े को चलाना, जहाँ हर एक अपनी कुंजी से पहुँच योग्य है।

क्योंकि यह परियोजना **AI-अनुकूल** बनाई गई है (एक प्रलेखित कॉन्फ़िगरेशन फ़ाइल, एक स्पष्ट रनटाइम
[env contract](../../patches/README.md), पूर्वानुमेय पथ और सादे-पाठ में स्थिति), इसलिए एक एजेंट बिना
अनुमान लगाए पता लगा सकता है कि इसका उपयोग कैसे करना है।

## इसे सुरक्षित रूप से करना

यह root है, इसलिए इसे root की तरह ही बरतें:

- एजेंट को एक **समर्पित उपयोगकर्ता और कुंजी** दें, अपनी व्यक्तिगत नहीं;
- बाइंड को केवल उन नेटवर्कों तक सीमित रखें जिन पर आप भरोसा करते हैं: खुले इंटरनेट के बजाय loopback या कोई VPN
  (देखें [Configuration](CONFIGURATION.md));
- पासवर्ड प्रमाणीकरण बंद रखें; एक कुंजी को रद्द किया जा सकता है और उसे कभी टाइप नहीं किया जाता;
- आप WebUI से किसी भी समय कुंजी रद्द कर सकते हैं या डेमॉन रोक सकते हैं;
- याद रखें हर कनेक्शन एक पूर्ण root सत्र है: एजेंट को केवल उतनी ही पहुँच दें जितनी उसे ज़रूरत है।

## एक न्यूनतम सेटअप

1. सिर्फ़ एजेंट के लिए एक कुंजी युग्म बनाएँ।
2. WebUI में उसकी सार्वजनिक कुंजी जोड़ें (**Authorized keys**)।
3. केवल loopback या अपने VPN पर, किसी ग़ैर-डिफ़ॉल्ट पोर्ट पर बाइंड करें।
4. एजेंट के SSH कॉन्फ़िग को डिवाइस की ओर इंगित करें और उसे काम करने दें।
