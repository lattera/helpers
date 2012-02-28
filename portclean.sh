#!/usr/local/bin/bash

for dir in `find /usr/ports -name work -type d`
do
    cleandir=`echo "${dir}" | sed 's/\/[^\/]*$/\//'`
    echo "=== Cleaning ${cleandir} ==="
    cd ${cleandir}
    sudo make clean
done
