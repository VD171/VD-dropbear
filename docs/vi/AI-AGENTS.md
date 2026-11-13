<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · Tiếng Việt · [中文](../zh/AI-AGENTS.md)

---

# Các tác nhân AI trên thiết bị của bạn

Một điểm cuối SSH thường trực biến điện thoại của bạn thành thứ mà **một tác nhân AI tự động có thể vận
hành trực tiếp**. Bất kỳ tác nhân nào có thể điều khiển một shell hoặc một kết nối SSH (Claude Code,
aider, một script có LLM trong vòng lặp, quy trình tự động của riêng bạn) đều có được một phiên root
thực sự trên thiết bị, qua mạng, không cần cáp USB và không có cờ gỡ lỗi tự phơi bày nào của ADB.

Trang này mở rộng ý tưởng đã được giới thiệu trong README.

## Vì sao dùng SSH chứ không phải ADB cho các tác nhân

ADB tự thông báo về mình: `adb_enabled` và `development_settings_enabled` ai cũng đọc được, kết nối
được ghi nhật ký, và không có cách nào được hỗ trợ để che giấu việc gỡ lỗi đang (hoặc đã) được bật. Một
tác nhân làm việc qua ADB để lại dấu vết đó trên thiết bị cho bất kỳ ứng dụng hoặc SDK chống gian lận
nào đọc được. VD Dropbear là lựa chọn riêng tư thay thế: một lần đăng nhập SSH bình thường, với thông
tin xác thực do bạn kiểm soát và một banner không tiết lộ điều gì.

## Những gì một tác nhân có thể làm

Qua một kết nối, tác nhân thấy một shell kiểu Linux bình thường và có thể:

- đọc và sửa tệp, thay đổi thiết lập, và quản lý mô-đun, gói và dịch vụ;
- phân loại nhật ký, kéo về các artifact, và chạy chẩn đoán hoặc điều tra pháp y theo nhu cầu;
- di chuyển và đồng bộ tệp theo cả hai chiều qua `scp` / `sftp` / `rsync`: sao lưu, di trú, cấp phát;
- điều khiển cả một đội thiết bị đã root từ một nơi, mỗi thiết bị truy cập được bằng khóa riêng của nó.

Vì dự án được xây dựng để **thân thiện với AI** (một tệp cấu hình có tài liệu, một
[hợp đồng env](../../patches/README.md) thời gian chạy rõ ràng, các đường dẫn có thể đoán trước và
trạng thái ở dạng văn bản thuần) một tác nhân có thể tự tìm ra cách dùng nó mà không cần phỏng đoán.

## Làm điều đó một cách an toàn

Đây là root, nên hãy đối xử với nó như root:

- cấp cho tác nhân **thông tin xác thực riêng** của nó, không phải của cá nhân bạn, và trỏ nó tới một tài khoản có đặc quyền thấp hơn (`shell`) nếu bạn muốn giới hạn tầm với của nó;
- giới hạn các bind vào những mạng bạn tin cậy: loopback hoặc một VPN thay vì Internet mở
  (xem [Cấu hình](CONFIGURATION.md));
- giữ xác thực bằng mật khẩu tắt; một khóa có thể thu hồi và không bao giờ phải gõ ra;
- bạn có thể thu hồi một khóa hoặc dừng daemon bất cứ lúc nào từ WebUI;
- hãy nhớ một kết nối mặc định là một phiên root đầy đủ. Chỉ trao cho tác nhân phạm vi mà nó cần.

## Một thiết lập tối thiểu

1. Tạo một cặp khóa chỉ dành cho tác nhân.
2. Thêm khóa công khai của nó trong WebUI (**Authorized keys**).
3. Chỉ bind vào loopback hoặc VPN của bạn, trên một cổng không mặc định.
4. Trỏ cấu hình SSH của tác nhân vào thiết bị và để nó làm việc.
