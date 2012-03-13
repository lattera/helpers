#!/bin/sh

if [ $# -lt 2 ]; then
	echo "USAGE: $0 <account> <name>"
	exit 1
fi

account=$1
name=$2

cd ~/clients

pfexec zfs snapshot tank/zones/appdata/git/data/git@delete:`date '+%F_%T'`

status=0
if [ -d $account/$name.git ]; then
	rm -rf $account/$name.git
	status=$?
else
	echo "Repo ${account}/${name} not found"
	status=1
fi

mail lattera@gmail.com <<EOF
Subject: [git] Repo Deleted

Repo ${name} deleted for account ${account}. Status: ${status}.
EOF

exit $status
