<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · Tiếng Việt · [中文](../zh/CONFIGURATION.md)

---

# Cấu hình

Các thiết lập nằm trong `/data/adb/vddropbear/config` (được tạo mầm từ `module/common/config.default`
ở lần khởi động đầu tiên). **WebUI** chỉnh sửa tệp này giúp bạn; bạn cũng có thể chỉnh sửa nó bằng tay.
Nó được source như shell, nên hãy dùng `KEY=value` không có khoảng trắng quanh `=`. Các thiết lập không
phải là secret và nằm trên kho device-encrypted; các secret (host keys, authorized keys, các hash mật
khẩu) nằm trong kho secret, không bao giờ ở đây.

Áp dụng thay đổi bằng cách khởi động lại daemon (**Save & restart** của WebUI làm điều này).

## Chung

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | Khởi động daemon khi boot. `0` vô hiệu hóa nó hoàn toàn. |
| `START_IN_BFU` | `0` | `0`: chỉ khởi động sau lần mở khóa đầu tiên (AFU); các secret vẫn ở kho credential-encrypted (CE). `1`: cũng khởi động trước lần mở khóa đầu tiên (BFU); các secret chuyển sang kho device-encrypted (DE), đọc được trước khi mở khóa. |
| `PORT` | `2222` | Cổng lắng nghe mặc định (các cổng theo từng bind có thể ghi đè nó trong `LISTEN_ADDRESSES`). |

## Lắng nghe / bind (kết hợp được)

Cho phép bất kỳ tổ hợp nào; các bind được chọn sẽ được gộp lại. Nếu bạn xóa hết, VD Dropbear bind
loopback thay vì mọi giao diện.

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Chỉ lắng nghe trên `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Lắng nghe trên mọi giao diện (`0.0.0.0` / `::`); phơi bày thiết bị. |
| `LISTEN_IPV4` | `1` | Bao gồm các bind IPv4. |
| `LISTEN_IPV6` | `1` | Bao gồm các bind IPv6. |
| `LISTEN_ADDRESSES` | `""` | Các bind cụ thể bổ sung, phân tách bằng dấu phẩy: `addr` (dùng `PORT`) hoặc `addr:port`, IPv4 hoặc IPv6. |

## Nhận dạng

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Gửi một banner nhận dạng SSH trung tính để các trình quét không thể lập dấu vân tay chính xác máy chủ/phiên bản. |
| `IDENT_STRING` | `""` | Một chuỗi nhận dạng tùy chỉnh. Để trống thì dùng mặc định tích hợp trung tính. |

## Xác thực

Một lần đăng nhập chạy dưới tài khoản mà bạn xác thực: mặc định là **root**, hoặc một tài khoản có đặc quyền thấp hơn (`shell`, `system`). Khóa là mặc định; mật khẩu là tùy chọn bật thêm.

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Cho phép đăng nhập bằng khóa công khai (đọc các authorized keys trong kho secret). |
| `PASSWORD_AUTH` | `0` | Cho phép đăng nhập bằng mật khẩu. Khi tắt, daemon được khởi động với xác thực mật khẩu bị vô hiệu hóa. |
| `MAX_AUTH_TRIES` | `3` | Số lần thử xác thực tối đa trên mỗi kết nối. |

## Phiên / môi trường

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell cho phiên. Để trống thì dùng mặc định của tài khoản. |
| `HOME_DIR` | `""` | `HOME` cho phiên. Để trống thì dùng thư mục của mô-đun. |
| `EXTRA_ENV` | `""` | Môi trường bổ sung, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Ngắt kết nối sau N giây không hoạt động. `0` vô hiệu hóa. |
| `KEEPALIVE` | `0` | Gửi một keepalive mỗi N giây. `0` vô hiệu hóa. |
| `RECEIVE_WINDOW` | `""` | Kích thước cửa sổ nhận của Dropbear. Để trống thì dùng mặc định. |

## Chuyển tiếp (tắt theo mặc định)

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Cho phép chuyển tiếp cổng cục bộ (`-L`). |
| `ALLOW_REMOTE_FORWARD` | `0` | Cho phép chuyển tiếp cổng từ xa (`-R`). |
| `GATEWAY_PORTS` | `0` | Cho phép các cổng từ xa được chuyển tiếp bind vào mọi giao diện. |

## Host key

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Loại host key: `ed25519`, `rsa` hoặc `ecdsa`. Được tạo ở lần khởi động đầu tiên vào kho secret. |

## Kho secret

Không được cấu hình ở đây, được xác định từ `START_IN_BFU`:

- **AFU (mặc định):** `/data/misc_ce/0/vddropbear/secret`: credential-encrypted, chỉ khả dụng sau khi
  bạn mở khóa thiết bị.
- **BFU:** `/data/adb/vddropbear/secret`: device-encrypted, đọc được trước lần mở khóa đầu tiên.

Nó chứa host key, `authorized_keys`, và tệp hash `passwd`. Xem [BUILDING.md](../BUILDING.md) để biết
định dạng hash mật khẩu.
