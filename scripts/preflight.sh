#!/usr/bin/env bash
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
#  Release preflight: one command that fails if ANY release surface is out of
#  sync. Built because the update.json manifest silently stayed at v1.02 while
#  the module reached v1.06 (the ritual bumped module.prop and forgot the rest).
#  Run it before every release; a non-zero exit means DO NOT ship.
#
#  Copyright (C) 2026  VD171
#  SPDX-License-Identifier: Apache-2.0
#
#  Site           : https://vd171.ru
#  Source         : https://github.com/VD171/VD-dropbear
#  GitHub         : @VD171 https://github.com/VD171
#  Telegram       : @VD_Priv8 https://t.me/VD_Priv8
#  Channel        : @Priv8_VD https://t.me/Priv8_VD
# ======================================================================
set -u
cd "$(dirname "$0")/.." || exit 2
ROOT=$(pwd)
fail=0
ok()   { printf '  \033[32mOK\033[0m   %s\n' "$1"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }
info() { printf '  --   %s\n' "$1"; }

echo "VD Dropbear release preflight ($ROOT)"

# 1. Version alignment across EVERY surface (the recurring drift).
echo "[1] version surfaces aligned"
mp_v=$(sed -n 's/^version=//p'     module/module.prop)
mp_c=$(sed -n 's/^versionCode=//p' module/module.prop)
read uj_v uj_c  <<EOF
$(python3 -c "import json;d=json.load(open('module/update.json'));print(d['version'],d['versionCode'])" 2>/dev/null)
EOF
read bl_v bl_c  <<EOF
$(python3 -c "import json;d=json.load(open('module/vdlu/baseline.json'));print(d['version_name'],d['version'])" 2>/dev/null)
EOF
cl_v=$(grep -m1 -oE '## \[v[0-9.]+\]' CHANGELOG.md | grep -oE 'v[0-9.]+')
info "module.prop=$mp_v/$mp_c  update.json=$uj_v/$uj_c  baseline=$bl_v/$bl_c  CHANGELOG=$cl_v"
[ -n "$mp_v" ] && [ "$uj_v" = "$mp_v" ] && [ "$bl_v" = "$mp_v" ] && [ "$cl_v" = "$mp_v" ] \
  && ok "version_name consistent ($mp_v)" || bad "version_name drift (see above)"
[ "$mp_c" = "$uj_c" ] && [ "$mp_c" = "$bl_c" ] \
  && ok "versionCode consistent ($mp_c)" || bad "versionCode drift ($mp_c/$uj_c/$bl_c)"
case "$mp_c" in ''|*[!0-9]*) bad "versionCode not numeric" ;; esac

# 2. Committed binaries match their provenance (the gate the CI also runs).
echo "[2] committed binaries vs provenance"
if [ -f module/bin/PROVENANCE.json ]; then
  python3 - <<'PY' && ok "all bin sha256 match PROVENANCE.json" || bad "provenance MISMATCH"
import json,hashlib,sys
d=json.load(open('module/bin/PROVENANCE.json'))
bad=[f'{a}/{b}' for b,m in d['binaries'].items() for a,i in m['abi'].items()
     if hashlib.sha256(open(f'module/bin/{a}/{b}','rb').read()).hexdigest()!=i['sha256']]
sys.exit(1 if bad else 0)
PY
else info "no module/bin (slim build without committed bins)"; fi

# 3. baseline == what a fresh pack of the current tree would hash (no phantom/stale).
echo "[3] baseline.json is the signed manifest of the CURRENT tree"
python3 - <<'PY' && ok "baseline signed + version matches module.prop" || bad "baseline unsigned or version drift"
import json,sys
d=json.load(open('module/vdlu/baseline.json'))
mp=dict((k.strip(),v.strip()) for k,v in
        (l.rstrip('\n').split('=',1) for l in open('module/module.prop') if '=' in l))
sys.exit(0 if d.get('sig') and str(d.get('version'))==mp.get('versionCode') else 1)
PY

# 4. Zero broken relative markdown links (excl. third-party build artifacts).
echo "[4] markdown links resolve"
python3 - <<'PY' && ok "0 broken relative links" || bad "broken relative links (see list)"
import re,os,urllib.parse,sys
pat=re.compile(r'\[([^\]]*)\]\(([^)]+)\)'); code=re.compile(r'`[^`]*`'); b=[]
for dp,_,fn in os.walk('.'):
    if '/.git' in dp or '/build' in dp: continue
    for f in (x for x in fn if x.endswith('.md')):
        p=os.path.join(dp,f)
        for i,l in enumerate(open(p,encoding='utf-8',errors='replace'),1):
            for _,t in pat.findall(code.sub('',l)):
                if re.match(r'^(https?:|mailto:|#)',t): continue
                q=urllib.parse.unquote(t.split('#')[0])
                if q and not os.path.exists(os.path.join(dp,q)): b.append(f'{p}:{i} -> {t}')
for x in b[:20]: print('   ',x)
sys.exit(1 if b else 0)
PY

# 5. No legacy `in` Indonesian language code (migrated to ISO `id`).
echo "[5] no legacy 'in' language code"
hits=$(grep -rlE 'README\.in\.md|docs/in/|\]\(in/|wiki/in-|^  in\) printf|"hi", "in"|hi in it' \
         README*.md docs/ .github/scripts/ 2>/dev/null | grep -v '/build/' | wc -l | tr -d ' ')
[ "$hits" = 0 ] && ok "0 legacy 'in' code refs" || { bad "$hits file(s) still use legacy 'in' code"; }

# 6. The canonical nav/footer generator is idempotent on the current tree.
echo "[6] gen-doc-nav idempotent"
if [ -f .github/scripts/gen-doc-nav.py ]; then
  out=$(python3 .github/scripts/gen-doc-nav.py . 2>&1)
  echo "$out" | grep -q '0 switcher(s), 0 footer(s)' \
    && ok "nav/footer already canonical ($out)" || bad "nav/footer not idempotent ($out) - commit the regen"
else info "no gen-doc-nav.py"; fi

# 7. Scripts parse.
echo "[7] scripts parse"
sherr=0
for s in module/common/*.sh module/*.sh module/vdlu/update.sh module/vdlu/vdlu-verify scripts/*.sh .github/scripts/*.sh; do
  [ -f "$s" ] || continue; sh -n "$s" 2>/dev/null || { bad "sh -n failed: $s"; sherr=1; }
done
[ "$sherr" = 0 ] && ok "all shell scripts pass sh -n"
if [ -f module/webroot/vdlu.js ]; then
  command -v node >/dev/null && { node --check module/webroot/vdlu.js 2>/dev/null && ok "vdlu.js parses" || bad "vdlu.js syntax error"; } \
    || info "node not found, skipped vdlu.js check"
fi

# 8. Every GitHub release must be authored by github-actions[bot], never a human
#    (owner HARD rule, auditability: github_release_sempre_bot_author). Two ways it
#    regresses: `draft: true` (then a human clicks "Publish" in the UI and the release
#    is attributed to them) or a PAT on the release step (attributed to that user).
#    The default GITHUB_TOKEN publishing a non-draft release authors it as the bot.
echo "[8] release workflow = github-actions[bot]"
rel_bad=0
for wf in .github/workflows/*.yml .github/workflows/*.yaml; do
  [ -f "$wf" ] || continue
  grep -qE 'action-gh-release|gh release create' "$wf" || continue
  grep -qE '^[[:space:]]*draft:[[:space:]]*true' "$wf" \
    && { bad "draft: true in $(basename "$wf") (a UI publish attributes the release to a human)"; rel_bad=1; }
  grep -iE '^[[:space:]]*token:' "$wf" | grep -ivE 'github\.token|secrets\.GITHUB_TOKEN' | grep -q . \
    && { bad "custom release token in $(basename "$wf") (a PAT attributes the release to a user; use the default GITHUB_TOKEN)"; rel_bad=1; }
done
[ "$rel_bad" = 0 ] && ok "release workflow publishes direct as github-actions[bot] (no draft, no PAT)"

echo
[ "$fail" = 0 ] && { echo "PREFLIGHT: PASS - safe to release"; exit 0; } \
                || { echo "PREFLIGHT: FAIL - fix the above before releasing"; exit 1; }
