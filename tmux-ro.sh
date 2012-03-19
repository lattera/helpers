#!/bin/sh

. ~/.profile

read -p "Session Name: " session_name

session_available=0
for sessions in `tmux ls 2> /dev/null | awk \{'print \$1;'\}`; do
    (echo ${sessions} | grep -wR ${session_name}) > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        session_available=1
    fi
done

if [ $session_available -eq 0 ]; then
    echo "Access Denied"
    exit 1
fi

tmux attach -rt ${session_name}
