# LuCI Remaining Traffic Monitor

[简体中文](README_CN.md)

A web-based SMS utility for QWRT / OpenWrt with QModem. It uses native uhttpd
CGI, does not depend on the LuCI dispatcher or `sms_tool_q`, and performs all
SMS I/O strictly through `tom_modem`:

- **Sending:** Calls `tom_modem -D -d <tty> -o s -p <PDU>` using the AT port
  resolved from the selected QModem UCI section.
- **Reading:** Calls `tom_modem -d <tty> -o r` using the same AT port.
- **Latest SMS:** First saves the complete modem response to
  `/tmp/sms_temp.json`. It then starts from the highest `index`, collects
  consecutive fragments with the same `reference`, sorts them by `part`,
  and writes the result to `/tmp/sms.json`. The temporary file is removed
  after a successful operation.
- **Parsing:** Uses `jq` to parse `/tmp/sms.json`, and shows the latest SMS,
  remaining traffic, a traffic overview, and minute-based scheduled sending in
  the LuCI page.

## Layout

```text
luci-app-luci-sms-dataflow/
  Makefile                         OpenWrt package definition
  root/etc/config/luci-sms-dataflow Four PDU preset definitions
  root/usr/libexec/luci-sms-dataflow Backend commands
  root/usr/lib/lua/luci/controller/  HTTP API routes
  htdocs/luci-static/resources/view/ LuCI frontend
```

## Preset configuration

Set the actual PDU after installation:

```sh
uci set luci-sms-dataflow.preset1.pdu='YOUR_PDU'
uci set luci-sms-dataflow.preset1.name='Standard SMS 1'
uci commit luci-sms-dataflow
```

The four built-in presets are:

- China Telecom: `00010005810100F100000431182E07`
- China Mobile: `0001000581100806F0000004633C9B0D`
- China Unicom: `0001000581100100F0000004633C9B0D`
- China Broadcasting: `0001000581100809F0000004633C9B0D`

PDUs may contain hexadecimal characters only.

Set the interval in minutes on the page and enable the timer to enable the
service automatically. Enabling it replaces the previous minute-based timer.
Runtime logs are available through `logread` under the
`luci-sms-dataflow` tag.

## Build

### SDK-free fallback package build

This project has no native binaries or kernel modules, so an architecture
independent `all` IPK can be built directly on Linux or WSL:

```sh
chmod +x build-ipk.sh
./build-ipk.sh
```

The generated package is
`dist/luci-app-luci-sms-dataflow_1.0.11-1_all.ipk`. Each manual or scheduled
check sends the selected PDU, waits 15 seconds, then reads SMS messages and
updates `/tmp/sms.json`. The traffic overview shows the file's last update
time. Open it in LuCI under **Services → Real-time Remaining Traffic Monitor**,
or visit `http://<router-ip>/sms-dataflow/` directly.
