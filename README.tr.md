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

**KernelSU / APatch / Magisk modülü olarak paketlenmiş, bağımsız ve tamamen yapılandırılabilir bir
[Dropbear](https://matt.ucc.asn.au/dropbear/) SSH sunucusu.** Kendi başına çalışır ve başka hiçbir modüle bağlı değildir.

> ⚠️ **Bir oturum varsayılan olarak tam bir ROOT kabuğu açar.** Buna cihazın anahtarları gibi davranın:
> parolalar yerine açık anahtarları tercih edin ve bağlantı noktasını açık İnternet'ten uzak tutun.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Neden

Android'in kendi telefonunuzda bir kabuk elde etmeye yönelik yerleşik yolu ADB'dir (USB hata
ayıklama) ve bunu açmak hem müdahaleci hem de sizi ele veren bir şeydir. `adb_enabled` ve
`development_settings_enabled`, herkesin okuyabildiği ayarlardır; herhangi bir uygulama, SDK ya da
dolandırıcılık karşıtı / RASP kütüphanesi bunları okuyabilir, bağlantı günlüğe kaydedilir ve ADB'nin
açık olduğunu ya da bir zamanlar açık olduğunu gizlemenin desteklenen bir yolu yoktur. Bu açığa çıkma,
root'suz, stok bir telefonda bile peşinizi bırakmaz: bir kabuk elde etmek için bunu ilan etmeniz gerekir.

VD Dropbear, gizli alternatiftir. Root'lu bir cihazda size gerçek bir SSH sunucusu verir; ağ
üzerinden root kabuğu, SFTP ve rsync, `adb_enabled` izi olmadan, USB hata ayıklama bayrağı olmadan,
hiçbir şey ele vermeyen bir sürüm başlığıyla ve sizin denetlediğiniz kimlik bilgileriyle. Erişiminiz
size ait kalır; cihazdaki herhangi bir şeyin okuyabileceği, herkese açık "hata ayıklanıyorum"
bayrağına dönüşmez.

## Özellikler

- **Her zaman tek bir arka plan hizmeti.** Önyüklemede ve yöneticinin **Action** düğmesiyle başlar;
  dilediğiniz an WebUI üzerinden **başlatabilir / durdurabilir / yeniden başlatabilirsiniz**; asla
  birden fazla örnek olmaz.
- **Her şey yapılandırılabilir**, WebUI üzerinden (ya da `/data/adb/vddropbear/config`):
  - bağlantı noktası ve loopback / tümü / IPv4 / IPv6 / belirli adreslere bağlama
  - **ilk kilit açmadan önce (BFU) ya da yalnızca ondan sonra (AFU) başlatma**, tek bir anahtar
  - açık anahtar ve/veya parola ile kimlik doğrulama, en fazla kimlik doğrulama denemesi
  - oturum açma kabuğu, `HOME`, ek ortam değişkenleri
  - boşta kalma zaman aşımı, keepalive, alım penceresi
  - yerel / uzak bağlantı noktası yönlendirme ve gateway bağlantı noktaları (tümü varsayılan olarak **kapalı**)
  - ana makine anahtarı türü (ed25519 / rsa / ecdsa)
- **Gizli sürüm başlığı.** SSH protokolü *bir* başlık ister, bu yüzden tümüyle kaldırılamaz; ancak
  VD Dropbear onu bilgi vermeyen bir başlıkla değiştirir; böylece tarayıcılar sunucunun ya da sürümün
  tam olarak ne olduğunu belirleyip ona bilinen sürüme özgü saldırılar yöneltemez.
- **Sırlar makul biçimde saklanır** (bkz. [Güvenlik modeli](#security-model)).
- **Kendi kimlik bilgilerinizi getirin.** Yetkili anahtarlar ve parolalı hesaplar ekleyin. Bir oturum,
  kimlik doğrulaması yaptığınız hesap olarak çalışır: varsayılan olarak **root** ya da daha düşük
  ayrıcalıklı bir Android hesabı (`shell`, `system`). WebUI
  asgari bir parola gücü dayatır ve parolayı asla düz metin olarak saklamaz.
- **Dosya aktarımı ve eşitleme yerleşik olarak gelir.** Paket `sftp-server`, `scp` ve `rsync`
  içerir; böylece SFTP, sshfs, grafik arayüzlü istemciler ve yedeklemelerin hepsi aynı bağlantı
  üzerinden çalışır.
- **Her cihaz ve emülatör.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## Cihazınızdaki yapay zeka ajanları

Sürekli açık bir SSH uç noktası, telefonunuzu **özerk bir yapay zeka ajanının doğrudan
çalıştırabileceği** bir şeye dönüştürür. Bir kabuğu ya da bir SSH bağlantısını yönetebilen herhangi
bir ajan (Claude Code, aider, döngüde bir LLM bulunan bir betik, kendi otomasyonunuz) cihazda ağ
üzerinden gerçek bir root oturumu elde eder; USB kablosu olmadan ve ADB'nin kendini ele veren hata
ayıklama bayraklarının hiçbiri olmadan. Ajan, sıradan, Linux benzeri bir kabuk görür ve şunları yapabilir:

- dosyaları okuyup düzenleyebilir, ayarları değiştirebilir, modülleri, paketleri ve hizmetleri yönetebilir;
- günlükleri eleyebilir, çıktıları çekebilir ve istendiğinde tanılama ya da adli inceleme çalıştırabilir;
- `scp` / `sftp` / `rsync` üzerinden dosyaları her iki yönde taşıyıp eşitleyebilir (yedeklemeler, geçişler ya da ilk kurulum için);
- root'lu bir cihaz filosunun tamamını tek bir yerden yönetebilir; her birine kendi anahtarıyla erişilir.

Proje **yapay zeka dostu** olacak biçimde kurulduğu için (belgelenmiş bir yapılandırma dosyası,
açık bir çalışma zamanı [ortam sözleşmesi](patches/README.md), öngörülebilir yollar ve düz metin
durum bilgisi) bir ajan, tahminde bulunmadan nasıl kullanılacağını kendi keşfedebilir.

> **Varsayılan olarak root'tur, o yüzden ona root gibi davranın.** Varsayılan bir oturum root olarak
> iner, ancak daha düşük ayrıcalıklı bir hesap (`shell`, `system`) ile de oturum açabilirsiniz
> (aşağıdaki uyarıya bakın). Bir ajana erişim verdiğinizde ona kendi kimlik bilgisini verin (kişisel
> anahtarınızı değil), erişimini sınırlamak isterseniz onu `shell` gibi daha düşük ayrıcalıklı bir
> hesaba yönlendirin, bağlamaları güvendiğiniz ağlarla (açık internet yerine loopback ya da bir VPN)
> sınırlayın, parola ile kimlik doğrulamayı kapalı tutun ve bir anahtarı iptal edebileceğinizi ya da
> arka plan hizmetini istediğiniz an WebUI üzerinden durdurabileceğinizi unutmayın.

## Kurulum

Modül zip'ini KernelSU, APatch ya da Magisk yöneticisinde (ya da komut satırından
`ksud module install` / `apd module install` ile) flash'layın, bağlantı noktasını ayarlamak ve
anahtarlarınızı eklemek için modülün **WebUI**'sini açın, ardından yeniden başlatın (ya da hemen
başlatmak için **Action**'a basın).

## Güvenlik modeli

### Sırlar nerede durur: BFU'ya karşı AFU

`/data/adb`, **cihaz şifrelemeli (DE)** depolamadır: kullanıcı telefonun kilidini açmadan *önce*
çözülür (Before First Unlock), bu nedenle oradaki her şey kilit açılmadan okunabilir. `/data/misc_ce`
ise **kimlik bilgisi şifrelemeli (CE)** depolamadır: Android, kullanıcı kilidi açana dek onu şifreli
tutar (After First Unlock).

- **AFU modu (varsayılan, `START_IN_BFU=0`):** arka plan hizmeti kilidin açılmasını bekler ve ana
  makine anahtarını, `authorized_keys` dosyasını ve parola özetlerini CE depolamasından okur. En
  yüksek koruma; SSH yalnızca cihaz önyüklemeden bu yana en az bir kez kilidi açıldıktan sonra çalışır.
- **BFU modu (`START_IN_BFU=1`):** arka plan hizmeti kilit açılmadan önce başlar; böylece erkenden
  SSH ile bağlanabilirsiniz (örneğin cihazın kilidini uzaktan açmak için). Sırları o zaman DE
  depolamasında durur ve kilit açılmadan okunabilir; bu, bilinçli ve belgelenmiş bir ödünleşmedir.
  Bunu yalnızca kilit açılmadan SSH'a ihtiyacınız varsa etkinleştirin.

CE'nin üstüne kendi şifrelememizi bilinçli olarak **eklemiyoruz**: o zaten kullanıcının kimlik
bilgisiyle şifrelidir ve başka bir şifre katmanı eklemek, bir yerde durması gereken bir anahtar
gerektirirdi (DE'de açıkta olurdu; onu kullanıcının kimlik bilgisinden türetmek de yalnızca CE'yi
yeniden uygulamak olurdu). Bu, gerçek bir koruma değil, yanlış bir güvenlik duygusu sağlardı.

### Parolalar

Parolayla oturum açma **varsayılan olarak kapalıdır**, çünkü bir oturum varsayılan olarak root'tur ve anahtarlar çok
daha güvenlidir. Bir parola belirlediğinizde WebUI asgari bir güç dayatır ve yalnızca bir özet
saklar, asla düz metin değil.

## Derleme

Sunucu ikili dosyası, CI tarafından **üst kaynak [mkj/dropbear](https://github.com/mkj/dropbear)**'den
küçük ve denetlenebilir bir yama kümesiyle derlenir (bkz. [`patches/`](patches/)): nötr/yapılandırılabilir
bir kimlik dizesi, `authorized_keys` ve parola dosyası için yapılandırmadan okunan yollar ve
etkileşimli PTY'ler için Android `openpty` düzeltmesi. Zamanlanmış bir iş akışı üst kaynağı izler ve
yeniden derler; böylece modül güncel kalır. Bkz. [`.github/workflows/`](.github/workflows/) ve
[`CONTRIBUTING.md`](CONTRIBUTING.md).

## Belgeler

<!-- vd-docs -->
Belgelerin tamamı [wiki](https://github.com/VD171/VD-dropbear/wiki) içinde ve [`docs/`](docs/) altında
bulunur.
<!-- /vd-docs -->

## Ayrıca bkz.

Aynı geliştiricinin kardeş projeleri:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: her bir öğeyi onu okuyabilen her yöntemle okuyan ve bunları yan yana karşılaştıran bir cihaz yöntemi hata ayıklayıcısı.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: Google hizmetleriniz (RCS, Wallet, Play Integrity doğrulamaları), cihazınızda internet olmadan okunur.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: root olarak tam uygulama ve veri yedekleme ve geri yükleme; tümüyle bir WebUI'den yönetilir.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: küresel bir cihaz parmak izi ve build taklitçisi.

## İletişim

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Kanal:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-posta:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA konusu:** <https://xdaforums.com/t/VD-Dropbear.4808524/>
* **GitHub:** @VD171 https://github.com/VD171

## Lisans

VD Dropbear'ın kendi kodu **Apache-2.0**'dır; bkz. [LICENSE](LICENSE). Modül ayrıca üçüncü taraf
ikili dosyalarını da paketler: [Dropbear](https://matt.ucc.asn.au/dropbear/) (MIT tarzı), OpenSSH'in
`sftp-server` ve `scp`'si (BSD) ve `rsync` (GPL-3.0), her biri kendi lisansı altındadır; rsync için
GPL'ye nasıl uyduğumuz dahil, bkz. [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md). Apache-2.0
kodumuz bundan etkilenmez (GPL ikili dosyası yalnızca bir araya getirilmiştir, bağlanmamıştır).

## Ticari markalar

VD Dropbear, bağımsız ve resmi olmayan bir projedir; herhangi bir üçüncü tarafla bağlantılı değildir
ve onlar tarafından onaylanmamıştır. "Android", Google LLC'nin ticari markasıdır; "SSH", SSH
Communications Security'nin tescilli ticari markasıdır. VD Dropbear tamamen sizin cihazınızda çalışır.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
