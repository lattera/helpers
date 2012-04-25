#!/bin/sh

if [ $# -lt 1 ]; then
    echo "USAGE: ${0} <dataset 1> .. <dataset N>"
    exit 1
fi

for dataset in $@;
do
    for snap in `zfs list -H -r -d 1 -t snapshot ${dataset} 2> /dev/null | awk {'print $1;'}`;
    do
        echo "==== Destroying ${snap} ===="
        sudo zfs destroy ${snap}
    done
done
