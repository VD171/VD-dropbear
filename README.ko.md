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

KernelSU / APatch / Magisk 모듈로 패키징된 **독립 실행형이며 완전히 설정 가능한
[Dropbear](https://matt.ucc.asn.au/dropbear/) SSH 서버**입니다. 스스로 실행되며 다른 어떤 모듈에도 의존하지 않습니다.

> ⚠️ **로그인은 기본적으로 완전한 ROOT 셸이 됩니다.** 이것을 기기의 열쇠처럼 다루세요.
> 비밀번호보다 공개 키를 우선하고, 포트를 공개 인터넷에 노출하지 마세요.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## 왜

안드로이드에서 자기 휴대폰에 셸을 얻는 기본 방법은 ADB(USB 디버깅)인데, 이를 켜는 것은 침습적이고 스스로를
노출시킵니다. `adb_enabled`와 `development_settings_enabled`는 누구나 읽을 수 있는 설정이라 어떤 앱, SDK,
사기 방지 / RASP 라이브러리든 읽을 수 있고, 연결은 로그로 남으며, ADB가 켜져 있거나 켜진 적이 있다는 사실을 숨길
공식적인 방법은 없습니다. 이 노출은 루팅하지 않은 순정 휴대폰에서도 따라다닙니다. 셸을 얻으려면 그 사실을
드러내야만 합니다.

VD Dropbear는 프라이빗한 대안입니다. 루팅된 기기에서 진짜 SSH 서버(루트 셸, 네트워크를 통한 SFTP와 rsync)
를 제공하며, `adb_enabled` 흔적도, USB 디버깅 플래그도 없고, 아무것도 드러내지 않는 버전 배너와 당신이 통제하는
자격 증명을 갖추고 있습니다. 당신의 접근 권한은 당신의 것으로 남습니다. 기기의 무엇이든 읽을 수 있는, 전역으로
읽히는 "나는 디버깅 중입니다"라는 플래그가 아닙니다.

## 기능

- **데몬은 언제나 하나.** 부팅 시와 매니저의 **Action** 버튼에서 시작되며, WebUI에서 언제든지
  **start / stop / restart** 할 수 있습니다. 인스턴스가 둘 이상이 되는 일은 결코 없습니다.
- **모든 것이 WebUI에서 설정 가능**(또는 `/data/adb/vddropbear/config`):
  - 포트, 그리고 loopback / all / IPv4 / IPv6 / 특정 주소로의 bind
  - **첫 잠금 해제 전(BFU)에 시작할지, 그 이후에만(AFU) 시작할지**, 단일 토글
  - 공개 키 및/또는 비밀번호 인증, 최대 인증 시도 횟수
  - 로그인 셸, `HOME`, 추가 environment
  - idle timeout, keepalive, receive window
  - 로컬 / 원격 포트 포워딩과 gateway ports(모두 기본적으로 **꺼짐**)
  - host-key 유형(ed25519 / rsa / ecdsa)
- **숨겨진 버전 배너.** SSH 프로토콜은 *어떤* 배너를 요구하므로 제거할 수는 없지만, VD Dropbear는 이를 아무런
  정보도 주지 않는 것으로 교체합니다. 그래서 스캐너가 정확한 서버나 버전을 식별하여 알려진 버전을 겨냥한 공격을
  들이댈 수 없습니다.
- **비밀 정보는 합리적으로 저장**([보안 모델](#security-model) 참조).
- **자신의 자격 증명을 가져오기.** 승인된 키와 비밀번호 계정을 추가하세요. 로그인은 인증에 사용한 계정으로
  실행됩니다. 기본값은 **root**이며, 권한이 낮은 Android 계정(`shell`, `system`)으로도 로그인할 수 있습니다.
  WebUI는 최소 비밀번호 강도를 강제하며 비밀번호를 평문으로 저장하는 일이 결코 없습니다.
- **파일 전송과 동기화 내장.** 번들에는 `sftp-server`, `scp`, `rsync`가 포함되어 있어 SFTP, sshfs, GUI 클라이언트,
  백업이 모두 같은 연결 위에서 동작합니다.
- **모든 기기와 에뮬레이터.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## 기기 위의 AI 에이전트

상시 대기하는 SSH 엔드포인트는 당신의 휴대폰을 **자율 AI 에이전트가 직접 조작할 수 있는** 것으로 바꿉니다. 셸이나
SSH 연결을 다룰 수 있는 에이전트(Claude Code, aider, LLM을 루프에 넣은 스크립트, 당신만의 자동화)는 네트워크를 통해
기기에서 진짜 루트 세션을 얻습니다. USB 연결선도, 스스로를 노출하는 ADB의 디버그 플래그도 필요 없습니다. 에이전트는
평범한 Linux 유사 셸을 보며 다음을 할 수 있습니다:

- 파일을 읽고 편집하고, 설정을 바꾸고, 모듈·패키지·서비스를 관리하기;
- 로그를 분류하고, 아티팩트를 가져오고, 요청에 따라 진단이나 포렌식을 실행하기;
- `scp` / `sftp` / `rsync`로 파일을 양방향으로 이동·동기화하여 백업, 마이그레이션, 프로비저닝에 사용하기;
- 루팅된 기기들의 함대 전체를 한곳에서 운용하고, 각 기기를 저마다의 키로 도달 가능하게 하기.

이 프로젝트는 **AI 친화적**으로 만들어졌기에(문서화된 설정 파일, 명시적인 런타임 [env 계약](patches/README.md),
예측 가능한 경로, 평문 상태) 에이전트는 추측 없이 사용법을 찾아낼 수 있습니다.

> **기본적으로 루트이므로 루트처럼 다루세요.** 기본 로그인은 루트로 접속되며, 권한이 낮은 계정(`shell`, `system`)으로
> 로그인할 수도 있습니다(아래 경고 참조). 에이전트에게
> 접근 권한을 넘길 때는 (당신 개인 키가 아니라) 전용 자격 증명을 주고, 도달 범위를 제한하려면 `shell` 같은 권한이
> 낮은 계정을 가리키게 하고, bind를 신뢰하는 네트워크(열린 인터넷이 아니라 loopback이나 VPN)로
> 한정하고, 비밀번호 인증은 꺼둔 채로 두며, WebUI에서 언제든지 키를 취소하거나 데몬을 멈출 수 있다는 점을 기억하세요.

## 설치

KernelSU, APatch 또는 Magisk 매니저에서 모듈 zip을 플래시하거나(또는 명령줄에서
`ksud module install` / `apd module install`), 모듈의 **WebUI**를 열어 포트를 설정하고 키를 추가한 다음,
재부팅하세요(또는 **Action**을 눌러 지금 바로 시작합니다).

## 보안 모델

### 비밀 정보가 사는 곳: BFU 대 AFU

`/data/adb`는 **device-encrypted(DE)** 저장소입니다. 사용자가 휴대폰을 잠금 해제하기 *전에* 복호화되므로
(Before First Unlock), 그곳의 어떤 것이든 잠금 해제 전에 읽을 수 있습니다. `/data/misc_ce`는
**credential-encrypted(CE)**로, 안드로이드는 사용자가 잠금을 해제할 때까지 암호화된 상태로 유지합니다(After First Unlock).

- **AFU 모드(기본값, `START_IN_BFU=0`):** 데몬은 잠금 해제를 기다렸다가 host key, `authorized_keys`,
  비밀번호 해시를 CE 저장소에서 읽습니다. 최대한의 보호이며, SSH는 기기가 부팅 이후 한 번 잠금 해제된 뒤에만 동작합니다.
- **BFU 모드(`START_IN_BFU=1`):** 데몬이 잠금 해제 전에 시작되어 일찍 SSH로 접속할 수 있습니다(예: 기기를 원격으로
  잠금 해제하기 위해). 그러면 비밀 정보가 DE 저장소에 놓여 잠금 해제 전에 읽힙니다. 이는 의도적이고 문서화된 절충입니다.
  잠금 해제 전 SSH가 필요한 경우에만 활성화하세요.

우리는 의도적으로 CE 위에 자체 암호화를 **덧붙이지 않습니다**. 이미 사용자 자격 증명으로 암호화되어 있고, 또 다른
암호를 겹치면 어딘가에 두어야 하는 키가 필요합니다(DE에 두면 노출되고, 사용자 자격 증명에서 유도하는 것은 CE를
재구현하는 것일 뿐입니다). 그것은 진짜 보호가 아니라 거짓된 안도감을 살 뿐입니다.

### 비밀번호

비밀번호 로그인은 **기본적으로 꺼져 있습니다**. 로그인이 기본적으로 루트이며 키가 훨씬 안전하기 때문입니다. 비밀번호를
설정할 때 WebUI는 최소 강도를 강제하고 해시만 저장하며, 평문은 결코 저장하지 않습니다.

## 빌드

서버 바이너리는 **upstream [mkj/dropbear](https://github.com/mkj/dropbear)**에서 CI가 빌드하며, 작고 감사 가능한
패치 세트가 적용됩니다([`patches/`](patches/) 참조): 중립적/설정 가능한 아이덴티티 문자열, `authorized_keys`와
비밀번호 파일을 위한 설정 기반 경로, 그리고 대화형 PTY를 위한 안드로이드 `openpty` 수정입니다. 예약된 workflow가
upstream을 추적하여 다시 빌드하므로 모듈은 항상 최신 상태로 유지됩니다. [`.github/workflows/`](.github/workflows/)와
[`CONTRIBUTING.md`](CONTRIBUTING.md)를 참조하세요.

## 문서

<!-- vd-docs -->
전체 문서는 [wiki](https://github.com/VD171/VD-dropbear/wiki)와 [`docs/`](docs/) 아래에 있습니다.
<!-- /vd-docs -->

## 함께 보기

같은 저자의 자매 프로젝트:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: 각 항목을, 그것을 읽을 수 있는 모든 방법으로 읽어 나란히 비교하는 기기 메서드 디버거.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: RCS, Wallet, Play Integrity에 대해 Google이 기기에 기록하는 내용을 완전히 기기 내에서 인터넷 없이 읽습니다.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: 루트로 앱과 데이터를 통째로 백업·복원하며, 전부 WebUI에서 조작합니다.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: 새로운 핑거프린트를 일관되고 정합적인 프로필로 바꾸는 기기 스푸퍼입니다.

## 연락처

- https://vd171.ru
- https://vd.priv8.ru
- *Telegram:* @VD_Priv8 https://t.me/VD_Priv8
- *Channel:* @Priv8_VD https://t.me/Priv8_VD
- *Discord:* @VD.Priv8 https://discord.com/users/1296831918989639721
- *E-mail:* vd.priv8@pm.me
- *XDA-Developers:* @VD171 https://xdaforums.com/m/vd171.4699873/
- *XDA thread:* https://xdaforums.com/t/VD-Dropbear.4808524/
- *GitHub:* @VD171 https://github.com/VD171

## 라이선스

VD Dropbear 자체 코드는 **Apache-2.0**입니다. [LICENSE](LICENSE)를 참조하세요. 모듈은 서드파티 바이너리도 함께
포함합니다: [Dropbear](https://matt.ucc.asn.au/dropbear/)(MIT 계열), OpenSSH의 `sftp-server`와 `scp`(BSD),
그리고 `rsync`(GPL-3.0), 각각 자체 라이선스를 따릅니다. [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)를
참조하세요. rsync에 대해 GPL을 어떻게 준수하는지도 포함되어 있습니다. 우리의 Apache-2.0 코드는 영향을 받지 않습니다
(GPL 바이너리는 단지 집합되어 있을 뿐 링크되지 않습니다).

## 상표

VD Dropbear는 독립적이고 비공식적인 프로젝트이며, 어떤 제3자와도 제휴하거나 그들의 보증을 받지 않았습니다.
"Android"는 Google LLC의 상표이고, "SSH"는 SSH Communications Security의 등록 상표입니다. VD Dropbear는 전적으로
당신의 기기에서 실행됩니다.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
