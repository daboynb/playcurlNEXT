#!/system/bin/sh

################################################################### Check if boot completed
check_boot_completed() {
    while true; do
        if [ "$(getprop sys.boot_completed)" = "1" ]; then
            echo "Boot process completed"
            return 0
        else
            echo "Waiting for boot process to complete..."
            sleep 10  # Wait 10 seconds before checking again
        fi
    done
}

# Wait until the boot is complete
check_boot_completed

log_file="/data/adb/playcurlNEXT.log"

# Function to log messages
log_message() {
    echo "[$(date)] $1" >> "$log_file"
}

################################################################### Start of the loop
while true; do
    log_message "================= Script Start ================="

    ################################################################### Declare vars
    log_message "[*] Detecting busybox..."
    busybox_path=""

    if [ -f "/data/adb/magisk/busybox" ]; then
        busybox_path="/data/adb/magisk/busybox"
        log_message "[+] Busybox found at /data/adb/magisk/busybox"
    elif [ -f "/data/adb/ksu/bin/busybox" ]; then
        busybox_path="/data/adb/ksu/bin/busybox"
        log_message "[+] Busybox found at /data/adb/ksu/bin/busybox"
    elif [ -f "/data/adb/ap/bin/busybox" ]; then
        busybox_path="/data/adb/ap/bin/busybox"
        log_message "[+] Busybox found at /data/adb/ap/bin/busybox"
    else
        log_message "[-] Busybox not found."
    fi
    ###################################################################

    ################################################################### Download pif
    log_message "[*] Downloading the pif.json..."

    # Temp file to capture errors
    error_log="/data/adb/curl_error.log"

    if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
        if [ -d /data/adb/modules/tricky_store ]; then
            # Download osmosis.json
            if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/osmosis.json > /dev/null 2> "$error_log"; then
                log_message "[+] Successfully downloaded osmosis.json."
            else
                log_message "[-] Failed to download osmosis.json. Error: $(cat $error_log)"
            fi
        else
            # If tricky_store does not exist, download device_osmosis.json
            if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/device_osmosis.json > /dev/null 2> "$error_log"; then
                log_message "[+] Successfully downloaded device_osmosis.json."
            else
                log_message "[-] Failed to download device_osmosis.json. Error: $(cat $error_log)"
            fi
        fi
    else
        # Download chiteroman.json
        if /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/main/chiteroman.json" -o /data/adb/pif.json > /dev/null 2> "$error_log"; then
            log_message "[+] Successfully downloaded chiteroman.json."
        else
            log_message "[-] Failed to download chiteroman.json. Error: $(cat $error_log)"
        fi
    fi
    ###################################################################

    ################################################################### Check unsigned ROM
    log_message "[*] Checking unsigned ROM..."

    # Check the keys of /system/etc/security/otacerts.zip
    get_keys=$("$busybox_path" unzip -l /system/etc/security/otacerts.zip)

    if echo "$get_keys" | "$busybox_path" grep -q test; then
        log_message "[+] Unsigned ROM detected. Setting custom props..."

        # Check for the presence of migrate.sh and use the appropriate file path
        if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
            $busybox_path sed -i 's/"spoofSignature": *0/"spoofSignature": 1/g' /data/adb/modules/playintegrityfix/custom.pif.json
            log_message "[+] Updated spoofSignature to 1 in custom.pif.json"
        else
            $busybox_path sed -i 's/"spoofSignature": *"false"/"spoofSignature": "true"/g' /data/adb/pif.json
            log_message "[+] Updated spoofSignature to true in pif.json"
        fi

        # Kill GMS processes
        killall com.google.android.gms
        killall com.google.android.gms.unstable
        log_message "[*] Killed GMS processes."
    else
        log_message "[-] No unsigned ROM detected."
    fi
    ###################################################################

    ################################################################### Clean up and sleep
    log_message "[*] Cleaning up the error log file..."
    rm -f "$error_log"

    log_message "[*] Sleeping for 3 seconds..."
    sleep 3

    log_message "================= Script End ================="

    ################################################################### Wait before the next run
    # Read the sleep interval from the file or default to 1800 seconds (30 minutes)
    filepath="/data/adb/modules/playcurlNEXT/seconds.txt"
    if [ -f "$filepath" ]; then
        time_interval=$(cat "$filepath")
    else
        time_interval=1800  # Default to 30 minutes
    fi
    log_message "[*] Sleeping for $time_interval seconds before the next run."
    sleep "$time_interval"
done