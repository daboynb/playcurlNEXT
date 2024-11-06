###################################################################
# Set permissions for the binaries
###################################################################
set_perm $MODPATH/system/bin/fp root root 0777
set_perm $MODPATH/system/bin/fpd root root 0777

###################################################################
# Detect and move curl to system
###################################################################
mv -f $MODPATH/system/bin/$ABI/curl $MODPATH/system/bin
set_perm $MODPATH/system/bin/curl root root 777

###################################################################
# Remove unused curl binaries
###################################################################
rm -rf $MODPATH/system/bin/arm64-v8a 
rm -rf $MODPATH/system/bin/armeabi-v7a 
rm -rf $MODPATH/system/bin/x86 
rm -rf $MODPATH/system/bin/x86_64

###################################################################
# Make all scripts executable
###################################################################
chmod +x $MODPATH/*.sh

echo "Installing playcurl"

###################################################################
# Remove old versions of playcurl
###################################################################
# Uninstall old app if it exists
su -c "pm uninstall com.playcurl.com" >/dev/null 2>&1

old_modules=(
    "/data/adb/modules/playcurl"
    "/data/adb/modules/playcurlNEXT"
)

# Mark old modules for removal
for module in "${old_modules[@]}"; do
    if [ -d "$module" ]; then
        touch "$module/remove"
    fi
done

###################################################################
# Disable incompatible modules
###################################################################
disable_modules=(
    "/data/adb/modules/safetynet-fix"
    "/data/adb/modules/MagiskHidePropsConf"
    "/data/adb/modules/FrameworkPatcherGo"
)

# Mark incompatible modules for disablement
for module in "${disable_modules[@]}"; do
    if [ -d "$module" ]; then
        touch "$module/disable"
    fi
done

###################################################################
# Disable incompatible APKs
###################################################################
# Disable problematic packages for various ROMs (MIUI EU, EvoX, LineageOS, PixelOS, EliteRom)
apk_names=("eu.xiaomi.module.inject" "com.goolag.pif" "com.lineageos.pif" "co.aospa.android.certifiedprops.overlay" "com.elitedevelopment.module")

for apk in "${apk_names[@]}"; do
    pm disable "$apk" > /dev/null 2>&1
    pm uninstall "$apk" > /dev/null 2>&1
done

###################################################################
echo "Done"