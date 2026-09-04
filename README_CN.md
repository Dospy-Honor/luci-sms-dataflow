# LuCI 流量剩余检测


适用于 QWRT / OpenWrt + QModem 的 Web 短信工具。它使用 uhttpd 原生 CGI，不依赖 LuCI dispatcher 或 `sms_tool_q`，且所有短信 I/O 都严格使用 `tom_modem`：

- 发送：通过所选 section 的 AT 端口调用 `tom_modem -D -d <tty> -o s -p <PDU>`
- 读取：通过同一 AT 端口调用 `tom_modem -d <tty> -o r`
- 最新短信：先写入 `/tmp/sms_temp.json`，按最大 `index` 向下收集连续同 `reference` 分片，再按 `part` 排序写入 `/tmp/sms.json`；成功后删除临时文件
- 解析：使用 `jq` 解析 `/tmp/sms.json`，并在 LuCI 页面中显示最新短信、剩余流量、流量概览和分钟定时发送功能

## 目录

```
luci-app-luci-sms-dataflow/
  Makefile                         OpenWrt 软件包定义
  root/etc/config/luci-sms-dataflow 四个 PDU 预设配置
  root/usr/libexec/luci-sms-dataflow 后端命令
  root/usr/lib/lua/luci/controller/  HTTP API 路由
  htdocs/luci-static/resources/view/ LuCI 前端页面
```

## 配置预设

安装后填入实际 PDU：

```sh
uci set luci-sms-dataflow.preset1.pdu='YOUR_PDU'
uci set luci-sms-dataflow.preset1.name='标准短信 1'
uci commit luci-sms-dataflow
```

四个内置预设为中国电信 `00010005810100F100000431182E07`、中国移动 `0001000581100806F0000004633C9B0D`、中国联通 `0001000581100100F0000004633C9B0D`、中国广电 `0001000581100809F0000004633C9B0D`。PDU 仅允许十六进制字符。

在页面中填写分钟间隔并开启定时功能后，服务会自动启用。每次开启会替换上一条分钟定时规则；执行日志位于 `logread`（标签 `luci-sms-dataflow`）。

## 构建

### 无 SDK 打包

本项目不含原生二进制或内核模块，可在 Linux 中直接生成 `all` 架构 IPK：

```sh
chmod +x build-ipk.sh
./build-ipk.sh
```

生成文件为 `dist/luci-app-luci-sms-dataflow_1.0.11-1_all.ipk`。每次立即或定时检测均会发送 PDU、等待 15 秒、自动读取短信并更新 `/tmp/sms.json`。流量概览会显示该文件的最后更新时间。可在 LuCI 的“服务 → 实时剩余流量检测”进入，或直接访问 `http://<路由器IP>/sms-dataflow/`。
