#!/bin/sh
# Build a pure-data OpenWrt .ipk without an SDK.
# Run on a Linux host or WSL from this repository root.

set -eu

PACKAGE='luci-app-luci-sms-dataflow'
VERSION='1.0.11-1'
SOURCE_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/$PACKAGE"
OUTPUT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/dist"

for command in gzip tar; do
	command -v "$command" >/dev/null 2>&1 || {
		echo "Missing required command: $command" >&2
		exit 1
	}
done

[ -d "$SOURCE_DIR/root" ] || {
	echo "Package source directory not found: $SOURCE_DIR" >&2
	exit 1
}

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT INT TERM
DATA_DIR="$WORK_DIR/data"
CONTROL_DIR="$WORK_DIR/control"
mkdir -p "$DATA_DIR" "$CONTROL_DIR" "$OUTPUT_DIR"

# Package payload. Legacy LuCI files remain in source for reference but are
# excluded: this fallback package is intentionally independent of dispatcher.
cp -a "$SOURCE_DIR/root/." "$DATA_DIR/"
rm -f "$DATA_DIR/usr/lib/lua/luci/controller/luci_sms_dataflow.lua"
rm -f "$DATA_DIR/usr/lib/lua/luci/view/sms-dataflow/main.htm"
rm -rf "$DATA_DIR/www/luci-static/resources/view/sms-dataflow"
# Source control on Windows may not preserve executable bits.
chmod 0755 "$DATA_DIR/usr/libexec/luci-sms-dataflow" "$DATA_DIR/etc/init.d/luci-sms-dataflow" \
	"$DATA_DIR/www/cgi-bin/luci-sms-dataflow"
chmod 0644 "$DATA_DIR/www/sms-dataflow/index.html" \
	"$DATA_DIR/usr/lib/lua/luci/controller/sms_dataflow_menu.lua" \
	"$DATA_DIR/usr/lib/lua/luci/view/sms-dataflow/menu.htm"

cat >"$CONTROL_DIR/control" <<EOF
Package: $PACKAGE
Version: $VERSION
Architecture: all
Maintainer: Luci SMS Dataflow
Depends: tom_modem
Description: Traffic remaining detection and timer using tom_modem and QModem module metadata.
EOF

cat >"$CONTROL_DIR/conffiles" <<'EOF'
/etc/config/luci-sms-dataflow
EOF

cat >"$CONTROL_DIR/postinst" <<'EOF'
#!/bin/sh
[ -n "$IPKG_INSTROOT" ] && exit 0
rm -f /usr/lib/lua/luci/controller/luci_sms_dataflow.lua
rm -f /usr/lib/lua/luci/view/sms-dataflow/main.htm
rm -rf /tmp/luci-indexcache
[ -x /etc/init.d/uhttpd ] && /etc/init.d/uhttpd restart
exit 0
EOF
chmod 0755 "$CONTROL_DIR/postinst"

printf '2.0\n' >"$WORK_DIR/debian-binary"
tar -C "$CONTROL_DIR" -czf "$WORK_DIR/control.tar.gz" .
tar -C "$DATA_DIR" -czf "$WORK_DIR/data.tar.gz" .

OUTPUT_FILE="$OUTPUT_DIR/${PACKAGE}_${VERSION}_all.ipk"
rm -f "$OUTPUT_FILE"
# OpenWrt's legacy opkg accepts a gzip-compressed outer tar archive. This is
# more broadly compatible with the old QWRT opkg build than a Debian ar file.
tar -C "$WORK_DIR" -czf "$OUTPUT_FILE" ./debian-binary ./data.tar.gz ./control.tar.gz

echo "Created: $OUTPUT_FILE"
