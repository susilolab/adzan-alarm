# !/bin/sh
#set -x

valac -X -lm --pkg gtk+-3.0 --pkg sqlite3 src/pray_time.vala src/adzan_alarm.vala src/calendar.vala src/preference.vala src/utils.vala -o adzan_alarm
