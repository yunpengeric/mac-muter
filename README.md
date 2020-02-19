# Schedule-Mute-Mac
## Process
In terminal, type `crontab -e`
Add line `0 23 * * * osascript <PATH>/Schedule-Mute-Mac/Schedule-Mute-Mac.applescript`
This will mute the macOs every day at 23:00.
### How to use Crontab
*     *     *   *    *        command to be executed
-     -     -   -    -
|     |     |   |    |
|     |     |   |    +----- day of week (0 - 6) (Sunday=0)
|     |     |   +------- month (1 - 12)
|     |     +--------- day of        month (1 - 31)
|     +----------- hour (0 - 23)
+------------- min (0 - 59)
### How to grant access to Crontab
1. System Preferences > Security & Privacy > Privacy tab.
2. Drag `/usr/sbin/cron` into Full Disk Access