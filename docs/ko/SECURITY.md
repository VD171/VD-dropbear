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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · 한국어 · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# 보안 정책

## 반드시 이해해야 할 한 가지

VD Dropbear는 SSH 서버를 시작하며, **인증에 성공한 모든 연결은 root 셸을 받습니다**. 따라서 여러분 기기의 보안은 이 서버의 설정과 자격 증명의 보안과 같습니다. 부디:

- **비밀번호보다 공개 키를 우선하십시오.** 비밀번호 로그인은 기본적으로 꺼져 있습니다.
- 꼭 비밀번호를 써야 한다면 강력한 것을 쓰십시오 - WebUI는 최소 길이를 강제하고 해시만 저장합니다.
- **포트를 공개 인터넷에 노출하지 마십시오.** 루프백이나 신뢰하는 LAN에 바인드하거나, VPN/터널로 접근하십시오.
- **BFU 트레이드오프** 를 이해하십시오: 잠금 해제 전 시작을 켜면 호스트 키와 자격 증명이 기기 암호화 저장소에 놓여, 기기 잠금 해제 전에 읽을 수 있게 됩니다. 잠금 해제 전 SSH가 필요하지 않다면 꺼 두십시오.
- 필요하지 않으면 포워딩을 꺼 두십시오(기본적으로 꺼져 있습니다).

## VD Dropbear가 돕는 것

- 중립적이고 정보를 주지 않는 버전 배너로, 네트워크 스캐너가 정확한 서버와 버전을 식별할 수 없습니다.
- 자격 증명은 기본적으로 자격 증명 암호화 저장소에 둡니다(잠금을 해제한 뒤에만 복호화됨).
- 텔레메트리 없음, 자체 네트워크 통신 없음, 분석 없음. 전적으로 여러분 기기에서만 동작합니다.

## 지원되는 버전

보안 수정은 최신 릴리스에 반영됩니다. 서버 바이너리는 upstream Dropbear를 따라갑니다; upstream 보안 릴리스는 CI가 가져오는 즉시 재빌드되어 배포됩니다.

## 취약점 신고

보안 문제는 공개 issue가 아니라 비공개로 신고해 주십시오:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

버전, 설명, 그리고 (가능하면) 재현 방법을 포함해 주십시오. 접수 확인을 보내 드리고, 수정과 공개 일정을 함께 조율하겠습니다. Dropbear 자체의 취약점은 <https://matt.ucc.asn.au/dropbear/> 의 upstream에도 신고해 주십시오.
