#!/usr/bin/env python3
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
#
#  WebUI screenshot harness (mirrors VD-Backup's tools/screenshots/shoot.py).
#  Serves the real module/webroot WebUI in a headless Chrome under a mocked
#  `ksu.exec` bridge that answers every vddb-webui.sh verb with fictional,
#  privacy-safe FIXTURES (NEVER real device data), frames it in simple phone
#  chrome (status bar + Android nav bar, dark theme, 396x882 @ 3x) and captures
#  the four documented panels to screenshots/ (flat, EN).
#
#  EN-ONLY: VD Dropbear's WebUI is hardcoded English (no lang/*.json, strings
#  live in index.html), so there is NO 22-language loop here. This script
#  captures a single locale (en) and writes the four PNGs the README points at.
#  Keeping it as a loop over ["en"] documents that choice and leaves one obvious
#  seam should the UI ever gain translations.
#
#  Why this lives in the repo:
#   - every label, the banner header and the panel layout come from the live
#     webroot, so a UI or copy change is reflected on the next run with no edit
#     here (this is how the recent "; " -> ", " clause-separator fix lands in
#     the Settings and Passwords panels);
#   - the shown version is read from module/module.prop, so a release bump needs
#     no change here either;
#   - fixtures are declared once in build_fixtures() below.
#
#  Usage:
#     python3 tools/screenshots/shoot.py        # the four EN panels
#  Requires: python3-playwright + a system Google Chrome/Chromium.
# ======================================================================

import json
import os
import socketserver
import sys
import threading
from http.server import SimpleHTTPRequestHandler

from playwright.sync_api import sync_playwright

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
WEBROOT = os.path.join(ROOT, "module", "webroot")
OUTDIR = os.path.join(ROOT, "screenshots")
LANGS = ["en"]   # EN-only WebUI: one locale, no 22-language variants.
# (tab button id, output basename)
SCREENS = [
    ("status", "status"),
    ("settings", "settings"),
    ("keys", "keys"),
    ("pw", "passwords"),
]
VIEWPORT = {"width": 396, "height": 882}
SCALE = 3


def module_version():
    try:
        with open(os.path.join(ROOT, "module", "module.prop"), encoding="utf-8") as f:
            for line in f:
                if line.startswith("version="):
                    return line.split("=", 1)[1].strip()
    except OSError:
        pass
    return "v1.0"


def build_fixtures(version):
    # Fictional, privacy-safe sample daemon state. NEVER derived from a real
    # device: invented pid, invented host-key fingerprint, placeholder public
    # keys. Mirrors the plausible "running SSH daemon" state used before.
    status = "\n".join([
        "running=1",
        "pid=7843",
        "port=2222",
        "mode=AFU",
        "ce_ready=1",
        "abi=arm64-v8a",
        "secret_dir=/data/misc_ce/0/vddropbear/secret",
        "version=" + version,
        "hostkey_fp=SHA256:Jd0p7qF2nR8sWkL4mZ1xV9cB3tY6uH5aQw0eD7iK2g",
    ])
    # Config keys the Settings panel reads (TOGGLES + FIELDS in index.html).
    config = {
        "ENABLED": "1",
        "START_IN_BFU": "0",
        "LISTEN_LOOPBACK": "1",
        "LISTEN_ALL": "0",
        "LISTEN_IPV4": "1",
        "LISTEN_IPV6": "1",
        "HIDE_IDENT": "1",
        "PUBKEY_AUTH": "1",
        "PASSWORD_AUTH": "1",
        "PASS_ENV": "1",
        "ALLOW_LOCAL_FORWARD": "0",
        "ALLOW_REMOTE_FORWARD": "0",
        "GATEWAY_PORTS": "0",
        "PORT": "2222",
        "LISTEN_ADDRESSES": "",
        "IDENT_STRING": "",
        "MAX_AUTH_TRIES": "3",
        "LOGIN_SHELL": "",
        "HOME_DIR": "",
        "EXTRA_ENV": "",
        "IDLE_TIMEOUT": "0",
        "KEEPALIVE": "0",
        "RECEIVE_WINDOW": "",
        "HOSTKEY_TYPE": "ed25519",
    }
    # Two sample ed25519 authorized keys (plausible 68-char bodies, invented).
    keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHm4Kx8pQb2vZ9pFqN3rT7wY1cJ6sD0eW5xV8uB2nL4 laptop@workstation",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2pL9mR4tY7wX1zB6cV3nD8qF5sH0jG2kM7aP4eW9u phone@pixel",
    ]
    pw_users = ["root"]
    return {"status": status, "config": config, "keys": keys, "pw": pw_users}


# Mocked ksu.exec bridge: parses the vddb-webui.sh verb out of the command and
# replies with the fixture's plain-text output (status is k=v lines; get-config,
# list-keys, list-pw are tab/base64 rows, exactly as the backend emits). Anything
# else (VDLU engine probes, journal reads) answers empty rc=0 so init never
# throws and no "Updating" banner sticks.
MOCK_JS = r"""
(function () {
  window.__VDDB = %s;
  function b64(s){ var u=new TextEncoder().encode(s); var r=""; for(var i=0;i<u.length;i++) r+=String.fromCharCode(u[i]); return btoa(r); }
  function reply(cmd){
    var fx = window.__VDDB;
    var m = /vddb-webui\.sh\s+([a-z-]+)/.exec(cmd);
    var verb = m ? m[1] : "";
    if (verb === "status")  return fx.status;
    if (verb === "get-config"){
      return Object.keys(fx.config).map(function(k){ return k + "\t" + b64(fx.config[k]); }).join("\n");
    }
    if (verb === "list-keys"){
      return fx.keys.map(function(k,i){ return (i+1) + "\t" + b64(k); }).join("\n");
    }
    if (verb === "list-pw"){
      return fx.pw.map(function(u){ return b64(u); }).join("\n");
    }
    return "";
  }
  window.ksu = {
    exec: function (cmd, opts, cbName) {
      var out = reply(String(cmd));
      setTimeout(function () {
        try { if (typeof window[cbName] === "function") window[cbName](0, out, ""); } catch (e) {}
      }, 0);
    }
  };
})();
"""


# Phone chrome: a slim status bar (clock + wifi/signal/battery) and an Android
# nav bar (back / home / recents), injected after load and themed from the page
# CSS vars. The panel below is clipped to the viewport, same framing as the
# earlier pass.
CHROME_JS = r"""
(function () {
  var css = document.createElement('style');
  css.textContent = '\
    #vddb-sb{position:fixed;top:0;left:0;right:0;height:30px;z-index:99998;display:flex;\
      align-items:center;justify-content:space-between;padding:0 16px;background:var(--bg);\
      color:var(--fg);font-size:15px;font-weight:600;letter-spacing:.2px}\
    #vddb-sb .ic{display:flex;align-items:center;gap:7px}\
    #vddb-nav{position:fixed;bottom:0;left:0;right:0;height:42px;z-index:99998;display:flex;\
      align-items:center;justify-content:space-around;background:var(--bg)}\
    #vddb-nav svg{opacity:.75}\
    body{padding-top:46px !important;padding-bottom:58px !important}';
  document.head.appendChild(css);
  var fg = getComputedStyle(document.documentElement).getPropertyValue('--fg').trim() || '#e8ecf3';
  var sb = document.createElement('div'); sb.id = 'vddb-sb';
  sb.innerHTML = '<span>9:41</span><span class="ic">'
    + '<svg width="17" height="13" viewBox="0 0 24 18" fill="' + fg + '"><path d="M12 3C7.5 3 3.7 4.9 1 7.9l2 2.2C5.3 7.7 8.5 6.3 12 6.3s6.7 1.4 9 3.8l2-2.2C20.3 4.9 16.5 3 12 3zm0 5.2c-2.6 0-5 1.1-6.7 2.9l2 2.2C8.5 12.2 10.1 11.5 12 11.5s3.5.7 4.7 1.8l2-2.2C17 9.3 14.6 8.2 12 8.2zm0 5.1c-1 0-1.9.4-2.6 1.1L12 17l2.6-2.6c-.7-.7-1.6-1.1-2.6-1.1z"/></svg>'
    + '<svg width="18" height="13" viewBox="0 0 24 18" fill="' + fg + '"><rect x="1" y="12" width="4" height="5" rx="1"/><rect x="7" y="8" width="4" height="9" rx="1"/><rect x="13" y="4" width="4" height="13" rx="1"/><rect x="19" y="0" width="4" height="17" rx="1"/></svg>'
    + '<svg width="25" height="13" viewBox="0 0 34 18" fill="none" stroke="' + fg + '" stroke-width="1.6"><rect x="1" y="2" width="28" height="13" rx="3"/><rect x="31" y="6" width="2.5" height="5" rx="1" fill="' + fg + '" stroke="none"/><rect x="3" y="4" width="20" height="9" rx="1.5" fill="' + fg + '" stroke="none"/></svg>'
    + '</span>';
  document.body.appendChild(sb);
  var nav = document.createElement('div'); nav.id = 'vddb-nav';
  var mu = getComputedStyle(document.documentElement).getPropertyValue('--muted').trim() || '#9aa4b2';
  nav.innerHTML = ''
    + '<svg width="17" height="17" viewBox="0 0 24 24" fill="' + mu + '"><path d="M15 5l-8 7 8 7z"/></svg>'
    + '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="' + mu + '" stroke-width="2"><circle cx="12" cy="12" r="9"/></svg>'
    + '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="' + mu + '" stroke-width="2"><rect x="4" y="4" width="16" height="16" rx="2"/></svg>';
  document.body.appendChild(nav);
})();
"""


def serve(directory):
    handler = lambda *a, **k: SimpleHTTPRequestHandler(*a, directory=directory, **k)
    httpd = socketserver.ThreadingTCPServer(("127.0.0.1", 0), handler)
    httpd.daemon_threads = True
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    return httpd, httpd.server_address[1]


def main(argv):
    version = module_version()
    fixtures = build_fixtures(version)
    fix_json = json.dumps(fixtures, ensure_ascii=False)
    httpd, port = serve(WEBROOT)
    base = "http://127.0.0.1:%d/index.html" % port
    os.makedirs(OUTDIR, exist_ok=True)
    total = 0
    with sync_playwright() as pw:
        browser = pw.chromium.launch(channel="chrome", headless=True,
                                     args=["--force-color-profile=srgb"])
        try:
            for lang in LANGS:
                ctx = browser.new_context(viewport=VIEWPORT, device_scale_factor=SCALE,
                                          locale=lang, color_scheme="dark")
                page = ctx.new_page()
                page.add_init_script(MOCK_JS % fix_json)
                page.goto(base, wait_until="networkidle")
                page.wait_for_timeout(600)   # let init() + helper microtasks settle
                page.evaluate(CHROME_JS)
                for tab, name in SCREENS:
                    page.evaluate("(t) => { var b = document.querySelector('#tabbtn-'+t); if (b) b.click(); }", tab)
                    page.wait_for_timeout(350)
                    page.evaluate("() => window.scrollTo(0, 0)")
                    page.wait_for_timeout(120)
                    out = os.path.join(OUTDIR, "%s.png" % name)
                    page.screenshot(path=out)
                    total += 1
                ctx.close()
        finally:
            browser.close()
    httpd.shutdown()
    print("done: %d PNGs (EN) at version %s -> %s" % (total, version, OUTDIR))


if __name__ == "__main__":
    main(sys.argv)
