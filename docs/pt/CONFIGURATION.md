<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Configuration reference.

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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · Português · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Configuração

As configurações ficam em `/data/adb/vddropbear/config` (semeadas de `module/common/config.default` no
primeiro boot). A **WebUI** edita esse arquivo para você; você também pode editá-lo à mão. Ele é lido
como shell, então use `KEY=value` sem espaços em volta do `=`. As configurações não são segredo e ficam
no armazenamento criptografado por dispositivo; os segredos (chaves de host, chaves autorizadas, hashes
de senha) ficam no cofre de segredos, nunca aqui.

Aplique as mudanças reiniciando o daemon (a opção **Save & restart** da WebUI faz isso).

## Geral

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | Inicia o daemon no boot. `0` o desativa por completo. |
| `START_IN_BFU` | `0` | `0`: inicia apenas após o primeiro desbloqueio (AFU); os segredos ficam no armazenamento criptografado por credencial (CE). `1`: inicia também antes do primeiro desbloqueio (BFU); os segredos vão para o armazenamento criptografado por dispositivo (DE), legível antes do desbloqueio. |
| `PORT` | `2222` | Porta de escuta padrão (portas por bind podem sobrescrevê-la em `LISTEN_ADDRESSES`). |

## Escuta / binds (combináveis)

Qualquer combinação é permitida; os binds selecionados são mesclados. Se você limpar tudo, o VD
Dropbear faz bind no loopback em vez de em todas as interfaces.

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Escuta apenas em `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Escuta em todas as interfaces (`0.0.0.0` / `::`) - expõe o dispositivo. |
| `LISTEN_IPV4` | `1` | Inclui binds IPv4. |
| `LISTEN_IPV6` | `1` | Inclui binds IPv6. |
| `LISTEN_ADDRESSES` | `""` | Binds específicos adicionais, separados por vírgula: `addr` (usa `PORT`) ou `addr:port`, IPv4 ou IPv6. |

## Identidade

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Envia um banner de identidade SSH neutro para que scanners não consigam identificar o servidor/versão exatos. |
| `IDENT_STRING` | `""` | Uma string de identidade personalizada. Vazio usa o padrão interno neutro. |

## Autenticação

Todo login autenticado é **root**. As chaves são o padrão; as senhas são opcionais.

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Permite login por chave pública (lê as chaves autorizadas no cofre de segredos). |
| `PASSWORD_AUTH` | `0` | Permite login por senha. Quando desativado, o daemon é iniciado com a autenticação por senha desabilitada. |
| `MAX_AUTH_TRIES` | `3` | Número máximo de tentativas de autenticação por conexão. |
| `LOGIN_USER` | `root` | A conta com a qual se faz login. Deve ser uma que o sistema resolva (geralmente `root`). |

## Sessão / ambiente

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell da sessão. Vazio usa o padrão da conta. |
| `HOME_DIR` | `""` | `HOME` da sessão. Vazio usa o diretório do módulo. |
| `EXTRA_ENV` | `""` | Ambiente extra, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Desconecta após N segundos ociosos. `0` desativa. |
| `KEEPALIVE` | `0` | Envia um keepalive a cada N segundos. `0` desativa. |
| `RECEIVE_WINDOW` | `""` | Tamanho da janela de recepção do Dropbear. Vazio usa o padrão. |

## Encaminhamento (desativado por padrão)

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Permite encaminhamento de porta local (`-L`). |
| `ALLOW_REMOTE_FORWARD` | `0` | Permite encaminhamento de porta remoto (`-R`). |
| `GATEWAY_PORTS` | `0` | Deixa as portas remotas encaminhadas fazerem bind em todas as interfaces. |

## Chave de host

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Tipo da chave de host: `ed25519`, `rsa` ou `ecdsa`. Gerada no primeiro início dentro do cofre de segredos. |

## O cofre de segredos

Não é configurado aqui - é resolvido a partir de `START_IN_BFU`:

- **AFU (padrão):** `/data/misc_ce/0/vddropbear/secret` - criptografado por credencial, disponível
  apenas depois que você desbloqueia o dispositivo.
- **BFU:** `/data/adb/vddropbear/secret` - criptografado por dispositivo, legível antes do primeiro desbloqueio.

Ele guarda a chave de host, o `authorized_keys` e o arquivo de hash `passwd`. Veja
[BUILDING.md](../BUILDING.md) para o formato do hash de senha.
