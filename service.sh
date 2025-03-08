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
log_path="/data/adb/playcurl.log"

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
else
    echo "Busybox not found, exiting." > "$log_path"
    exit 1
fi
###################################################################

###################################################################
# Copy and set up cron script
###################################################################
pif_folder="/data/adb/modules/playintegrityfix"
temp_dir="/data/local/tmp/pif"
MODULE_PROP="/data/adb/modules/playcurlNEXT/module.prop"

# Check if the action script exists
if [ ! -f "$pif_folder/action.sh" ]; then
    $busybox_path sed -i 's/^description=.*/description=Unsupported environment, update pif!/' "$MODULE_PROP"
    echo "Unsupported environment, update pif!" > "$log_path"
    exit 1
fi

# If temp dir exist remove it
if [ -d "$temp_dir" ]; then
    rm -rf "$temp_dir"
fi

# Copy the pif folder to the temp directory
cp -r "$pif_folder" "$temp_dir"
chmod -R +x "$temp_dir"/*.sh

# Remove unnecessary lines from action.sh
$busybox_path sed -i '/set +o standalone/d' "$temp_dir/action.sh"
$busybox_path sed -i '/unset ASH_STANDALONE/d' "$temp_dir/action.sh"
###################################################################

###################################################################
# Read minutes from configuration
###################################################################
# Read minutes from the action (default to 60 minutes if the action doesn't exist or has an invalid value)
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
    echo "action minutes.txt is missing. Defaulting to 1 hour."
fi
###################################################################

###################################################################
# Set up the cron job
###################################################################
# Ensure crontab directory exists
mkdir -p /data/cron

# Remove the old cron file if it exists
if [ -f /data/cron/root ]; then
    rm -f /data/cron/root
fi

# Set up the cron job
echo "*/$minutes * * * * /data/local/tmp/pif/action.sh" > /data/cron/playcurlNEXT
###################################################################

###################################################################
# Initialize and run scripts
###################################################################
# Init log
echo "Phone started..." > "$log_path"
echo "" >> "$log_path"

# Run once
/system/bin/sh /data/local/tmp/pif/action.sh  >> "$log_path" 

# Configure cron daemon
"$busybox_path" crond -c /data/cron -L "$log_path" 
###################################################################
