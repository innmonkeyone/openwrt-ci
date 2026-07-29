#!/bin/bash

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

# Disable IPV6 ula prefix
# sed -i 's/^[^#].*option ula/#&/' /etc/config/network

# Check file system during boot
# uci set fstab.@global[0].check_fs=1
# uci commit fstab

# nginx
uci set nginx.global.uci_enable='true'
uci del nginx._lan
uci del nginx._redirect2ssl
uci add nginx server
uci rename nginx.@server[0]='_lan'
uci set nginx._lan.server_name='_lan'
uci add_list nginx._lan.listen='80 default_server'
uci add_list nginx._lan.listen='[::]:80 default_server'
#uci add_list nginx._lan.include='restrict_locally'
uci add_list nginx._lan.include='conf.d/*.locations'
uci set nginx._lan.access_log='off; # logd openwrt'
uci commit nginx
service nginx restart

exit 0
