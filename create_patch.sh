#!/bin/sh

if [ ! $# -eq 2 ]; then
    echo "USAGE: ${0} <tag> <patchfile>"
    exit 1
fi

tag="${1}"
patchfile="${2}"

exists="false"
for gittag in $(git tag); do
    if [ "${gittag}" == "${tag}" ]; then
        exists="true"
    fi
done

if [ "${exists}" == "false" ]; then
    echo "Tag doesn't exist. Exiting."
    exit 1
fi

if [ -f ${patchfile} ]; then
    echo "Patch file already exists. Exiting."
    exit 1
fi

git diff "${tag}" --dst-prefix= > ${patchfile}
exit $?
