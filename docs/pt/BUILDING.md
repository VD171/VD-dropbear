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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · Português · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Compilando o VD Dropbear

O VD Dropbear entrega o **[Dropbear](https://github.com/mkj/dropbear) upstream** (a tag fixada em
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION)) mais o conjunto de patches pequeno e auditável em
[`patches/`](../../patches/). A CI o compila, você pode reproduzi-lo localmente.

## Início rápido

```sh
# uma vez: um Android NDK (r27 ou mais novo)
export NDK=/path/to/android-ndk

# compila todos os ABIs (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# ou só um, para iterar rápido
ABIS="arm64-v8a" ./scripts/build.sh
```

O `scripts/build.sh` clona a tag upstream fixada, aplica `patches/*.patch` e `localoptions.h`,
e então faz a compilação cruzada de `vddropbear` e `dropbearkey` em `module/bin/<abi>/`. A saída é um
ELF **dinâmico** (`file` relata `dynamically linked, interpreter /system/bin/linker64 … for Android
24`), ligado contra a libc bionic que todo dispositivo Android já tem. O libtomcrypt fica embutido
dentro do binário, só a biblioteca C é dinâmica. Veja [Dinâmico, não static-PIE](#dinâmico-não-static-pie).

Os binários **não são commitados**, são compilados pela CI a cada tag e anexados à release.
Veja [`.gitignore`](../../.gitignore).

---

## A história do crypt()/libcrypto (por que a autenticação por senha deu trabalho de verdade)

A autenticação por senha do Dropbear é escrita para um host Unix normal com `crypt()` e
`/etc/shadow`. O Android **não tem nenhum dos dois**, e isso colide com a compilação em três lugares
distintos. Esta seção documenta cada um deles, porque é exatamente o tipo de coisa dolorosa de
redescobrir. Tudo isso é tratado pelo patch
[`0003-password-file.patch`](../../patches/0003-password-file.patch), nada abaixo é deixado ao acaso em
tempo de execução.

### 1. a bionic não tem um `crypt()` utilizável

A biblioteca C do Android (bionic) não fornece `crypt()`, `crypt_r()`, nem um banco de dados shadow. O
NDK não expõe nenhum `<crypt.h>`. Então o caminho padrão de senha do Dropbear, que chama
`crypt(password, salt)` e compara contra `/etc/shadow`, simplesmente não pode ser compilado nem
executado no Android. Também não há nenhum `libcrypt` para ligar, e puxar o `libcrypto` do OpenSSL só
para um hash de senha seria uma dependência grande e desajeitada para um binário estático.

**Nossa resposta:** não usar `crypt()` de jeito nenhum. A autenticação por senha verifica a senha
apresentada com **PBKDF2-HMAC-SHA256** contra um arquivo de hash (`DROPBEAR_PASSWD_FILE`), uma KDF
pública, padrão, com salt e iterada. O formato do arquivo está documentado em
[`patches/README.md`](../../patches/README.md).

### 2. o guard de tempo de compilação em `sysoptions.h`

Antes mesmo de qualquer código rodar, o Dropbear se recusa a compilar:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Com `HAVE_CRYPT` não definido (sempre, na bionic) e a autenticação por senha habilitada, isso é um
`#error` rígido. Como nosso verificador nunca chama `crypt()`, o patch `0003` **remove esse guard**.
(Ele deixa intacta a checagem de "pelo menos um método de autenticação deve estar habilitado".)

### 3. a armadilha do libtomcrypt: o PBKDF2 é compilado *para fora*

O Dropbear embute um **libtomcrypt** enxuto, que *de fato* contém o PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). A correção óbvia é chamá-lo. Ela não funciona, por duas razões que se
somam:

- **O protótipo está escondido.** `pkcs_5_alg2` é declarado só dentro de `#ifdef LTC_PKCS_5` em
  `tomcrypt_pkcs.h`. Os *próprios* arquivos-fonte do Dropbear não são compilados com `LTC_PKCS_5`
  definido, então a declaração fica invisível e o compilador dá erro de *implicit function
  declaration*.
- **O símbolo não existe.** Pior, o *corpo* do `pkcs_5_alg2` também está atrás de `#ifdef
  LTC_PKCS_5`. A compilação do libtomcrypt do Dropbear não o define, então `pkcs_5_2.o` compila para um
  **objeto vazio**: ele está em `libtomcrypt.a`, mas não contém nenhum símbolo `pkcs_5_alg2`. A
  ligação falha com `undefined symbol: pkcs_5_alg2`.

Você pode ver isso por si mesmo:

```sh
# o objeto existe mas está vazio (sem T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> só um marcador de dados, sem pkcs_5_alg2

# o HMAC, por outro lado, é totalmente compilado (o Dropbear o usa para os MACs do SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> define hmac_memory
```

**Nossa resposta:** construir o PBKDF2 nós mesmos sobre as primitivas que o Dropbear *de fato*
compila. `hmac_memory` e o hash `sha256` registrado estão ambos presentes e linkáveis, então o patch
`0003` implementa o PBKDF2-HMAC-SHA256 diretamente (RFC 2898; um único bloco de saída de 32 bytes, já
que `dkLen == hLen` para SHA-256). Declaramos `hmac_memory` nós mesmos (mesmo problema de protótipo
escondido de cima) e o objeto é puxado de `libtomcrypt.a` na ligação. O resultado é PBKDF2 padrão e,
portanto, interoperável: o hash que a WebUI calcula com o **WebCrypto** `deriveBits` do navegador é
byte a byte idêntico ao que o servidor calcula, verificado contra o `hashlib.pbkdf2_hmac` do Python
como uma terceira implementação independente.

> **Em resumo:** o Android não te dá nenhum `crypt()`, e o PBKDF2 embutido do Dropbear é compilado
> para nada. A autenticação por senha aqui é um PBKDF2-HMAC-SHA256 do zero sobre o HMAC do
> libtomcrypt, com o guard de compilação do crypt() removido. Sem OpenSSL/`libcrypto`, sem ofuscação,
> sem shadow do sistema.

---

## Dinâmico, não static-PIE

Os binários são **dinâmicos** (ligados contra a bionic do sistema via `/system/bin/linker64`), não
estáticos. Isso importa, e foi aprendido do jeito difícil, **num aparelho real**, não na CI:

- Uma compilação **static-PIE** *parece* boa (`file` relata um `static-pie executable` limpo) e liga
  sem erro, mas **dá SIGSEGV no instante em que roda no aparelho** (verificado num celular arm64
  Android 16, exit 139, sem tombstone útil). Executáveis estáticos no Android são frágeis, a forma
  confiável é um binário dinâmico normal, que também é como todo dropbear de Android consolidado é
  entregue.
- Uma compilação **estática, não-PIE** nem inicia: a bionic a rejeita com
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Então a compilação é **dinâmica** (`make` sem `STATIC=1`; `-pie`), ligando só a libc bionic,
  presente em todo aparelho. O libtomcrypt ainda fica embutido estaticamente no binário, então não há
  biblioteca extra para entregar.

Lição para testar: **`qemu-aarch64` (qemu-user) não é um smoke test válido** aqui (ele também dá
segfault nesses binários), e um compile+link bem-sucedido também não é. **Rode o binário num aparelho
Android arm64 real.** (Isto foi validado exatamente assim: o daemon foi iniciado numa porta alternativa num aparelho vivo e um login por senha foi
confirmado como bem-sucedido, com uma senha errada rejeitada.)

## Sem a flag `-E`

O servidor é compilado com `--disable-syslog`, então ele sempre loga no stderr e a opção `-E` do
upstream ("log to stderr") **não existe** neste binário, passá-la imprime `Invalid option -E` e o
daemon nunca inicia. Por isso o construtor de argumentos do módulo não passa `-E`.

## openpty

Sessões PTY interativas usam `openpty()`. A bionic o declara em `<pty.h>`, e o `configure` cruzado do
Dropbear o detecta com o NDK (`HAVE_OPENPTY` é setado, `HAVE_PTY_H 1`), então **nenhum patch é
necessário**, os PTYs funcionam de imediato. (Usos não interativos como exec, SFTP, rsync e
encaminhamento de portas não dependem dele de qualquer forma.)

## Ferramentas embutidas: sftp-server, scp, rsync

O `scripts/build-bundles.sh` faz a compilação cruzada das ferramentas de transferência de arquivos
como binários dinâmicos em `module/bin/<abi>/`. A CI o roda logo depois do `build.sh`.

- **rsync** (com popt + zlib embutidos) compila limpo assim que você diz ao configure dele que a
  bionic não tem `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** e **scp** vêm do **OpenSSH portable**, compilados com `--without-openssl` (a cripto
  interna do OpenSSH basta para esses dois), com um pequeno **zlib** estático que este script compila
  primeiro.

O OpenSSH no Android é tão delicado quanto a história do crypt() acima, porque o `configure` dele
detecta errado várias funções da libc ao compilar cruzado. O script codifica a correção, para
registro, as peças são:

1. **Um seed de cache das funções que a bionic não tem** mas que o configure acha que tem, para que as
   versões compat sejam compiladas no lugar: `recallocarray`, `close_range`, `getentropy`,
   `getrandom`, `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`,
   `strtonum`, `pledge`, `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Sem eles, o `defines.h` do
   OpenSSH faz `#define __sentinel__` (vazio), o que então estraga o próprio
   `__attribute__((__sentinel__(1)))` da bionic em `<unistd.h>` e toda compilação falha com
   `expected ')'`.
3. **Um compat de `explicit_bzero` que usa `memset`.** O `bzero` da bionic é uma macro parecida com
   função (não um símbolo real), então o compat padrão do OpenSSH, que pega `&bzero` como ponteiro de
   função, não compila. A bionic não tem um `explicit_bzero` próprio.
4. **Descartar `xcrypt.o` e `getrrsetbyname.o`** da biblioteca compat. `xcrypt.c` chama
   `getpwent()`/`crypt()` incondicionalmente (a bionic não tem nenhum dos dois), e
   `getrrsetbyname.c` usa internos do resolver que a bionic não expõe. Nenhum dos dois é usado pelo
   `sftp-server` ou pelo `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` é o espelho das funções em (1): a bionic não
   a *declara* na API 24, então o OpenSSH compila o próprio compat, mas o **símbolo** de fato existe
   em `libc.a`, então os dois colidem na ligação. Permitir a duplicata pega o da bionic, o que é
   ok.
6. **Proteger `pw_gecos` contra NULL em `pwcopy()`.** O `getpwuid()` da bionic retorna um `pw_gecos`
   `NULL` (o Android não mantém campo GECOS). O `pwcopy()` do OpenSSH protege `pw_passwd` contra
   `NULL` mas não `pw_gecos`, então o `sftp-server` chega a `xstrdup(NULL)` e dá SIGSEGV na
   inicialização, no instante em que uma sessão abre. (O `scp` sobre o protocolo legado nunca chama
   `pwcopy`, e é por isso que ele funcionava enquanto o SFTP não.) A compilação faz um patch no
   `pwcopy()` para coalescer `pw_gecos` para `""`.

As versões fixadas ficam no topo do `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Reproduzindo um único ABI à mão

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

> _Esta documentação foi gerada com o Claude (Anthropic) e é mantida por VD171. Correções e melhorias são bem-vindas, veja [CONTRIBUTING.md](CONTRIBUTING.md)._
