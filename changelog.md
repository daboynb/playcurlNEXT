V1.04 -> New Features!

1) You can now set your own check interval by specifying the number of minutes inside the file: `/data/adb/modules/playcurlNEXT/minutes.txt` (minimum 1 minute, maximum 1400 minutes).

2) You can now set whether you want to use a random beta FP from the last month (since multiple are available) or the latest one.
   - Follow these steps to configure:
     a) Open the file: `/data/adb/modules/playcurlNEXT/mode.txt`
     b) Write `random` in the file if you want to use a random FP.
     c) Write `normal` or leave the file empty if you want to use the latest one.

Version 1.04 comes with these default values: 
    - check interval -> every hour 
    - mode -> normal (latest FP)

If you are okay with these values, do not edit anything.