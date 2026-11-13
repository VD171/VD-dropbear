<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.

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

<p align="center">
  <img src="module/webroot/assets/logo-wordmark.svg" alt="VD Dropbear" width="540">
</p>

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-1a7f37" alt="License"></a>
  <img src="https://img.shields.io/badge/KernelSU-%E2%9C%94-635bff" alt="KernelSU">
  <img src="https://img.shields.io/badge/APatch-%E2%9C%94-ff7043" alt="APatch">
  <img src="https://img.shields.io/badge/Magisk-%E2%9C%94-00af9c" alt="Magisk">
  <a href="https://github.com/VD171/VD-dropbear/stargazers"><img src="https://img.shields.io/github/stars/VD171/VD-dropbear?color=d29922" alt="Stars"></a>
  <a href="https://github.com/VD171/VD-dropbear/releases"><img src="https://img.shields.io/github/v/release/VD171/VD-dropbear?color=1a7f37" alt="Release"></a>
</p>

**Samostatný, plně konfigurovatelný SSH server [Dropbear](https://matt.ucc.asn.au/dropbear/)**
zabalený jako modul pro KernelSU / APatch / Magisk. Spouští se sám a nezávisí na žádném jiném modulu.

> ⚠️ **Každé úspěšně ověřené připojení dostane ROOT shell.** Ber to jako klíče od zařízení:
> dávej přednost veřejným klíčům před hesly a nenech port vystavený do veřejného internetu.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Proč

Vestavěný způsob, jak v Androidu získat shell na vlastním telefonu, je ADB (ladění přes USB), a jeho
zapnutí je invazivní a samo tě prozradí. Nastavení `adb_enabled` a `development_settings_enabled`
jsou čitelná pro kohokoli - může je přečíst jakákoli aplikace, SDK nebo protipodvodová / RASP
knihovna, připojení se loguje a neexistuje podporovaný způsob, jak skrýt, že ADB je nebo někdy bylo
zapnuté. Toto odhalení tě pronásleduje i na továrním, neroubnutém telefonu: abys získal shell, musíš
to oznámit.

VD Dropbear je soukromá alternativa. Na rootnutém zařízení ti dá skutečný SSH server - root shell,
SFTP a rsync přes síť - bez prozrazujícího `adb_enabled`, bez příznaku ladění přes USB, s verzovým
bannerem, který nic neprozradí, a s přihlašovacími údaji, které máš pod kontrolou. Tvůj přístup
zůstává tvůj, místo globálně čitelného příznaku „jsem laděn", který může přečíst cokoli na zařízení.

## Funkce

- **Jeden démon, vždy.** Spouští se při startu a tlačítkem **Action** ve správci a kdykoli jej můžeš
  **spustit / zastavit / restartovat** z WebUI; nikdy neběží víc než jedna instance.
- **Vše je konfigurovatelné** z WebUI (nebo `/data/adb/vddropbear/config`):
  - port a vazba na loopback / vše / IPv4 / IPv6 / konkrétní adresy
  - **start před prvním odemčením (BFU), nebo až po něm (AFU)** - jediný přepínač
  - ověřování veřejným klíčem a/nebo heslem, maximální počet pokusů o ověření
  - přihlašovací uživatel, shell, `HOME`, další proměnné prostředí
  - časový limit nečinnosti, keepalive, přijímací okno
  - lokální / vzdálené přesměrování portů a gateway porty (vše ve výchozím stavu **vypnuto**)
  - typ hostitelského klíče (ed25519 / rsa / ecdsa)
- **Skrytý verzový banner.** Protokol SSH vyžaduje *nějaký* banner, takže jej nelze odstranit, ale VD
  Dropbear jej nahradí ničím neříkajícím, aby skenery nemohly přesně identifikovat server či verzi a
  zacílit na něj útoky na známou verzi.
- **Tajné údaje uložené rozumně** (viz [Bezpečnostní model](#security-model)).
- **Přines si vlastní přihlašovací údaje.** Přidej sady `user + key` a `user + password`; WebUI
  vynucuje minimální sílu hesla a nikdy neukládá heslo v otevřené podobě.
- **Přenos souborů a synchronizace vestavěné.** Balíček obsahuje `sftp-server`, `scp` a `rsync`,
  takže SFTP, sshfs, grafičtí klienti i zálohy fungují přes totéž připojení.
- **Každé zařízení i emulátor.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## AI agenti na tvém zařízení

Stálý SSH endpoint promění tvůj telefon v něco, co může **autonomní AI agent řídit přímo**. Jakýkoli
agent schopný ovládat shell nebo SSH připojení - Claude Code, aider, skript se smyčkou LLM, tvoje
vlastní automatizace - získá skutečnou root relaci na zařízení, přes síť, bez USB kabelu a bez
jakýchkoli prozrazujících ladicích příznaků ADB. Agent vidí běžný shell podobný Linuxu a může:

- číst a upravovat soubory, přepínat nastavení a spravovat moduly, balíčky a služby;
- třídit logy, stahovat artefakty a na vyžádání spouštět diagnostiku či forenzní analýzu;
- přesouvat a synchronizovat soubory oběma směry přes `scp` / `sftp` / `rsync`, pro zálohy, migrace nebo nasazení;
- řídit celou flotilu rootnutých zařízení z jednoho místa, každé dostupné svým vlastním klíčem.

Protože je projekt postavený tak, aby byl **přátelský k AI** - zdokumentovaný konfigurační soubor,
explicitní [kontrakt prostředí](patches/README.md) za běhu, předvídatelné cesty a stav v otevřeném
textu - agent dokáže zjistit, jak jej používat, bez dohadů.

> **Tohle je root, tak s tím zacházej jako s rootem.** Každé ověřené připojení přistane jako root
> (viz varování níže). Když předáváš přístup agentovi, dej mu **vyhrazeného uživatele a klíč**, omez
> vazby na sítě, kterým důvěřuješ (loopback nebo VPN místo otevřeného internetu), nech ověřování
> heslem vypnuté a pamatuj, že klíč můžeš kdykoli zneplatnit nebo démona zastavit z WebUI.

## Instalace

Nahraj zip modulu ve správci KernelSU, APatch nebo Magisk (nebo z příkazové řádky pomocí
`ksud module install` / `apd module install`), otevři **WebUI** modulu, nastav port a přidej své
klíče, pak restartuj (nebo stiskni **Action** a spusť jej hned).

## Bezpečnostní model

### Kde žijí tajné údaje: BFU vs AFU

`/data/adb` je úložiště **šifrované na úrovni zařízení (DE)**: dešifruje se *dříve*, než uživatel
telefon odemkne (Before First Unlock), takže cokoli tam je čitelné před odemčením. `/data/misc_ce`
je **šifrované přihlašovacím údajem (CE)**: Android jej drží zašifrovaný, dokud uživatel neodemkne
(After First Unlock).

- **Režim AFU (výchozí, `START_IN_BFU=0`):** démon počká na odemčení a svůj hostitelský klíč,
  `authorized_keys` a hashe hesel načte z úložiště CE. Maximální ochrana; SSH funguje až poté, co bylo
  zařízení od startu alespoň jednou odemčeno.
- **Režim BFU (`START_IN_BFU=1`):** démon se spustí před odemčením, aby ses mohl připojit přes SSH
  brzy (například abys zařízení odemkl na dálku). Jeho tajné údaje pak žijí na úložišti DE a jsou
  čitelné před odemčením, což je záměrný a zdokumentovaný kompromis. Zapni jej jen tehdy, když SSH
  před odemčením potřebuješ.

Záměrně **nepřidáváme** vlastní šifrování nad CE: to už je zašifrované uživatelovým přihlašovacím
údajem a přidání další šifry by vyžadovalo klíč, který musí někde žít (na DE by byl odhalený;
odvozování z uživatelského přihlašovacího údaje jen znovu implementuje CE). To by přineslo falešný
pocit bezpečí, ne skutečnou ochranu.

### Hesla

Přihlášení heslem je **ve výchozím stavu vypnuté**, protože každé přihlášení je root a klíče jsou
mnohem bezpečnější. Když už heslo nastavíš, WebUI vynutí minimální sílu a uloží jen hash, nikdy
otevřený text.

## Sestavení

Binárku serveru sestavuje CI z **upstreamu [mkj/dropbear](https://github.com/mkj/dropbear)** s malou,
auditovatelnou sadou patchů (viz [`patches/`](patches/)): neutrální/konfigurovatelný identifikační
řetězec, cesty řízené konfigurací pro `authorized_keys` a soubor s hesly a androidí oprava `openpty`
pro interaktivní PTY. Naplánovaný workflow sleduje upstream a sestavuje znovu, takže modul zůstává
aktuální. Viz [`.github/workflows/`](.github/workflows/) a [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Dokumentace

<!-- vd-docs -->
Úplná dokumentace je na [wiki](https://github.com/VD171/VD-dropbear/wiki) a ve složce
[`docs/`](docs/).
<!-- /vd-docs -->

## Viz také

Příbuzné projekty téhož autora:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: debugger metod zařízení, který čte každou položku přes každou metodu, jež ji umí přečíst, a porovnává je vedle sebe.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: tvoje služby Google (RCS, Wallet, atestace Play Integrity), čtené na tvém zařízení bez internetu.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: kompletní záloha a obnova aplikací a dat jako root, řízená zcela z WebUI.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: globální spoofer otisku zařízení a buildu.

## Kontakty

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** _(zástupný text - doplní se při prvním veřejném vydání)_
* **GitHub:** @VD171 https://github.com/VD171

## Licence

Vlastní kód VD Dropbear je pod **Apache-2.0** - viz [LICENSE](LICENSE). Modul rovněž přibaluje binárky
třetích stran - [Dropbear](https://matt.ucc.asn.au/dropbear/) (styl MIT), `sftp-server` a `scp` z
OpenSSH (BSD) a `rsync` (GPL-3.0) - každou pod vlastní licencí; viz
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), včetně toho, jak u rsync dodržujeme GPL. Náš kód pod
Apache-2.0 tím není dotčen (binárka pod GPL je jen agregovaná, nikoli linkovaná).

## Ochranné známky

VD Dropbear je nezávislý, neoficiální projekt, nijak nespojený s žádnou třetí stranou ani jí
podporovaný. „Android" je ochranná známka společnosti Google LLC; „SSH" je registrovaná ochranná
známka společnosti SSH Communications Security. VD Dropbear běží zcela na tvém zařízení.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
