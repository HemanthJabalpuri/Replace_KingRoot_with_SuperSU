#!/system/bin/sh

# Source files.sh
. /sdcard/mrw/files.sh

mount -o remount,rw /system

echo; echo -e $C"Cleaning..."$N

kingroot_data
kingroot_dev
kingroot_storage

kingoroot_data
kingoroot_storage

remove_ddexe

echo; echo -e $G"Finished Cleaning..."$N
echo
