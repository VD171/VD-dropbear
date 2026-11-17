<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Building the binaries, and the Android crypto/crypt() story.

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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../in/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · 한국어 · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# VD Dropbear 빌드

VD Dropbear는 **[Dropbear](https://github.com/mkj/dropbear) upstream**([`UPSTREAM_VERSION`](../UPSTREAM_VERSION)에
고정된 태그)에, [`patches/`](../patches/)에 있는 작고 감사 가능한 패치 세트를 더해 제공합니다. CI가 이를
빌드하며, 로컬에서 재현할 수 있습니다.

## 빠른 시작

```sh
# 한 번: Android NDK (r27 이상)
export NDK=/path/to/android-ndk

# 모든 ABI 빌드 (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# 또는 빠른 반복을 위해 하나만
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh`는 고정된 upstream 태그를 클론하고, `patches/*.patch`와 `localoptions.h`를 적용한 다음,
`vddropbear`와 `dropbearkey`를 `module/bin/<abi>/`로 교차 컴파일합니다. 출력은 **동적** ELF이며(`file`은
`dynamically linked, interpreter /system/bin/linker64 … for Android 24`로 보고), 모든 Android 기기가 이미
가지고 있는 bionic libc에 링크됩니다. libtomcrypt는 바이너리 안에 임베드된 채로 남고, 동적인 것은 C 라이
브러리뿐입니다. [동적, static-PIE 아님](#동적-static-pie-아님)을 참고하세요.

바이너리는 **커밋되지 않습니다**. 태그마다 CI가 빌드하여 릴리스에 첨부합니다. [`.gitignore`](../.gitignore)를
참고하세요.

---

## crypt()/libcrypto 이야기 (왜 비밀번호 인증에 진짜 작업이 필요했는가)

Dropbear의 비밀번호 인증은 `crypt()`와 `/etc/shadow`를 갖춘 일반적인 Unix 호스트용으로 작성되었습니다.
Android에는 **둘 다 없고**, 이는 빌드와 세 군데에서 충돌합니다. 이 절은 그 각각을 기록합니다. 바로 다시
발견하기 고통스러운 종류의 것이기 때문입니다. 이 모든 것은 패치
[`0003-password-file.patch`](../patches/0003-password-file.patch)가 처리하며, 아래의 어떤 것도 런타임에서
운에 맡기지 않습니다.

### 1. bionic에는 쓸 만한 `crypt()`가 없다

Android의 C 라이브러리(bionic)는 `crypt()`도, `crypt_r()`도, shadow 데이터베이스도 제공하지 않습니다. NDK는
어떤 `<crypt.h>`도 노출하지 않습니다. 따라서 `crypt(password, salt)`를 호출하고 `/etc/shadow`와 비교하는
Dropbear의 표준 비밀번호 경로는 Android에서 아예 빌드도 실행도 할 수 없습니다. 링크할 `libcrypt`도 없고,
비밀번호 해시 하나를 위해 OpenSSL의 `libcrypto`를 끌어들이는 것은 정적 바이너리에 크고 거추장스러운 의존성이
될 것입니다.

**우리의 답:** `crypt()`를 전혀 쓰지 않는 것입니다. 비밀번호 인증은 제시된 비밀번호를 해시 파일
(`DROPBEAR_PASSWD_FILE`)에 대해 **PBKDF2-HMAC-SHA256**으로 검증합니다. 이는 공개·표준·솔트·반복 KDF입니다.
파일 형식은 [`patches/README.md`](../patches/README.md)에 문서화되어 있습니다.

### 2. `sysoptions.h`의 컴파일 타임 가드

어떤 코드가 실행되기도 전에 Dropbear는 빌드를 거부합니다:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

`HAVE_CRYPT`가 정의되지 않고(bionic에서는 항상) 비밀번호 인증이 활성화되면, 이것은 강한 `#error`입니다. 우리
검증기는 `crypt()`를 결코 호출하지 않으므로, 패치 `0003`은 **이 가드를 제거합니다**. (「적어도 하나의 인증
방식이 활성화되어야 한다」는 검사는 그대로 둡니다.)

### 3. libtomcrypt의 함정: PBKDF2가 컴파일에서 *빠진다*

Dropbear는 다듬은 **libtomcrypt**를 임베드하며, 거기에는 PBKDF2가 *실제로* 들어 있습니다(`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). 당연한 수정은 그것을 호출하는 것입니다. 그것은 동작하지 않으며, 서로 겹치는
두 가지 이유 때문입니다:

- **프로토타입이 숨겨져 있다.** `pkcs_5_alg2`는 `tomcrypt_pkcs.h`의 `#ifdef LTC_PKCS_5` 안에서만 선언됩니다.
  Dropbear *자신의* 소스 파일들은 `LTC_PKCS_5`를 정의한 채 컴파일되지 않으므로 선언이 보이지 않고, 컴파일러는
  *implicit function declaration*으로 실패합니다.
- **심볼이 존재하지 않는다.** 더 나쁘게도, `pkcs_5_alg2`의 *본체* 자체도 `#ifdef LTC_PKCS_5` 뒤에 있습니다.
  Dropbear의 libtomcrypt 빌드는 그것을 정의하지 않으므로 `pkcs_5_2.o`는 **빈 오브젝트**로 컴파일됩니다.
  `libtomcrypt.a` 안에는 있지만 `pkcs_5_alg2` 심볼이 전혀 없습니다. 링크는 `undefined symbol: pkcs_5_alg2`로
  실패합니다.

직접 확인할 수 있습니다:

```sh
# 오브젝트는 존재하지만 비어 있음 (T pkcs_5_alg2 없음):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> 데이터 마커뿐, pkcs_5_alg2 없음

# 반면 HMAC은 완전히 컴파일됨 (Dropbear가 SSH의 MAC에 사용):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> hmac_memory를 정의
```

**우리의 답:** Dropbear가 *실제로* 컴파일하는 프리미티브 위에 PBKDF2를 직접 구축하는 것입니다. `hmac_memory`와
등록된 `sha256` 해시는 둘 다 존재하고 링크 가능하므로, 패치 `0003`은 PBKDF2-HMAC-SHA256을 직접 구현합니다
(RFC 2898; SHA-256에서는 `dkLen == hLen`이므로 32바이트 출력 블록 하나). `hmac_memory`를 직접 선언하고(위와
동일한 숨겨진 프로토타입 문제), 오브젝트는 링크 시 `libtomcrypt.a`에서 끌어옵니다. 결과는 표준 PBKDF2이며
따라서 상호 운용 가능합니다. WebUI가 브라우저의 **WebCrypto** `deriveBits`로 계산하는 해시는 서버가 계산하는
것과 바이트 단위로 동일하며, 세 번째 독립 구현으로 Python의 `hashlib.pbkdf2_hmac`에 대해 검증되었습니다.

> **요컨대:** Android는 `crypt()`를 전혀 주지 않고, Dropbear의 임베드된 PBKDF2는 아무것도 아닌 것으로
> 컴파일됩니다. 여기서의 비밀번호 인증은 libtomcrypt의 HMAC 위에 처음부터 만든 PBKDF2-HMAC-SHA256이며,
> crypt() 빌드 가드는 제거되었습니다. OpenSSL/`libcrypto` 없음, 난독화 없음, 시스템 shadow 없음.

---

## 동적, static-PIE 아님

바이너리는 **동적**입니다(`/system/bin/linker64`를 통해 시스템 bionic에 링크), 정적이 아닙니다. 이는 중요
하며, CI가 아니라 **실제 기기에서** 어렵게 배웠습니다:

- **static-PIE** 빌드는 *괜찮아 보이고*(`file`이 깔끔한 `static-pie executable`을 보고), 오류 없이 링크되지만,
  **기기에서 실행되는 순간 SIGSEGV합니다**(arm64 Android 16 폰에서 확인, exit 139, 유용한 tombstone 없음).
  Android의 정적 실행 파일은 깨지기 쉽고, 신뢰할 수 있는 형태는 일반 동적 바이너리이며, 이는 자리 잡은 모든
  Android용 dropbear가 배포되는 방식이기도 합니다.
- **정적, 비 PIE** 빌드는 시작조차 못 합니다. bionic이
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`로 거부합니다.
- 그래서 빌드는 **동적**입니다(`STATIC=1` 없는 `make`; `-pie`). 모든 기기에 존재하는 bionic libc만 링크합니다.
  libtomcrypt는 여전히 바이너리에 정적으로 임베드되므로 배포할 추가 라이브러리가 없습니다.

테스트를 위한 교훈: **`qemu-aarch64`(qemu-user)는 여기서 유효한 스모크 테스트가 아닙니다**(이것 역시 이
바이너리들에서 segfault합니다). 성공적인 compile+link도 마찬가지입니다. **실제 arm64 Android 기기에서
바이너리를 실행하세요.** (이것은 정확히 이렇게 검증되었습니다.
살아 있는 기기의 대체 포트에서 데몬을 실행하고 비밀번호 로그인의 성공을 확인했으며, 잘못된 비밀번호는
거부되었습니다.)

## `-E` 플래그 없음

서버는 `--disable-syslog`로 빌드되므로 항상 stderr에 로깅하고, upstream의 `-E`(「log to stderr」) 옵션은 이
바이너리에 **존재하지 않습니다**. 이를 전달하면 `Invalid option -E`가 출력되고 데몬은 결코 시작하지 않습니다.
그래서 모듈의 인자 빌더는 `-E`를 전달하지 않습니다.

## openpty

대화형 PTY 세션은 `openpty()`를 사용합니다. bionic은 이를 `<pty.h>`에서 선언하고, Dropbear의 교차
`configure`는 NDK로 이를 감지합니다(`HAVE_OPENPTY`가 설정되고 `HAVE_PTY_H 1`). 그래서 **패치가 필요 없고**,
PTY는 바로 동작합니다. (exec, SFTP, rsync, 포트 포워딩 같은 비대화형 사용은 어차피 이에 의존하지 않습니다.)

## 임베드 도구: sftp-server, scp, rsync

`scripts/build-bundles.sh`는 파일 전송 도구들을 동적 바이너리로 `module/bin/<abi>/`에 교차 컴파일합니다.
CI는 `build.sh` 직후에 이를 실행합니다.

- **rsync**(임베드된 popt + zlib 포함)는 그 configure에 bionic에 `lutimes`가 없다고 알려주면
  (`ac_cv_func_lutimes=no`) 깔끔하게 컴파일됩니다.
- **sftp-server**와 **scp**는 **OpenSSH portable** 출신이며, `--without-openssl`로 빌드되고(이 둘에는 OpenSSH
  내장 암호로 충분), 이 스크립트가 먼저 빌드하는 작은 정적 **zlib**를 동반합니다.

Android에서 OpenSSH는 위의 crypt() 이야기만큼 까다롭습니다. 교차 컴파일 시 그 `configure`가 여러 libc 함수를
잘못 감지하기 때문입니다. 스크립트가 그 수정을 인코딩합니다. 기록을 위해 그 조각들은 다음과 같습니다:

1. **bionic에 없는데 configure가 있다고 여기는 함수들의 캐시 seed**. 대신 compat 버전이 컴파일되도록 합니다:
   `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`, `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** 이것들이 없으면 OpenSSH의 `defines.h`가
   `#define __sentinel__`(빈)을 하고, 그러면 `<unistd.h>`에 있는 bionic 자신의 `__attribute__((__sentinel__(1)))`을
   망가뜨려 모든 컴파일이 `expected ')'`로 실패합니다.
3. **`memset`을 사용하는 `explicit_bzero` compat.** bionic의 `bzero`는 함수형 매크로(진짜 심볼이 아님)이므로,
   `&bzero`를 함수 포인터로 받는 OpenSSH의 기본 compat는 컴파일되지 않습니다. bionic에는 자체 `explicit_bzero`가
   없습니다.
4. **compat 라이브러리에서 `xcrypt.o`와 `getrrsetbyname.o` 제외.** `xcrypt.c`는 무조건 `getpwent()`/`crypt()`를
   호출하고(bionic에는 둘 다 없음), `getrrsetbyname.c`는 bionic이 노출하지 않는 resolver 내부를 사용합니다. 둘 다
   `sftp-server`나 `scp`가 사용하지 않습니다.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray`는 (1)의 함수들의 거울상입니다. bionic은 API 24에서 그것을
   *선언하지 않으므로* OpenSSH가 자체 compat를 컴파일하지만, **심볼**은 `libc.a`에 분명히 존재하므로 둘이 링크 시
   충돌합니다. 중복을 허용하면 bionic 것을 취하며, 그것으로 괜찮습니다.
6. **`pwcopy()`에서 `pw_gecos`를 NULL로부터 보호.** bionic의 `getpwuid()`는 `NULL`인 `pw_gecos`를 반환합니다
   (Android는 GECOS 필드를 유지하지 않음). OpenSSH의 `pwcopy()`는 `pw_passwd`를 `NULL`로부터 보호하지만 `pw_gecos`는
   보호하지 않으므로, `sftp-server`는 `xstrdup(NULL)`에 도달하여 세션이 열리는 순간 시작 시 SIGSEGV합니다.
   (`scp`는 레거시 프로토콜에서 `pwcopy`를 결코 호출하지 않아, SFTP가 안 되는 동안 그것은 동작했습니다.) 빌드는
   `pwcopy()`에 패치를 적용해 `pw_gecos`를 `""`로 합칩니다.

고정된 버전은 `scripts/build-bundles.sh` 상단에 있습니다(`ZLIB_VERSION`, `RSYNC_VERSION`, `OPENSSH_VERSION`).

## 단일 ABI를 손으로 재현하기

```sh
git clone --depth 1 --branch "$(cat UPSTREAM_VERSION)" https://github.com/mkj/dropbear /tmp/db
cp patches/localoptions.h /tmp/db/localoptions.h
for p in patches/*.patch; do patch -p1 -d /tmp/db < "$p"; done
cd /tmp/db
TC="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
./configure --host=aarch64-linux-android --disable-zlib --disable-syslog \
    CC="$TC/aarch64-linux-android24-clang"
make PROGRAMS="dropbear dropbearkey" -j"$(nproc)"
file ./dropbear   # -> dynamically linked, interpreter /system/bin/linker64, for Android 24
```

<!-- doc-footer -->

---

> _이 문서는 Claude (Anthropic)로 생성되었으며 VD171이 유지 관리합니다. 수정 및 개선을 환영합니다. [CONTRIBUTING.md](CONTRIBUTING.md)를 참조하세요._
