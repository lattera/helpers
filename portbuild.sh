#!/usr/local/bin/bash

date=`/bin/date '+%F_%T'`
curdir="$(cd "$(dirname $0)" && pwd)"

# Step 1 - Sanity checking
if [ ! -f "${curdir}/pkgs.txt" ]; then
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

if [ -f "${curdir}/pkgexcludes.txt" ]; then
    for exclude in `cat ${curdir}/pkgexcludes.txt`; do
        excludes="${excludes} | grep -v ${exclude}"
    done
fi

# Step 4 - Set up initial logging
exec 1> $curdir/logs/$date
exec 2>&1

# Step 5 - Delete all packages minus the above excluded packages
cmd="pkg_info | awk '{print \$1;}' ${excludes} | xargs sudo pkg_delete"
eval $cmd

# Step 6 - Make sure libtool is installed
pkg_info | grep libtool > /dev/null

if [ $? -gt 0 ]; then
    echo "==== Installing libtool ===="

    cd /usr/ports/devel/libtool
    sudo make DISABLE_LICENSES=YES BATCH=YES package-recursive clean
fi

# Step 7 - Build new packages
for pkg in `cat ${curdir}/pkgs.txt`; do
    logfile=`echo $pkg | sed 's/\//_/g'`
    exec 1> $curdir/logs/$date-$logfile
    exec 2>&1

    cd /usr/ports/$pkg
    sudo make DISABLE_LICENSES=YES BATCH=YES clean package-recursive clean | tee -a $curdir/logs/$date
done
