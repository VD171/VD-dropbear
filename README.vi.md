<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.

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

<p align="center">
  <img src="module/webroot/assets/logo-wordmark.svg" alt="VD Dropbear" width="540">
</p>

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-1a7f37" alt="License"></a>
  <img src="https://img.shields.io/badge/KernelSU-%E2%9C%94-635bff" alt="KernelSU">
  <img src="https://img.shields.io/badge/APatch-%E2%9C%94-ff7043" alt="APatch">
  <img src="https://img.shields.io/badge/Magisk-%E2%9C%94-00af9c" alt="Magisk">
  <a href="https://github.com/VD171/VD-dropbear/stargazers"><img src="https://img.shields.io/github/stars/VD171/VD-dropbear?color=d29922" alt="Stars"></a>
  <a href="https://github.com/VD171/VD-dropbear/releases"><img src="https://img.shields.io/github/v/release/VD171/VD-dropbear?color=1a7f37" alt="Release"></a>
</p>

**Một máy chủ SSH [Dropbear](https://matt.ucc.asn.au/dropbear/) độc lập, có thể cấu hình hoàn toàn**,
được đóng gói thành một mô-đun KernelSU / APatch / Magisk. Nó tự khởi chạy và không phụ thuộc vào bất kỳ mô-đun nào khác.

> ⚠️ **Mọi kết nối được xác thực đều nhận được một shell ROOT.** Hãy coi nó như chìa khóa của thiết bị:
> ưu tiên dùng khóa công khai thay vì mật khẩu, và giữ cổng tránh xa Internet công cộng.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Tại sao

Cách tích hợp sẵn của Android để có được một shell trên chính điện thoại của bạn là ADB (gỡ lỗi
USB), và việc bật nó lên vừa xâm phạm vừa tự phơi bày bản thân. `adb_enabled` và
`development_settings_enabled` là những cài đặt mà ai cũng đọc được: bất kỳ ứng dụng, SDK hay thư
viện chống gian lận / RASP nào cũng đọc được chúng, kết nối thì bị ghi log, và không có cách nào được
hỗ trợ để che giấu việc ADB đang bật, hoặc từng được bật. Sự phơi bày này bám theo bạn ngay cả trên
một chiếc điện thoại nguyên gốc, chưa root: để có một shell, bạn buộc phải tuyên bố điều đó.

VD Dropbear là lựa chọn riêng tư. Trên một thiết bị đã root, nó cho bạn một máy chủ SSH thực thụ:
shell root, SFTP và rsync qua mạng, không có dấu vết `adb_enabled`, không có cờ gỡ lỗi USB, một
banner phiên bản chẳng để lộ gì, và thông tin đăng nhập do bạn kiểm soát. Quyền truy cập của bạn vẫn
là của bạn, thay vì một lá cờ "tôi đang bị gỡ lỗi" mà bất cứ thứ gì trên thiết bị cũng đọc được.

## Tính năng

- **Luôn chỉ một daemon.** Nó khởi động lúc boot và từ nút **Action** của trình quản lý, và bạn có
  thể **khởi động / dừng / khởi động lại** nó từ WebUI bất cứ lúc nào; không bao giờ có quá một thể hiện.
- **Mọi thứ đều có thể cấu hình** từ WebUI (hoặc `/data/adb/vddropbear/config`):
  - cổng, và gắn vào loopback / tất cả / IPv4 / IPv6 / các địa chỉ cụ thể
  - **khởi động trước lần mở khóa đầu tiên (BFU) hoặc chỉ sau đó (AFU)**, chỉ một công tắc
  - xác thực bằng khóa công khai và/hoặc mật khẩu, số lần thử xác thực tối đa
  - người dùng đăng nhập, shell, `HOME`, biến môi trường bổ sung
  - thời gian chờ khi nhàn rỗi, keepalive, cửa sổ nhận
  - chuyển tiếp cổng cục bộ / từ xa và cổng gateway (tất cả đều **tắt** theo mặc định)
  - loại khóa máy chủ (ed25519 / rsa / ecdsa)
- **Banner phiên bản được ẩn.** Giao thức SSH yêu cầu phải có *một* banner, nên không thể bỏ đi,
  nhưng VD Dropbear thay nó bằng một banner vô thưởng vô phạt để các trình quét không thể nhận diện
  chính xác máy chủ hay phiên bản mà nhắm các đòn tấn công theo phiên bản đã biết vào nó.
- **Bí mật được lưu trữ một cách hợp lý** (xem [Mô hình bảo mật](#security-model)).
- **Mang theo thông tin đăng nhập của riêng bạn.** Thêm các bộ `user + key` và `user + password`;
  WebUI buộc mật khẩu đạt độ mạnh tối thiểu và không bao giờ lưu mật khẩu ở dạng văn bản thuần.
- **Tích hợp sẵn truyền và đồng bộ tệp.** Gói đi kèm `sftp-server`, `scp` và `rsync`, nên SFTP,
  sshfs, các trình khách giao diện đồ họa và sao lưu đều hoạt động qua cùng một kết nối.
- **Mọi thiết bị và trình giả lập.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## Tác nhân AI trên thiết bị của bạn

Một điểm cuối SSH luôn thường trực biến điện thoại của bạn thành thứ mà **một tác nhân AI tự động có
thể vận hành trực tiếp**. Bất kỳ tác nhân nào có thể điều khiển một shell hay một kết nối SSH
(Claude Code, aider, một script có LLM trong vòng lặp, hệ thống tự động hóa của riêng bạn) đều có được
một phiên root thực sự trên thiết bị, qua mạng, không cần dây USB và không có cờ gỡ lỗi tự phơi bày
nào của ADB. Tác nhân thấy một shell kiểu Linux bình thường và có thể:

- đọc và chỉnh sửa tệp, thay đổi cài đặt, và quản lý mô-đun, gói và dịch vụ;
- sàng lọc log, kéo về các artifact, và chạy chẩn đoán hoặc pháp y số theo yêu cầu;
- di chuyển và đồng bộ tệp theo cả hai chiều qua `scp` / `sftp` / `rsync`, để sao lưu, di chuyển hoặc thiết lập ban đầu;
- điều khiển cả một đội thiết bị đã root từ một nơi duy nhất, mỗi thiết bị truy cập được bằng khóa riêng của nó.

Vì dự án được xây dựng để **thân thiện với AI** (một tệp cấu hình có tài liệu, một
[hợp đồng biến môi trường](patches/README.md) lúc chạy rõ ràng, các đường dẫn dễ đoán và trạng thái
dạng văn bản thuần), một tác nhân có thể tự khám phá cách dùng mà không cần đoán mò.

> **Đây là root, nên hãy đối xử với nó như root.** Mọi kết nối đã xác thực đều vào với quyền root
> (xem cảnh báo bên dưới). Khi trao quyền truy cập cho một tác nhân, hãy cấp cho nó một **người dùng
> và khóa riêng**, giới hạn các ràng buộc vào những mạng bạn tin tưởng (loopback hoặc một VPN thay vì
> internet mở), giữ xác thực bằng mật khẩu ở trạng thái tắt, và nhớ rằng bạn có thể thu hồi một khóa
> hoặc dừng daemon bất cứ lúc nào từ WebUI.

## Cài đặt

Flash tệp zip của mô-đun trong trình quản lý KernelSU, APatch hoặc Magisk (hoặc từ dòng lệnh với
`ksud module install` / `apd module install`), mở **WebUI** của mô-đun để đặt cổng và thêm khóa của
bạn, rồi khởi động lại (hoặc nhấn **Action** để chạy nó ngay bây giờ).

## Mô hình bảo mật

### Bí mật nằm ở đâu: BFU so với AFU

`/data/adb` là bộ nhớ **mã hóa theo thiết bị (DE)**: nó được giải mã *trước khi* người dùng mở khóa
điện thoại (Before First Unlock), nên mọi thứ ở đó đều đọc được trước khi mở khóa. `/data/misc_ce` là
**mã hóa theo thông tin đăng nhập (CE)**: Android giữ nó ở dạng mã hóa cho đến khi người dùng mở khóa
(After First Unlock).

- **Chế độ AFU (mặc định, `START_IN_BFU=0`):** daemon chờ mở khóa rồi đọc khóa máy chủ,
  `authorized_keys` và các hash mật khẩu từ bộ nhớ CE. Bảo vệ tối đa; SSH chỉ hoạt động sau khi thiết
  bị đã được mở khóa ít nhất một lần kể từ lúc boot.
- **Chế độ BFU (`START_IN_BFU=1`):** daemon khởi động trước khi mở khóa để bạn có thể SSH vào sớm (ví
  dụ, để mở khóa thiết bị từ xa). Khi đó các bí mật của nó nằm trên bộ nhớ DE và đọc được trước khi mở
  khóa, một sự đánh đổi có chủ đích và được ghi chép rõ. Chỉ bật nó nếu bạn cần SSH trước khi mở khóa.

Chúng tôi cố ý **không** thêm lớp mã hóa riêng lên trên CE: nó đã được mã hóa bằng thông tin đăng
nhập của người dùng, và việc chồng thêm một lớp mã hóa nữa sẽ cần một khóa phải nằm ở đâu đó (trên DE
thì nó bị phơi bày; còn dẫn xuất từ thông tin đăng nhập của người dùng thì chỉ là triển khai lại CE).
Điều đó chỉ mang lại cảm giác an toàn giả tạo, chứ không phải sự bảo vệ thực sự.

### Mật khẩu

Đăng nhập bằng mật khẩu **tắt theo mặc định**, bởi mọi lần đăng nhập đều là root và khóa thì an toàn
hơn nhiều. Khi bạn thực sự đặt một mật khẩu, WebUI buộc nó đạt độ mạnh tối thiểu và chỉ lưu một hash,
không bao giờ lưu văn bản thuần.

## Build

Tệp nhị phân của máy chủ được CI build từ **upstream [mkj/dropbear](https://github.com/mkj/dropbear)**
với một bộ patch nhỏ, có thể kiểm tra được (xem [`patches/`](patches/)): một chuỗi định danh
trung lập/có thể cấu hình, các đường dẫn do cấu hình điều khiển cho `authorized_keys` và tệp mật khẩu,
cùng bản sửa `openpty` của Android cho các PTY tương tác. Một workflow theo lịch sẽ theo dõi upstream
và build lại, nhờ đó mô-đun luôn được cập nhật. Xem [`.github/workflows/`](.github/workflows/) và
[`CONTRIBUTING.md`](CONTRIBUTING.md).

## Tài liệu

<!-- vd-docs -->
Tài liệu đầy đủ nằm trong [wiki](https://github.com/VD171/VD-dropbear/wiki) và trong thư mục
[`docs/`](docs/).
<!-- /vd-docs -->

## Xem thêm

Các dự án cùng tác giả:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: một trình gỡ lỗi phương thức thiết bị, đọc từng mục qua mọi phương thức có thể đọc nó và so sánh chúng cạnh nhau.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: các dịch vụ Google của bạn (RCS, Wallet, các chứng thực Play Integrity), đọc ngay trên thiết bị mà không cần internet.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: sao lưu và khôi phục toàn bộ ứng dụng và dữ liệu với quyền root, điều khiển hoàn toàn từ một WebUI.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: một công cụ giả mạo dấu vân tay thiết bị và build toàn cục.

## Liên hệ

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Kênh:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **Chủ đề XDA:** _(chỗ giữ sẵn, sẽ thêm ở bản phát hành công khai đầu tiên)_
* **GitHub:** @VD171 https://github.com/VD171

## Giấy phép

Mã của riêng VD Dropbear theo **Apache-2.0**; xem [LICENSE](LICENSE). Mô-đun cũng đóng gói các tệp
nhị phân của bên thứ ba: [Dropbear](https://matt.ucc.asn.au/dropbear/) (kiểu MIT), `sftp-server` và
`scp` của OpenSSH (BSD), và `rsync` (GPL-3.0), mỗi thứ theo giấy phép riêng của nó; xem
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), bao gồm cả cách chúng tôi tuân thủ GPL cho rsync. Mã
Apache-2.0 của chúng tôi không bị ảnh hưởng (tệp nhị phân GPL chỉ được gộp chung, chứ không liên kết).

## Nhãn hiệu

VD Dropbear là một dự án độc lập, không chính thức, không liên kết với hay được chứng thực bởi bất kỳ
bên thứ ba nào. "Android" là nhãn hiệu của Google LLC; "SSH" là nhãn hiệu đã đăng ký của SSH
Communications Security. VD Dropbear chạy hoàn toàn trên thiết bị của bạn.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
