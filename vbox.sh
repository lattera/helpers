#!/usr/local/bin/bash

cd $(dirname ${0})

startport=5901

shutdown_vms ()
{
    needsleep=0

    for vm in $(VBoxManage list runningvms | awk '{print $3};'); do
        echo "[+] Stopping ${vm}"
        VBoxManage controlvm ${vm} acpipowerbutton
        needsleep=1
    done

    if [ ${needsleep} == 1 ]; then
        echo "[+] One or more VMs needed to be powered off. Sleeping for 60 seconds."
        sleep 60
    fi
}

if [ ! -f "vm_list.txt" ]; then
    echo "[-] Please add each VM on its own line in vm_list.txt"
    exit 1
fi

case $1 in
    start|restart)
        shutdown_vms
        OIFS=$IFS
        IFS=$'\n'

        for vm in `cat vm_list.txt`; do
            echo "[+] Starting ${vm} with VNC port ${startport}"
            nohup VBoxHeadless -s "${vm}" -n -m ${startport} &
            startport=$((startport+1))
        done

        IFS=$OIFS
        ;;
    stop)
        shutdown_vms
        ;;
    *)
        ;;
esac

exit 0
