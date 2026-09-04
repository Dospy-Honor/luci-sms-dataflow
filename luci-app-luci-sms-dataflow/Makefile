include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-luci-sms-dataflow
PKG_VERSION:=1.0.11
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_MAINTAINER:=Luci SMS Dataflow

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Traffic remaining detection for QModem via tom_modem
  DEPENDS:=+tom_modem +jsonfilter
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
Standalone uhttpd interface for sending fixed PDU SMS presets exclusively with
tom_modem. QModem supplies module metadata.
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/luci-sms-dataflow
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/luci-sms-dataflow $(1)/etc/config/luci-sms-dataflow
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) ./root/usr/libexec/luci-sms-dataflow $(1)/usr/libexec/luci-sms-dataflow
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/luci-sms-dataflow $(1)/etc/init.d/luci-sms-dataflow
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) ./root/www/cgi-bin/luci-sms-dataflow $(1)/www/cgi-bin/luci-sms-dataflow
	$(INSTALL_DIR) $(1)/www/sms-dataflow
	$(INSTALL_DATA) ./root/www/sms-dataflow/index.html $(1)/www/sms-dataflow/index.html
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./root/usr/lib/lua/luci/controller/sms_dataflow_menu.lua $(1)/usr/lib/lua/luci/controller/sms_dataflow_menu.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/sms-dataflow
	$(INSTALL_DATA) ./root/usr/lib/lua/luci/view/sms-dataflow/menu.htm $(1)/usr/lib/lua/luci/view/sms-dataflow/menu.htm
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] && exit 0
rm -f /usr/lib/lua/luci/controller/luci_sms_dataflow.lua
rm -f /usr/lib/lua/luci/view/sms-dataflow/main.htm
rm -rf /tmp/luci-indexcache
[ -x /etc/init.d/uhttpd ] && /etc/init.d/uhttpd restart
exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
