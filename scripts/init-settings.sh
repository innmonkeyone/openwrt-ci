#!/bin/bash

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

# Disable IPV6 ula prefix
# sed -i 's/^[^#].*option ula/#&/' /etc/config/network

# --- 自定义 Overlay 迁移逻辑开始 ---

TARGET_DEV="/dev/mmcblk0p10"
MOUNT_POINT="/mnt/mmcblk0p10"
FLAG_FILE="/overlay/.migration_done"

# 1. 检查是否已执行过迁移
if [ ! -f "$FLAG_FILE" ]; then
    echo "Detected first boot or un-migrated state. Starting migration..."

    # 2. 确保目标分区存在且未挂载
    if [ -b "$TARGET_DEV" ]; then
        # 尝试挂载
        mkdir -p "$MOUNT_POINT"
        mount "$TARGET_DEV" "$MOUNT_POINT" 2>/dev/null
        
        if mountpoint -q "$MOUNT_POINT"; then
            # 3. 执行复制 (保留权限和属性)
            echo "Copying /overlay to $TARGET_DEV ..."
            cp -a /overlay/. "$MOUNT_POINT/"
            
            # 4. 卸载目标分区
            umount "$MOUNT_POINT"
            
            # 5. 创建标志文件，防止下次重启再次复制
            touch "$FLAG_FILE"
            echo "Migration completed. Flag file created."
        else
            echo "Failed to mount $TARGET_DEV. Skipping migration."
        fi
    else
        echo "Target device $TARGET_DEV not found. Skipping migration."
    fi
else
    echo "Migration flag found. Skipping copy operation."
fi

# --- 自定义 Overlay 迁移逻辑结束 ---


# Check file system during boot
# uci set fstab.@global[0].check_fs=1
# uci commit fstab
uci set fstab.@global.anon_swap='0'
uci set fstab.@global.anon_mount='1'
uci set fstab.@global.auto_swap='1'
uci set fstab.@global.auto_mount='1'
uci set fstab.@global.delay_root='5'
uci set fstab.@global.check_fs='0'
# 设置目标挂载点
uci set fstab.@mount.target='/overlay'
# 设置分区 UUID
uci set fstab.@mount.uuid='060db9db-61f3-42ce-b751-3bd9946f96c9'
# 禁用此挂载项 (enabled '0')
uci set fstab.@mount.enabled='0'
uci commit fstab

exit 0
