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

2) You can set whether you want to use a random beta FP from the last month (since multiple are available) or the latest one.
    - Follow these steps to configure:
        a) Open the file: `/data/adb/modules/playcurlNEXT/mode.txt`
        b) Write `random` in the file if you want to use a random FP.
        c) Write `normal` or leave the file empty if you want to use the latest one.

# Additional Information

- You can manually trigger the action (`action.sh`) if you're using Magisk Canary.
- You can also run the script in Termux with the following command: su -c 'fp'

# Recommended setups

Instructions for device integrity :

                - Download play integrity fix
                - Download playcurlNEXT
                - Install both
                - Reboot 
                - Open Spic and check for integrity

Instructions for strong integrity on custom rom:
        
                - Install shamiko 
                - Install Tricky_store and put a valid keybox inside /data/adb/Tricky_store
                - Install Pif  
                - enjoy

# Credits

The backend of this module (autojson repo), was created using **Shell Scripts** that have been carefully adapted and customized from the original work of the **PlayIntegrityFork** module.

The original scripts were forked from the following repository:

- [osm0sis/PlayIntegrityFork](https://github.com/osm0sis/PlayIntegrityFork)