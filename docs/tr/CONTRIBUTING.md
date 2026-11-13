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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · Türkçe · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# VD Dropbear'a Katkıda Bulunma

İlginiz için teşekkürler. Bu, küçük ve güvenlik açısından hassas bir projedir (root dağıtır), bu yüzden
değişiklikler bu göz önünde bulundurularak incelenir.

## Depo düzeni

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Derleme

İkili dosya CI tarafından **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** ve `patches/`
içindeki yamalardan üretilir. Yerelde derlemek için Android NDK'ya ihtiyacınız var:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Yama kümesi bilinçli olarak asgari ve denetlenebilirdir: nötr/yapılandırılabilir bir kimlik dizesi,
`authorized_keys` ve parola dosyası için yapılandırmayla sürülen yollar, Android `openpty` düzeltmesi ve
çalışma zamanı yapılandırması. Lütfen yeni yamaları küçük, belgelenmiş ve PR'de gerekçelendirilmiş
tutun.

## Pull request'ler

- PR başına bir mantıksal değişiklik; motivasyonu ve güvenlik etkisini açıklayın.
- Mevcut kabuk stiline uyun (POSIX `sh` / Android `mksh`; bashism yok).
- Her dosya kısa bir SPDX başlığı taşır. Onu koruyun.
- Gerçek, kullanıcıya görünür her değişiklik için [`CHANGELOG.md`](../../CHANGELOG.md)'yi `[Unreleased]` altında güncelleyin.
- Bir PR göndererek, katkınızı projenin [Apache-2.0](../../LICENSE) lisansı altında lisanslamayı kabul edersiniz.

## Çeviriler

README ve belgeler birçok dilde tutulur (`README.<lang>.md`). İngilizce gerçeğin kaynağıdır; çeviriler
onu izler. Bir çeviriyi geliştirir veya bir dil eklerseniz, yapıyı ve bölüm bağlantı noktalarını
İngilizce sürümle aynı tutun.

## Hataları ve güvenlik sorunlarını bildirme

Hatalar ve özellik istekleri için sorun şablonlarını kullanın. Bir cihazı tehlikeye atabilecek her şey
için, [`SECURITY.md`](SECURITY.md)'yi izleyin ve kamuya açık bir sorun açmak yerine özel olarak
bildirin.
