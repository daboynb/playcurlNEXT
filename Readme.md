# If you'd like to support me:

<a href="https://www.buymeacoffee.com/daboynb" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

This is a rewrite of Playcurl, the old version became outdated as many things have changed. Paradoxically, this is more lightweight and easier to use.

# Support group
https://t.me/playfixnext

# How to Use
- Flash the module. (You must have play integrity fix installed)
- Reboot.
- Check for integity.

# How it Works
- At every boot, the fingerprint (fp) will be pulled.
- Every 30 minutes, the updated fingerprint will be downloaded.

# How to configure extra settings

1) You can set your own check interval by specifying the number of minutes inside the file: 
        `/data/adb/modules/playcurlNEXT/minutes.txt` 
(minimum 1 minute, maximum 1400 minutes)
Reboot to apply.   

# Additional Information

- You can manually trigger the action (`action.sh`) if you're using Magisk Canary.
- You can also run the script in Termux with the following command: su -c 'fp'

# Broken volume button?

## Run on Termux (as root)

### To run the FP downloader when the action button is triggered:
1. rm /data/adb/modules/playcurlNEXT/action.sh
2. cp /data/adb/modules/playcurlNEXT/system/bin/fp /data/adb/modules/playcurlNEXT/action.sh
3. Enjoy!

### To run the troubleshooting script when the action button is triggered:
1. rm /data/adb/modules/playcurlNEXT/action.sh
2. cp /data/adb/modules/playcurlNEXT/system/bin/fpd /data/adb/modules/playcurlNEXT/action.sh
3. Enjoy!

# Credits

The backend of this module (autojson repo), was created using **Shell Scripts** that have been carefully adapted and customized from the original work of the **PlayIntegrityFork** module.

The original scripts were forked from the following repository:

- [osm0sis/PlayIntegrityFork](https://github.com/osm0sis/PlayIntegrityFork)