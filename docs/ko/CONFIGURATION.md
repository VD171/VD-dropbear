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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · 한국어 · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# 설정

설정은 `/data/adb/vddropbear/config` 에 있습니다(첫 부팅 때 `module/common/config.default` 에서 생성됩니다). **WebUI** 가 이 파일을 대신 편집해 주며, 직접 손으로 편집할 수도 있습니다. 셸로 읽어들이므로 `KEY=value` 형식을 쓰고 `=` 앞뒤에 공백을 두지 마십시오. 설정은 시크릿이 아니며 기기 암호화 저장소에 있습니다; 시크릿(호스트 키, authorized keys, 비밀번호 해시)은 시크릿 저장소에 있고 여기에는 결코 두지 않습니다.

변경은 데몬을 재시작해서 적용합니다(WebUI의 **Save & restart** 가 이것을 합니다).

## 일반

| Key | Default | 의미 |
|-----|---------|---------|
| `ENABLED` | `1` | 부팅 시 데몬을 시작합니다. `0` 은 완전히 비활성화합니다. |
| `START_IN_BFU` | `0` | `0`: 첫 잠금 해제 후(AFU)에만 시작; 시크릿은 자격 증명 암호화(CE) 저장소에 남습니다. `1`: 첫 잠금 해제 전(BFU)에도 시작; 시크릿이 기기 암호화(DE) 저장소로 옮겨져 잠금 해제 전에 읽을 수 있습니다. |
| `PORT` | `2222` | 기본 수신 포트(`LISTEN_ADDRESSES` 에서 바인드별 포트로 덮어쓸 수 있습니다). |

## 수신 / 바인드(조합 가능)

어떤 조합이든 허용되며, 선택한 바인드는 병합됩니다. 모두 비우면 VD Dropbear는 모든 인터페이스가 아니라 루프백에 바인드합니다.

| Key | Default | 의미 |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | `127.0.0.1` / `::1` 에서만 수신합니다. |
| `LISTEN_ALL` | `0` | 모든 인터페이스(`0.0.0.0` / `::`)에서 수신합니다 - 기기를 노출합니다. |
| `LISTEN_IPV4` | `1` | IPv4 바인드를 포함합니다. |
| `LISTEN_IPV6` | `1` | IPv6 바인드를 포함합니다. |
| `LISTEN_ADDRESSES` | `""` | 추가의 구체적 바인드, 쉼표로 구분: `addr`(`PORT` 사용) 또는 `addr:port`, IPv4 또는 IPv6. |

## 신원

| Key | Default | 의미 |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | 중립적인 SSH 신원 배너를 보내 스캐너가 정확한 서버/버전을 식별하지 못하게 합니다. |
| `IDENT_STRING` | `""` | 사용자 지정 신원 문자열. 비우면 중립적인 내장 기본값을 사용합니다. |

## 인증

인증된 로그인은 모두 **root** 입니다. 키가 기본이고 비밀번호는 선택 사항입니다.

| Key | Default | 의미 |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | 공개 키 로그인을 허용합니다(시크릿 저장소의 authorized keys를 읽습니다). |
| `PASSWORD_AUTH` | `0` | 비밀번호 로그인을 허용합니다. 꺼져 있으면 데몬은 비밀번호 인증을 끈 채로 시작됩니다. |
| `MAX_AUTH_TRIES` | `3` | 연결당 최대 인증 시도 횟수. |
| `LOGIN_USER` | `root` | 로그인할 계정. 시스템이 해석할 수 있는 것(보통 `root`)이어야 합니다. |

## 세션 / 환경

| Key | Default | 의미 |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | 세션의 셸. 비우면 계정 기본값을 사용합니다. |
| `HOME_DIR` | `""` | 세션의 `HOME`. 비우면 모듈 디렉터리를 사용합니다. |
| `EXTRA_ENV` | `""` | 추가 환경 변수, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | N초 유휴 후 연결을 끊습니다. `0` 은 비활성화. |
| `KEEPALIVE` | `0` | N초마다 keepalive를 보냅니다. `0` 은 비활성화. |
| `RECEIVE_WINDOW` | `""` | Dropbear 수신 윈도 크기. 비우면 기본값을 사용합니다. |

## 포워딩(기본적으로 꺼짐)

| Key | Default | 의미 |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | 로컬(`-L`) 포트 포워딩을 허용합니다. |
| `ALLOW_REMOTE_FORWARD` | `0` | 원격(`-R`) 포트 포워딩을 허용합니다. |
| `GATEWAY_PORTS` | `0` | 포워딩된 원격 포트가 모든 인터페이스에 바인드되도록 합니다. |

## 호스트 키

| Key | Default | 의미 |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | 호스트 키 종류: `ed25519`, `rsa` 또는 `ecdsa`. 첫 시작 시 시크릿 저장소에 생성됩니다. |

## 시크릿 저장소

여기서 설정하지 않습니다 - `START_IN_BFU` 에서 결정됩니다:

- **AFU(기본):** `/data/misc_ce/0/vddropbear/secret` - 자격 증명 암호화이며, 기기를 잠금 해제한 뒤에만 사용할 수 있습니다.
- **BFU:** `/data/adb/vddropbear/secret` - 기기 암호화이며, 첫 잠금 해제 전에 읽을 수 있습니다.

여기에는 호스트 키, `authorized_keys`, `passwd` 해시 파일이 들어갑니다. 비밀번호 해시 형식은 [BUILDING.md](../BUILDING.md) 를 참고하십시오.
