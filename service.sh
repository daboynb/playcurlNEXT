#!/system/bin/sh

# Source external functions
. /data/adb/modules/playcurlNEXT/common_func.sh

# Check if boot is completed
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 10
done

# Sleep 10 seconds 
sleep 10

################################################################### Declare vars
# Detect busybox path
busybox_path=""

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
else
    echo "Busybox not found, exiting."
    exit 1
fi
###################################################################

# Copy the cron script and set execute permission
cp /data/adb/modules/playcurlNEXT/action.sh /data/local/tmp/fp.sh
chmod +x /data/local/tmp/fp.sh

# Ensure crontab directory exists
mkdir -p /data/cron

# Add the cron job to run every 30 minutes
echo "*/30 * * * * /data/local/tmp/fp.sh" > /data/cron/root

# Init log
echo "Phone started..." > /data/adb/playcurl.log
echo "" >> /data/adb/playcurl.log

# Run once
/system/bin/sh /data/local/tmp/fp.sh  >> /data/adb/playcurl.log 

# Conf cron
"$busybox_path" crond -c /data/cron -L /data/adb/playcurl.log 