<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · Deutsch · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Benutzerhandbuch

VD Dropbear gibt deinem gerooteten Gerät einen privaten SSH-Server. Dieses Handbuch führt dich von
der Installation bis zu einer funktionierenden Verbindung, einschließlich Dateiübertragung und des
Modus vor der ersten Entsperrung (BFU).

> **Jede authentifizierte Verbindung erhält eine Root-Shell.** Bevorzuge Schlüssel gegenüber
> Passwörtern, binde nur an Netzwerke, denen du vertraust, und gib den Port niemals ohne Grund ins
> offene Internet frei.

## 1. Installieren

Flashe das Modul-Zip im **KernelSU**-, **APatch**- oder **Magisk**-Manager (oder aus einer Shell mit
`ksud module install` / `apd module install`) und öffne dann die **WebUI** des Moduls.

## 2. Einen Schlüssel hinzufügen (empfohlen)

Füge in der WebUI unter **Authorized keys** deinen öffentlichen Schlüssel ein
(`ssh-ed25519 AAAA... you@host`) und drücke **Add key**. Schlüssel sind der Standard und der sicherste
Weg hinein.

So erzeugst du auf deinem Computer einen Schlüssel, falls du keinen hast:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Oder ein Passwort setzen

Die Passwortanmeldung ist standardmäßig aus (jede Anmeldung ist root, daher werden Schlüssel
bevorzugt). Zum Aktivieren schalte in den Einstellungen **Password login** ein und setze dann unter
**Password accounts** ein Passwort für den Anmeldebenutzer. Der Hash wird in deinem Browser mit
PBKDF2 berechnet; das Passwort selbst verlässt die Seite nie.

## 4. Einen Port und das Lauschziel wählen

Setze unter **Settings** den **Port** und wähle die Bindungen. Standardmäßig lauscht VD Dropbear nur
auf **Loopback**; um es aus deinem LAN oder einem VPN zu erreichen, aktiviere die gewünschten
Schnittstellen. Vermeide **Listen on all interfaces**, es sei denn, du verstehst die damit
verbundene Exponierung.

Drücke **Save & restart** zum Anwenden und dann **Start**, falls es nicht bereits läuft.

## 5. Verbinden

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` und `rsync` sind mitgeliefert, sodass SFTP, `sshfs`, GUI-Clients und Backups
alle über dieselbe Verbindung funktionieren.

## 6. Vor der ersten Entsperrung (BFU)

Standardmäßig startet der Daemon erst, **nachdem** du das Gerät einmal entsperrt hast (AFU), weil
seine Geheimnisse auf mit Zugangsdaten verschlüsseltem Speicher liegen. Wenn du SSH **vor** der ersten
Entsperrung brauchst - zum Beispiel, um ein Gerät nach einem Neustart aus der Ferne zu entsperren -
schalte **Start before first unlock (BFU)** ein. Die Geheimnisse wandern dann auf
gerätverschlüsselten Speicher, der vor der Entsperrung lesbar ist: ein bewusster, dokumentierter
Kompromiss. Siehe [Sicherheitsmodell](#) in der README.

## 7. Den Daemon steuern

- **WebUI:** Start / Stopp / Neustart und Live-Status (läuft, PID, Port, Modus, Host-Schlüssel-Fingerprint).
- **Action-Schaltfläche des Managers:** startet den Daemon (neu).
- Er startet außerdem automatisch beim Booten (sofern du ihn nicht deaktivierst).

## Fehlerbehebung

- **Er startet nicht.** Prüfe `/data/adb/vddropbear/state/daemon.log`. Stelle sicher, dass
  **Enabled** an ist und ein Host-Schlüssel erzeugt werden konnte.
- **Schlüssel abgelehnt.** Vergewissere dich, dass die Zeile des öffentlichen Schlüssels genau so
  ist, wie dein Client sie anbietet, und dass der Anmeldebenutzer einer ist, den das System auflöst
  (gewöhnlich `root`).
- **Keine Verbindung von einem anderen Rechner.** Wahrscheinlich bist du noch nur an Loopback
  gebunden - aktiviere die benötigte Schnittstelle und starte neu.
- **SFTP/scp schlägt fehl, aber die Shell funktioniert.** Stelle sicher, dass der mitgelieferte
  `sftp-server` für deine ABI ausgeliefert wurde; der WebUI-Status zeigt die erkannte ABI.
