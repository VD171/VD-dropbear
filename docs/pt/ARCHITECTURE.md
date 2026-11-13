<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Architecture.

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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · Português · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Arquitetura

O VD Dropbear é um módulo KernelSU / APatch / Magisk que executa exatamente um daemon SSH Dropbear,
controlado inteiramente por configuração. Nada no servidor SSH está fixado no código para um único
dispositivo; tudo o que é específico é configuração de execução ou um segredo.

## Peças

- `module/common/vddropbear.sh`: a biblioteca central: carregar a configuração (com padrões internos
  seguros), resolver o cofre de segredos, garantir uma chave de host, montar o vetor de argumentos do
  Dropbear e gerenciar uma única instância do daemon (start / stop / status / restart).
- `module/service.sh`: entrada de boot. Respeita a política de início BFU/AFU; no modo AFU, aguarda o
  armazenamento criptografado por credencial desbloquear sem travar o boot.
- `module/action.sh`: o botão **Action** do gerenciador: (re)iniciar o daemon. Ele nunca lê o stdin e
  desacopla o daemon em sua própria sessão, para que o gerenciador não trave.
- `module/common/vddb-webui.sh` + `module/webroot/index.html`: o backend e a página da WebUI.
- `patches/`: patches pequenos e auditáveis aplicados ao Dropbear upstream no momento da compilação.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml`: a compilação.

## Ciclo de vida do daemon (instância única)

`vddb_start` carrega a configuração, para qualquer instância em execução, garante que exista uma chave
de host e então inicia um daemon. O binário é distribuído como `vddropbear`, de modo que seu nome de
processo corresponde exatamente a `pgrep -x` (o `mksh` do Android não tem `exec -a`). Ele é iniciado
com `setsid` para se desacoplar do grupo de processos do chamador: é isso que impede que o botão
Action do gerenciador bloqueie.

## O cofre de segredos (CE vs DE, BFU vs AFU)

As configurações não são segredo e ficam no armazenamento criptografado por dispositivo
(`/data/adb/vddropbear`), legível no boot. Os segredos (chave de host, `authorized_keys`, hashes de
senha) por padrão vão para o armazenamento **criptografado por credencial**
(`/data/misc_ce/0/vddropbear`), que só desbloqueia depois que o usuário se autentica. Ativar
`START_IN_BFU` move os segredos para o armazenamento criptografado por dispositivo, para que o daemon
possa rodar antes do primeiro desbloqueio, ao custo de esses segredos ficarem legíveis mais cedo. O
módulo calcula qual cofre usar em cada etapa do boot.

## O conjunto de patches

O servidor SSH continua sendo o Dropbear upstream; nossas mudanças são alguns patches revisáveis (veja
[patches/README.md](../../patches/README.md)):

- um banner de identidade neutro e configurável em tempo de execução;
- `authorized_keys` lido de um caminho definido por ambiente (para que as chaves fiquem no cofre de segredos);
- autenticação por senha contra um arquivo de hash PBKDF2 em vez do `crypt()`/shadow do sistema, que o
  Android não possui (veja [BUILDING.md](../BUILDING.md)).

## A WebUI

Uma página estática na WebUI do gerenciador (KernelSU / APatch / WebUI-X). Ela controla
`module/common/vddb-webui.sh` por meio da ponte `ksu.exec`: status, start/stop/restart, leitura/escrita
de configuração e gerenciamento de chaves e contas de senha. Todos os dados cruzam a ponte codificados
em base64, de modo que o shell nunca os interpreta; os hashes de senha são calculados no navegador com
WebCrypto, de modo que a senha em texto claro nunca sai da página.
