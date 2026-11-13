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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · Português · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# Agentes de IA no seu dispositivo

Um ponto de acesso SSH permanente transforma o seu celular em algo que um **agente de IA autônomo
pode operar diretamente**. Qualquer agente capaz de conduzir um shell ou uma conexão SSH (Claude
Code, aider, um script com LLM no laço, a sua própria automação) ganha uma sessão root real no
dispositivo, pela rede, sem cabo USB e sem nenhuma das flags de depuração autodenunciadoras do ADB.

Esta página amplia a ideia apresentada no README.

## Por que SSH, e não ADB, para agentes

O ADB se denuncia: `adb_enabled` e `development_settings_enabled` são legíveis por qualquer um, a
conexão é registrada e não há maneira suportada de esconder que a depuração está (ou esteve) ativa. Um
agente trabalhando por ADB deixa esse rastro no dispositivo para qualquer app ou SDK antifraude ler. O
VD Dropbear é a alternativa privada: um login SSH comum, com credenciais que você controla e um banner
que não revela nada.

## O que um agente pode fazer

Por uma única conexão, um agente vê um shell comum no estilo Linux e pode:

- ler e editar arquivos, alterar configurações e gerenciar módulos, pacotes e serviços;
- triar logs, extrair artefatos e executar diagnósticos ou perícia sob demanda;
- mover e sincronizar arquivos nos dois sentidos por `scp` / `sftp` / `rsync`: backups, migrações, provisionamento;
- comandar uma frota inteira de dispositivos com root a partir de um só lugar, cada um acessível pela sua própria chave.

Como o projeto foi construído para ser **amigável à IA** (um arquivo de configuração documentado, um
[contrato de ambiente](../../patches/README.md) de execução explícito, caminhos previsíveis e status
em texto puro) um agente consegue descobrir como usá-lo sem adivinhação.

## Fazendo isso com segurança

Isto é root, então trate como root:

- dê ao agente um **usuário e uma chave dedicados**, não os seus pessoais;
- restrinja os binds a redes em que você confia: loopback ou uma VPN em vez da Internet aberta
  (veja [Configuração](CONFIGURATION.md));
- mantenha a autenticação por senha desativada; uma chave é revogável e nunca é digitada;
- você pode revogar uma chave ou parar o daemon a qualquer momento pela WebUI;
- lembre-se de que toda conexão é uma sessão root completa. Dê ao agente apenas o alcance de que ele precisa.

## Uma configuração mínima

1. Gere um par de chaves apenas para o agente.
2. Adicione a chave pública dele na WebUI (**Authorized keys**).
3. Faça o bind apenas no loopback ou na sua VPN, em uma porta não padrão.
4. Aponte a configuração SSH do agente para o dispositivo e deixe-o trabalhar.
