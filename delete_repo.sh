#!/bin/sh

# Security-related variables
email="lattera@gmail.com"
date=`date '+%F_%T'`
dataset="tank/zones/appdata/git/data/git"

if [ $# -lt 2 ]; then
	echo "USAGE: $0 <account> <name>"
	exit 1
fi

account=$1
name=$2

cd ~/clients

pfexec zfs snapshot $dataset@delete:$date

status=0
if [ -d $account/$name.git ]; then
	rm -rf $account/$name.git
	status=$?
else
	echo "Repo ${account}/${name} not found"
	status=1
fi

mail $email <<EOF
Subject: [git] Repo Deleted

Repo ${name} deleted for account ${account} on ${date}. Status: ${status}.
EOF

exit $status
