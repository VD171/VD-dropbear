<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · Tiếng Việt · [中文](../zh/CONTRIBUTING.md)

---

# Đóng góp cho VD Dropbear

Cảm ơn bạn đã quan tâm. Đây là một dự án nhỏ, nhạy cảm về bảo mật (nó trao quyền root), nên các thay
đổi được xem xét với điều đó trong đầu.

## Bố cục kho mã

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Build

Tệp nhị phân được CI tạo ra từ **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** cộng với
các bản vá trong `patches/`. Để build cục bộ bạn cần Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Bộ bản vá được giữ tối thiểu và có thể kiểm tra một cách có chủ đích: một chuỗi nhận dạng trung tính/cấu
hình được, các đường dẫn do cấu hình điều khiển cho `authorized_keys` và tệp mật khẩu, bản sửa `openpty`
cho Android, và cấu hình thời gian chạy. Vui lòng giữ các bản vá mới nhỏ, có tài liệu, và được biện giải
trong PR.

## Pull request

- Mỗi PR một thay đổi logic; mô tả động cơ và tác động bảo mật.
- Khớp với phong cách shell hiện có (POSIX `sh` / Android `mksh`; không dùng bashisms).
- Mỗi tệp mang một header SPDX ngắn. Hãy giữ nó.
- Cập nhật [`CHANGELOG.md`](../../CHANGELOG.md) dưới mục `[Unreleased]` cho bất kỳ thay đổi thực sự, hữu
  hình với người dùng nào.
- Khi gửi một PR, bạn đồng ý cấp phép đóng góp của mình theo giấy phép [Apache-2.0](../../LICENSE) của
  dự án.

## Bản dịch

README và tài liệu được duy trì bằng nhiều ngôn ngữ (`README.<lang>.md`). Tiếng Anh là nguồn chuẩn; các
bản dịch bám theo nó. Nếu bạn cải thiện một bản dịch hoặc thêm một ngôn ngữ, hãy giữ cấu trúc và các neo
mục giống hệt phiên bản tiếng Anh.

## Báo cáo lỗi và vấn đề bảo mật

Dùng các mẫu issue cho lỗi và yêu cầu tính năng. Với bất cứ điều gì có thể làm tổn hại một thiết bị, hãy
theo [`SECURITY.md`](SECURITY.md) và báo cáo riêng tư thay vì mở một issue công khai.
