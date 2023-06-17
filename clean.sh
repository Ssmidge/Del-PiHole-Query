#!/bin/bash

#       This is a very simple script that removes some querries from the pihole querry every time this was executed.
#       This removes them in both the long term querry log, the 24-hour log and the recent 100 querries.

# Check user root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root. (Did you forgot sudo?)"
  exit 1
fi

domain=$1
if [[ -z "$domain" ]]; then
    echo ERROR: A domain is required
    exit 1
fi


rmQuery () {
        sqlite3 /etc/pihole/pihole-FTL.db "delete from query_storage where domain in (select id from domain_by_id where domain like '$domain');"
}

echo Script Started at $(date)
echo 'Both code should be a 0. If not there is a problem.'
# Stops FTL, So that we are not writing to a live database.
systemctl stop pihole-FTL
echo stop code = $?
cd /etc/pihole


# Remove whatever ends with "in-addr.arpa"
rmQuery

echo [✓] Done removing.
wait 1
echo [✓] Restarting.

# Restart FTL
systemctl restart pihole-FTL
echo restart code = $?
echo [✓] Done.
echo Script Ended at $(date)