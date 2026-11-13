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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · Português · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Guia do usuário

O VD Dropbear dá ao seu dispositivo com root um servidor SSH privado. Este guia leva você da instalação
até uma conexão funcionando, incluindo transferência de arquivos e o modo antes do primeiro desbloqueio
(BFU).

> **Um login resulta, por padrão, em um shell root completo.** Prefira chaves a senhas, faça bind apenas em redes
> em que você confia e nunca exponha a porta à Internet aberta sem motivo.

## 1. Instalar

Instale o zip do módulo no gerenciador **KernelSU**, **APatch** ou **Magisk** (ou por um shell com
`ksud module install` / `apd module install`), e então abra a **WebUI** do módulo.

## 2. Adicionar uma chave (recomendado)

Na WebUI, em **Authorized keys**, cole a sua chave pública (`ssh-ed25519 AAAA... you@host`) e
pressione **Add key**. As chaves são o padrão e a forma mais segura de entrar.

Para gerar uma chave no seu computador, caso não tenha uma:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Ou definir uma senha

O login por senha é desativado por padrão (um login é root por padrão, então as chaves são preferíveis). Para
ativá-lo, ligue **Password login** nas configurações e, em **Password accounts**, defina uma senha para
o usuário de login. O hash é calculado no seu navegador com PBKDF2; a senha em si nunca sai da página.

## 4. Escolher uma porta e onde escutar

Em **Settings**, defina a **Port** e escolha os binds. Por padrão o VD Dropbear escuta apenas no
**loopback**; para alcançá-lo a partir da sua LAN ou de uma VPN, habilite as interfaces que quiser.
Evite **Listen on all interfaces**, a menos que compreenda a exposição.

Pressione **Save & restart** para aplicar e então **Start**, se ainda não estiver em execução.

## 5. Conectar

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` e `rsync` estão incluídos, então SFTP, `sshfs`, clientes gráficos e backups
funcionam todos pela mesma conexão.

## 6. Antes do primeiro desbloqueio (BFU)

Por padrão, o daemon inicia apenas **depois** que você desbloqueia o dispositivo uma vez (AFU), porque
seus segredos ficam no armazenamento criptografado por credencial. Se você precisar de SSH **antes** do
primeiro desbloqueio (por exemplo, para desbloquear um dispositivo remotamente após um reboot) ligue
**Start before first unlock (BFU)**. Os segredos então vão para o armazenamento
criptografado por dispositivo, que é legível antes do desbloqueio: um trade-off deliberado e
documentado. Veja [Modelo de segurança](#) no README.

## 7. Controlando o daemon

- **WebUI:** Start / Stop / Restart, e status ao vivo (em execução, PID, porta, modo, impressão
  digital da chave de host).
- **Botão Action do gerenciador:** (re)inicia o daemon.
- Ele também inicia automaticamente no boot (a menos que você desative).

## Solução de problemas

- **Não inicia.** Verifique `/data/adb/vddropbear/state/daemon.log`. Certifique-se de que **Enabled**
  está ligado e de que uma chave de host pôde ser gerada.
- **Chave rejeitada.** Confirme que a linha da chave pública está exatamente como o seu cliente a
  oferece e que o nome de usuário com que você faz login é um que o sistema resolve (geralmente `root`).
- **Não consigo conectar de outra máquina.** Você provavelmente ainda está vinculado apenas ao loopback.
  Habilite a interface de que precisa e reinicie.
- **SFTP/scp falha, mas o shell funciona.** Verifique se o `sftp-server` incluído foi distribuído para
  o seu ABI; o status da WebUI mostra o ABI detectado.
