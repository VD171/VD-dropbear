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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · Italiano · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Guida utente

VD Dropbear dà al tuo dispositivo con root un server SSH privato. Questa guida ti porta
dall'installazione a una connessione funzionante, incluso il trasferimento di file e la modalità
before-first-unlock (BFU).

> **Un accesso è per impostazione predefinita una shell root completa.** Preferisci le chiavi alle password, fai il
> bind solo su reti di cui ti fidi e non esporre mai la porta all'Internet aperto senza un motivo.

## 1. Installazione

Flasha lo zip del modulo nel manager **KernelSU**, **APatch** o **Magisk** (oppure da una shell con
`ksud module install` / `apd module install`), poi apri la **WebUI** del modulo.

## 2. Aggiungi una chiave (consigliato)

Nella WebUI, sotto **Authorized keys**, incolla la tua chiave pubblica (`ssh-ed25519 AAAA... you@host`)
e premi **Add key**. Le chiavi sono il default e il modo più sicuro per entrare.

Per generare una chiave sul tuo computer, se non ne hai una:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Oppure imposta una password

L'accesso con password è disattivato per impostazione predefinita (un accesso è root per impostazione predefinita, quindi le
chiavi sono da preferire). Per abilitarlo, attiva **Password login** nelle impostazioni, poi sotto
**Password accounts** imposta una password per l'utente di accesso. L'hash viene calcolato nel tuo
browser con PBKDF2; la password stessa non lascia mai la pagina.

## 4. Scegli una porta e dove ascoltare

Sotto **Settings**, imposta la **Port** e scegli i bind. Per impostazione predefinita VD Dropbear
ascolta solo su **loopback**; per raggiungerlo dalla tua LAN o da una VPN, abilita le interfacce che
vuoi. Evita **Listen on all interfaces** a meno che tu non comprenda l'esposizione.

Premi **Save & restart** per applicare, poi **Start** se non è già in esecuzione.

## 5. Connetti

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` e `rsync` sono inclusi, così SFTP, `sshfs`, i client GUI e i backup funzionano
tutti sulla stessa connessione.

## 6. Prima del primo sblocco (BFU)

Per impostazione predefinita il daemon si avvia solo **dopo** che hai sbloccato il dispositivo una
volta (AFU), perché i suoi secret risiedono sullo storage credential-encrypted. Se hai bisogno di SSH
**prima** del primo sblocco (per esempio per sbloccare un dispositivo da remoto dopo un riavvio),
attiva **Start before first unlock (BFU)**. I secret passano allora allo storage device-encrypted, che
è leggibile prima dello sblocco: un compromesso deliberato e documentato. Vedi [Security model](#) nel
README.

## 7. Controllare il daemon

- **WebUI:** Start / Stop / Restart, e stato in tempo reale (in esecuzione, PID, porta, modalità, fingerprint della host key).
- **Pulsante Action del manager:** (ri)avvia il daemon.
- Si avvia anche automaticamente all'avvio (a meno che tu non lo disabiliti).

## Risoluzione dei problemi

- **Non si avvia.** Controlla `/data/adb/vddropbear/state/daemon.log`. Assicurati che **Enabled** sia
  attivo e che sia stato possibile generare una host key.
- **Chiave rifiutata.** Verifica che la riga della chiave pubblica sia esattamente quella che il tuo
  client offre, e che il nome utente con cui accedi sia uno che il sistema riconosce (di solito `root`).
- **Non riesco a connettermi da un'altra macchina.** Probabilmente sei ancora in bind solo su loopback:
  abilita l'interfaccia che ti serve e riavvia.
- **SFTP/scp fallisce ma la shell funziona.** Assicurati che il `sftp-server` incluso sia stato
  distribuito per la tua ABI; lo stato della WebUI mostra l'ABI rilevata.
