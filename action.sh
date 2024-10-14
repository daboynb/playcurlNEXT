################################################################### Declare vars
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

################################################################### Download pif
echo "[*] Start of the script"

if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
    if [ -d /data/adb/modules/tricky_store ]; then
        # Download osmosis.json
        if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/osmosis.json >/dev/null 2>&1; then
            echo "[+] Successfully downloaded osmosis.json."
        else
            echo "[-] Failed to download osmosis.json."
        fi
    else
        # If tricky_store does not exist, download device_osmosis.json
        if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/device_osmosis.json >/dev/null 2>&1; then
            echo "[+] Successfully downloaded device_osmosis.json."
        else
            echo "[-] Failed to download device_osmosis.json."
        fi
    fi
else
    # Download chiteroman.json
    if /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/main/chiteroman.json" -o /data/adb/pif.json >/dev/null 2>&1; then
        echo "[+] Successfully downloaded chiteroman.json."
    else
        echo "[-] Failed to download chiteroman.json."
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
fi

# Kill GMS processes
killall com.google.android.gms >/dev/null 2>&1
killall com.google.android.gms.unstable >/dev/null 2>&1

echo "[*] End of the script"
echo ""
sleep 3
###################################################################