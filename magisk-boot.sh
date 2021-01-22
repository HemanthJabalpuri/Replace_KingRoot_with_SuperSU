#!/system/bin/sh
#
# This script is based on magisk-boot.sh from
# https://forum.xda-developers.com/t/amazing-temp-root-for-mediatek-armv8-2020-08-24.3922213/
# by diplomatic @ XDA dated Mar 31, 2020
#
# This script sets up bootless root with Magisk on Android devices.
# Must be run as root for executing this script and we have to do this on every boot.
# We can run this from the app 'init.d scripts support' by RYO Software which can run scripts on boot.
# Put this file into /storage/emulated/0/init.d and put magiskinit into .../init.d/bin
# Point the app to run sh scripts from /storage/emulated/0/init.d at boot time.
#
# You can use whatever you want to execute on every boot.
#
# WARNING: DO NOT UPDATE MAGISK THROUGH MAGISK MANAGER OR YOU WILL BRICK YOUR
#          DEVICE ON A LOCKED BOOTLOADER
#

HOMEDIR=/data/local/tmp
SRCDIR=/storage/emulated/0/init.d

mkdir -p $HOMEDIR
cd $HOMEDIR || exit 1

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
fi

if ! cmp $SRCDIR/bin/magiskinit magiskinit >/dev/null 2>&1; then
  cp -f $SRCDIR/bin/magiskinit ./
  chmod 700 magiskinit

  rm magiskpolicy magisk >/dev/null 2>&1
  $SELINUX && ln -s magiskinit magiskpolicy
  ln -s magiskinit magisk
fi

# Magisk function to find boot partition and prevent the installer from finding
# it again
find_block() {
  for BLOCK in "$@"; do
    DEVICES=$(find /dev/block -type l -iname $BLOCK) 2>/dev/null
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
SLOT=$(getprop ro.boot.slot_suffix)
find_block boot$SLOT

cd $HOMEDIR || { $SELINUX && setenforce 1; exit 1; }

# Patch selinux policy
$SELINUX && ./magiskpolicy --live --magisk "allow magisk * * *"
if [ ! -f /sbin/.init-stamp ]; then
  # Set up /root links to /sbin files
  mount | grep -qF rootfs
  have_rootfs=$?
  if [ $have_rootfs -eq 0 ]; then
    echo "Have rootfs"
    mount -o rw,remount /
    mkdir /root
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
fi

$SELINUX && setenforce 1
echo "Done..."
