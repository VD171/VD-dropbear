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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · Português · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Contribuindo com o VD Dropbear

Obrigado pelo seu interesse. Este é um projeto pequeno e sensível à segurança (ele distribui root),
então as mudanças são revisadas com isso em mente.

## Organização do repositório

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Compilação

O binário é produzido pelo CI a partir do **upstream [mkj/dropbear](https://github.com/mkj/dropbear)**
mais os patches em `patches/`. Para compilar localmente você precisa do Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

O conjunto de patches é intencionalmente mínimo e auditável: uma string de identidade
neutra/configurável, caminhos definidos por configuração para o `authorized_keys` e o arquivo de senha,
a correção do `openpty` do Android e a configuração em tempo de execução. Por favor, mantenha os novos
patches pequenos, documentados e justificados no PR.

## Pull requests

- Uma mudança lógica por PR; descreva a motivação e o impacto na segurança.
- Siga o estilo de shell existente (POSIX `sh` / Android `mksh`; sem bashisms).
- Todo arquivo carrega um cabeçalho SPDX curto - mantenha-o.
- Atualize o [`CHANGELOG.md`](../../CHANGELOG.md) sob `[Unreleased]` para qualquer mudança real e visível ao usuário.
- Ao enviar um PR você concorda em licenciar sua contribuição sob a licença [Apache-2.0](../../LICENSE) do projeto.

## Traduções

O README e a documentação são mantidos em vários idiomas (`README.<lang>.md`). O inglês é a fonte da
verdade; as traduções o seguem. Se você melhorar uma tradução ou adicionar um idioma, mantenha a
estrutura e as âncoras de seção idênticas às da versão em inglês.

## Relatando bugs e problemas de segurança

Use os templates de issue para bugs e pedidos de recurso. Para qualquer coisa que possa comprometer um
dispositivo, siga o [`SECURITY.md`](SECURITY.md) e relate em privado em vez de abrir uma issue pública.
