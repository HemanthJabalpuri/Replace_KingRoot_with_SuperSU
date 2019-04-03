#!/system/bin/sh

rm -rf /data/app/*kinguser*
rm -rf /data/data/*kinguser*
rm -rf /data/dalvik-cache/*kinguser*
rm -rf /data/dalvik-cache/*/*kinguser*
rm -rf /data/app-lib/*kinguser*
rm -rf /data/app-lib/uranus/*kinguser*
rm -rf /data/data-lib/*kinguser*
rm -rf /data/data-lib/uranus/*kinguser*
rm -rf /data/local/tmp/*uranus*
rm -rf /data/system/*uranus*

rm -rf /storage/*/Android/data/*kinguser*
rm -rf /storage/*/Android/obb/*kinguser*
rm -rf /storage/*/Android/media/*kinguser*
rm -rf /storage/emulated/obb/*kinguser*
rm -rf /data/media/obb/*kinguser*
rm -rf /sdcard/*kinguser*


# Kingoroot
rm -rf /system/app/*Kingo*
rm -rf /data/app/*kingo*
rm -rf /data/data/*kingo*
rm -rf /data/dalvik-cache/*kingo*
rm -rf /data/dalvik-cache/*/*kingo*
rm -rf /data/app-lib/*kingo*
rm -rf /data/data-lib/*kingo*
rm -rf /data/data-lib/uranus/*kingo*
rm -rf /storage/*/Android/data/*kingo*
rm -rf /storage/*/Android/obb/*kingo*
rm -rf /storage/*/Android/media/*kingo*
rm -rf /storage/emulated/obb/*kingo*
rm -rf /data/media/obb/*kingo*
rm -rf /sdcard/*kingo*

LD_LIBRARY_PATH=/vendor/lib:/system/lib am kill com.kingroot.kinguser
LD_LIBRARY_PATH=/vendor/lib:/system/lib pm uninstall com.kingroot.kinguser
