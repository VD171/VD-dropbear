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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · Español · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Compilar VD Dropbear

VD Dropbear entrega el **[Dropbear](https://github.com/mkj/dropbear) upstream** (la etiqueta fijada en
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION)) más el conjunto de parches pequeño y auditable en
[`patches/`](../../patches/). La CI lo compila; puedes reproducirlo localmente.

## Inicio rápido

```sh
# una vez: un Android NDK (r27 o más nuevo)
export NDK=/path/to/android-ndk

# compila cada ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# o solo uno, para iterar rápido
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` clona la etiqueta upstream fijada, aplica `patches/*.patch` y `localoptions.h`, y
luego compila de forma cruzada `vddropbear` y `dropbearkey` en `module/bin/<abi>/`. La salida es un ELF
**dinámico** (`file` informa `dynamically linked, interpreter /system/bin/linker64 … for Android 24`),
enlazado contra la libc bionic que todo dispositivo Android ya tiene. libtomcrypt queda incrustado
dentro del binario; solo la biblioteca C es dinámica. Véase [Dinámico, no static-PIE](#dinámico-no-static-pie).

Los binarios **no se commitean**; los compila la CI en cada etiqueta y se adjuntan a la release.
Véase [`.gitignore`](../../.gitignore).

---

## La historia de crypt()/libcrypto (por qué la autenticación por contraseña dio trabajo de verdad)

La autenticación por contraseña de Dropbear está escrita para un host Unix normal con `crypt()` y
`/etc/shadow`. Android **no tiene ninguno de los dos**, y eso choca con la compilación en tres lugares
distintos. Esta sección documenta cada uno de ellos, porque es exactamente el tipo de cosa dolorosa de
redescubrir. Todo ello lo gestiona el parche
[`0003-password-file.patch`](../../patches/0003-password-file.patch); nada de lo de abajo se deja al azar
en tiempo de ejecución.

### 1. bionic no tiene un `crypt()` utilizable

La biblioteca C de Android (bionic) no proporciona `crypt()`, `crypt_r()`, ni una base de datos shadow.
El NDK no expone ningún `<crypt.h>`. Así que la ruta estándar de contraseña de Dropbear, que llama a
`crypt(password, salt)` y compara contra `/etc/shadow`, simplemente no puede compilarse ni ejecutarse
en Android. Tampoco hay ningún `libcrypt` al que enlazar, y traer el `libcrypto` de OpenSSL solo para un
hash de contraseña sería una dependencia grande y torpe para un binario estático.

**Nuestra respuesta:** no usar `crypt()` en absoluto. La autenticación por contraseña verifica la
contraseña presentada con **PBKDF2-HMAC-SHA256** contra un archivo de hash (`DROPBEAR_PASSWD_FILE`), una
KDF pública, estándar, con salt e iterada. El formato del archivo está documentado en
[`patches/README.md`](../../patches/README.md).

### 2. el guard de tiempo de compilación en `sysoptions.h`

Antes incluso de que corra cualquier código, Dropbear se niega a compilar:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Con `HAVE_CRYPT` sin definir (siempre, en bionic) y la autenticación por contraseña habilitada, esto es
un `#error` rígido. Como nuestro verificador nunca llama a `crypt()`, el parche `0003` **elimina este
guard**. (Deja intacta la comprobación de "al menos un método de autenticación debe estar habilitado".)

### 3. la trampa de libtomcrypt: PBKDF2 se compila *hacia fuera*

Dropbear incrusta un **libtomcrypt** recortado, que *sí* contiene PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). El arreglo obvio es llamarlo. No funciona, por dos razones que se suman:

- **El prototipo está oculto.** `pkcs_5_alg2` se declara solo dentro de `#ifdef LTC_PKCS_5` en
  `tomcrypt_pkcs.h`. Los *propios* archivos fuente de Dropbear no se compilan con `LTC_PKCS_5` definido,
  así que la declaración queda invisible y el compilador da error de *implicit function declaration*.
- **El símbolo no existe.** Peor aún, el *cuerpo* de `pkcs_5_alg2` también está tras `#ifdef
  LTC_PKCS_5`. La compilación de libtomcrypt de Dropbear no lo define, así que `pkcs_5_2.o` compila a un
  **objeto vacío**: está en `libtomcrypt.a`, pero no contiene ningún símbolo `pkcs_5_alg2`. El enlace
  falla con `undefined symbol: pkcs_5_alg2`.

Puedes verlo tú mismo:

```sh
# el objeto existe pero está vacío (sin T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> solo un marcador de datos, sin pkcs_5_alg2

# el HMAC, en cambio, está totalmente compilado (Dropbear lo usa para los MAC de SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> define hmac_memory
```

**Nuestra respuesta:** construir PBKDF2 nosotros mismos sobre las primitivas que Dropbear *sí* compila.
`hmac_memory` y el hash `sha256` registrado están ambos presentes y enlazables, así que el parche
`0003` implementa PBKDF2-HMAC-SHA256 directamente (RFC 2898; un único bloque de salida de 32 bytes, ya
que `dkLen == hLen` para SHA-256). Declaramos `hmac_memory` nosotros mismos (el mismo problema de
prototipo oculto de arriba) y el objeto se extrae de `libtomcrypt.a` en el enlace. El resultado es
PBKDF2 estándar y por tanto interoperable: el hash que la WebUI calcula con el **WebCrypto**
`deriveBits` del navegador es byte a byte idéntico al que calcula el servidor, verificado contra el
`hashlib.pbkdf2_hmac` de Python como una tercera implementación independiente.

> **En resumen:** Android no te da ningún `crypt()`, y el PBKDF2 incrustado de Dropbear se compila a
> nada. La autenticación por contraseña aquí es un PBKDF2-HMAC-SHA256 desde cero sobre el HMAC de
> libtomcrypt, con el guard de compilación de crypt() eliminado. Sin OpenSSL/`libcrypto`, sin
> ofuscación, sin shadow del sistema.

---

## Dinámico, no static-PIE

Los binarios son **dinámicos** (enlazados contra la bionic del sistema vía `/system/bin/linker64`), no
estáticos. Esto importa, y se aprendió por las malas, **en un dispositivo real**, no en la CI:

- Una compilación **static-PIE** *parece* estar bien (`file` informa un `static-pie executable` limpio)
  y enlaza sin error, pero **da SIGSEGV en el instante en que corre en el dispositivo** (verificado en
  un teléfono arm64 Android 16, exit 139, sin tombstone útil). Los ejecutables estáticos en Android son
  frágiles; la forma fiable es un binario dinámico normal, que también es como se entrega todo dropbear
  de Android consolidado.
- Una compilación **estática, no-PIE** ni siquiera arranca: bionic la rechaza con
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Así que la compilación es **dinámica** (`make` sin `STATIC=1`; `-pie`), enlazando solo la libc bionic,
  presente en todo dispositivo. libtomcrypt sigue incrustado estáticamente en el binario, así que no hay
  biblioteca extra que entregar.

Lección para probar: **`qemu-aarch64` (qemu-user) no es un smoke test válido** aquí (también da
segfault en estos binarios), y un compile+link exitoso tampoco lo es. **Ejecuta el binario en un
dispositivo Android arm64 real.** (Esto se validó exactamente así: el daemon se lanzó en un puerto alternativo en un dispositivo vivo y se confirmó que un
inicio de sesión por contraseña tenía éxito, con una contraseña incorrecta rechazada.)

## Sin la flag `-E`

El servidor se compila con `--disable-syslog`, así que siempre registra en stderr y la opción `-E` del
upstream ("log to stderr") **no existe** en este binario; pasarla imprime `Invalid option -E` y el
daemon nunca arranca. Por eso el constructor de argumentos del módulo no pasa `-E`.

## openpty

Las sesiones PTY interactivas usan `openpty()`. bionic lo declara en `<pty.h>`, y el `configure` cruzado
de Dropbear lo detecta con el NDK (`HAVE_OPENPTY` se establece, `HAVE_PTY_H 1`), así que **no hace falta
ningún parche**; los PTY funcionan de inmediato. (El uso no interactivo como exec, SFTP, rsync y reenvío
de puertos no depende de él de todos modos.)

## Herramientas incluidas: sftp-server, scp, rsync

`scripts/build-bundles.sh` compila de forma cruzada las herramientas de transferencia de archivos como
binarios dinámicos en `module/bin/<abi>/`. La CI lo ejecuta justo después de `build.sh`.

- **rsync** (con popt + zlib incluidos) compila limpio en cuanto le dices a su configure que bionic no
  tiene `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** y **scp** vienen de **OpenSSH portable**, compilados con `--without-openssl` (la
  cripto integrada de OpenSSH basta para estos dos), con un pequeño **zlib** estático que este script
  compila primero.

OpenSSH en Android es tan quisquilloso como la historia de crypt() de arriba, porque su `configure`
detecta mal varias funciones de la libc al compilar de forma cruzada. El script codifica el arreglo;
para que conste, las piezas son:

1. **Un seed de caché de funciones que bionic no tiene** pero que configure cree que tiene, para que se
   compilen en su lugar las versiones compat: `recallocarray`, `close_range`, `getentropy`,
   `getrandom`, `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`,
   `strtonum`, `pledge`, `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Sin ellos, el `defines.h` de
   OpenSSH hace `#define __sentinel__` (vacío), lo que luego estropea el propio
   `__attribute__((__sentinel__(1)))` de bionic en `<unistd.h>` y toda compilación falla con
   `expected ')'`.
3. **Un compat de `explicit_bzero` que usa `memset`.** El `bzero` de bionic es una macro parecida a una
   función (no un símbolo real), así que el compat por defecto de OpenSSH, que toma `&bzero` como
   puntero a función, no compila. bionic no tiene un `explicit_bzero` propio.
4. **Descartar `xcrypt.o` y `getrrsetbyname.o`** de la biblioteca compat. `xcrypt.c` llama a
   `getpwent()`/`crypt()` incondicionalmente (bionic no tiene ninguno de los dos), y `getrrsetbyname.c`
   usa internos del resolver que bionic no expone. Ninguno de los dos lo usan `sftp-server` ni `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` es la imagen especular de las funciones en (1):
   bionic no la *declara* en la API 24, así que OpenSSH compila su propio compat, pero el **símbolo** sí
   existe en `libc.a`, así que los dos chocan en el enlace. Permitir el duplicado toma el de bionic, lo
   cual está bien.
6. **Proteger `pw_gecos` contra NULL en `pwcopy()`.** El `getpwuid()` de bionic devuelve un `pw_gecos`
   `NULL` (Android no guarda campo GECOS). El `pwcopy()` de OpenSSH protege `pw_passwd` contra `NULL`
   pero no `pw_gecos`, así que `sftp-server` llega a `xstrdup(NULL)` y da SIGSEGV al arrancar, en el
   instante en que se abre una sesión. (`scp` sobre el protocolo legado nunca llama a `pwcopy`, por eso
   funcionaba mientras SFTP no.) La compilación parchea `pwcopy()` para coalescer `pw_gecos` a `""`.

Las versiones fijadas están en la parte superior de `scripts/build-bundles.sh` (`ZLIB_VERSION`,
`RSYNC_VERSION`, `OPENSSH_VERSION`).

## Reproducir un único ABI a mano

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

> _Esta documentación se generó con Claude (Anthropic) y la mantiene VD171. Las correcciones y mejoras son bienvenidas; consulta [CONTRIBUTING.md](CONTRIBUTING.md)._
