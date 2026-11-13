<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · Tiếng Việt · [中文](../zh/USER-GUIDE.md)

---

# Hướng dẫn người dùng

VD Dropbear mang lại cho thiết bị đã root của bạn một máy chủ SSH riêng tư. Hướng dẫn này đưa bạn từ cài
đặt đến một kết nối hoạt động, bao gồm cả truyền tệp và chế độ before-first-unlock (BFU).

> **Một lần đăng nhập mặc định cho một root shell đầy đủ.** Hãy ưu tiên khóa hơn mật khẩu, chỉ bind vào
> những mạng bạn tin cậy, và không bao giờ phơi bày cổng ra Internet mở mà không có lý do.

## 1. Cài đặt

Flash tệp zip của mô-đun trong trình quản lý **KernelSU**, **APatch** hoặc **Magisk** (hoặc từ một shell
bằng `ksud module install` / `apd module install`), rồi mở **WebUI** của mô-đun.

## 2. Thêm một khóa (khuyến nghị)

Trong WebUI, dưới mục **Authorized keys**, dán khóa công khai của bạn (`ssh-ed25519 AAAA... you@host`)
và nhấn **Add key**. Khóa là mặc định và là cách vào an toàn nhất.

Để tạo một khóa trên máy tính của bạn, nếu bạn chưa có:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Hoặc đặt một mật khẩu

Đăng nhập bằng mật khẩu tắt theo mặc định (một lần đăng nhập mặc định là root, nên khóa được ưu tiên). Để
bật nó, hãy bật **Password login** trong thiết lập, rồi dưới mục **Password accounts** đặt một mật khẩu
cho người dùng đăng nhập. Hash được tính trong trình duyệt của bạn bằng PBKDF2; bản thân mật khẩu không
bao giờ rời khỏi trang.

## 4. Chọn một cổng và nơi lắng nghe

Dưới mục **Settings**, đặt **Port** và chọn các bind. Theo mặc định VD Dropbear chỉ lắng nghe trên
**loopback**; để truy cập nó từ LAN hoặc một VPN của bạn, hãy bật các giao diện bạn muốn. Tránh
**Listen on all interfaces** trừ khi bạn hiểu mức độ phơi bày.

Nhấn **Save & restart** để áp dụng, rồi **Start** nếu nó chưa chạy.

## 5. Kết nối

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` và `rsync` được đóng gói kèm theo, nên SFTP, `sshfs`, các client GUI và sao lưu
đều hoạt động qua cùng một kết nối.

## 6. Before first unlock (BFU)

Theo mặc định, daemon chỉ khởi động **sau** khi bạn mở khóa thiết bị một lần (AFU), vì các secret của
nó nằm trên kho credential-encrypted. Nếu bạn cần SSH **trước** lần mở khóa đầu tiên (ví dụ để mở khóa
một thiết bị từ xa sau khi khởi động lại) hãy bật **Start before first unlock (BFU)**. Các secret khi
đó chuyển sang kho device-encrypted, vốn đọc được trước khi mở khóa: một sự đánh đổi có chủ đích, có tài
liệu. Xem [Mô hình bảo mật](#) trong README.

## 7. Điều khiển daemon

- **WebUI:** Start / Stop / Restart, và trạng thái trực tiếp (đang chạy, PID, cổng, chế độ, dấu vân tay
  của host key).
- **Nút Action của trình quản lý:** (tái) khởi chạy daemon.
- Nó cũng tự động khởi động khi boot (trừ khi bạn vô hiệu hóa nó).

## Xử lý sự cố

- **Nó không khởi động.** Kiểm tra `/data/adb/vddropbear/state/daemon.log`. Hãy chắc chắn **Enabled**
  đang bật và một host key có thể được tạo.
- **Khóa bị từ chối.** Xác nhận dòng khóa công khai đúng y như client của bạn cung cấp, và rằng tên người dùng bạn
  đăng nhập là một cái tên mà hệ thống phân giải được (thường là `root`).
- **Không thể kết nối từ máy khác.** Có lẽ bạn vẫn chỉ đang bind vào loopback. Hãy bật giao diện bạn
  cần và khởi động lại.
- **SFTP/scp thất bại nhưng shell hoạt động.** Hãy chắc chắn `sftp-server` đóng gói kèm theo đã được
  phát hành cho ABI của bạn; trạng thái WebUI hiển thị ABI được phát hiện.
