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
desc_supported="Supported environment"
desc_unsupported="Unsupported environment, update pif!"

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
else
    echo "[ERROR] Busybox not found, exiting." > "$log_path"
    exit 1
fi

# Logging function with timestamp
log_msg() {
    local level="$1"
    local msg="$2"
    local timestamp=$("$busybox_path" date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" >> "$log_path"
}

log_header() {
    echo "" >> "$log_path"
    echo "============================================" >> "$log_path"
    log_msg "INFO" "$1"
    echo "============================================" >> "$log_path"
}
###################################################################

###################################################################
# Copy and set up cron script
###################################################################
pif_folder="/data/adb/modules/playintegrityfix"
MODULE_PROP="/data/adb/modules/playcurlNEXT/module.prop"

# Check if any supported PIF script exists
if [ -f "$pif_folder/action.sh" ] \
    || ls "$pif_folder"/autopif*.sh >/dev/null 2>&1; then
    # Supported environment - at least one PIF implementation exists
    $busybox_path sed -i "s/^description=.*/description=$desc_supported/" "$MODULE_PROP"
    echo "" > "$log_path"
    log_msg "INFO" "$desc_supported"
else
    # No supported PIF implementation found
    $busybox_path sed -i "s/^description=.*/description=$desc_unsupported/" "$MODULE_PROP"
    echo "" > "$log_path"
    log_msg "ERROR" "$desc_unsupported"
    exit 1
fi

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
            log_msg "WARN" "Minutes value exceeds 24 hours. Setting to maximum of 1440 minutes."
        elif [ "$read_minutes" -lt 1 ]; then
            minutes=1
            log_msg "WARN" "Minutes value is below 1 minute. Setting to minimum of 1 minute."
        else
            minutes=$read_minutes
        fi
    else
        log_msg "WARN" "Invalid value in minutes.txt. Defaulting to 1 hour."
    fi
else
    log_msg "INFO" "minutes.txt not found. Defaulting to 1 hour."
fi
###################################################################

###################################################################
# Set up the cron job
###################################################################
# Ensure crontab directory exists
mkdir -p /data/cron

# Check if pc cron exists
if [ -f "/data/cron/root" ]; then
    rm -f "/data/cron/root"
fi

# Detect PIF variant based on module.prop author field
module_contents=$("$busybox_path" cat "$pif_folder/module.prop")

# Find autopif script with version number (autopif4.sh, autopif5.sh, etc.)
# Sort by version number descending to get the latest
osm0sis_script=$(ls "$pif_folder"/autopif[0-9]*.sh 2>/dev/null | sort -V -r | head -n1)

if echo "$module_contents" | "$busybox_path" grep -q 'KOWX712'; then
    pif_variant="kowx712"
    pif_script="$pif_folder/autopif.sh"
    pif_args="-p"
elif echo "$module_contents" | "$busybox_path" grep -q 'osm0sis'; then
    pif_variant="osm0sis"
    pif_script="$osm0sis_script"
    pif_args="-p"
else
    pif_variant="chiteroman"
    pif_script="$pif_folder/action.sh"
    pif_args=""
fi

# Set up cron job
echo "*/$minutes * * * * /system/bin/sh $pif_script $pif_args" > /data/cron/root

###################################################################

###################################################################
# Initialize and run scripts
###################################################################
log_header "PlaycurlNEXT Service Started"
log_msg "INFO" "PIF variant detected: $pif_variant"
log_msg "INFO" "PIF script: $pif_script"
log_msg "INFO" "Cron interval: every $minutes minutes"

# Patch migrate.sh for osm0sis variant if needed
# autopif script has built-in busybox handling, but migrate.sh runs in subshell
migrate_script="$pif_folder/migrate.sh"
grep_wrapper="BUSYBOX=\"$busybox_path\"; grep() { \"\$BUSYBOX\" grep \"\$@\"; }"

if [ "$pif_variant" = "osm0sis" ] && [ -f "$migrate_script" ]; then
    if ! "$busybox_path" grep -qE 'grep\(\)|find_busybox|BUSYBOX=' "$migrate_script"; then
        sed -i "2i$grep_wrapper" "$migrate_script"
        log_msg "INFO" "Patched migrate.sh with busybox grep wrapper"
    fi
fi

# Run OTA script first for kowx712 variant
if [ "$pif_variant" = "kowx712" ] && [ -f "$pif_folder/autopif_ota.sh" ]; then
    log_msg "INFO" "Running OTA script..."
    /system/bin/sh "$pif_folder/autopif_ota.sh" >> "$log_path" 2>&1 || true
fi

# Run main PIF script
log_msg "INFO" "Running PIF script..."
/system/bin/sh "$pif_script" $pif_args >> "$log_path" 2>&1

###################################################################
# Fix CRLF and set executable permissions for all .sh files
###################################################################
log_msg "INFO" "Fixing permissions and line endings for PIF scripts..."
for file in /data/adb/modules/playintegrityfix/*.sh; do
    if [ -f "$file" ]; then
        $busybox_path sed -i 's/\r$//' "$file"
        chmod +x "$file"
    fi
done
log_msg "INFO" "Permissions fixed"

###################################################################
# Start cron daemon
###################################################################
log_msg "INFO" "Starting cron daemon..."
"$busybox_path" crond -c /data/cron -L "$log_path"
log_msg "INFO" "Service initialization complete"
###################################################################