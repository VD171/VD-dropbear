<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · Italiano · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Contribuire a VD Dropbear

Grazie per il tuo interesse. Questo è un piccolo progetto sensibile alla sicurezza (distribuisce
root), quindi le modifiche vengono esaminate tenendo conto di questo.

## Struttura del repository

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Build

Il binario è prodotto dalla CI a partire da **upstream [mkj/dropbear](https://github.com/mkj/dropbear)**
più le patch in `patches/`. Per compilare in locale ti serve l'Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

L'insieme di patch è volutamente minimo e verificabile: una stringa d'identità neutra/configurabile,
percorsi guidati dalla configurazione per `authorized_keys` e per il file delle password, il fix
`openpty` di Android e la configurazione a runtime. Mantieni le nuove patch piccole, documentate e
giustificate nella PR.

## Pull request

- Una modifica logica per PR; descrivi la motivazione e l'impatto sulla sicurezza.
- Rispetta lo stile shell esistente (POSIX `sh` / `mksh` di Android; niente bashism).
- Ogni file reca un breve header SPDX - mantienilo.
- Aggiorna [`CHANGELOG.md`](../../CHANGELOG.md) sotto `[Unreleased]` per ogni modifica reale e visibile all'utente.
- Inviando una PR accetti di licenziare il tuo contributo sotto la licenza [Apache-2.0](../../LICENSE) del progetto.

## Traduzioni

Il README e la documentazione sono mantenuti in molte lingue (`README.<lang>.md`). L'inglese è la fonte
di verità; le traduzioni lo seguono. Se migliori una traduzione o aggiungi una lingua, mantieni la
struttura e gli anchor delle sezioni identici alla versione inglese.

## Segnalare bug e problemi di sicurezza

Usa i template delle issue per bug e richieste di funzionalità. Per qualsiasi cosa possa compromettere
un dispositivo, segui [`SECURITY.md`](SECURITY.md) e segnala in privato anziché aprire una issue
pubblica.
