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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · 日本語 · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# セキュリティポリシー

## 理解すべき唯一のこと

VD DropbearはSSHサーバーを起動し、**認証に成功したすべての接続はrootシェルを受け取ります**。したがって、あなたのデバイスのセキュリティは、このサーバーの設定と認証情報のセキュリティに等しくなります。どうか：

- **パスワードより公開鍵を優先してください。** パスワードログインは既定で無効です。
- どうしてもパスワードを使う必要があるなら、強力なものにしてください - WebUIは最小限の長さを強制し、ハッシュのみを保存します。
- **ポートを公開インターネットに露出させないでください。** ループバックや信頼できるLANにバインドするか、VPN／トンネル経由で到達してください。
- **BFUのトレードオフ** を理解してください：アンロック前の起動を有効にすると、ホスト鍵と認証情報がデバイス暗号化ストレージに置かれ、デバイスのアンロック前に読み取れるようになります。アンロック前のSSHが必要でない限り、無効のままにしてください。
- 必要でない限りフォワーディングは無効のままにしてください（既定で無効です）。

## VD Dropbearが助けになること

- 中立で情報を与えないバージョンバナーにより、ネットワークスキャナが正確なサーバーとバージョンをフィンガープリントできません。
- 認証情報は既定で認証情報暗号化ストレージに置かれます（アンロック後にのみ復号されます）。
- テレメトリなし、独自のネットワーク通信なし、アナリティクスなし。すべてあなたのデバイス上だけで動作します。

## サポートされるバージョン

セキュリティ修正は最新リリースに適用されます。サーバーバイナリはupstreamのDropbearを追跡します；upstreamのセキュリティリリースは、CIが取り込み次第、再ビルドして配布されます。

## 脆弱性の報告

セキュリティ問題は公開のissueではなく、非公開で報告してください：

- **E-mail：** vd.priv8@pm.me
- **Telegram：** [@VD_Priv8](https://t.me/VD_Priv8)

バージョン、説明、そして（できれば）再現手順を含めてください。受領の返信をお送りし、修正と公開のタイムラインをあなたと調整します。Dropbear自体の脆弱性については、<https://matt.ucc.asn.au/dropbear/> のupstreamにも報告してください。
