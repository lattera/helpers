#!/usr/local/bin/zsh

function usage() {
    echo "USAGE: ${1}"
    echo "    -b    [BE name]                 (requried)"
    echo "    -e    [old BE name]             (optional)"
    echo "    -B    Build new world/kernel    (optional)"
    echo "    -k    [kernel name]             (optional, default \"SEC\")"
    echo "    -m    [mount point]             (optional, default /mnt/[BE name])"
    echo "    -s    Use sudo                  (optional, default to no)"
    echo "    -p    [ports]                   (optional, rebuild certain ports)"
    exit 1
}

function build() {
    kern=${1}

    pushd /usr/src
    
    make -sj7 buildworld buildkernel KERNCONF=${kern}
    ret=${?}

    popd
    return ${ret}
}

function installuniverse() {
    kern=${1}
    destdir=${2}
    lsudo=${3}

    pushd /usr/src
    ${lsudo} make -s installkernel KERNCONF=${kern} DESTDIR=${destdir}
    ret=${?}
    if [ ! ${ret} -eq 0 ]; then
        popd
        return ${ret}
    fi
    ${lsudo} make -s installworld DESTDIR=${destdir}
    ret=${?}

    popd
    return ${ret}
}

function portbuild() {
    lmnt=${1}
    lports=${2}
    lsudo=${3}

    ${lsudo} mount -t nullfs /usr/ports ${lmnt}/usr/ports
    ret=${?}
    if [ ! ${ret} -eq 0 ]; then
        echo "[-] Could not mount ports nullfs in chroot"
        return ${ret}
    fi

    ${lsudo} mount -t nullfs /usr/src ${lmnt}/usr/src
    ret=${?}
    if [ ! ${ret} -eq 0 ]; then
        ${lsudo} umount ${lmnt}/usr/ports

        echo "[-] Could not mount src nullfs in chroot"
        return ${ret}
    fi

    ${lsudo} mount -t devfs devfs ${lmnt}/dev
    ret=${?}
    if [ ! ${ret} -eq 0 ]; then
        ${lsudo} umount ${lmnt}/usr/ports
        ${lsudo} umount ${lmnt}/usr/src

        echo "[-] Could not mount devfs in chroot"
        return ${ret}
    fi

    ${lsudo} chroot ${lmnt} portmaster -HwD --no-confirm ${lports}
    ret=${?}
    if [ ! ${ret} -eq 0 ]; then
        echo "[-] [Re]Installing ports failed"
    fi

    ${lsudo} umount ${lmnt}/dev
    ${lsudo} umount ${lmnt}/usr/ports
    ${lsudo} umount ${lmnt}/usr/src
}

if [ ${#@} -lt 2 ]; then
    usage ${0}
fi

bename=""
oldbename=""
buildme="false"
kernel="SEC"
mntpoint=""
sudo=""
ports=""

while getopts 'b:e:k:m:p:Bsh' o; do
    case "${o}" in
        b)
            bename=${OPTARG}
            ;;
        e)
            oldbename="-e ${OPTARG}"
            ;;
        B)
            buildme="true"
            ;;
        k)
            kernel=${OPTARG}
            ;;
        m)
            mntpoint=${OPTARG}
            ;;
        p)
            ports="${OPTARG}"
            ;;
        s)
            sudo=$(which sudo)
            if [ ${#sudo} -eq 0 ]; then
                echo "[-] Sudo not installed. Please install the security/sudo port"
                exit 1
            fi
            ;;
        h)
            usage ${0}
            ;;
        *)
            usage ${0}
            ;;
    esac
done

if [ ${#bename} -eq 0 ]; then
    usage ${0}
fi

if [ ${#mntpoint} -eq 0 ]; then
    mntpoint="/mnt/${bename}"
fi

beadm=$(which beadm)
if [ ${#beadm} -eq 0 ]; then
    echo "[-] No beadm installed. Please install the sysutils/beadm port"
    exit 1
fi

if [ "${buildme}" = "true" ]; then
    # Don't use sudo. Force an unprivileged build.

    build ${kernel}
    if [ ! ${?} -eq 0 ]; then
        echo "    [-] Build failed"
        exit 1
    fi
fi

echo "[+] Creating new BE ${bename}"

${sudo} ${beadm} create ${oldbename} ${bename}
if [ ! ${?} -eq 0 ]; then
    echo "    [-] Creation of new BE failed"
    exit 1
fi

echo "[+] Mounting new BE"
${sudo} ${beadm} mount ${bename} ${mntpoint}
if [ ! ${?} -eq 0 ]; then
    echo "    [-] Mounting the new BE failed"
    ${sudo} ${beadm} destroy -F ${bename}
    exit 1
fi

echo "[+] Installing new world/kernel"
installuniverse ${kernel} ${mntpoint} ${sudo}
if [ ! ${?} -eq 0 ]; then
    echo "    [-] Installing new world/kernel failed"
    ${sudo} ${beadm} umount ${bename}
    ${sudo} ${beadm} destroy -F ${bename}
    exit 1
fi

if [ ${#ports} -gt 0 ]; then
    echo "[+] Rebuilding ports."
    portbuild ${mntpoint} ${ports} ${sudo}
    if [ ! ${?} -eq 0 ]; then
        echo "    [-] Rebuilding ports failed"
        ${sudo} ${beadm} umount ${bename}
        ${sudo} ${beadm} destroy -F ${bename}
        exit 1
    fi
fi

${sudo} ${beadm} umount ${bename}
${sudo} ${beadm} activate ${bename}

echo "[+] New BE created. Reboot to activate BE"
