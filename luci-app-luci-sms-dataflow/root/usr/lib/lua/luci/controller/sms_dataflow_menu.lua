module("luci.controller.sms_dataflow_menu", package.seeall)

function index()
	entry({ "admin", "services", "sms-dataflow" }, template("sms-dataflow/menu"), _("实时剩余流量检测"), 60).dependent = false
end
