<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   User guide.

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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · 한국어 · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# 사용자 가이드

VD Dropbear는 root 기기에 비공개 SSH 서버를 제공합니다. 이 가이드는 설치부터, 파일 전송과 첫 잠금 해제 전(BFU) 모드를 포함해, 동작하는 연결까지 안내합니다.

> **인증된 모든 연결은 root 셸을 얻습니다.** 비밀번호보다 키를 우선하고, 신뢰하는 네트워크에만 바인드하며, 이유 없이 포트를 개방된 인터넷에 노출하지 마십시오.

## 1. 설치

**KernelSU**, **APatch** 또는 **Magisk** 매니저에서 모듈 zip을 플래시하고(또는 셸에서 `ksud module install` / `apd module install` 로), 이어서 모듈의 **WebUI** 를 엽니다.

## 2. 키 추가(권장)

WebUI의 **Authorized keys** 에서 공개 키(`ssh-ed25519 AAAA... you@host`)를 붙여넣고 **Add key** 를 누릅니다. 키가 기본이자 가장 안전한 진입 방법입니다.

아직 키가 없다면, 컴퓨터에서 키를 생성하려면:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. 또는 비밀번호 설정

비밀번호 로그인은 기본적으로 꺼져 있습니다(모든 로그인이 root이므로 키가 권장됩니다). 켜려면 설정에서 **Password login** 을 켜고, 이어서 **Password accounts** 에서 로그인 사용자의 비밀번호를 설정합니다. 해시는 브라우저에서 PBKDF2로 계산되며, 비밀번호 자체는 페이지를 떠나지 않습니다.

## 4. 포트와 수신 위치 선택

**Settings** 에서 **Port** 를 설정하고 바인드를 선택합니다. 기본적으로 VD Dropbear는 **loopback** 에서만 수신합니다; LAN이나 VPN에서 접근하려면 원하는 인터페이스를 켜십시오. 노출을 이해하지 못한다면 **Listen on all interfaces** 는 피하십시오.

적용하려면 **Save & restart** 를 누르고, 아직 실행 중이 아니면 **Start** 를 누르십시오.

## 5. 연결

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp`, `rsync` 가 함께 제공되므로 SFTP, `sshfs`, GUI 클라이언트, 백업이 모두 같은 연결로 동작합니다.

## 6. 첫 잠금 해제 전(BFU)

기본적으로 데몬은 기기를 한 번 잠금 해제한 **뒤**(AFU)에만 시작합니다. 시크릿이 자격 증명 암호화 저장소에 있기 때문입니다. 첫 잠금 해제 **전** 에 SSH가 필요하다면 - 예를 들어 재부팅 후 기기를 원격으로 잠금 해제하기 위해 - **Start before first unlock (BFU)** 를 켜십시오. 그러면 시크릿이 기기 암호화 저장소로 옮겨져 잠금 해제 전에 읽을 수 있게 됩니다: 의도적이고 문서화된 트레이드오프입니다. README의 [Security model](#) 을 참고하십시오.

## 7. 데몬 제어

- **WebUI:** Start / Stop / Restart, 그리고 실시간 상태(실행 여부, PID, 포트, 모드, 호스트 키 지문).
- **매니저 Action 버튼:** 데몬을 (재)실행합니다.
- 부팅 시 자동으로도 시작됩니다(비활성화하지 않는 한).

## 문제 해결

- **시작되지 않음.** `/data/adb/vddropbear/state/daemon.log` 를 확인하십시오. **Enabled** 가 켜져 있고 호스트 키가 생성될 수 있었는지 확인하십시오.
- **키 거부됨.** 공개 키 줄이 클라이언트가 제시하는 것과 정확히 같은지, 그리고 로그인 사용자가 시스템이 해석하는 것(보통 `root`)인지 확인하십시오.
- **다른 기기에서 연결할 수 없음.** 아마 아직 루프백에만 바인드되어 있을 것입니다 - 필요한 인터페이스를 켜고 재시작하십시오.
- **SFTP/scp는 실패하지만 셸은 동작함.** 함께 제공되는 `sftp-server` 가 여러분의 ABI용으로 배포되었는지 확인하십시오; WebUI 상태에 감지된 ABI가 표시됩니다.
