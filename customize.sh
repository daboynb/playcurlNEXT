# Set permissions for the binaries
set_perm $MODPATH/system/bin/fp root root 0777
set_perm $MODPATH/system/bin/fpd root root 0777

# Detect and move curl to system
mv -f $MODPATH/system/bin/$ABI/curl $MODPATH/system/bin
set_perm $MODPATH/system/bin/curl root root 777

# Remove uselesss curl binaries
rm -rf $MODPATH/system/bin/arm64-v8a 
rm -rf $MODPATH/system/bin/armeabi-v7a 
rm -rf $MODPATH/system/bin/x86 
rm -rf $MODPATH/system/bin/x86_64

echo "Installing playcurl"

# Removing old app if exist
su -c "pm uninstall com.playcurl.com" >/dev/null 2>&1

# Old playcurl remove 
if [ -d "/data/adb/modules/playcurl" ]; then
    touch "/data/adb/modules/playcurl/remove"
fi

# Old playcurl remove 
if [ -d "/data/adb/modules/playcurlNEXT" ]; then
    touch "/data/adb/modules/playcurlNEXT/remove"
fi

# Allow all the scripts to be executable
chmod +x $MODPATH/*.sh

echo "Done"