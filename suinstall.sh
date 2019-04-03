#!/system/bin/sh

exec 2>/sdcard/mrw/suinstall.log

echo "Cleaning..."
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
for i in /dev/kinguser.req.cache/*; do
  chattr -ia $i
done
rm -rf /dev/kinguser.req.cache
rm -f /dev/ktools
LD_LIBRARY_PATH=/vendor/lib:/system/lib am kill com.kingroot.kinguser
LD_LIBRARY_PATH=/vendor/lib:/system/lib pm uninstall com.kingroot.kinguser
rm -f /system/bin/su /system/xbin/su /system/xbin/supolicy
if [ -f /system/bin/ddexe_real -o -f /system/bin/ddexe-ku.bak ]; then
  chattr -ia /system/bin/ddexe_real
  chattr -ia /system/bin/ddexe-ku.bak
  chattr -ia /system/bin/ddexe
  mv /system/bin/ddexe_real /system/bin/ddexe || mv /system/bin/ddexe-ku.bak /system/bin/ddexe
  chattr -ia /system/bin/ddexe_real
  chattr -ia /system/bin/ddexe-ku.bak
  rm -f /system/bin/ddexe_real /system/bin/ddexe-ku.bak
fi
if [ -f /system/etc/install-recovery.sh ] && grep -q ku.sud /system/etc/install-recovery.sh
then
  chattr -ia /system/etc/install-recovery.sh
  rm -f /system/etc/install-recovery.sh
  chattr -ia /system/bin/install-recovery.sh
  rm -f /system/bin/install-recovery.sh
fi

while true; do
  echo "Cleaning..."
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
  for i in /dev/kinguser.req.cache/*; do
    chattr -ia $i
  done
  rm -rf /dev/kinguser.req.cache
  rm -f /dev/ktools
  LD_LIBRARY_PATH=/vendor/lib:/system/lib am kill com.kingroot.kinguser
  LD_LIBRARY_PATH=/vendor/lib:/system/lib pm uninstall com.kingroot.kinguser
  rm -f /system/bin/su /system/xbin/su /system/xbin/supolicy
  if [ -f /system/bin/ddexe_real -o -f /system/bin/ddexe-ku.bak ]; then
    chattr -ia /system/bin/ddexe_real
    chattr -ia /system/bin/ddexe-ku.bak
    chattr -ia /system/bin/ddexe
    mv /system/bin/ddexe_real /system/bin/ddexe || mv /system/bin/ddexe-ku.bak /system/bin/ddexe
    chattr -ia /system/bin/ddexe_real
    chattr -ia /system/bin/ddexe-ku.bak
    rm -f /system/bin/ddexe_real /system/bin/ddexe-ku.bak
  fi
  if [ -f /system/etc/install-recovery.sh ] && grep -q ku.sud /system/etc/install-recovery.sh
  then
    chattr -ia /system/etc/install-recovery.sh
    rm -f /system/etc/install-recovery.sh
    chattr -ia /system/bin/install-recovery.sh
    rm -f /system/bin/install-recovery.sh
  fi
  LD_LIBRARY_PATH=/vendor/lib:/system/lib am kill com.kingroot.kinguser
  LD_LIBRARY_PATH=/vendor/lib:/system/lib pm uninstall com.kingroot.kinguser
  sleep 1
  if [ ! -L /system/bin/su ]; then
    break
  fi
done

echo "Cleaning..."
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
for i in /dev/kinguser.req.cache/*; do
  chattr -ia $i
done
rm -rf /dev/kinguser.req.cache
rm -f /dev/ktools
LD_LIBRARY_PATH=/vendor/lib:/system/lib am kill com.kingroot.kinguser
LD_LIBRARY_PATH=/vendor/lib:/system/lib pm uninstall com.kingroot.kinguser
rm -f /system/bin/su /system/xbin/su /system/xbin/supolicy
if [ -f /system/bin/ddexe_real -o -f /system/bin/ddexe-ku.bak ]; then
  chattr -ia /system/bin/ddexe_real
  chattr -ia /system/bin/ddexe-ku.bak
  chattr -ia /system/bin/ddexe
  mv /system/bin/ddexe_real /system/bin/ddexe || mv /system/bin/ddexe-ku.bak /system/bin/ddexe
  chattr -ia /system/bin/ddexe_real
  chattr -ia /system/bin/ddexe-ku.bak
  rm -f /system/bin/ddexe_real /system/bin/ddexe-ku.bak
fi
if [ -f /system/etc/install-recovery.sh ] && grep -q ku.sud /system/etc/install-recovery.sh
then
  chattr -ia /system/etc/install-recovery.sh
  rm -f /system/etc/install-recovery.sh
  chattr -ia /system/bin/install-recovery.sh
  rm -f /system/bin/install-recovery.sh
fi
LD_LIBRARY_PATH=/vendor/lib:/system/lib am kill com.kingroot.kinguser
LD_LIBRARY_PATH=/vendor/lib:/system/lib pm uninstall com.kingroot.kinguser

# SuperSU installation
mount -o remount,rw /
mkdir /tmp || exit 1
sh /sdcard/mrw/update-binary "dummy" "1" "/sdcard/mrw/SuperSU-v2.46.zip" 2>/sdcard/mrw/supersu.log

if [ -f /system/xbin/su -o -f /system/lib/libsupol.so ]; then
  echo "* the device will reboot after a few seconds *"
  echo "**********************************************"
  (sleep 8; /system/bin/reboot)&
fi

echo "Finished"

