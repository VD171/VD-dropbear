<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · Tiếng Việt · [中文](../zh/ARCHITECTURE.md)

---

# Kiến trúc

VD Dropbear là một mô-đun KernelSU / APatch / Magisk chạy đúng một daemon SSH Dropbear, được điều khiển
hoàn toàn bằng cấu hình. Không có gì về máy chủ SSH được mã hóa cứng cho một thiết bị duy nhất; mọi thứ
riêng biệt đều là cấu hình thời gian chạy hoặc một secret.

## Các thành phần

- `module/common/vddropbear.sh` - thư viện lõi: tải cấu hình (với các giá trị mặc định tích hợp an
  toàn), xác định kho secret, bảo đảm có host key, dựng vector đối số của Dropbear, và quản lý một thực
  thể daemon duy nhất (start / stop / status / restart).
- `module/service.sh` - điểm vào khi khởi động. Tuân theo chính sách khởi động BFU/AFU; ở chế độ AFU nó
  chờ kho credential-encrypted được mở khóa mà không làm nghẽn quá trình khởi động.
- `module/action.sh` - nút **Action** của trình quản lý: (tái) khởi chạy daemon. Nó không bao giờ đọc
  stdin và tách daemon ra phiên riêng của nó, nên trình quản lý không bị treo.
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - backend và trang của WebUI.
- `patches/` - các bản vá nhỏ, có thể kiểm tra, được áp dụng lên Dropbear upstream khi build.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - quá trình build.

## Vòng đời của daemon (một thực thể duy nhất)

`vddb_start` tải cấu hình, dừng mọi thực thể đang chạy, bảo đảm host key tồn tại, rồi sinh ra một
daemon. Tệp nhị phân được phát hành dưới tên `vddropbear`, nên tên tiến trình của nó khớp chính xác với
`pgrep -x` (Android `mksh` không có `exec -a`). Nó được khởi chạy bằng `setsid` để tách khỏi nhóm tiến
trình của bên gọi - đó là điều giữ cho nút Action của trình quản lý không bị chặn.

## Kho secret (CE so với DE, BFU so với AFU)

Các thiết lập không phải là secret và nằm trên kho device-encrypted (`/data/adb/vddropbear`), đọc được
khi khởi động. Các secret - host key, `authorized_keys`, các hash mật khẩu - mặc định nằm trên kho
**credential-encrypted** (`/data/misc_ce/0/vddropbear`), chỉ mở khóa sau khi người dùng xác thực. Bật
`START_IN_BFU` chuyển các secret sang kho device-encrypted để daemon có thể chạy trước lần mở khóa đầu
tiên, với cái giá là các secret đó đọc được sớm hơn. Mô-đun tính toán kho nào sẽ dùng ở mỗi giai đoạn
khởi động.

## Bộ bản vá

Máy chủ SSH vẫn là Dropbear upstream; các thay đổi của chúng tôi là vài bản vá có thể xem xét (xem
[patches/README.md](../../patches/README.md)):

- một banner nhận dạng trung tính, cấu hình được ở thời gian chạy;
- `authorized_keys` được đọc từ một đường dẫn đặt qua biến môi trường (nên khóa nằm trong kho secret);
- xác thực mật khẩu dựa trên một tệp hash PBKDF2 thay vì `crypt()`/shadow của hệ thống, thứ mà Android
  không có (xem [BUILDING.md](../BUILDING.md)).

## WebUI

Một trang tĩnh trong WebUI của trình quản lý (KernelSU / APatch / WebUI-X). Nó điều khiển
`module/common/vddb-webui.sh` qua cầu nối `ksu.exec`: trạng thái, start/stop/restart, đọc/ghi cấu hình,
và quản lý khóa cùng các tài khoản mật khẩu. Mọi dữ liệu đi qua cầu nối đều được mã hóa base64, nên
shell không bao giờ diễn giải nó; các hash mật khẩu được tính trong trình duyệt bằng WebCrypto, nên mật
khẩu dạng văn bản rõ không bao giờ rời khỏi trang.
