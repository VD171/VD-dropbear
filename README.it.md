<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.

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

Un **server SSH [Dropbear](https://matt.ucc.asn.au/dropbear/) autonomo e completamente configurabile**,
distribuito come modulo KernelSU / APatch / Magisk. Si avvia da solo e non dipende da nessun altro modulo.

> ⚠️ **Ogni connessione che si autentica ottiene una shell ROOT.** Trattala come le chiavi del
> dispositivo: preferisci le chiavi pubbliche alle password e tieni la porta lontana da Internet pubblica.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Perché

Il modo nativo di Android per ottenere una shell sul proprio telefono è ADB (debug USB), e attivarlo è
invasivo e ti espone. `adb_enabled` e `development_settings_enabled` sono impostazioni leggibili da
chiunque: qualsiasi app, SDK o libreria antifrode / RASP può leggerle, la connessione viene registrata e
non esiste un modo supportato per nascondere che ADB è, o è mai stato, attivo. L'esposizione ti segue
anche su un telefono stock e non rootato: per ottenere una shell devi dichiararlo.

VD Dropbear è l'alternativa privata. Su un dispositivo rootato ti dà un vero server SSH: shell root,
SFTP e rsync sulla rete, senza la traccia `adb_enabled`, senza il flag di debug USB, con un banner di
versione che non rivela nulla e con credenziali che controlli tu. Il tuo accesso resta tuo, invece di un
flag "sto venendo sottoposto a debug" leggibile a livello globale che qualunque cosa sul dispositivo può leggere.

## Funzionalità

- **Un solo daemon, sempre.** Si avvia al boot e dal pulsante **Action** del manager, e puoi
  **avviarlo / fermarlo / riavviarlo** dalla WebUI in qualsiasi momento; mai più di un'istanza.
- **Tutto è configurabile** dalla WebUI (o da `/data/adb/vddropbear/config`):
  - porta, e bind su loopback / all / IPv4 / IPv6 / indirizzi specifici
  - **avvio prima del primo sblocco (BFU) o solo dopo di esso (AFU)**, un singolo interruttore
  - autenticazione a chiave pubblica e/o a password, numero massimo di tentativi di autenticazione
  - utente di login, shell, `HOME`, environment aggiuntivo
  - idle timeout, keepalive, receive window
  - port forwarding locale / remoto e gateway ports (tutti **disattivati** di default)
  - tipo di host-key (ed25519 / rsa / ecdsa)
- **Banner di versione nascosto.** Il protocollo SSH richiede *un* banner, quindi non può essere rimosso,
  ma VD Dropbear lo sostituisce con uno privo di informazioni, così gli scanner non possono identificare
  il server o la versione esatti e puntargli contro attacchi mirati a versioni note.
- **Segreti conservati con criterio** (vedi [Modello di sicurezza](#security-model)).
- **Porta le tue credenziali.** Aggiungi insiemi di `user + key` e `user + password`; la WebUI impone una
  robustezza minima della password e non memorizza mai una password in chiaro.
- **Trasferimento e sincronizzazione file integrati.** Il pacchetto include `sftp-server`, `scp` e
  `rsync`, così SFTP, sshfs, client GUI e backup funzionano tutti sulla stessa connessione.
- **Ogni dispositivo ed emulatore.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## Agenti AI sul tuo dispositivo

Un endpoint SSH sempre attivo trasforma il tuo telefono in qualcosa che un **agente AI autonomo può
operare direttamente**. Qualsiasi agente in grado di guidare una shell o una connessione SSH (Claude
Code, aider, uno script con un LLM nel loop, la tua automazione) ottiene una vera sessione root sul
dispositivo, sulla rete, senza cavo USB e senza nessuno dei flag di debug di ADB che ti espongono.
L'agente vede una normale shell in stile Linux e può:

- leggere e modificare file, cambiare impostazioni e gestire moduli, pacchetti e servizi;
- analizzare log, prelevare artefatti ed eseguire diagnostica o analisi forense su richiesta;
- spostare e sincronizzare file in entrambe le direzioni tramite `scp` / `sftp` / `rsync`, per backup, migrazioni o provisioning;
- gestire da un unico posto un'intera flotta di dispositivi rootati, ciascuno raggiungibile con la propria chiave.

Poiché il progetto è pensato per essere **AI-friendly** (un file di configurazione documentato, un
esplicito [contratto env](patches/README.md) di runtime, percorsi prevedibili e stato in testo semplice),
un agente può scoprire come usarlo senza tirare a indovinare.

> **Questo è root, quindi trattalo come root.** Ogni connessione autenticata entra come root (vedi
> l'avviso qui sotto). Quando affidi l'accesso a un agente, dagli un **utente e una chiave dedicati**,
> limita i bind alle reti di cui ti fidi (loopback o una VPN anziché l'internet aperta), tieni disattivata
> l'autenticazione a password e ricorda che puoi revocare una chiave o fermare il daemon in qualsiasi
> momento dalla WebUI.

## Installazione

Flasha lo zip del modulo nel manager KernelSU, APatch o Magisk (o da riga di comando con
`ksud module install` / `apd module install`), apri la **WebUI** del modulo per impostare la porta e
aggiungere le tue chiavi, poi riavvia (o premi **Action** per avviarlo subito).

## Modello di sicurezza

### Dove vivono i segreti: BFU vs AFU

`/data/adb` è uno storage **device-encrypted (DE)**: viene decrittato *prima* che l'utente sblocchi il
telefono (Before First Unlock), quindi tutto ciò che vi si trova è leggibile prima dello sblocco.
`/data/misc_ce` è **credential-encrypted (CE)**: Android lo mantiene crittato finché l'utente non sblocca
(After First Unlock).

- **Modalità AFU (default, `START_IN_BFU=0`):** il daemon attende lo sblocco e legge la sua host key,
  `authorized_keys` e gli hash delle password dallo storage CE. Massima protezione; SSH funziona solo dopo
  che il dispositivo è stato sbloccato almeno una volta dal boot.
- **Modalità BFU (`START_IN_BFU=1`):** il daemon si avvia prima dello sblocco così puoi fare SSH presto
  (per esempio, per sbloccare il dispositivo da remoto). I suoi segreti vivono allora sullo storage DE e
  sono leggibili prima dello sblocco, un compromesso deliberato e documentato. Attivala solo se hai bisogno
  di SSH prima dello sblocco.

Deliberatamente **non** aggiungiamo una nostra cifratura sopra a CE: è già crittato con la credenziale
dell'utente, e sovrapporre un altro cifrario richiederebbe una chiave che deve risiedere da qualche parte
(su DE sarebbe esposta; derivarla dalla credenziale dell'utente non fa che re-implementare CE). Comprerebbe
un falso senso di sicurezza, non una protezione reale.

### Password

Il login con password è **disattivato di default**, perché ogni login è root e le chiavi sono molto più
sicure. Quando imposti una password, la WebUI impone una robustezza minima e memorizza solo un hash, mai
testo in chiaro.

## Build

Il binario del server è compilato dalla CI a partire dall'**upstream [mkj/dropbear](https://github.com/mkj/dropbear)**
con un piccolo set di patch verificabili (vedi [`patches/`](patches/)): una stringa di identità
neutra/configurabile, percorsi guidati dalla configurazione per `authorized_keys` e il file delle password,
e la correzione `openpty` per Android per le PTY interattive. Un workflow pianificato segue l'upstream e
ricompila, così il modulo resta aggiornato. Vedi [`.github/workflows/`](.github/workflows/) e
[`CONTRIBUTING.md`](CONTRIBUTING.md).

## Documentazione

<!-- vd-docs -->
La documentazione completa si trova nella [wiki](https://github.com/VD171/VD-dropbear/wiki) e sotto
[`docs/`](docs/).
<!-- /vd-docs -->

## Vedi anche

Progetti affini dello stesso autore:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: un debugger dei metodi del dispositivo che legge ogni elemento tramite ogni metodo in grado di leggerlo e li confronta fianco a fianco.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: i tuoi servizi Google (RCS, Wallet, attestazioni Play Integrity), letti sul tuo dispositivo senza internet.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: backup e ripristino completi di app e dati come root, gestiti interamente da una WebUI.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: uno spoofer globale di fingerprint del dispositivo e della build.

## Contatti

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** _(placeholder, aggiunto alla prima release pubblica)_
* **GitHub:** @VD171 https://github.com/VD171

## Licenza

Il codice proprio di VD Dropbear è **Apache-2.0**; vedi [LICENSE](LICENSE). Il modulo include anche
binari di terze parti: [Dropbear](https://matt.ucc.asn.au/dropbear/) (stile MIT), `sftp-server` e `scp`
di OpenSSH (BSD) e `rsync` (GPL-3.0), ciascuno sotto la propria licenza; vedi
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), incluso come rispettiamo la GPL per rsync. Il nostro
codice Apache-2.0 non ne è influenzato (il binario GPL è semplicemente aggregato, non linkato).

## Marchi

VD Dropbear è un progetto indipendente e non ufficiale, non affiliato né approvato da alcuna terza parte.
"Android" è un marchio di Google LLC; "SSH" è un marchio registrato di SSH Communications Security. VD
Dropbear funziona interamente sul tuo dispositivo.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
