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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · 한국어 · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# VD Dropbear에 기여하기

관심을 가져 주셔서 감사합니다. 이것은 root를 넘겨주는, 작고 보안에 민감한 프로젝트입니다. 그래서 변경은 그 점을 염두에 두고 검토됩니다.

## 저장소 구성

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## 빌드

바이너리는 **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** 에 `patches/` 의 패치를 더한 것으로부터 CI가 생성합니다. 로컬에서 빌드하려면 Android NDK가 필요합니다:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

패치 세트는 의도적으로 최소한이며 감사 가능하게 유지됩니다: 중립적/설정 가능한 신원 문자열, `authorized_keys` 와 비밀번호 파일의 설정 기반 경로, Android `openpty` 수정, 그리고 런타임 설정. 새 패치는 작게, 문서화하여, PR에서 정당화해 주십시오.

## 풀 리퀘스트

- PR 하나에 논리적 변경 하나; 동기와 보안 영향을 설명하십시오.
- 기존 셸 스타일에 맞추십시오(POSIX `sh` / Android `mksh`; bashism 금지).
- 모든 파일에 짧은 SPDX 헤더가 있습니다 - 그대로 유지하십시오.
- 실제로 사용자에게 보이는 변경은 [`CHANGELOG.md`](../../CHANGELOG.md) 의 `[Unreleased]` 아래에 갱신하십시오.
- PR을 제출함으로써, 귀하의 기여를 프로젝트의 [Apache-2.0](../../LICENSE) 라이선스로 제공하는 데 동의하게 됩니다.

## 번역

README와 문서는 여러 언어로 유지됩니다(`README.<lang>.md`). 영어가 기준이며 번역은 그것을 따릅니다. 번역을 개선하거나 언어를 추가할 때는 구조와 섹션 앵커를 영어판과 동일하게 유지하십시오.

## 버그 및 보안 문제 신고

버그와 기능 요청에는 issue 템플릿을 사용하십시오. 기기를 위험에 빠뜨릴 수 있는 것은 [`SECURITY.md`](SECURITY.md) 를 따라, 공개 issue를 여는 대신 비공개로 신고하십시오.
