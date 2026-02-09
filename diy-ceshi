#!/bin/bash

# 移除要替换的包
# 移除luci-app-attendedsysupgrade软件包
sed -i "/attendedsysupgrade/d" $(find ./feeds/luci/collections/ -type f -name "Makefile")

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
#git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
#git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush package/luci-app-wechatpush
#git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky
#git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash
git_sparse_clone master https://github.com/kenzok8/openwrt-packages luci-app-adguardhome adguardhome
git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-onliner
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-floatip floatip
git_sparse_clone main https://github.com/kiddin9/kwrt-packages  luci-app-lucky lucky

# MosDNS
#git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns

echo "
# 插件
CONFIG_PACKAGE_luci-app-adguardhome=y
CONFIG_PACKAGE_luci-app-floatip=y
CONFIG_PACKAGE_luci-app-lucky=y
CONFIG_PACKAGE_luci-app-onliner=y
" >> .config

# 修改默认IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 网卡补丁
cat 731-net-aqr108-new.patch 
--- a/drivers/net/phy/aquantia/aquantia_main.c
+++ b/drivers/net/phy/aquantia/aquantia_main.c
@@ -34,6 +34,7 @@
 #define PHY_ID_AQR813  0x31c31cb2
 #define PHY_ID_AQR112C 0x03a1b790
 #define PHY_ID_AQR112R 0x31c31d12
+#define PHY_ID_AQR108   0x03a1b4f0
 
 #define MDIO_PHYXS_VEND_IF_STATUS              0xe812
 #define MDIO_PHYXS_VEND_IF_STATUS_TYPE_MASK    GENMASK(7, 3)
@@ -1231,6 +1232,24 @@ static struct phy_driver aqr_driver[] =
        .get_strings    = aqr107_get_strings,
        .get_stats      = aqr107_get_stats,
 },
+{
+       PHY_ID_MATCH_MODEL(PHY_ID_AQR108),
+       .name           = "Aquantia AQR108",
+       .probe          = aqr107_probe,
+       .config_init    = aqr107_config_init,
+       .config_aneg    = aqr_config_aneg,
+       .config_intr    = aqr_config_intr,
+       .handle_interrupt = aqr_handle_interrupt,
+       .read_status    = aqr107_read_status,
+       .get_tunable    = aqr107_get_tunable,
+       .set_tunable    = aqr107_set_tunable,
+       .suspend        = aqr107_suspend,
+       .resume         = aqr107_resume,
+       .get_sset_count = aqr107_get_sset_count,
+       .get_strings    = aqr107_get_strings,
+       .get_stats      = aqr107_get_stats,
+       .link_change_notify = aqr107_link_change_notify,
+},
 };

cat 731-net-aq-macsec.patch  
--- a/drivers/net/phy/aquantia/Makefile
+++ b/drivers/net/phy/aquantia/Makefile
@@ -1,0 +2,1 @@
+aquantia-objs                   += aqr_macsec/aqr_macsec.o

./scripts/feeds update -a
./scripts/feeds install -a
