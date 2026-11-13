#!/usr/bin/env python3
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
#  Render docs/ into GitHub Wiki pages (used by .github/workflows/wiki-sync.yml).
#
#  Copyright (C) 2026  VD171
#  SPDX-License-Identifier: Apache-2.0
#
#  Licensed under the Apache License, Version 2.0; you may obtain a copy at
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Site           : https://vd171.ru
#  Site           : https://vd.priv8.ru
#  Source         : https://github.com/VD171/VD-dropbear
#  GitHub         : @VD171 https://github.com/VD171
#  XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
#  XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
#  Telegram       : @VD_Priv8 https://t.me/VD_Priv8
#  Channel        : @Priv8_VD https://t.me/Priv8_VD
#  Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
#  E-mail         : vd.priv8@pm.me
# ======================================================================
# docs/ is the source of truth. This strips the banner + language switcher,
# rewrites relative links (sibling docs -> wiki pages, repo files -> github
# blob URLs) and writes one wiki page per doc, plus a Home page.
#   usage: gen_wiki.py <docs_dir> <wiki_out_dir>
import re, os, sys

SRC = sys.argv[1] if len(sys.argv) > 1 else "docs"
WIKI = sys.argv[2] if len(sys.argv) > 2 else "wiki"
BLOB = "https://github.com/VD171/VD-dropbear/blob/master"
REPO = "https://github.com/VD171/VD-dropbear"

# docs file (without .md) -> wiki page name
PAGES = [("USER-GUIDE", "User-Guide"), ("CONFIGURATION", "Configuration"),
         ("ARCHITECTURE", "Architecture"), ("FILE-STRUCTURE", "File-Structure"),
         ("AI-AGENTS", "AI-Agents"), ("BUILDING", "Building")]

def strip_header(text):
    # drop the HTML banner comment and the Languages switcher; keep from first '# '
    m = re.search(r'^# ', text, re.M)
    return text[m.start():] if m else text

def fix_links(b):
    b = b.replace("](../BUILDING.md)", "](Building)").replace("](BUILDING.md)", "](Building)")
    b = b.replace("](CONFIGURATION.md)", "](Configuration)")
    b = b.replace("](../../patches/README.md)", f"]({BLOB}/patches/README.md)")
    b = b.replace("](../patches/README.md)", f"]({BLOB}/patches/README.md)")
    b = b.replace("](../../LICENSE)", f"]({BLOB}/LICENSE)").replace("](LICENSE)", f"]({BLOB}/LICENSE)")
    b = b.replace("](../../CHANGELOG.md)", f"]({BLOB}/CHANGELOG.md)")
    b = b.replace("](../README.md)", f"]({REPO})").replace("](../../README.md)", f"]({REPO})")
    b = b.replace("[Security model](#)", f"[Security model]({REPO}#security-model)")
    b = b.replace("](../patches/)", f"]({REPO}/tree/master/patches)")
    b = b.replace("](../../", f"]({BLOB}/").replace("](../", f"]({BLOB}/")
    return b

FOOTER = "\n\n---\n\n_Part of the [VD-dropbear](%s) documentation. Generated with Claude._\n" % REPO

os.makedirs(WIKI, exist_ok=True)
for src, page in PAGES:
    p = os.path.join(SRC, src + ".md")
    if not os.path.exists(p):
        continue
    body = fix_links(strip_header(open(p, encoding="utf-8").read())).rstrip("\n")
    open(os.path.join(WIKI, page + ".md"), "w", encoding="utf-8").write(body + FOOTER)
    print("wiki:", page)

home = """# VD Dropbear

A standalone, fully configurable **rooted SSH server** for KernelSU, APatch and Magisk: a private SSH
daemon with a WebUI, with none of ADB's invasive, self-exposing debug flags.

> **An authenticated login defaults to a root shell.** Prefer keys over passwords, bind only to
> networks you trust, and keep the port off the open Internet.

## Documentation

- **[[User-Guide]]** - install, keys, passwords, connecting, file transfer, BFU/AFU.
- **[[Configuration]]** - every setting, with defaults.
- **[[Architecture]]** - how the module and daemon work.
- **[[File-Structure]]** - what lives where, in the repo and at runtime.
- **[[AI-Agents]]** - running an autonomous agent over SSH, safely.
- **[[Building]]** - the build, and the Android crypt()/cross-compile story.

The documentation is also in the repository under [`docs/`](%s/tree/master/docs), translated into 21
languages.

## Links

- Source & releases: %s
- XDA thread: https://xdaforums.com/t/VD-Dropbear.4808524/
- Telegram: https://t.me/Priv8_VD
%s""" % (REPO, REPO, FOOTER)
open(os.path.join(WIKI, "Home.md"), "w", encoding="utf-8").write(home)
print("wiki: Home")
