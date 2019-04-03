#!/system/bin/sh

id="$(id)"; id="${id#*=}"; id="${id%%\(*}"; id="${id%% *}"
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
  clear
  echo ""
  echo "Type su and then execute"
  sleep 2
  clear
  exit 1
fi

exec 2>/sdcard/mrw/root.log

echo "---------------------------------------"
echo "---------- Made By : Mr.W0lf ----------"
echo "---- Thanks @Chainfire for SuperSU ----"
echo "---------------------------------------"

mount -o remount,rw /system

if [ ! -f /system/xbin/busybox -o ! -e /system/bin/busybox ]; then
  if [ -f /sdcard/mrw/busybox ]; then
    cp /sdcard/mrw/busybox /system/xbin/busybox
    /system/xbin/busybox --install -s /system/xbin
  fi
fi

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

if [ -f /system/etc/install-recovery.sh-ku.bak ]; then
  chattr -ia /system/etc/install-recovery.sh
  chattr -ia /system/etc/install-recovery.sh-ku.bak
  mv /system/etc/install-recovery.sh-ku.bak /system/etc/install-recovery.sh
elif [ -f /system/etc/install-recovery.sh ] && grep -q su /system/etc/install-recovery.sh
then
  chattr -ia /system/etc/install-recovery.sh
  rm -f /system/etc/install-recovery.sh
  chattr -ia /system/bin/install-recovery.sh
  rm -f /system/bin/install-recovery.sh
fi
if [ -f /system/bin/ddexe_real -o -f /system/bin/ddexe-ku.bak ]; then
  chattr -ia /system/bin/ddexe_real
  chattr -ia /system/bin/ddexe-ku.bak
  chattr -ia /system/bin/ddexe
  mv /system/bin/ddexe_real /system/bin/ddexe || mv /system/bin/ddexe-ku.bak /system/bin/ddexe
  chattr -ia /system/bin/ddexe_real
  rm -f /system/bin/ddexe_real /system/bin/ddexe-ku.bak
fi
if [ -f /system/bin/rt.sh ]; then
  rm -f /system/bin/rt.sh
fi
if [ -d /system/bin/.usr -a -f /system/bin/.usr/.ku ]; then
  chattr -ia /system/bin/.usr/.ku
  rm -rf /system/bin/.usr
fi
if [ -d /system/usr/iku -a -f /system/usr/iku/isu ]; then
  chattr -ia /system/usr/iku/isu
  rm -rf /system/usr/iku
fi
for i in ku.sud ku.sud.tmp su supolicy daemonsu; do
  if [ -e /system/xbin/$i ]; then
    chattr -ia /system/xbin/$i
    rm -f /system/xbin/$i
  fi
  if [ -e /system/bin/$i ]; then
    chattr -ia /system/bin/$i
    rm -f /system/bin/$i
  fi
done

for i in /dev/kinguser.req.cache/*; do
  chattr -ia $i
done
rm -rf /dev/kinguser.req.cache /dev/ktools

# Kingo
if [ -f /system/sbin/su ]; then
  chattr -ia /system/sbin/su
  rm -f /system/sbin/su
fi
if [ -d /system/bin/.ext -a -f /system/bin/.ext/.su ]; then
  chattr -ia /system/bin/.ext/.su
  rm -f /system/bin/.ext/.su
  rmdir /system/bin/.ext
fi
if [ -f /system/etc/init.d/99SuperSUDaemon ]; then
  chattr -ia /system/etc/init.d/99SuperSUDaemon
  rm -f /system/etc/init.d/99SuperSUDaemon
fi
if [ -f /system/lib/libsupol.so ]; then
  chattr -ia /system/lib/libsupol.so
  rm -f /system/lib/libsupol.so
fi
if [ -f /system/etc/.has_su_daemon ]; then
  chattr -ia /system/etc/.has_su_daemon
  rm -f /system/etc/.has_su_daemon
fi
if [ -f /system/etc/.installed_su_daemon ]; then
  chattr -ia /system/etc/.installed_su_daemon
  rm -f /system/etc/.installed_su_daemon
fi
if [ -f /system/etc/install_recovery.sh ]; then
  chattr -ia /system/etc/install_recovery.sh
  rm -f /system/etc/install_recovery.sh
fi

# Second time cleaning to destroy all
while [ -L /system/bin/su ]; do
  echo "Cleaning ..."
  rm -rf /data/app/*kinguser*
  rm -rf /data/data/*kinguser*
  rm -rf /data/dalvik-cache/*kinguser*
  rm -rf /data/dalvik-cache/*/*kinguser*
  rm -rf /data/app-lib/*kinguser*
  rm -rf /data/app-lib/uranus/*kinguser*
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
done

echo "Finished Cleaning King(o)Root"
echo "Execute suinstall.sh to install supersu"
