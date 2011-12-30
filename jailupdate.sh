#!/usr/local/bin/bash

date=`/bin/date '+%F_%T'`

for jail in /jails/*; do
    logfile=`echo $jail | sed 's/\//_/g'`
    exec 1> logs/$date-$logfile.log
    exec 2>&1

    dataset=`zfs mount | grep $jail | awk '{print \$1}'`
    sudo zfs snapshot $dataset@$date:BeforeUpdate
    (cd /usr/src; sudo make installworld DESTDIR=$jail)
done
