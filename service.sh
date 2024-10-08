################################################################### Check if booted
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    echo "Waiting for boot to complete..."
    sleep 1
done
###################################################################

################################################################### Busybox
# Detect busybox
busybox_path=""

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
fi
###################################################################

################################################################### While 
while true; do

    # Log
    log="/storage/emulated/0/playcurl_service.log"
    rm -f "$log"
    echo "Starting...." > "$log"

    ################################################################### Check for internet
    max_attempts=5  
    for attempt in $(seq 1 $max_attempts); do
        # Ping gstatic once
        ping -c 1 gstatic.com > /dev/null 2>&1

        # Check if the ping was successful
        if [ $? -eq 0 ]; then
            current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
            echo "$current_date_time Ping successful: Internet connection is available." >> "$log"
            break  # Exit the loop if the ping is successful
        else
            current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
            echo "$current_date_time Ping failed: No internet connection. Attempt $attempt of $max_attempts." >> "$log"
        fi

        # If not the last attempt, wait 15 seconds before retrying
        if [ "$attempt" -lt "$max_attempts" ]; then
            sleep 15
        fi
    done

    if [ "$attempt" -eq "$max_attempts" ]; then
        current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$current_date_time Exceeded $max_attempts attempts without success." >> "$log"
    fi
    ###################################################################

    ################################################################### Download pif
    if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
        if [ -d /data/adb/modules/tricky_store ]; then
            # Download osmosis.json
            if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/osmosis.json; then
                current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_date_time [+] Successfully downloaded osmosis.json." >> "$log"
            else
                current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_date_time [-] Failed to download osmosis.json." >> "$log"
            fi
        else
            if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/device_osmosis.json; then
                current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_date_time [+] Successfully downloaded device_osmosis.json." >> "$log"
            else
                current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_date_time [-] Failed to download device_osmosis.json." >> "$log"
            fi
        fi
    else
        if /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/main/chiteroman.json" -o /data/adb/pif.json; then
            current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
            echo "$current_date_time [+] Successfully downloaded chiteroman.json." >> "$log"
        else
            current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
            echo "$current_date_time [-] Failed to download chiteroman.json." >> "$log"
        fi
    fi
    ###################################################################

    ################################################################### Check unsigned rom
    # Check the keys of /system/etc/security/otacerts.zip
    get_keys=$("$busybox_path" unzip -l /system/etc/security/otacerts.zip)

    if echo "$get_keys" | "$busybox_path" grep -q test; then
        # Check for the presence of migrate.sh and use the appropriate file path
        if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
            $busybox_path sed -i 's/"spoofSignature": *0/"spoofSignature": 1/g' /data/adb/modules/playintegrityfix/custom.pif.json
        else
            $busybox_path sed -i 's/"spoofSignature": *"false"/"spoofSignature": "true"/g' /data/adb/pif.json
        fi

        # Kill GMS processes
        echo "Killing GMS processes..." >> "$log"
        killall com.google.android.gms
        killall com.google.android.gms.unstable
    fi
    ###################################################################

    ################################################################### Check interval
        echo "Sleeping for 1800 seconds..." >> "$log"
        sleep 1800
done
###################################################################