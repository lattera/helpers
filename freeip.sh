#!/usr/bin/env bash

subnet="$1"
i=0

for i in `seq 2 254`;
do
    ping -c1 $subnet.$i > /dev/null 2>&1
    if [ $? -gt 0 ]; then
        break
    fi
done

echo $subnet.$i
