PRODUCT_OUT=$B2G_HOME/out/target/product/flame
adb root
sleep 2
adb shell "mount -o rw,remount /system"
adb push $PRODUCT_OUT/system/app /system/app
adb push $PRODUCT_OUT/system/priv-app /system/priv-app
adb push $PRODUCT_OUT/system/framework /system/framework
ROOT=/system/dalvy-walvy
adb shell "mkdir $ROOT"
adb push $PRODUCT_OUT/system/bin/app_process $ROOT/
adb push $PRODUCT_OUT/system/lib/ $ROOT/
adb push $PRODUCT_OUT/system/lib/libart.so $ROOT/libdvm.so
adb push $PRODUCT_OUT/system/bin/am $ROOT/
adb push $PRODUCT_OUT/system/bin/surfaceflinger $ROOT/
adb push $PRODUCT_OUT/system/bin/dex2oat /system/bin/
adb push dexopt /system/bin/
adb push $PRODUCT_OUT/system/bin/dexopt $ROOT/
adb shell ln -s /system/dalvy-walvy/app_process /system/bin/app_process
adb push zygote.sh /system/bin/

adb shell mv /system/bin/settings $ROOT/
adb push settings /system/bin
adb reboot
