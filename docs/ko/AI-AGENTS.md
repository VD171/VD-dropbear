<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · 한국어 · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# 기기 위의 AI 에이전트

상시 동작하는 SSH 엔드포인트는 여러분의 휴대폰을 **자율 AI 에이전트가 직접 조작할 수 있는** 대상으로 바꿉니다. 셸이나 SSH 연결을 다룰 수 있는 에이전트라면 - Claude Code, aider, LLM을 반복 호출하는 스크립트, 여러분 자신의 자동화 등 - USB 테더링도, ADB처럼 스스로를 드러내는 디버그 플래그도 없이, 네트워크를 통해 기기에서 진짜 root 세션을 얻습니다.

이 페이지는 README에서 소개한 개념을 더 깊이 설명합니다.

## 에이전트에게 ADB가 아니라 SSH를 쓰는 이유

ADB는 스스로를 드러냅니다. `adb_enabled` 와 `development_settings_enabled` 는 누구나 읽을 수 있고, 연결은 로그에 남으며, 디버깅이 켜져 있다(또는 켜져 있었다)는 사실을 숨기는 공식적인 방법은 없습니다. ADB로 작업하는 에이전트는 어떤 앱이나 사기 방지 SDK도 읽을 수 있는 그 흔적을 기기에 남깁니다. VD Dropbear는 그 비공개 대안입니다 - 평범한 SSH 로그인이며, 자격 증명은 여러분이 관리하고, 배너는 아무것도 드러내지 않습니다.

## 에이전트가 할 수 있는 것

하나의 연결을 통해 에이전트는 평범한 Linux 계열 셸을 보고 다음을 할 수 있습니다:

- 파일을 읽고 편집하며, 설정을 바꾸고, 모듈과 패키지와 서비스를 관리;
- 로그를 분류하고, 산출물을 가져오며, 필요에 따라 진단이나 포렌식을 실행;
- `scp` / `sftp` / `rsync` 로 양방향 파일 이동과 동기화 - 백업, 마이그레이션, 프로비저닝;
- 각각 고유한 키로 접근할 수 있는, root 기기 무리 전체를 한곳에서 운용.

이 프로젝트는 **AI 친화적** 으로 만들어졌기 때문에 - 문서화된 설정 파일, 명시적인 런타임 [env contract](../../patches/README.md), 예측 가능한 경로, 평문 상태 - 에이전트는 추측 없이 사용법을 파악할 수 있습니다.

## 안전하게 하기

이것은 root이므로 root처럼 다루십시오:

- 에이전트에게는 개인용이 아니라 **전용 사용자와 키** 를 주십시오;
- 바인드는 신뢰하는 네트워크로 한정하십시오 - 개방된 인터넷이 아니라 루프백이나 VPN([Configuration](CONFIGURATION.md) 참고);
- 비밀번호 인증은 꺼 두십시오; 키는 폐기할 수 있고 입력할 일도 없습니다;
- WebUI에서 언제든 키를 폐기하거나 데몬을 멈출 수 있습니다;
- 모든 연결이 완전한 root 세션임을 기억하십시오 - 에이전트에게는 필요한 범위만 주십시오.

## 최소 설정

1. 에이전트 전용 키 쌍을 생성합니다.
2. WebUI에서 그 공개 키를 추가합니다(**Authorized keys**).
3. 기본이 아닌 포트에서 루프백 또는 VPN에만 바인드합니다.
4. 에이전트의 SSH 설정을 기기로 향하게 하고 작업하도록 둡니다.
