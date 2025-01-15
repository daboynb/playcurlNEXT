#!/system/bin/sh

###################################################################
# Check if boot is completed
###################################################################
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 10
done

# Sleep 10 seconds 
sleep 10

###################################################################
# Declare vars
###################################################################
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

###################################################################
# Copy and set up cron script
###################################################################
# Copy the cron script and set execute permission
cp /data/adb/modules/playcurlNEXT/system/bin/fp /data/local/tmp/fp.sh
chmod +x /data/local/tmp/fp.sh

# Ensure crontab directory exists
mkdir -p /data/cron
###################################################################

###################################################################
# Read minutes from configuration
###################################################################
# Read minutes from the file (default to 60 minutes if the file doesn't exist or has an invalid value)
minutes=60
if [ -f "/data/adb/modules/playcurlNEXT/minutes.txt" ]; then
    read_minutes=$(cat /data/adb/modules/playcurlNEXT/minutes.txt)
    
    # Ensure it's a valid positive integer
    if [ "$read_minutes" -ge 1 ] 2>/dev/null; then
        # Ensure the value is between 1 and 1440 minutes
        if [ "$read_minutes" -gt 1440 ]; then
            minutes=1440
            echo "Minutes value exceeds 24 hours. Setting to maximum of 1440 minutes (24 hours)."
        elif [ "$read_minutes" -lt 1 ]; then
            minutes=1
            echo "Minutes value is below 1 minute. Setting to minimum of 1 minute."
        else
            minutes=$read_minutes
        fi
    else
        echo "Invalid value in minutes.txt. Defaulting to 1 hour."
    fi
else
    echo "File minutes.txt is missing. Defaulting to 1 hour."
fi
###################################################################

###################################################################
# Set up the cron job
###################################################################
# Set up the cron job with the specified interval in minutes
echo "*/$minutes * * * * /data/local/tmp/fp.sh" > /data/cron/root
###################################################################

###################################################################
# Initialize and run scripts
###################################################################
# Init log
echo "Phone started..." > /data/adb/playcurl.log
echo "" >> /data/adb/playcurl.log

# Run once
/system/bin/sh /data/local/tmp/fp.sh  >> /data/adb/playcurl.log 

# Conf cron
"$busybox_path" crond -c /data/cron -L /data/adb/playcurl.log 
###################################################################