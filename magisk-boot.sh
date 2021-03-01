#!/system/bin/sh
#
# This script is based on magisk-boot.sh from
# https://forum.xda-developers.com/t/amazing-temp-root-for-mediatek-armv8-2020-08-24.3922213/
# by diplomatic @ XDA dated Mar 31, 2020
#
# This script sets up bootless root with Magisk v22+ on Android devices.
# Must be run as root for executing this script and we have to do this on every boot.
# We can run this from the app 'init.d scripts support' by RYO Software which can run scripts on boot.
# Put this file into /storage/emulated/0/init.d and put magisk.apk into .../init.d/bin
#
# Point the app to run sh scripts from /storage/emulated/0/init.d at boot time.
#
# You can use whatever you want to execute on every boot.
#
# WARNING: DO NOT UPDATE MAGISK THROUGH MAGISK MANAGER OR YOU WILL BRICK YOUR
#          DEVICE ON A LOCKED BOOTLOADER
#

HOMEDIR=/data/local/tmp
SRCDIR=/storage/emulated/0/init.d

API=`getprop ro.build.version.sdk`
ABI=`getprop ro.product.cpu.abi | dd bs=1 count=3 2>/dev/null`
ABI2=`getprop ro.product.cpu.abi2 | dd bs=1 count=3 2>/dev/null`
ABILONG=`getprop ro.product.cpu.abi`

ARCH=arm
IS64BIT=false
[ "$ABI" = "x86" ] && ARCH=x86
[ "$ABI2" = "x86" ] && ARCH=x86
if [ "$ABILONG" = "arm64-v8a" ]; then ARCH=arm; IS64BIT=true; fi
if [ "$ABILONG" = "x86_64" ]; then ARCH=x86; IS64BIT=true; fi

if [ "$1" = "info" ]; then
  echo "API is $API"
  echo "Architecture is $ARCH"
  echo "64bit == $IS64BIT"
  exit
fi
[ "$API" -lt 17 ] && echo " Magisk is only for 4.2(17)+" && exit

# SELinux stuffs
SELINUX=false
[ -e /sys/fs/selinux ] && [ -e /sys/fs/selinux/policy ] && SELINUX=true

# Root only at this point; hoping selinux is permissive
id="$(id)"; id="${id#*=}"; id="${id%%\(*}"; id="${id%% *}"
[ "$id" != "0" ] && [ "$id" != "root" ] && notsu=1
if [ "$notsu" = 1 ]; then
  echo "Root user only" >&2
  exit 1
elif $SELINUX && [ "$(getenforce)" != "Permissive" ]; then
  echo "SELinux not Permissive" >&2
  exit 1
elif [ -f /sbin/.init-stamp ]; then
  exit 1
fi

MAPK=$SRCDIR/bin/magisk.apk
if [ -n "$1" ]; then
  tmpd="$PWD"; [ "$PWD" = "/" ] && tmpd=""
  case "$1" in
    /*) fpath="$1";;
    *) fpath="$tmpd/${1#./}";;
  esac
  MAPK="$fpath"
fi
if ! [ -f "$MAPK" ]; then
  echo "magisk apk not found" >&2
  exit 1
fi

mkdir -p $HOMEDIR
cd $HOMEDIR || exit 1

BUSYBOX="$(command -v busybox)"
if [ -z "$BUSYBOX" ]; then
  echo "Install busybox" >&2
  exit 1
fi
#BUSYBOX=/data/busybox && chmod 777 $BUSYBOX
[ "$ARCH" = "arm" ] && ARCH=armeabi-v7a
$BUSYBOX unzip -ojq "$MAPK" "lib/$ARCH/*" -x "lib/$ARCH/libbusybox.so" || exit 1
for libfile in lib*.so; do
  file="${libfile#lib}"; file="${file%.so}"
  mv -f "$libfile" "$file"
  chmod 700 "$file"
done

find_fun() {
  if [ -n "$(command -v find)" ]; then
    find "$@"
    return
  fi
  block=$1
  if [ -e /dev/block/by-name/$block ]; then
    target=/dev/block/by-name/$block
  elif [ -e /dev/block/bootdevice/by-name/$block ]; then
    target=/dev/block/bootdevice/by-name/$block
  elif [ -e /dev/block/platform/*/by-name/$block ]; then
    target=/dev/block/platform/*/by-name/$block
  elif [ -e /dev/block/platform/*/*/by-name/$block ]; then
    target=/dev/block/platform/*/*/by-name/$block
  elif [ -e /dev/$block ]; then
    target=/dev/$block
  fi
  [ -L "$target" ] && ls $target 2>/dev/null
}

# Magisk function to find boot partition and prevent the installer from finding
# it again
find_boot() {
  SLOT=$1
  for BLOCK in boot BOOT; do
    DEVICES=$(find_fun /dev/block -type l -name ${BLOCK}${SLOT}) 2>/dev/null
    for DEVICE in $DEVICES; do
      cd ${DEVICE%/*}
      local BASENAME="${DEVICE##*/}"
      mv "$BASENAME" ".$BASENAME"
      cd -
    done
  done
  # Fallback by parsing sysfs uevents
  typeset -l PARTNAME BLOCK
  local FILELIST=$(grep -s PARTNAME= /sys/dev/block/*/uevent) 2>/dev/null
  for uevent in $FILELIST; do
    local PARTNAME=${uevent##*PARTNAME=}
    for BLOCK in "$@"; do
      if [ "$BLOCK" = "$PARTNAME" ]; then
        local FNAME=${uevent%:*}
        chmod 0 $FNAME
      fi
    done
  done
  return 0
}

# Disaster prevention
find_boot $(getprop ro.boot.slot_suffix)

rm magiskpolicy magisk >/dev/null 2>&1
$SELINUX && ln -s magiskinit magiskpolicy
ln -s magiskinit magisk

# Patch selinux policy
$SELINUX && ./magiskpolicy --live --magisk "allow magisk * * *"

# Set up /root links to /sbin files
mount | grep -qF rootfs
have_rootfs=$?
if [ $have_rootfs -eq 0 ]; then
  echo "Have rootfs"
  mount -o rw,remount /
#  rm -rf /root
  mkdir /root 2>/dev/null
  chmod 750 /root
  for i in /sbin/*; do
    ln $i /root/${i/'/sbin/'/}
    if [ $? != 0 ]; then
      echo "Error making /sbin hardlinks" >&2
      mount -o ro,remount /
      $SELINUX && setenforce 1
      exit 1
    fi
  done
  # copy xz compressed magisk binaries to /sbin
  ./magiskboot compress=xz magisk32 /sbin/magisk32.xz
  $IS64BIT && ./magiskboot compress=xz magisk64 /sbin/magisk64.xz
  mount -o ro,remount /
fi

# Create tmpfs /sbin overlay
# This may crash on system-as-root with no /root directory
./magisk -c >&2

touch /sbin/.init-stamp

if [ ! -f /sbin/magiskinit ] || [ ! -f /sbin/magisk ]; then
  echo "Bad /sbin mount?" >&2
  $SELINUX && setenforce 1
  exit 1
fi

# Copy binaries
cp magiskinit /sbin/
rm -rf magisk*

if [ $have_rootfs -ne 0 ]; then
  mkdir /sbin/.magisk/mirror/system_root
  block=$(mount | grep " / " | cut -d\  -f1)
  [ $block = "/dev/root" ] && block=/dev/block/dm-0
  mount -o ro $block /sbin/.magisk/mirror/system_root
  for file in /sbin/.magisk/mirror/system_root/sbin/*; do
    if [ -L $file ]; then
      cp -a $file /sbin/
    else
      cp -ps $file /sbin/${file##*/}
    fi
  done
fi

export PATH=/sbin:$PATH

# Finish startup calls
magisk --post-fs-data
sleep 1        # hack to prevent race with later service calls
magisk --service
magisk --boot-complete

$SELINUX && setenforce 1
echo "Done..."
