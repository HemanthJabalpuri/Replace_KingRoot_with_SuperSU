#!/system/bin/sh

delete() {
  rm -rf $1
}

chattr_() {
  chattr -ia $1 1>/dev/null 2>/dev/null
}

# KingRoot
kingroot_data() {
  delete /data/app/*kinguser*
  delete /data/data/com.kingroot.kinguser
  delete /data/dalvik-cache/*kinguser*
  delete /data/dalvik-cache/*/*kinguser*
  delete /data/app-lib/*kinguser*
  delete /data/app-lib/*uranus*
  delete /data/data-lib
  delete /data/local/tmp/*uranus*
  delete /data/system/*uranus*
  delete /data/media/obb/*kinguser*

  LD_LIBRARY_PATH=/system/lib:/vendor/lib am kill com.kingroot.kinguser 1>/dev/null 2>/dev/null
  LD_LIBRARY_PATH=/system/lib:/vendor/lib pm uninstall com.kingroot.kinguser 1>/dev/null 2>/dev/null
}

kingroot_storage() {
  delete /storage/*/Android/*/*kinguser*
  delete /storage/emulated/obb/*kinguser*
  delete /sdcard/*kinguser*
}

kingroot_dev() {
  if [ -d /dev/kinguser.req.cache ]; then
    if [ ! -z "$(ls /dev/kinguser.req.cache)" ]; then
      for i in /dev/kinguser.req.cache/*; do
        chattr_ $i
      done
    fi
    delete /dev/kinguser.req.cache
  fi
  delete /dev/ktools
}

kingroot_system() {
  kingfiles="
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
      rmdir $file 2>/dev/null
    else
      chattr_ $file
      delete $file
    fi
  done
}


# Kingoroot
kingoroot_data() {
  delete /data/app/*kingo*
  delete /data/data/*kingo*
  delete /data/dalvik-cache/*kingo*
  delete /data/dalvik-cache/*Kingo*
  delete /data/dalvik-cache/*/*kingo*
  delete /data/dalvik-cache/*/*Kingo*
  delete /data/app-lib/*kingo*
  delete /data/media/obb/*kingo*

  LD_LIBRARY_PATH=/system/lib:/vendor/lib pm uninstall com.kingoapp.apk 1>/dev/null 2>/dev/null
}

kingoroot_storage() {
  delete /storage/*/Android/*/*kingo*
  delete /storage/emulated/obb/*kingo*
  delete /sdcard/*kingo*
}

kingoroot_system() {
  kingofiles="
    /system/app/KingoUser.apk
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
      rmdir $file 2>/dev/null
    else
      chattr_ $file
      delete $file
    fi
  done
}

remove_install-recovery() {
  if [ -f /system/etc/install-recovery.sh-ku.bak ]; then
    chattr_ /system/etc/install-recovery.sh
    chattr_ /system/etc/install-recovery.sh-ku.bak
    mv /system/etc/install-recovery.sh-ku.bak /system/etc/install-recovery.sh
  elif [ -f /system/etc/install-recovery.sh ] && grep -q su /system/etc/install-recovery.sh; then
    chattr_ /system/etc/install-recovery.sh
    delete /system/etc/install-recovery.sh
    chattr_ /system/bin/install-recovery.sh
    delete /system/bin/install-recovery.sh
  fi
}

remove_ddexe() {
  if [ -f /system/bin/ddexe_real ]; then
    chattr_ /system/bin/ddexe_real
    chattr_ /system/bin/ddexe-ku.bak
    chattr_ /system/bin/ddexe
    mv /system/bin/ddexe_real /system/bin/ddexe
    if [ -f /system/bin/ddexe-ku.bak ]; then
      mv /system/bin/ddexe-ku.bak /system/bin/ddexe
    fi
    chattr_ /system/bin/ddexe_real
    chattr_ /system/bin/ddexe-ku.bak
    chattr_ /system/bin/ddexe
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

abort() {
  echo "$1"
  exit 1
}

BL='\e[01;90m' > /dev/null 2>&1; # Black
R='\e[01;91m' > /dev/null 2>&1; # Red
G='\e[01;92m' > /dev/null 2>&1; # Green
Y='\e[01;93m' > /dev/null 2>&1; # Yellow
B='\e[01;94m' > /dev/null 2>&1; # Blue
P='\e[01;95m' > /dev/null 2>&1; # Purple
C='\e[01;96m' > /dev/null 2>&1; # Cyan
W='\e[01;97m' > /dev/null 2>&1; # White
N='\e[0m' > /dev/null 2>&1; # Null
