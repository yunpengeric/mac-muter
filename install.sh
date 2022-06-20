#!/bin/sh
    echo
    echo "+-------------------------------------------------------------------+"
    echo "| Mac Muter                                               |"
    echo "|                                                                   |"
    echo "+-------------------------------------------------------------------+"
    echo


read -p "What time do you want to mute(HH:MM format | 24 hour system)?" time
H=${time%:*}
M=${time#"$H"}
M=${M#:}
crontab -l | { cat; echo "$M $H * * * ~/.mac-muter/Schedule-Mute-Mac.applescript"; } | crontab -
echo "Done! Your computer will be muted at $time every day."