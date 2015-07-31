AAPT=~/B2G/out/host/linux-x86/bin/aapt
pkg=$($AAPT dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
act=$($AAPT dump badging $1|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
echo $pkg/$act
adb shell /system/dalvy-walvy/am start -n $pkg/$act
