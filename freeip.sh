#!/usr/bin/env bash

subnet="$1"
startip="$2"
endip="$3"
i=0

for i in `seq $startip $endip`;
do
    ping -c1 $subnet.$i > /dev/null 2>&1
    if [ $? -gt 0 ]; then
        break
    fi
done

echo $subnet.$i
