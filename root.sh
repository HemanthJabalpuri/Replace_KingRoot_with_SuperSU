#!/system/bin/sh

id="$(id)"; id="${id#*=}"; id="${id%%\(*}"; id="${id%% *}"
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
  clear
  echo ""
  echo "Type su and then execute"
  sleep 2
  clear
  exit 1
elif ! [ -e /system/xbin/busybox ]; then
  clear
  echo ""
  echo "Install BusyBox and then execute"
  sleep 2
  clear
  exit 1
fi 

exec 2>/sdcard/mrw/root.log

mount -o remount,rw /system

# Source files.sh
. /sdcard/mrw/files.sh

echo -e $C"---------------------------------------"$N
echo -e $C"---------- ${G}Made By : Mr.W0lf${N}${C} ----------"$N
echo -e $C"---- ${G}Thanks @Chainfire for SuperSU${N}${C} ----"$N
echo -e $C"---------------------------------------"$N

remove_king

# Second time cleaning to destroy all
echo;  echo -e $B"Cleaning ..."$N
remove_king
sleep 1

echo; echo -e $G"Finished Cleaning King(o)Root"$N
echo; echo -e $G"Execute suinstall.sh to install supersu"$N; echo
