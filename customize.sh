###################################################################
# Set permissions for the binaries
###################################################################
# Set permissions for fp and fpd binaries
set_perm $MODPATH/system/bin/fp root root 0777
set_perm $MODPATH/system/bin/fpd root root 0777

###################################################################
# Detect and move curl to system
###################################################################
# Move curl binary to system directory and set permissions
mv -f $MODPATH/system/bin/$ABI/curl $MODPATH/system/bin
set_perm $MODPATH/system/bin/curl root root 777

###################################################################
# Remove useless curl binaries
###################################################################
# Remove architecture-specific curl binaries
rm -rf $MODPATH/system/bin/arm64-v8a 
rm -rf $MODPATH/system/bin/armeabi-v7a 
rm -rf $MODPATH/system/bin/x86 
rm -rf $MODPATH/system/bin/x86_64

###################################################################
# Install playcurl
###################################################################
echo "Installing playcurl"

# Check if the kernel name is banned, banned kernels names from https://xdaforums.com/t/module-play-integrity-fix-safetynet-fix.4607985/post-89308909 and telegram
get_kernel_name=$(uname -r)
banned_names=("aicp" "arter97" "blu_spark" "caf" "cm-" "crdroid" "cyanogenmod" "deathly" "eas-" "eas" "elementalx" "elite" "franco" "hadeskernel" "lineage-" "lineage" "lineageos" "mokee" "morokernel" "noble" "optimus" "slimroms" "sultan")

for keyword in "${banned_names[@]}"; do
    if echo "$get_kernel_name" | "$busybox_path" grep -iq "$keyword"; then
        echo
        echo "[-] Your kernel name \"$keyword\" is banned."
        echo ""
        echo "Play integrity fix, Play integrity fix fork and playcurlNEXT won't work."
    fi
done

###################################################################
# Removing old app if exists
###################################################################
# Uninstall old playcurl app if installed
su -c "pm uninstall com.playcurl.com" >/dev/null 2>&1

###################################################################
# Remove old playcurl modules
###################################################################
# Remove old playcurl module if it exists
if [ -d "/data/adb/modules/playcurl" ]; then
    touch "/data/adb/modules/playcurl/remove"
fi

# Remove old playcurlNEXT module if it exists
if [ -d "/data/adb/modules/playcurlNEXT" ]; then
    touch "/data/adb/modules/playcurlNEXT/remove"
fi

###################################################################
# Allow all the scripts to be executable
###################################################################
# Set execute permissions for all .sh scripts in MODPATH
chmod +x $MODPATH/*.sh

###################################################################
# Finalize installation
###################################################################
echo "Done"