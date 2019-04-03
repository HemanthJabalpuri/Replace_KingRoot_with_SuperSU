#!/system/bin/sh

exec 2>/sdcard/mrw/suinstall.log

# Source files.sh
. /sdcard/mrw/files.sh

echo; echo -e $B"Cleaning..."$N
remove_king

echo; echo -e $B"Cleaning..."$N
remove_king

echo; echo -e $B"Cleaning..."$N
remove_king

# SuperSU installation
mount -o remount,rw /

mkdir /dev/tmp || abort "Unable to create /dev/tmp, aborting"


sh /sdcard/mrw/update-binary "dummy" "1" "/sdcard/mrw/SuperSU-v2.82-SR5-20171001.zip" 2>/sdcard/mrw/supersu.log

if [ -f /system/xbin/su -a -f /system/lib/libsupol.so ]; then
  echo; echo -e $G"* ${C}the device will reboot after a few seconds${N}${G} *"$N
  echo; echo -e $G"**********************************************"$N
  (sleep 8; /system/bin/reboot)&
fi

echo; echo "Finished"; echo
