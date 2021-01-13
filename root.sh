#!/system/bin/sh

# @HemanthJabalpuri XDA

# Replace KingRoot or Kingo ROOT possibly others with SuperSU
# Idea to remove root from terminal with shell script is by Mr.Wolf and edited his script
# +for compatible of newer versions of KingRoot
# Newer versions of KingRoot are capable of recreating deleted files immediately
# For this you need to completely uninstall KingRoot app
# +or delete files of KingRoot in /data will solve this
# My script will do the same thing by deleting all dirs and files of KingRoot
# +and capable of flashing SuperSU directly in booted android without need of custom recovery

# TODO
# -Get attributes using `lsattr` command and remove only listed ones.
# -Add more app data paths in `find_delete` function

##########################################################################################
# Helper Functions
##########################################################################################
set_perm() {
  chown $1 "$4"; chgrp $2 "$4"
  chmod $3 "$4"
  [ -z "$(command -v chcon)" ] && return
  if [ -z "$5" ] ; then
    chcon u:object_r:system_file:s0 "$4"
  else
    chcon u:object_r:$5:s0 "$4"
  fi
}

delete() {
  for i in "$@"; do
    [ -z "$i" ] && continue
    if [ -f $i ] || [ -L $i ]; then
      echo "removing file--$i" >&2
      set_perm 0 0 0755 "$i"
    elif [ -d $i ]; then
      echo "removing dir--$i" >&2
    fi
    chattr -ia $i 2>/dev/null
    shred -fzu $i 2>/dev/null
    rm -rf $i
  done
}

move() {
  chattr -ia "$1"
  if [ -f "$2" ]; then
    chattr -ia "$2"
  fi
  mv -f "$1" "$2"
}

get_context() {
  [ -z "$(command -v chcon)" ] && return
  CON=$(ls -Z "$1" 2>/dev/null | grep "u:object_r" | cut -d: -f3)
  if [ -z "$CON" ] ; then
    CON=$(LD_LIBRARY_PATH=/system/lib:/vendor/lib /system/bin/toolbox ls -Z "$1" 2>/dev/null | grep "u:object_r" | cut -d: -f3)
  fi
  if [ -z "$CON" ] ; then
    CON=$(LD_LIBRARY_PATH=/system/lib:/vendor/lib /system/bin/toybox ls -Z "$1" 2>/dev/null | grep "u:object_r" | cut -d: -f3)
  fi
  if [ -z "$CON" ] ; then
    CON=system_file
  fi
  echo "$CON"
}

find_delete() {
  if [ "$find_delete_app" -eq "3" ]; then
    return
  fi
  greppkg="$(pm list packages -f 2>/dev/null | grep -i "$1" | head -n1 | cut -d= -f2)"

  if [ -z "$greppkg" ]; then
    return
  else
    find_delete_app=$((find_delete_app+1))
  fi
  rootapk="$(dumpsys package $greppkg | grep -i "codepath" | head -n1 | cut -d= -f2 | cut -d' ' -f1)"
  rootlib="$(dumpsys package $greppkg | grep -i "nativelibrarypath" | head -n1 | cut -d= -f2 | cut -d' ' -f1)"
  rootdata="$(dumpsys package $greppkg | grep -i "datadir" | head -n1 | cut -d= -f2 | cut -d' ' -f1)"
  rootver="$(dumpsys package $greppkg | grep -i "versionname" | head -n1 | cut -d= -f2 | cut -d' ' -f1)"
  rootverc="$(dumpsys package $greppkg | grep -i "versioncode" | head -n1 | cut -d= -f2 | cut -d' ' -f1)"
  echo "$rootapk--$rootver--$rootverc--$rootdata--$rootlib" >&2

  sys=0
  if [ "$(dumpsys package $greppkg | grep -ci "codepath")" -eq 2 ]; then
    rootsysapk="$(dumpsys package $greppkg | grep -i "codepath" | tail -n1 | cut -d= -f2 | cut -d' ' -f1)"
    rootsysver="$(dumpsys package $greppkg | grep -i "versionname" | tail -n1 | cut -d= -f2 | cut -d' ' -f1)"
    rootsysverc="$(dumpsys package $greppkg | grep -i "versioncode" | tail -n1 | cut -d= -f2 | cut -d' ' -f1)"
    echo "$rootsysapk--$rootsysver--$rootsysverc" >&2
    sys=1
  fi

  LD_LIBRARY_PATH=/system/lib:/vendor/lib am force-stop $greppkg >/dev/null 2>&1
  LD_LIBRARY_PATH=/system/lib:/vendor/lib am kill $greppkg >/dev/null 2>&1
  for i in disable block clear uninstall; do
    LD_LIBRARY_PATH=/system/lib:/vendor/lib pm $i $greppkg >/dev/null 2>&1
  done
  delete "$rootapk"
  delete "$rootdata"
  delete "$rootlib"
  find /data/dalvik-cache -iname "*${greppkg}*" -delete

  if [ "$sys" -eq "1" ]; then
    delete "$rootsysapk"
    find /data/dalvik-cache -iname "*$(basename $rootsysapk)*" -delete
  fi
}

sha1_check() {
  [ $2 = "$(sha1sum "$1" | cut -d' ' -f1)" ] && return 0
  return 1
}

abort() {
  echo
  for i in "$@"; do
    echo -e $R"  ${i}"$N; echo
  done
  exit 1
}

##########################################################################################
# KingRoot
##########################################################################################
kingroot_data() {
  delete /data/app/*kingroot*
  delete /data/data/com.kingroot.kinguser
  delete /data/data/*kingroot*
  delete /data/dalvik-cache/*kingroot*
  delete /data/dalvik-cache/*/*kingroot*
  delete /data/dalvik-cache/*tpsdaemon*
  delete /data/dalvik-cache/*/*tpsdaemon*
  delete /data/dalvik-cache/daemon
  delete /data/app-lib/*kingroot*
  delete /data/app-lib/*uranus*
  delete /data/data-lib
  delete /data/local/tmp/*uranus*
  delete /data/system/*uranus*
  delete /data/system/tmp_init.rc
  delete /data/media/obb/*kingroot*
  LD_LIBRARY_PATH=/system/lib:/vendor/lib pm uninstall com.kingroot.kinguser >/dev/null 2>&1
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
  for i in user root; do
    if [ -d /dev/king${i}.req.cache ]; then
      if ! [ -z "$(ls /dev/king${i}.req.cache)" ]; then
        for j in /dev/king${i}.req.cache/*; do
          delete $j
        done
      fi
      delete /dev/king${i}.req.cache
    fi
  done
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
  if [ -f /system/bin/debuggerd64 ] && strings /system/bin/debuggerd64 | grep -qF ku.sud; then
    delete /system/bin/debuggerd64
  fi
}

##########################################################################################
# Kingoroot
##########################################################################################
kingoroot_data() {
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
    /system/lib64/libsupol.so
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
remove_install_recovery() {
  if [ -f /system/etc/install-recovery.sh-ku.bak ]; then
    move /system/etc/install-recovery.sh-ku.bak /system/etc/install-recovery.sh
    IRCON=$(get_context /system/etc/install-recovery.sh-ku.bak)
    set_perm 0 0 755 /system/etc/install-recovery.sh $IRCON
    #restorecon /system/etc/install-recovery.sh
  elif [ -f /system/etc/install-recovery.sh ] && grep -q xbin /system/etc/install-recovery.sh; then
    delete /system/etc/install-recovery.sh
    delete /system/bin/install-recovery.sh
  fi
  if [ -f /system/bin/install-recovery.sh-ku.bak ] && ! [ -L /system/bin/install-recovery.sh ]; then
    move /system/bin/install-recovery.sh-ku.bak /system/bin/install-recovery.sh
    IRCON=$(get_context /system/bin/install-recovery.sh-ku.bak)
    set_perm 0 0 755 /system/bin/install-recovery.sh $IRCON
    #restorecon /system/bin/install-recovery.sh
  fi
}

remove_ddexe_debuggerd() {
  for i in ddexe debuggerd; do
    if ! [ -f /system/bin/${i}_real ]; then continue; fi
    CONTEXT=$(get_context /system/bin/${i}_real)
    move /system/bin/${i}_real /system/bin/$i
    if [ -f /system/bin/${i}-ku.bak ]; then
      move /system/bin/${i}-ku.bak /system/bin/$i
    fi
    set_perm 0 0 755 /system/bin/$i $CONTEXT
    #restorecon /system/bin/$i
    delete /system/bin/${i}_real
    delete /system/bin/${i}-ku.bak
  done
}

supersu_code() {
  if [ -f "/system/etc/install-recovery_original.sh" ]; then
    rm -f /system/etc/install-recovery.sh
    mv -f /system/etc/install-recovery_original.sh /system/etc/install-recovery.sh
  fi
  if [ -f "/system/bin/install-recovery_original.sh" ]; then
    rm -f /system/bin/install-recovery.sh
    mv -f /system/bin/install-recovery_original.sh /system/bin/install-recovery.sh
  fi
  if [ -f "/system/bin/app_process64_original" ]; then
    rm -f /system/bin/app_process64
    if [ -f "/system/bin/app_process64_xposed" ]; then
      ln -s /system/bin/app_process64_xposed /system/bin/app_process64
    else
      mv -f /system/bin/app_process64_original /system/bin/app_process64
    fi
  fi
  if [ -f "/system/bin/app_process32_original" ]; then
    rm -f /system/bin/app_process32
    if [ -f "/system/bin/app_process32_xposed" ]; then
      ln -s /system/bin/app_process32_xposed /system/bin/app_process32
    else
      mv -f /system/bin/app_process32_original /system/bin/app_process32
    fi
  fi
  if [ -f "/system/bin/app_process64" ]; then
    rm -f /system/bin/app_process
    ln -s /system/bin/app_process64 /system/bin/app_process
  elif [ -f "/system/bin/app_process32" ]; then
    rm -f /system/bin/app_process
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
  remove_install_recovery
  supersu_code
}

root() {
  if ! [ -f /data/replaceroot ]; then
    echo 1 > /data/replaceroot
  elif [ "$(cat /data/replaceroot)" -eq 5 ]; then
    rm -f /data/replaceroot
    abort "Unable to remove Kingroot" "Try other methods by reading $cdir/README.html"
  else
    echo $((`cat /data/replaceroot`+1)) > /data/replaceroot
  fi

  delete /data/app/*kingroot*
  find /system/app -iname "*kinguser*" -delete
  LD_LIBRARY_PATH=/system/lib:/vendor/lib pm install -r $cdir/KingRoot_4.5.0.apk >/dev/null 2>&1

  find_delete_app=0
  find_delete kingroot
  find_delete com.toprange.locker
  find_delete com.kingx.cloudsdk
  find_delete kingo
  find_delete kingo
  find_delete mgyun.shua.su
  find_delete geohot.towelroot
  find_delete shuame.rootgenius
  find_delete z4mod.z4root
  find_delete dianxinos.superuser
  find_delete baidu.easyroot
  find_delete baiyi_mobile.easyroot
  find_delete zhiqupk.root.global
  find_delete qihoo.permmgr
  find_delete corner23.android.universalandroot
  find_delete m0narx.su
  find_delete genymotion.superuser

  echo;  echo -e $B"Cleaning ..."$N
  remove_king
  # Second time cleaning to destroy all
  echo;  echo -e $B"Cleaning ..."$N
  remove_king
  sleep 1
  echo; echo -e $G"Finished Cleaning King(o)Root"$N
  echo; echo -e $G"Execute root.sh again to install root"$N
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
  remove_ddexe_debuggerd
  postfiles="
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
    /system/app/KingoUser.apk
    /system/app/KingoUser/*
    /system/app/KingoUser
    /system/sbin/su
    /system/sbin
  "
  for file in $postfiles; do
    if [ -d $file ]; then
      rmdir $file
    else
      delete $file
    fi
  done
  echo; echo -e $G"Finished Cleaning..."$N
  echo
  exit
}

##########################################################################################
# Pre-Checks
##########################################################################################
R='\e[01;91m' >/dev/null 2>&1; # Red
G='\e[01;92m' >/dev/null 2>&1; # Green
B='\e[01;94m' >/dev/null 2>&1; # Blue
C='\e[01;96m' >/dev/null 2>&1; # Cyan
N='\e[0m' >/dev/null 2>&1; # Null

id="$(id)"; id="${id#*=}"; id="${id%%\(*}"; id="${id%% *}"
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
  abort "Type su and then execute"
fi

tmpd="$PWD"; [ "$PWD" = "/" ] && tmpd=""
case "$0" in
  /*) cdir="$0";;
  *) cdir="$tmpd/${0#./}";;
esac
cdir="${cdir%/*}"

if ! [ -f "$cdir/root.sh" ]; then
  abort "Unable to get path of this script.. aborting"
fi

case "$(getprop ro.product.cpu.abi)" in
  *arm*) ARCH=arm;;
  *86*) ARCH=x86;;
  *mips*) ARCH=mips;;
  *) abort "Unsupported ARCH $(getprop ro.product.cpu.abi)" ;;
esac

mount -o remount,rw /
mount -o remount,rw /system

echo test >/system/test || abort "Unable to mount /system"
rm /system/test

bb="/system/xbin/busybox"
[ -e $bb ] && rm $bb

if ! [ -d /system/xbin ]; then
  mkdir /system/xbin && chmod 755 /system/xbin
fi
cat ${cdir}/busybox-$ARCH > $bb
chmod 555 $bb
[ -x "$bb" ] || abort "Busybox setup failed"

cd /system/xbin
for link in $($bb ls); do
  if [ -L $link ]; then
    case $($bb readlink $link) in
      *busybox) $bb rm -f $link;;
    esac
  fi
done
$bb --install -s /system/xbin

export PATH=/system/xbin:/system/bin
set_perm 0 0 0755 $bb
cd /

for i in basename cat chattr chgrp chmod chown cut dd dirname echo find grep head ln mkdir mv readlink reboot rm rmdir sh sha1sum shred sleep strings tail unzip; do
  if [ -z "$(command -v $i)" ]; then
    abort "Busybox setup failed .. aborting"
  fi
done

LOG="$cdir/root.log"
exec 2>>"$LOG"

for i in busybox-arm busybox-mips busybox-x86 KingRoot_4.5.0.apk README.html SuperSU-v2.82-SR5-20171001.zip update-binary; do
  if ! [ -f "$cdir/$i" ]; then
    abort "Essential files are missing" "Place all essential files in correct folder and execute"
  fi
done

if sha1_check "$cdir/busybox-arm" "fd959938c3858cdb0a4bcdc76667844231c025d4" &&
  sha1_check "$cdir/busybox-mips" "dfdaae9740002eff0f9bfcaa8f8e1d9f56b0afd7" &&
  sha1_check "$cdir/busybox-x86" "72551a6fc55bc25386c87c5803d77dc731e46c4e" &&
  sha1_check "$cdir/KingRoot_4.5.0.apk" "df48a7852a458da71f44bb3c95ef9b9588938e82" &&
  sha1_check "$cdir/README.html" "c8fcdf115eea49963f7de872bb90a2b57cf36f56" &&
  sha1_check "$cdir/SuperSU-v2.82-SR5-20171001.zip" "263e0d8ebecfa1cb5a6a3a7fcdd9ad1ecd7710b7" &&
  sha1_check "$cdir/update-binary" "4d6146d6df1ecc7d9c59d86cbc23e1c61bd7dfee"
then
  true
else
  abort "Some files are moidfied" "Please download correct package"
fi

##########################################################################################
# Logging
##########################################################################################
ARCH="$(grep -Eo "ro.product.cpu.abi(2)?=.+" /system/build.prop 2>/dev/null | grep -Eo "[^=]*$" | head -n1)"
for field in ro.product.device ro.build.product ro.product.name; do
  device_name="$(getprop "$field")"
  if [ "${#device_name}" -ge "2" ]; then
    break
  fi
  device_name="Bad ROM"
done
if [ -z "$(cat $LOG)" ]; then
  {
  echo "### Replace KingRoot with SuperSU ###"
  echo "Version:- 5"
  echo "   "
  echo ">> Device: $(getprop ro.product.brand) $(getprop ro.product.model)"
  echo ">> Device Name: $device_name"
  echo ">> Device Model: $(getprop ro.product.model)"
  echo ">> Architecture: $ARCH"
  echo ">> ROM version: $(getprop ro.build.display.id)"
  echo ">> Android version: $(getprop ro.build.version.release)"
  echo ">> SDK: $(getprop ro.build.version.sdk)"
  if [ -n "$(command -v getenforce)" ]; then
    echo ">> SElinux state: $(getenforce)"
  fi
  } >>$LOG
fi

##########################################################################################
# Main
##########################################################################################
echo -e $C"---------------------------------------"$N
echo -e $C"---------- ${G}Made By : Mr.W0lf${C} ----------"$N
echo -e $C"---- ${G}Thanks @Chainfire for SuperSU${C} ----"$N
echo -e $C"---------------------------------------"$N

[ -e /system/bin/su ] && root
[ -e /system/xbin/ku.sud ] && root
[ -L /system/bin/su ] && root
[ -L /system/xbin/su ] && root
[ -L /system/xbin/supolicy ] && root
[ -e /system/xbin/ku.sud ] && exit
[ -L /system/bin/su ] && exit
[ -e /system/bin/su ] && exit
[ -L /system/xbin/su ] && exit

if [ -f /system/xbin/su ]; then
  if su -v | grep -qi SUPERSU; then
    postuninstall
  else
    root
  fi
elif [ -d /data/adb/magisk ]; then
  root
fi

echo; echo -e $G" Installing Root"$N; echo

[ -f /data/replaceroot ] && rm -f /data/replaceroot
# SuperSU installation
mkdir /dev/tmp || abort "Unable to create /dev/tmp, aborting"
echo "###BEGIN SUPERSU LOG###" >&2
sh "$cdir/update-binary" "dummy" "1" "$cdir/SuperSU-v2.82-SR5-20171001.zip"
echo "###END SUPERSU LOG###" >&2

if [ -f /system/xbin/su ] && su -v | grep -qi SUPERSU
then
  echo; echo -e $G"* ${C}the device will reboot after a few seconds${G} *"$N
  echo; echo -e $G"**********************************************"$N
  (
  setprop sys.powerctl reboot
  sleep 3
  /system/bin/reboot
  )&
fi
echo; echo "Finished"; echo

exit 0
