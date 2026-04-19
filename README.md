# Mac Muter
## Background
One of the problems with Do Not Disturb (DND) on a Mac is that it does not mute sound. It will still make a sound even you are in DND.(For example,Outlook Web App)
This will be very annoying if you are sleeping! So I created this script to mute sound regularly every day.

## Installation
Open Terminal on Mac, paste the following command: 
```bash
git clone https://github.com/yunpengeric/mac-muter.git && mv mac-muter ~/.mac-muter && ./.mac-muter/install.sh
```
Enter the time you want to mute sound. Make sure the time is in HH:MM & 24-hour format.
For example:
```bash
What time do you want to mute(HH:MM format | 24 hour system)?22:00
```
![screenshot](images/screenshot.png)

You will see a message that says `Done! Your computer will be muted at 22:00 every day.`

## How it works now
Recent macOS versions are much less reliable with old cron-based AppleScript automation, so the installer now:

- compiles a small Swift command-line tool to mute the default output device
- installs a per-user `launchd` agent in `~/Library/LaunchAgents`
- removes the old cron entry if one exists

This makes the scheduled mute job much more reliable on modern macOS.

## Reinstall after updating
If you already installed an older version, run:

```bash
cd ~/.mac-muter
./install.sh
```

This refreshes the compiled binary and reloads the LaunchAgent.
