#!/bin/sh

if [ $# -lt 2 ]; then
	echo "USAGE: $0 <account> <name>"
	exit 1
fi

account=$1
name=$2

cd ~/clients

if [ -d $account/$name.git ]; then
	rm -rf $account/$name.git
else
	echo "Repo ${account}/${name} not found"
fi
