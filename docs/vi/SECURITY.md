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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · Tiếng Việt · [中文](../zh/SECURITY.md)

---

# Chính sách bảo mật

## Điều duy nhất cần hiểu

VD Dropbear khởi động một máy chủ SSH, và **mọi kết nối xác thực thành công đều nhận được một root
shell**. Do đó, sự an toàn của thiết bị bạn ngang bằng với sự an toàn của cấu hình và thông tin xác
thực của máy chủ này. Vui lòng:

- **Ưu tiên khóa công khai hơn mật khẩu.** Đăng nhập bằng mật khẩu tắt theo mặc định.
- Nếu bạn buộc phải dùng mật khẩu, hãy dùng một mật khẩu mạnh - WebUI áp mức tối thiểu và chỉ lưu một
  hash.
- **Đừng phơi bày cổng ra Internet công cộng.** Bind vào loopback hoặc một LAN tin cậy, hoặc truy cập
  nó qua một VPN / đường hầm.
- Hiểu **sự đánh đổi BFU**: bật khởi động trước khi mở khóa đặt host key và thông tin xác thực lên kho
  device-encrypted, đọc được trước khi thiết bị được mở khóa. Hãy để nó tắt trừ khi bạn cần SSH trước
  khi mở khóa.
- Giữ chuyển tiếp tắt trừ khi bạn cần nó (nó tắt theo mặc định).

## VD Dropbear làm gì để hỗ trợ

- Một banner phiên bản trung tính, không cung cấp thông tin, để các trình quét mạng không thể lập dấu
  vân tay chính xác máy chủ và phiên bản.
- Thông tin xác thực nằm trên kho credential-encrypted theo mặc định (chỉ được giải mã sau khi bạn mở
  khóa).
- Không có telemetry, không có lời gọi mạng của riêng nó, không có phân tích. Nó chạy hoàn toàn trên
  thiết bị của bạn.

## Các phiên bản được hỗ trợ

Các bản sửa bảo mật đến với bản phát hành mới nhất. Tệp nhị phân máy chủ bám theo Dropbear upstream; các
bản phát hành bảo mật upstream được build lại và phát hành ngay khi CI nhận được chúng.

## Báo cáo một lỗ hổng

Vui lòng báo cáo các vấn đề bảo mật một cách riêng tư, không trong một issue công khai:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Hãy bao gồm phiên bản, một mô tả, và (lý tưởng là) cách tái hiện. Bạn sẽ nhận được một xác nhận, và
chúng tôi sẽ phối hợp với bạn về bản sửa và mốc thời gian công bố. Với các lỗ hổng trong chính Dropbear,
vui lòng cũng báo cáo lên upstream tại <https://matt.ucc.asn.au/dropbear/>.
