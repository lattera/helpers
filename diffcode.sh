#!/usr/local/bin/bash

cd $1

commits=`git log --author="$2" --oneline | grep -v upstream | awk '{print $1;}'`

for commit in $commits; do
    git diff $commit^ $commit >> $3
done
