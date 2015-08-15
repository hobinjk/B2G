#!/system/bin/sh
cd /system/dalvy-walvy
echo "zygote: $ANDROID_SOCKET_zygote"
LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH" NO_ADDR_COMPAT_LAYOUT_FIXUP=1 exec ./app_process -Xzygote /system/bin --zygote --start-system-server
