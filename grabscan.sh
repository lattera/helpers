#!/bin/sh

if [ ! $# -eq 3 ]; then
    echo "USAGE: ${0} <host> <days back> <output directory>"
    exit 1
fi

host="${1}"
days=${2}
dir=${3}

results=$(ssh ${host} ./nmapresults.sh ${days})

if [ ${#results} -gt 0 ]; then
    file=$(echo ${results} | awk 'BEGIN { FS = "/" }; {print $5};');
    scp -q ${host}:${results} ${dir}/${file}
    if [ ! $? -eq 0 ]; then
        echo "scp failed! Results: \"${results}\". Output: \"${dir}/${file}\"."
        exit 1
    fi

    echo "[+] Success: ${dir}/${file}"
else
    echo "[-] ssh failed!"
    exit 1
fi
