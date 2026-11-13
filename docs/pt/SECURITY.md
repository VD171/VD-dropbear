<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Security policy.

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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · Português · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Política de Segurança

## A única coisa a entender

O VD Dropbear inicia um servidor SSH, e **toda conexão que se autentica com sucesso recebe um shell
root**. A segurança do seu dispositivo, portanto, é igual à segurança da configuração e das
credenciais deste servidor. Por favor:

- **Prefira chaves públicas a senhas.** O login por senha é desativado por padrão.
- Se precisar usar uma senha, use uma forte - a WebUI impõe um mínimo e armazena apenas um hash.
- **Não exponha a porta à Internet pública.** Faça bind no loopback ou em uma LAN confiável, ou
  alcance-a por uma VPN / túnel.
- Entenda o **trade-off do BFU**: ativar o início antes do desbloqueio coloca a chave de host e as
  credenciais no armazenamento criptografado por dispositivo, legível antes de o dispositivo ser
  desbloqueado. Deixe desativado, a menos que precise de SSH antes do desbloqueio.
- Mantenha o encaminhamento desativado, a menos que precise dele (ele é desativado por padrão).

## O que o VD Dropbear faz para ajudar

- Um banner de versão neutro e sem informação, para que scanners de rede não consigam identificar o
  servidor e a versão exatos.
- Credenciais no armazenamento criptografado por credencial por padrão (descriptografadas apenas após você desbloquear).
- Sem telemetria, sem chamadas de rede próprias, sem analytics. Ele roda inteiramente no seu dispositivo.

## Versões suportadas

As correções de segurança chegam ao último lançamento. O binário do servidor acompanha o Dropbear
upstream; os lançamentos de segurança do upstream são recompilados e distribuídos assim que o CI os
detecta.

## Relatando uma vulnerabilidade

Por favor, relate problemas de segurança em privado, não em uma issue pública:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Inclua a versão, uma descrição e (idealmente) uma forma de reproduzir. Você receberá uma confirmação, e
coordenaremos com você uma correção e um cronograma de divulgação. Para vulnerabilidades no próprio
Dropbear, por favor relate também ao upstream em <https://matt.ucc.asn.au/dropbear/>.
