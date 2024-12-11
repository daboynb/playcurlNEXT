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