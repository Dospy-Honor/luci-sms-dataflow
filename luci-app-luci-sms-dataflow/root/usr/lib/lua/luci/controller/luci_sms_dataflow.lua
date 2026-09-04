module("luci.controller.luci_sms_dataflow", package.seeall)

function index()
	if not nixio.fs.access("/usr/libexec/luci-sms-dataflow") then
		return
	end

	entry({ "admin", "services", "sms-dataflow" }, call("action_index"), _("短信定时与读取"), 60).dependent = false
	entry({ "admin", "services", "sms-dataflow", "modules" }, call("action_modules")).leaf = true
	entry({ "admin", "services", "sms-dataflow", "send" }, call("action_send")).leaf = true
	entry({ "admin", "services", "sms-dataflow", "read" }, call("action_read")).leaf = true
	entry({ "admin", "services", "sms-dataflow", "schedule" }, call("action_schedule")).leaf = true
	entry({ "admin", "services", "sms-dataflow", "interval" }, call("action_interval")).leaf = true
end

function action_index()
	require("luci.template").render("sms-dataflow/main")
end

local function run(action, ...)
	local util = require "luci.util"
	local http = require "luci.http"
	local sys = require "luci.sys"
	local command = "/usr/libexec/luci-sms-dataflow " .. util.shellquote(action)

	for _, value in ipairs({ ... }) do
		command = command .. " " .. util.shellquote(value or "")
	end

	http.prepare_content("application/json")
	http.write(sys.exec(command))
end

function action_modules()
	run("modules")
end

function action_send()
	local http = require "luci.http"
	run("send", http.formvalue("module"), http.formvalue("preset"))
end

function action_read()
	local http = require "luci.http"
	run("read", http.formvalue("module"))
end

function action_schedule()
	local http = require "luci.http"
	run("add-schedule", http.formvalue("module"), http.formvalue("preset"), http.formvalue("time"))
end

function action_interval()
	local http = require "luci.http"
	run("add-interval", http.formvalue("module"), http.formvalue("preset"), http.formvalue("minutes"))
end
