If you'd like to support me:

<a href="https://www.buymeacoffee.com/daboynb" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

This is a rewrite of Playcurl, the old version became outdated as many things have changed. Paradoxically, this is more lightweight and easier to use.

# How to Use

- Flash the module.
- Confirm when prompted to install the app and reboot.
- Note: For KSU and Apatch users, you may need to enable notifications in the app's settings and then reboot the phone to see the notification.

# How it Works
- At every boot, the fingerprint (fp) will be pulled.
- Every 30 minutes, the updated fingerprint will be downloaded, starting from 7:00 AM to 12:00 AM.

# Additional Information

- You can manually trigger the action (`action.sh`) if you're using Magisk Canary.
- You can also run the script in Termux with the following command: su -c 'fp'

# Why a Tasker App and Not `service.sh`

Android kills the process while in deep sleep, so even if I set a 30-minute interval, it will be random. 

Instead, the app is precise, and since it doesn't operate during the night, it won't excessively drain the battery.


# Battery

If you think that the app is consuming your battery, you can uninstall it and trigger the FP command via termux or magisk action