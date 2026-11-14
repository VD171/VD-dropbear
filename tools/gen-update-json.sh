#!/usr/bin/env sh
# Generate module/update.json from module.prop (single source of version/versionCode).
# Run it in the release ritual: bump module.prop, run this, then publish the GitHub release.
set -e
cd "$(dirname "$0")/.."
ver=$(grep '^version=' module/module.prop | cut -d= -f2)
vc=$(grep '^versionCode=' module/module.prop | cut -d= -f2)
cat > module/update.json <<EOF
{
  "version": "$ver",
  "versionCode": $vc,
  "zipUrl": "https://github.com/VD171/VD-dropbear/releases/download/$ver/VD-dropbear-$ver.zip",
  "changelog": "https://raw.githubusercontent.com/VD171/VD-dropbear/master/CHANGELOG.md"
}
EOF
echo "module/update.json generated: $ver ($vc)"
