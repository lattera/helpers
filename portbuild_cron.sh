#!/usr/local/bin/bash

curdir="$(cd "$(dirname $0)" && pwd)"

# We need to run portclean twice
# Once before in case other jails have tainted the ports tree
# Once after just to be curteous to other jails

$curdir/portclean.sh
$curdir/portbuild.sh
$curdir/portclean.sh
