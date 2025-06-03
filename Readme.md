## As of 03/06/2025, a recent update of PIF from Osmosis has broken this module. For now, it is only compatible with the PIF by Chiteroman until I fix the issue.

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
- At every boot, the fingerprint (fp) will be pulled using the action.sh script of your pif module.
- Every hour, the updated fingerprint will be downloaded.

# How to configure a different time interval
1) You can set your own time interval by specifying the number of minutes inside the file: 
        `/data/adb/modules/playcurlNEXT/minutes.txt` 
(minimum 1 minute, maximum 1400 minutes)
Reboot to apply.   

# Credits
- [chiteroman/PlayIntegrityFix](https://github.com/chiteroman/PlayIntegrityFix)

- [osm0sis/PlayIntegrityFork](https://github.com/osm0sis/PlayIntegrityFork)
