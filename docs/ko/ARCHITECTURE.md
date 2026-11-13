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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · 한국어 · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# 아키텍처

VD Dropbear는 정확히 하나의 Dropbear SSH 데몬을 실행하는 KernelSU / APatch / Magisk 모듈이며, 동작은 전적으로 설정으로 제어됩니다. SSH 서버에 관해 특정 기기에 하드코딩된 것은 없으며, 고유한 요소는 모두 런타임 설정이거나 시크릿입니다.

## 구성 요소

- `module/common/vddropbear.sh`: 핵심 라이브러리: 설정 읽기(안전한 내장 기본값 포함), 시크릿 저장소 확인, 호스트 키 보장, Dropbear 인자 벡터 구성, 그리고 단일 데몬 인스턴스 관리(start / stop / status / restart).
- `module/service.sh`: 부팅 진입점. BFU/AFU 시작 정책을 따르며, AFU 모드에서는 부팅을 멈추지 않고 자격 증명 암호화 저장소의 잠금 해제를 기다립니다.
- `module/action.sh`: 매니저의 **Action** 버튼: 데몬을 (재)실행합니다. stdin을 전혀 읽지 않고 데몬을 자신의 세션으로 분리하므로 매니저가 멈추지 않습니다.
- `module/common/vddb-webui.sh` + `module/webroot/index.html`: WebUI 백엔드와 페이지.
- `patches/`: 빌드 시점에 upstream Dropbear에 적용되는, 작고 감사 가능한 패치.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml`: 빌드.

## 데몬 수명 주기(단일 인스턴스)

`vddb_start` 는 설정을 읽고, 실행 중인 인스턴스가 있으면 멈추고, 호스트 키의 존재를 보장한 뒤 데몬 하나를 띄웁니다. 바이너리는 `vddropbear` 로 배포되므로 그 프로세스 이름이 `pgrep -x` 와 정확히 일치합니다(Android `mksh` 에는 `exec -a` 가 없습니다). `setsid` 로 실행되어 호출자의 프로세스 그룹에서 분리됩니다: 이것이 매니저의 Action이 멈추지 않게 하는 핵심입니다.

## 시크릿 저장소(CE 대 DE, BFU 대 AFU)

설정은 시크릿이 아니며 기기 암호화 저장소(`/data/adb/vddropbear`)에 있어 부팅 시 읽을 수 있습니다. 시크릿(호스트 키, `authorized_keys`, 비밀번호 해시)은 기본적으로 **자격 증명 암호화(credential-encrypted)** 저장소(`/data/misc_ce/0/vddropbear`)에 있으며, 이는 사용자가 인증한 뒤에야 잠금이 풀립니다. `START_IN_BFU` 를 켜면 시크릿이 기기 암호화 저장소로 옮겨져 데몬이 첫 잠금 해제 전에 실행될 수 있지만, 그 대가로 시크릿을 더 이른 시점에 읽을 수 있게 됩니다. 모듈은 각 부팅 단계에서 어떤 저장소를 쓸지 계산합니다.

## 패치 세트

SSH 서버는 upstream Dropbear 그대로이며, 우리의 변경은 검토 가능한 몇 개의 패치뿐입니다([patches/README.md](../../patches/README.md) 참고):

- 중립적이고 런타임에 설정 가능한 신원 배너;
- 환경 변수로 설정한 경로에서 읽는 `authorized_keys`(그래서 키가 시크릿 저장소에 있게 됨);
- Android에 없는 시스템 `crypt()`/shadow 대신 PBKDF2 해시 파일에 대해 수행하는 비밀번호 인증([BUILDING.md](../BUILDING.md) 참고).

## WebUI

매니저 WebUI(KernelSU / APatch / WebUI-X) 안의 정적 페이지입니다. `ksu.exec` 브리지를 통해 `module/common/vddb-webui.sh` 를 구동합니다: 상태, start/stop/restart, 설정 읽기/쓰기, 키와 비밀번호 계정 관리. 모든 데이터는 base64로 인코딩되어 브리지를 건너므로 셸이 그것을 해석하지 않습니다; 비밀번호 해시는 브라우저에서 WebCrypto로 계산되므로 평문 비밀번호가 페이지를 떠나지 않습니다.
