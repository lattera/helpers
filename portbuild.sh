#!/usr/local/bin/bash

date=`/bin/date '+%F_%T'`
curdir="$(dirname $0)"

# Step 1 - Sanity checking
if [ ! -f "pkgs.txt" ]; then
    echo "Please enter packages you would like to build in pkgs.txt"
    exit 1
fi

# Step 2 - Exclude packages that shouldn't be deleted
excludes=""
if [ $# -gt 0 ]; then
    for exclude in $@; do
        excludes="${excludes} | grep -v ${exclude}"
    done
fi

if [ -f "pkgexcludes.txt" ]; then
    for exclude in `cat pkgexcludes.txt`; do
        excludes="${excludes} | grep -v ${exclude}"
    done
fi

exec 1> $curdir/logs/$date
exec 2>&1

# Step 4 - Delete all packages minus the above excluded packages
cmd="pkg_info | awk '{print \$1;}' ${excludes} | xargs sudo pkg_delete"
eval $cmd

# Step 5 - Build new packages
for pkg in `cat pkgs.txt`; do
    logfile=`echo $pkg | sed 's/\//_/g'`
    exec 1> $curdir/logs/$date-$logfile
    exec 2>&1

    cd /usr/ports/$pkg
    sudo make DISABLE_LICENSES=YES BATCH=YES package-recursive clean | tee -a $curdir/logs/$date
done
