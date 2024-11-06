#!/system/bin/sh

###################################################################
# Source external functions
###################################################################
. /data/adb/modules/playcurl_NEXT/common_func.sh

###################################################################
# Wait for boot to complete
###################################################################
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 10
done

# Additional sleep for stability
sleep 10

###################################################################
# Disable built-in spoof on some ROMs and kill GMS processes
###################################################################
setprop persist.sys.pihooks.disable.gms_props true
setprop persist.sys.pihooks.disable.gms_key_attestation_block true

killall com.google.android.gms >/dev/null 2>&1
killall com.google.android.gms.unstable >/dev/null 2>&1

###################################################################
# Declare variables and detect busybox path
###################################################################
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
# Copy the cron script and set permissions
###################################################################
cp /data/adb/modules/playcurl_NEXT/action.sh /data/local/tmp/fp.sh
chmod +x /data/local/tmp/fp.sh

# Ensure crontab directory exists
mkdir -p /data/cron

###################################################################
# Configure cron job interval based on minutes.txt
###################################################################
minutes=60
if [ -f "/data/adb/modules/playcurl_NEXT/minutes.txt" ]; then
    read_minutes=$(cat /data/adb/modules/playcurl_NEXT/minutes.txt)
    
    if [ "$read_minutes" -ge 1 ] 2>/dev/null; then
        if [ "$read_minutes" -gt 1440 ]; then
            minutes=1440
        elif [ "$read_minutes" -lt 1 ]; then
            minutes=1
        else
            minutes=$read_minutes
        fi
    fi
fi

# Set up the cron job with the specified interval in minutes
echo "*/$minutes * * * * /data/local/tmp/fp.sh" > /data/cron/root

###################################################################
# Initialize log and run fp command
###################################################################
echo "Phone started..." > /data/adb/playcurl.log
echo "" >> /data/adb/playcurl.log

/system/bin/sh /data/local/tmp/fp.sh >> /data/adb/playcurl.log 

###################################################################
# Start crond with specified log file
###################################################################
"$busybox_path" crond -c /data/cron -L /data/adb/playcurl.log 

###################################################################
# Disable incompatible APKs for various ROMs
###################################################################
apk_names=("eu.xiaomi.module.inject" "com.goolag.pif" "com.lineageos.pif" "co.aospa.android.certifiedprops.overlay" "com.elitedevelopment.module")

for apk in "${apk_names[@]}"; do
    pm disable "$apk" > /dev/null 2>&1
    pm uninstall "$apk" > /dev/null 2>&1
done