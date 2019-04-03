#!/system/bin/sh

# @HemanthJabalpuri XDA

# Replace KingRoot or KingoRoot possibly others with SuperSU(<4.2) or with Magisk(greater than 4.1)
# Idea to remove root from terminal with shell script is by Mr.Wolf and edited his script
# +for compatible of newer versions of Kingroot
# Newer versions of KingRoot are capable of recreating deleted files immediately
# For this you need to completely uninstall KingRoot app
# +or delete files of Kingroot in /data will solve this
# My script will do the same thing by deleting all dirs and files of Kingroot
# +and capable of flashing SuperSU directly in booted android without need of custom recovery

##########################################################################################
# Set Variables
##########################################################################################
BL='\e[01;90m' >/dev/null 2>&1; # Black
R='\e[01;91m' >/dev/null 2>&1; # Red
G='\e[01;92m' >/dev/null 2>&1; # Green
Y='\e[01;93m' >/dev/null 2>&1; # Yellow
B='\e[01;94m' >/dev/null 2>&1; # Blue
P='\e[01;95m' >/dev/null 2>&1; # Purple
C='\e[01;96m' >/dev/null 2>&1; # Cyan
W='\e[01;97m' >/dev/null 2>&1; # White
N='\e[0m' >/dev/null 2>&1; # Null

##########################################################################################
# Pre-Checks
##########################################################################################

id="$(id)"; id="${id#*=}"; id="${id%%\(*}"; id="${id%% *}"
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
  clear
  echo; echo -e $R"Type su and then execute"$N
  sleep 2
  clear
  exit 1
fi

getdir() {
  case "$1" in
    */*) dir=${1%/*}; [ -z $dir ] && echo "/" || echo $dir ;;
    *) echo "." ;;
  esac
}
if [ -f "$(getdir "$0")/busybox-arm" ]; then
  bbpath="$(getdir "$0")"
elif [ -f "$PWD/busybox-arm" ]; then
  bbpath="$PWD"
elif [ -f "$(getdir "$(readlink -f "$0")")/busybox-arm" ]; then
  bbpath="$(getdir "$(readlink -f "$0")")"
else
  echo -e $R" Unable to get path of this script.. aborting"$N
  exit 1
fi

case "$(uname -m)" in
  *arm*) ARCH=arm;;
  *86*) ARCH=x86;;
  *mips*) ARCH=mips;;
  *) echo -e $R" Unsupported ARCH $(uname -m)"$N
     exit 1
  ;;
esac

mount -o remount,rw /
mount -o remount,rw /system

if ! mount | grep " /system " | grep -q "rw,"
then
  echo; echo -e $R"Unable to mount /system"$N; echo
  exit 1
fi

echo; echo -e $G"Preparing busybox setup"$N; echo

cd /system/xbin
for link in $(ls); do
  if [ -L "$link" ]; then
    case "$(readlink "$link")" in
      *busybox) rm "$link";;
    esac
  fi
done
rm -f /system/xbin/busybox

cp ${bbpath}/busybox-$ARCH /system/xbin/busybox
chmod 555 /system/xbin/busybox
/system/xbin/busybox --install -s /system/xbin

export PATH=/system/xbin:/system/bin

for i in echo dirname readlink sha1sum rm rmdir chattr mv ln chmod chown chgrp chcon strings mkdir unzip; do
  if [ -z "$(command -v $i)" ]; then
    echo; echo -e $R"Busybox setup failed .. aborting"$N; echo
    exit 1
  fi
done

cdir="$(dirname "$(readlink -f "$0")")";

exec 2>>"$cdir/root.log"

for i in Magisk.zip SuperSU-v2.82-SR5-20171001.zip update-binary README.txt busybox-arm busybox-x86 busybox-mips; do
  if ! [ -r "$cdir/$i" ]; then
    echo; echo -e $R"Essential files are missing"$N
    echo; echo -e $R"Place all essential files in correct folder and execute"$N; echo
    exit 1
  fi
done
sha1_check() {
  local hash=$(sha1sum "$1" | cut -d' ' -f1)
  if [[ $2 != "$hash" ]]; then return 1; fi
  return 0
}
if sha1_check "$cdir/busybox-arm" "35b3dd09ae379afa030fcfab422e9504c10244e9" &&
   sha1_check "$cdir/busybox-mips" "3df1a0803395aab2ec66160482fd571096b3911d" &&
   sha1_check "$cdir/busybox-x86" "11b3bc6a97b6632dcaf61c6bbe50bb2310307b23" &&
   sha1_check "$cdir/Magisk.zip" "05a0c9661c6f620115a6f0d3f108bd21896ba555" &&
   sha1_check "$cdir/README.txt" "9cf824029b81b9e1194a2e52f86e2dfbbdf65cfb" &&
   sha1_check "$cdir/SuperSU-v2.82-SR5-20171001.zip" "263e0d8ebecfa1cb5a6a3a7fcdd9ad1ecd7710b7" &&
   sha1_check "$cdir/update-binary" "2cfe503f14bc4f7971237dda1eb3188a6e663fd8"
then
   true
else
   echo; echo -e $R" Some files are moidfied"$N
   echo; echo -e $R" Please download correct package"$N; echo
   exit 1
fi

##########################################################################################
# Helper Functions
##########################################################################################
delete() {
  if [ -f $1 -o -L $1 ]; then
    echo "removing file--$1" >&2
    chattr -ia $1 2>/dev/null
  elif [ -d $1 ]; then
    echo "removing dir--$1" >&2
  fi 
  rm -rf $1
}

move() {
  chattr -ia $1
  if [ -f $2 ]; then
    chattr -ia $2
  fi
  mv -f $1 $2
}

set_perm() {
  chown $1 "$4"; chgrp $2 "$4"
  chmod $3 "$4"
  if [ -z "$5" ] ; then
    chcon u:object_r:system_file:s0 "$4"
  else
    chcon u:object_r:$5:s0 "$4"
  fi
}

##########################################################################################
# KingRoot
##########################################################################################
kingroot_data() {
  kingroot="$(pm list packages -f | grep -i kingroot | head -n1)"

  if [ -n "$kingroot" ]; then
    kingrootapk="$(echo "$kingroot" | cut -d: -f2 | cut -d= -f1)"
    kingrootpkg="$(echo "$kingroot" | cut -d= -f2)"
    for i in disable block clear uninstall; do
      LD_LIBRARY_PATH=/system/lib:/vendor/lib pm $i $kingrootpkg >/dev/null 2>&1
    done
    LD_LIBRARY_PATH=/system/lib:/vendor/lib am kill $kingrootpkg >/dev/null 2>&1
    LD_LIBRARY_PATH=/system/lib:/vendor/lib am force-stop $kingrootpkg >/dev/null 2>&1
    delete $kingrootapk
  fi
  delete /data/app/*kingroot*
  delete /data/data/com.kingroot.kinguser
  delete /data/data/*kingroot*
  delete /data/dalvik-cache/*kingroot*
  delete /data/dalvik-cache/*/*kingroot*
  delete /data/app-lib/*kingroot*
  delete /data/app-lib/*uranus*
  delete /data/data-lib
  delete /data/local/tmp/*uranus*
  delete /data/system/*uranus*
  delete /data/media/obb/*kingroot*
}

kingroot_storage() {
  delete /storage/emulated/obb/*kinguser*
  delete /storage/emulated/*/Android/*/*kinguser*
  delete /storage/*/Android/*/*kinguser*
  delete /storage/emulated/*/*kinguser*
  delete /storage/*/*kinguser*
  delete /storage/emulated/*/*Kingroot*
  delete /storage/*/*Kingroot*
  delete /storage/emulated/*/tencent
  delete /storage/*/tencent
  delete /storage/emulated/*/toprange
  delete /storage/*/toprange
  delete /storage/emulated/*/*-stock-conf
  delete /storage/*/*-stock-conf
}

kingroot_dev() {
  if [ -d /dev/kinguser.req.cache ]; then
    if [ ! -z "$(ls /dev/kinguser.req.cache)" ]; then
      for i in /dev/kinguser.req.cache/*; do
        delete $i
      done
    fi
    delete /dev/kinguser.req.cache
  fi
  delete /dev/ktools
  delete /dev/kufblck
  delete /dev/kulck
  delete /dev/rt.sh
}

kingroot_system() {
  kingfiles="
    /system/app/Kinguser.apk
    /system/app/Kinguser/*
    /system/app/Kinguser
    /system/bin/.usr/.ku
    /system/bin/.usr
    /system/bin/rt.sh
    /system/bin/su
    /system/usr/iku/isu
    /system/usr/iku
    /system/xbin/ku.sud
    /system/xbin/ku.sud.tmp
    /system/xbin/su
    /system/xbin/supolicy
  "
  for file in $kingfiles; do
    if [ -d $file ]; then
      rmdir $file
    else
      delete $file
    fi
  done
  if [ -f /system/bin/debuggerd64 ]; then
    strings /system/bin/debuggerd64 | grep -q ku.sud
    if [ $? -eq 0 ]; then
      delete /system/bin/debuggerd64
    fi
  fi
}

##########################################################################################
# Kingoroot
##########################################################################################
kingoroot_data() {
  kingoroot="$(pm list packages -f | grep -i kingo | head -n1)"

  if [ -n "$kingoroot" ]; then
    kingorootapk="$(echo "$kingoroot" | cut -d: -f2 | cut -d= -f1)"
    kingorootpkg="$(echo "$kingoroot" | cut -d= -f2)"
    for i in disable block clear uninstall; do
      LD_LIBRARY_PATH=/system/lib:/vendor/lib pm $i $kingorootpkg >/dev/null 2>&1
    done
    LD_LIBRARY_PATH=/system/lib:/vendor/lib am kill $kingorootpkg >/dev/null 2>&1
    LD_LIBRARY_PATH=/system/lib:/vendor/lib am force-stop $kingorootpkg >/dev/null 2>&1
    delete $kingorootapk
  fi

  delete /data/app/*kingo*
  delete /data/data/*kingo*
  delete /data/dalvik-cache/*kingo*
  delete /data/dalvik-cache/*Kingo*
  delete /data/dalvik-cache/*/*kingo*
  delete /data/dalvik-cache/*/*Kingo*
  delete /data/app-lib/*kingo*
  delete /data/media/obb/*kingo*
}

kingoroot_storage() {
  delete /storage/*/Android/*/*kingo*
  delete /storage/emulated/obb/*kingo*
  delete /storage/emulated/*/*kingoroot*
  delete /storage/*/*kingoroot*
}

kingoroot_system() {
  kingofiles="
    /system/app/KingoUser.apk
    /system/app/KingoUser/*
    /system/app/KingoUser
    /system/bin/.ext/.su
    /system/bin/.ext
    /system/bin/su
    /system/etc/init.d/99SuperSUDaemon
    /system/etc/.has_su_daemon
    /system/lib/libsupol.so
    /system/sbin/su
    /system/sbin
    /system/xbin/daemonsu
    /system/xbin/su
    /system/xbin/supolicy
  "
  for file in $kingofiles; do
    if [ -d $file ]; then
      rmdir $file
    else
      delete $file
    fi
  done
}

##########################################################################################
# Special files
##########################################################################################
remove_install-recovery() {
  if [ -f /system/etc/install-recovery.sh-ku.bak ]; then
    INSTALLRECOVERYCON=$(ls -Z "/system/etc/install-recovery.sh-ku.bak" 2>/dev/null | grep "u:object_r" | cut -d: -f3)
    if [ -z "$INSTALLRECOVERYCON" ] ; then
      INSTALLRECOVERYCON=$(LD_LIBRARY_PATH=/system/lib:/vendor/lib /system/bin/toolbox ls -Z "/system/etc/install-recovery.sh-ku.bak" 2>/dev/null | grep "u:object_r" | cut -d: -f3)
    fi
    if [ -z "$INSTALLRECOVERYCON" ] ; then
      INSTALLRECOVERYCON=$(LD_LIBRARY_PATH=/system/lib:/vendor/lib /system/bin/toybox ls -Z "/system/etc/install-recovery.sh-ku.bak" 2>/dev/null | grep "u:object_r" | cut -d: -f3)
    fi
    if [ -z "$INSTALLRECOVERYCON" ] ; then
      INSTALLRECOVERYCON=system_file
    fi
    move /system/etc/install-recovery.sh-ku.bak /system/etc/install-recovery.sh
    set_perm 0 0 755 /system/etc/install-recovery.sh $INSTALLRECOVERYCON
#    restorecon /system/etc/install-recovery.sh
  elif [ -f /system/etc/install-recovery.sh ] && grep -q su /system/etc/install-recovery.sh; then
    delete /system/etc/install-recovery.sh
    delete /system/bin/install-recovery.sh
  fi
}

remove_ddexe() {
  if [ -f /system/bin/ddexe_real ]; then
    DDEXECON=$(ls -Z "/system/bin/ddexe_real" 2>/dev/null | grep "u:object_r" | cut -d: -f3)
    if [ -z "$DDEXECON" ] ; then
      DDEXECON=$(LD_LIBRARY_PATH=/system/lib:/vendor/lib /system/bin/toolbox ls -Z "/system/bin/ddexe_real" 2>/dev/null | grep "u:object_r" | cut -d: -f3)
    fi
    if [ -z "$DDEXECON" ] ; then
      DDEXECON=$(LD_LIBRARY_PATH=/system/lib:/vendor/lib /system/bin/toybox ls -Z "/system/bin/ddexe_real" 2>/dev/null | grep "u:object_r" | cut -d: -f3)
    fi
    if [ -z "$DDEXECON" ] ; then
      DDEXECON=system_file
    fi
    move /system/bin/ddexe_real /system/bin/ddexe
    if [ -f /system/bin/ddexe-ku.bak ]; then
      move /system/bin/ddexe-ku.bak /system/bin/ddexe
    fi
    set_perm 0 0 755 /system/bin/ddexe $DDEXECON
#    restorecon /system/bin/ddexe
    delete /system/bin/ddexe_real /system/bin/ddexe-ku.bak
  fi
}

supersu_code() {
  if [ -f "/system/etc/install-recovery_original.sh" ]; then
    rm -f /system/etc/install-recovery.sh
    mv /system/etc/install-recovery_original.sh /system/etc/install-recovery.sh
  fi
  if [ -f "/system/bin/install-recovery_original.sh" ]; then
    rm -f /system/bin/install-recovery.sh
    mv /system/bin/install-recovery_original.sh /system/bin/install-recovery.sh
  fi
  if [ -f "/system/bin/app_process64_original" ]; then
    rm -f /system/bin/app_process64
    if [ -f "/system/bin/app_process64_xposed" ]; then
      ln -s /system/bin/app_process64_xposed /system/bin/app_process64
    else
      mv /system/bin/app_process64_original /system/bin/app_process64
    fi
  fi
  if [ -f "/system/bin/app_process32_original" ]; then
    rm -f /system/bin/app_process32
    if [ -f "/system/bin/app_process32_xposed" ]; then
      ln -s /system/bin/app_process32_xposed /system/bin/app_process32
    else
      mv /system/bin/app_process32_original /system/bin/app_process32
    fi
  fi
  if [ -f "/system/bin/app_process64" ]; then
    rm /system/bin/app_process
    ln -s /system/bin/app_process64 /system/bin/app_process
  elif [ -f "/system/bin/app_process32" ]; then
    rm /system/bin/app_process
    ln -s /system/bin/app_process32 /system/bin/app_process
  fi
  rm -f /system/bin/app_process_init
}

##########################################################################################
# Remove Root
##########################################################################################
remove_king() {
  # KingRoot
  kingroot_data
  kingroot_storage
  kingroot_dev
  kingroot_system

  # KingoRoot
  kingoroot_data
  kingoroot_storage
  kingoroot_system

  # Special files
  remove_install-recovery
  supersu_code
}

##########################################################################################
# Main
##########################################################################################
root() {
  if ! [ -f /data/replaceroot ]; then
    echo 1 > /data/replaceroot
  elif [ "$(cat /data/replaceroot)" -eq 5 ]; then
    rm /data/replaceroot
    echo; echo -e $R" Unable to remove Kingroot"$N
    echo; echo -e $R" Try other methods by reading $cdir/README.txt"; echo
    exit 1
  else
    echo $((`cat /data/replaceroot`+1)) > /data/replaceroot
  fi
  echo;  echo -e $B"Cleaning ..."$N
  remove_king
  # Second time cleaning to destroy all
  echo;  echo -e $B"Cleaning ..."$N
  remove_king
  sleep 1
  if [ -d /data/adb/magisk ]; then
    echo; echo -e $G"Finished Cleaning..."$N
  else
    echo; echo -e $G"Finished Cleaning King(o)Root"$N
    echo; echo -e $G"Execute suinstall.sh to install root"$N
  fi
  echo
  exit
}

postuninstall() {
  echo; echo -e $C"Cleaning..."$N
  kingroot_data
  kingroot_dev
  kingroot_storage
  kingoroot_data
  kingoroot_storage
  remove_ddexe
  echo; echo -e $G"Finished Cleaning..."$N
  echo
  exit
}

echo -e $C"---------------------------------------"$N
echo -e $C"---------- ${G}Made By : Mr.W0lf${N}${C} ----------"$N
echo -e $C"---- ${G}Thanks @Chainfire for SuperSU${N}${C} ----"$N
echo -e $C"---------------------------------------"$N

[ -L /system/xbin/su ] && root
[ -L /system/xbin/supolicy ] && root
[ -L /system/bin/su ] && root
[ -e /system/bin/su ] && root
[ -L /system/xbin/su ] && exit
[ -L /system/bin/su ] && exit

if [ -d /data/adb/magisk ]; then
  root
elif [ -f /system/xbin/su ]; then
  su -v | grep -qi SUPERSU && postuninstall || root
fi

echo; echo -e $G" Installing Root"$N; echo

[ -f /data/replaceroot ] && rm /data/replaceroot
# SuperSU installation
mkdir /dev/tmp || ( echo "Unable to create /dev/tmp, aborting"; exit 1; )
API=$(cat /system/build.prop | grep "ro.build.version.sdk=" | dd bs=1 skip=21 count=2 2>/dev/null)
if [ "$API" -ge "21" ]; then
  unzip -oq "$cdir/Magisk.zip" META-INF/com/google/android/update-binary -p > "$cdir/magisk-updater"
  echo "###BEGIN MAGISK LOG###" >&2
  sh "$cdir/magisk-updater" "dummy" "1" "$cdir/Magisk.zip"
  echo "###END MAGISK LOG###" >&2
  if [ $? -ne 0 ]; then
    echo "###BEGIN SUPERSU LOG###" >&2
    sh "$cdir/update-binary" "dummy" "1" "$cdir/SuperSU-v2.82-SR5-20171001.zip"
    echo "###END SUPERSU LOG###" >&2
  fi
  delete "$cdir/magisk-updater"
else
  echo "###BEGIN SUPERSU LOG###" >&2
  sh "$cdir/update-binary" "dummy" "1" "$cdir/SuperSU-v2.82-SR5-20171001.zip"
  echo "###END SUPERSU LOG###" >&2
fi
if [ -f /system/xbin/su -a -f /system/lib/libsupol.so ] || [ -d /data/adb/magisk ]; then
  echo; echo -e $G"* ${C}the device will reboot after a few seconds${N}${G} *"$N
  echo; echo -e $G"**********************************************"$N
  setprop sys.powerctl reboot
  sleep 3
  /system/bin/reboot # fallback
fi
echo; echo "Finished"; echo

exit 0
