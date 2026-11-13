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

Um **servidor SSH [Dropbear](https://matt.ucc.asn.au/dropbear/) independente e totalmente configurável**,
empacotado como módulo KernelSU / APatch / Magisk. Ele sobe por conta própria e não depende de nenhum outro módulo.

> ⚠️ **Toda conexão que se autentica recebe um shell ROOT.** Trate isso como as chaves do
> aparelho: prefira chaves públicas a senhas e mantenha a porta fora da Internet pública.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Por quê

A maneira nativa do Android de obter um shell no próprio celular é o ADB (depuração USB), e ligá-lo é
invasivo e se expõe sozinho. `adb_enabled` e `development_settings_enabled` são configurações legíveis por
qualquer um: qualquer app, SDK ou biblioteca antifraude / RASP consegue lê-las, a conexão fica registrada e
não existe forma suportada de esconder que o ADB está, ou já esteve, ativado. Essa exposição te acompanha
mesmo num celular de fábrica, sem root: para conseguir um shell, você precisa anunciá-lo.

O VD Dropbear é a alternativa privada. Num aparelho com root, ele te dá um servidor SSH de verdade: shell
root, SFTP e rsync pela rede, sem o rastro do `adb_enabled`, sem flag de depuração USB, com um banner de
versão que não revela nada e credenciais sob o seu controle. Seu acesso continua sendo seu, em vez de uma
flag "estou sendo depurado", legível globalmente, que qualquer coisa no aparelho pode ler.

## Recursos

- **Um daemon, sempre.** Ele inicia no boot e pelo botão **Action** do gerenciador, e você pode
  **iniciar / parar / reiniciar** pela WebUI a qualquer momento; nunca mais de uma instância.
- **Tudo é configurável** pela WebUI (ou por `/data/adb/vddropbear/config`):
  - porta, e bind em loopback / all / IPv4 / IPv6 / endereços específicos
  - **iniciar antes do primeiro desbloqueio (BFU) ou só depois dele (AFU)**, um único botão
  - autenticação por chave pública e/ou senha, número máximo de tentativas de autenticação
  - usuário de login, shell, `HOME`, environment extra
  - idle timeout, keepalive, receive window
  - encaminhamento de portas local / remoto e gateway ports (tudo **desligado** por padrão)
  - tipo de host-key (ed25519 / rsa / ecdsa)
- **Banner de versão oculto.** O protocolo SSH exige *um* banner, então ele não pode ser removido, mas o VD
  Dropbear o substitui por um banner sem informação, de modo que scanners não conseguem identificar o servidor
  ou a versão exatos e mirar nele ataques voltados a versões conhecidas.
- **Segredos armazenados com bom senso** (veja [Modelo de segurança](#security-model)).
- **Traga suas próprias credenciais.** Adicione conjuntos de `user + key` e `user + password`; a WebUI impõe
  uma força mínima de senha e nunca armazena a senha em texto puro.
- **Transferência e sincronização de arquivos embutidas.** O pacote inclui `sftp-server`, `scp` e `rsync`,
  então SFTP, sshfs, clientes gráficos e backups funcionam todos pela mesma conexão.
- **Todo aparelho e emulador.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## Agentes de IA no seu aparelho

Um endpoint SSH permanente transforma seu celular em algo que um **agente de IA autônomo pode operar
diretamente**. Qualquer agente capaz de conduzir um shell ou uma conexão SSH (Claude Code, aider, um script
com um LLM no loop, sua própria automação) ganha uma sessão root de verdade no aparelho, pela rede, sem cabo
USB e sem nenhuma das flags de depuração do ADB que se expõem sozinhas. O agente vê um shell comum, no estilo
Linux, e pode:

- ler e editar arquivos, alternar configurações e gerenciar módulos, pacotes e serviços;
- triar logs, puxar artefatos e rodar diagnósticos ou forense sob demanda;
- mover e sincronizar arquivos nos dois sentidos via `scp` / `sftp` / `rsync`, para backups, migrações ou provisionamento;
- comandar uma frota inteira de aparelhos com root de um só lugar, cada um alcançável pela sua própria chave.

Como o projeto é feito para ser **amigável a IA** (um arquivo de configuração documentado, um
[contrato de env](patches/README.md) de runtime explícito, caminhos previsíveis e status em texto puro), um
agente consegue descobrir como usá-lo sem ter que adivinhar.

> **Isto é root, então trate como root.** Toda conexão autenticada entra como root (veja o aviso abaixo).
> Quando entregar o acesso a um agente, dê a ele um **usuário e uma chave dedicados**, restrinja os binds às
> redes em que você confia (loopback ou uma VPN, em vez da internet aberta), mantenha a autenticação por senha
> desligada e lembre-se de que você pode revogar uma chave ou parar o daemon a qualquer momento pela WebUI.

## Instalação

Instale o zip do módulo no gerenciador do KernelSU, APatch ou Magisk (ou pela linha de comando com
`ksud module install` / `apd module install`), abra a **WebUI** do módulo para definir a porta e adicionar suas
chaves, e então reinicie (ou aperte **Action** para iniciá-lo agora).

## Modelo de segurança

### Onde os segredos vivem: BFU vs AFU

`/data/adb` é armazenamento **device-encrypted (DE)**: ele é descriptografado *antes* de o usuário desbloquear
o celular (Before First Unlock), então qualquer coisa ali é legível antes do desbloqueio. `/data/misc_ce` é
**credential-encrypted (CE)**: o Android o mantém criptografado até o usuário desbloquear (After First Unlock).

- **Modo AFU (padrão, `START_IN_BFU=0`):** o daemon espera o desbloqueio e lê sua host key, o
  `authorized_keys` e os hashes de senha a partir do armazenamento CE. Proteção máxima; o SSH só funciona
  depois que o aparelho tiver sido desbloqueado ao menos uma vez desde o boot.
- **Modo BFU (`START_IN_BFU=1`):** o daemon inicia antes do desbloqueio para você poder entrar via SSH cedo
  (por exemplo, para desbloquear o aparelho remotamente). Seus segredos passam então a ficar no armazenamento DE
  e são legíveis antes do desbloqueio, um compromisso deliberado e documentado. Ative apenas se você precisar de
  SSH antes do desbloqueio.

Deliberadamente **não** adicionamos criptografia nossa por cima do CE: ele já está criptografado com a
credencial do usuário, e sobrepor outra cifra exigiria uma chave que teria que morar em algum lugar (no DE ela
ficaria exposta; derivá-la da credencial do usuário apenas reimplementa o CE). Isso compraria uma falsa sensação
de segurança, não proteção de verdade.

### Senhas

O login por senha vem **desligado por padrão**, porque todo login é root e as chaves são muito mais seguras.
Quando você define uma senha, a WebUI impõe uma força mínima e armazena apenas um hash, nunca texto puro.

## Build

O binário do servidor é compilado pelo CI a partir do **upstream [mkj/dropbear](https://github.com/mkj/dropbear)**
com um conjunto de patches pequeno e auditável (veja [`patches/`](patches/)): uma string de identidade
neutra/configurável, caminhos guiados por configuração para `authorized_keys` e o arquivo de senhas, e a
correção `openpty` do Android para PTYs interativas. Um workflow agendado acompanha o upstream e recompila, de
modo que o módulo se mantém atualizado. Veja [`.github/workflows/`](.github/workflows/) e
[`CONTRIBUTING.md`](CONTRIBUTING.md).

## Documentação

<!-- vd-docs -->
A documentação completa fica na [wiki](https://github.com/VD171/VD-dropbear/wiki) e em
[`docs/`](docs/).
<!-- /vd-docs -->

## Veja também

Projetos irmãos do mesmo autor:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: um depurador de métodos do aparelho que lê cada item por todos os métodos capazes de lê-lo e os compara lado a lado.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: seus serviços Google (RCS, Wallet, atestações do Play Integrity), lidos no seu aparelho sem internet.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: backup e restauração completos de apps e dados como root, conduzidos inteiramente por uma WebUI.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: um spoofer global de fingerprint do aparelho e do build.

## Contatos

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** _(placeholder, adicionado no primeiro lançamento público)_
* **GitHub:** @VD171 https://github.com/VD171

## Licença

O código próprio do VD Dropbear é **Apache-2.0**; veja [LICENSE](LICENSE). O módulo também empacota binários de
terceiros: [Dropbear](https://matt.ucc.asn.au/dropbear/) (estilo MIT), o `sftp-server` e o `scp` do OpenSSH
(BSD), e o `rsync` (GPL-3.0), cada um sob sua própria licença; veja
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), inclusive como cumprimos a GPL do rsync. Nosso código
Apache-2.0 não é afetado (o binário GPL é apenas agregado, não linkado).

## Marcas registradas

O VD Dropbear é um projeto independente e não oficial, sem afiliação ou endosso de qualquer terceiro. "Android"
é marca registrada da Google LLC; "SSH" é marca registrada da SSH Communications Security. O VD Dropbear roda
inteiramente no seu aparelho.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
