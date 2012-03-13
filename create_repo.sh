#!/bin/sh

if [ $# -lt 2 ]; then
	echo "USAGE: $0 <account> <name>"
	exit 1
fi

account=$1
name=$2
upstream=""

if [ ! "$3" == "" ]; then
	upstream=$3
fi

cd ~

pfexec zfs snapshot tank/zones/appdata/git/data/git@create:`date '+%F_%T'`

if [ ! -d clients/$account/$name.git ]; then
	mkdir -p clients/$account/$name.git
	if [ ! $? -eq 0 ]; then
		echo "Could not create repo directory!"
		exit 1
	fi
else
	echo "Repo ${account}/${name} already exists!"
	exit 1
fi

cd clients/$account/$name.git
git --bare init

if [ ! "$upstream" == "" ]; then
	git --bare fetch $upstream master:master
fi

status=$?

mail lattera@gmail.com <<EOF
Subject: [git] Repo Created

Repo ${name} created for account ${account}. Status: ${status}
EOF

exit $status
