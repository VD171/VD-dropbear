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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../in/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · Tiếng Việt · [中文](../zh/BUILDING.md)

---

# Biên dịch VD Dropbear

VD Dropbear cung cấp **[Dropbear](https://github.com/mkj/dropbear) upstream** (tag được ghim trong
[`UPSTREAM_VERSION`](../UPSTREAM_VERSION)) cùng bộ patch nhỏ, có thể kiểm toán trong
[`patches/`](../patches/). CI biên dịch nó; bạn có thể tái tạo cục bộ.

## Bắt đầu nhanh

```sh
# một lần: một Android NDK (r27 trở lên)
export NDK=/path/to/android-ndk

# biên dịch mọi ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# hoặc chỉ một, để lặp nhanh
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` clone tag upstream được ghim, áp dụng `patches/*.patch` và `localoptions.h`, rồi biên
dịch chéo `vddropbear` và `dropbearkey` vào `module/bin/<abi>/`. Đầu ra là một ELF **động** (`file` báo
`dynamically linked, interpreter /system/bin/linker64 … for Android 24`), liên kết với libc bionic mà
mọi thiết bị Android đã có sẵn. libtomcrypt vẫn được nhúng bên trong tệp nhị phân; chỉ thư viện C là
động. Xem [Động, không phải static-PIE](#động-không-phải-static-pie).

Các tệp nhị phân **không được commit**; chúng được CI biên dịch ở mỗi tag và đính kèm vào bản phát hành.
Xem [`.gitignore`](../.gitignore).

---

## Câu chuyện crypt()/libcrypto (vì sao xác thực mật khẩu cần công sức thực sự)

Xác thực bằng mật khẩu của Dropbear được viết cho một máy chủ Unix thông thường với `crypt()` và
`/etc/shadow`. Android **không có cả hai**, và điều đó xung đột với quá trình biên dịch ở ba chỗ riêng
biệt. Phần này ghi lại từng chỗ, vì đây đúng là loại việc gây đau đớn khi phải khám phá lại. Tất cả được
xử lý bởi patch [`0003-password-file.patch`](../patches/0003-password-file.patch); không có gì bên dưới
bị phó mặc cho may rủi lúc chạy.

### 1. bionic không có `crypt()` dùng được

Thư viện C của Android (bionic) không cung cấp `crypt()`, `crypt_r()`, hay một cơ sở dữ liệu shadow. NDK
không phơi bày bất kỳ `<crypt.h>` nào. Vậy nên đường đi mật khẩu tiêu chuẩn của Dropbear, vốn gọi
`crypt(password, salt)` và so sánh với `/etc/shadow`, đơn giản là không thể biên dịch hay chạy trên
Android. Cũng không có `libcrypt` nào để liên kết, và kéo `libcrypto` của OpenSSL vào chỉ vì một hash mật
khẩu sẽ là một phụ thuộc lớn, vụng về cho một tệp nhị phân tĩnh.

**Câu trả lời của chúng tôi:** không dùng `crypt()` chút nào. Xác thực mật khẩu kiểm tra mật khẩu được
cung cấp bằng **PBKDF2-HMAC-SHA256** đối chiếu với một tệp hash (`DROPBEAR_PASSWD_FILE`), một KDF công
khai, chuẩn, có salt và lặp. Định dạng tệp được ghi lại trong [`patches/README.md`](../patches/README.md).

### 2. bộ bảo vệ thời điểm biên dịch trong `sysoptions.h`

Ngay cả trước khi bất kỳ mã nào chạy, Dropbear từ chối biên dịch:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Với `HAVE_CRYPT` không được định nghĩa (luôn luôn, trên bionic) và xác thực mật khẩu được bật, đây là một
`#error` cứng. Vì trình xác minh của chúng tôi không bao giờ gọi `crypt()`, patch `0003` **loại bỏ bộ bảo
vệ này**. (Nó giữ nguyên kiểm tra "ít nhất một phương thức xác thực phải được bật".)

### 3. cái bẫy libtomcrypt: PBKDF2 bị biên dịch *ra ngoài*

Dropbear nhúng một **libtomcrypt** đã cắt gọt, vốn *thực sự* chứa PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). Cách sửa hiển nhiên là gọi nó. Nó không hoạt động, vì hai lý do cộng dồn:

- **Nguyên mẫu bị ẩn.** `pkcs_5_alg2` chỉ được khai báo bên trong `#ifdef LTC_PKCS_5` trong
  `tomcrypt_pkcs.h`. Các tệp nguồn *của chính* Dropbear không được biên dịch với `LTC_PKCS_5` được định
  nghĩa, nên khai báo bị vô hình và trình biên dịch báo lỗi *implicit function declaration*.
- **Biểu tượng không tồn tại.** Tệ hơn, *thân* của `pkcs_5_alg2` cũng nằm sau `#ifdef LTC_PKCS_5`. Bản
  build libtomcrypt của Dropbear không định nghĩa nó, nên `pkcs_5_2.o` biên dịch thành một **đối tượng
  rỗng**: nó nằm trong `libtomcrypt.a`, nhưng không chứa biểu tượng `pkcs_5_alg2` nào. Việc liên kết thất
  bại với `undefined symbol: pkcs_5_alg2`.

Bạn có thể tự thấy điều này:

```sh
# đối tượng tồn tại nhưng rỗng (không có T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> chỉ một dấu dữ liệu, không có pkcs_5_alg2

# HMAC thì ngược lại được biên dịch đầy đủ (Dropbear dùng nó cho các MAC của SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> định nghĩa hmac_memory
```

**Câu trả lời của chúng tôi:** tự xây PBKDF2 trên các nguyên thủy mà Dropbear *thực sự* biên dịch.
`hmac_memory` và hash `sha256` đã đăng ký đều hiện diện và có thể liên kết, nên patch `0003` triển khai
PBKDF2-HMAC-SHA256 trực tiếp (RFC 2898; một khối đầu ra 32 byte duy nhất, vì `dkLen == hLen` với
SHA-256). Chúng tôi tự khai báo `hmac_memory` (cùng vấn đề nguyên mẫu bị ẩn như trên) và đối tượng được
kéo từ `libtomcrypt.a` khi liên kết. Kết quả là PBKDF2 chuẩn và do đó tương thích: hash mà WebUI tính
bằng **WebCrypto** `deriveBits` của trình duyệt giống hệt từng byte với hash mà máy chủ tính, được kiểm
chứng đối chiếu với `hashlib.pbkdf2_hmac` của Python như một triển khai thứ ba, độc lập.

> **Tóm lại:** Android không cho bạn `crypt()` nào, và PBKDF2 nhúng của Dropbear biên dịch thành số
> không. Xác thực mật khẩu ở đây là một PBKDF2-HMAC-SHA256 từ đầu trên HMAC của libtomcrypt, với bộ bảo
> vệ build crypt() đã bị gỡ. Không OpenSSL/`libcrypto`, không làm rối, không shadow hệ thống.

---

## Động, không phải static-PIE

Các tệp nhị phân là **động** (liên kết với bionic hệ thống qua `/system/bin/linker64`), không phải tĩnh.
Điều này quan trọng, và đã học được theo cách khó khăn, **trên thiết bị thật**, không phải trong CI:

- Một bản build **static-PIE** *trông* ổn (`file` báo một `static-pie executable` sạch sẽ) và liên kết
  không lỗi, nhưng **SIGSEGV ngay khoảnh khắc nó chạy trên thiết bị** (được kiểm chứng trên điện thoại
  arm64 Android 16, exit 139, không có tombstone hữu ích). Tệp thực thi tĩnh trên Android dễ vỡ; dạng
  đáng tin cậy là một tệp nhị phân động thông thường, cũng là cách mọi dropbear Android lâu đời được phân
  phối.
- Một bản build **tĩnh, non-PIE** thậm chí không khởi động: bionic từ chối nó với
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Vậy nên bản build là **động** (`make` không có `STATIC=1`; `-pie`), chỉ liên kết libc bionic, hiện diện
  trên mọi thiết bị. libtomcrypt vẫn được nhúng tĩnh vào tệp nhị phân, nên không có thư viện phụ nào để
  phân phối.

Bài học cho việc kiểm thử: **`qemu-aarch64` (qemu-user) không phải một smoke test hợp lệ** ở đây (nó cũng
segfault trên các tệp nhị phân này), và một compile+link thành công cũng không. **Chạy tệp nhị phân trên
một thiết bị Android arm64 thật.** (Điều này được xác thực chính xác theo cách này: daemon được khởi chạy trên một cổng thay thế trên thiết bị sống và một lần đăng nhập bằng
mật khẩu được xác nhận là thành công, với mật khẩu sai bị từ chối.)

## Không có cờ `-E`

Máy chủ được build với `--disable-syslog`, nên nó luôn ghi log ra stderr và tùy chọn `-E` của upstream
("log to stderr") **không tồn tại** trong tệp nhị phân này; truyền nó in ra `Invalid option -E` và daemon
không bao giờ khởi động. Vì vậy bộ dựng đối số của module không truyền `-E`.

## openpty

Các phiên PTY tương tác dùng `openpty()`. bionic khai báo nó trong `<pty.h>`, và `configure` chéo của
Dropbear phát hiện nó bằng NDK (`HAVE_OPENPTY` được đặt, `HAVE_PTY_H 1`), nên **không cần patch nào**;
PTY hoạt động ngay. (Việc dùng phi tương tác như exec, SFTP, rsync và chuyển tiếp cổng dù sao cũng không
phụ thuộc vào nó.)

## Công cụ nhúng: sftp-server, scp, rsync

`scripts/build-bundles.sh` biên dịch chéo các công cụ truyền tệp thành tệp nhị phân động vào
`module/bin/<abi>/`. CI chạy nó ngay sau `build.sh`.

- **rsync** (với popt + zlib nhúng) biên dịch sạch ngay khi bạn báo cho configure của nó rằng bionic
  không có `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** và **scp** đến từ **OpenSSH portable**, build với `--without-openssl` (crypto tích hợp
  của OpenSSH là đủ cho hai cái này), với một **zlib** tĩnh nhỏ mà script này build trước.

OpenSSH trên Android khó tính y như câu chuyện crypt() ở trên, vì `configure` của nó phát hiện sai vài
hàm libc khi biên dịch chéo. Script mã hóa bản sửa; để ghi nhận, các mảnh là:

1. **Một seed cache của các hàm mà bionic thiếu** nhưng configure tưởng là có, để thay vào đó các phiên
   bản compat được biên dịch: `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Thiếu chúng, `defines.h` của
   OpenSSH làm `#define __sentinel__` (rỗng), sau đó làm hỏng chính `__attribute__((__sentinel__(1)))`
   của bionic trong `<unistd.h>` và mọi biên dịch thất bại với `expected ')'`.
3. **Một compat `explicit_bzero` dùng `memset`.** `bzero` của bionic là một macro giống hàm (không phải
   biểu tượng thật), nên compat mặc định của OpenSSH, vốn lấy `&bzero` làm con trỏ hàm, không biên dịch
   được. bionic không có `explicit_bzero` riêng.
4. **Loại bỏ `xcrypt.o` và `getrrsetbyname.o`** khỏi thư viện compat. `xcrypt.c` gọi
   `getpwent()`/`crypt()` vô điều kiện (bionic không có cái nào), và `getrrsetbyname.c` dùng nội bộ
   resolver mà bionic không phơi bày. Cả hai đều không được `sftp-server` hay `scp` dùng.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` là hình ảnh phản chiếu của các hàm ở (1): bionic
   không *khai báo* nó ở API 24, nên OpenSSH biên dịch compat riêng, nhưng **biểu tượng** thì vẫn tồn tại
   trong `libc.a`, nên hai cái va chạm khi liên kết. Cho phép bản trùng lặp sẽ lấy của bionic, điều đó
   ổn.
6. **Bảo vệ `pw_gecos` khỏi NULL trong `pwcopy()`.** `getpwuid()` của bionic trả về `pw_gecos` bằng
   `NULL` (Android không giữ trường GECOS). `pwcopy()` của OpenSSH bảo vệ `pw_passwd` khỏi `NULL` nhưng
   không bảo vệ `pw_gecos`, nên `sftp-server` chạm tới `xstrdup(NULL)` và SIGSEGV lúc khởi động, ngay
   khoảnh khắc một phiên mở ra. (`scp` qua giao thức cũ không bao giờ gọi `pwcopy`, đó là lý do nó hoạt
   động trong khi SFTP thì không.) Bản build vá `pwcopy()` để gộp `pw_gecos` thành `""`.

Các phiên bản được ghim nằm ở đầu `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Tái tạo một ABI đơn lẻ bằng tay

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

> _Tài liệu này được tạo bằng Claude (Anthropic) và được duy trì bởi VD171. Chúng tôi hoan nghênh các chỉnh sửa và cải tiến; xem [CONTRIBUTING.md](CONTRIBUTING.md)._
