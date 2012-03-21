#!/bin/sh

if [ ! $# -eq 1 ]; then
	echo "USAGE: ${0} client"
	exit 1
fi

cd ~/clients

(echo ${1} | grep \\.\\.) > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Access Denied"
	exit 1
fi

if [ ! -d $1 ]; then
	echo "Access Denied"
	exit 1
fi

ls $1
