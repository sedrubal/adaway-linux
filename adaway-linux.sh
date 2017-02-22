#!/bin/bash
#############################################################
# adaway-linux                                              #
# Remove ads system-wide in Linux                           #
#############################################################
# authors:  sedrubal, diy-electronics                       #
# version:  v3.0                                            #
# licence:  CC BY-SA 4.0                                    #
# github:   https://github.com/sedrubal/adaway-linux        #
#############################################################

# settings
HOSTSORIG="/etc/.hosts.original"
TMPDIR="/tmp/adaway-linux/"
#

# show help
if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then

    echo "Welcome to adaway-linux, a small script to add domains hosting ads to the hosts file to block them."
    echo ""
    echo "[!] please run ./install.sh before using this! It will backup your original hosts-file"
    echo ""
    echo "Usage:"
    echo "You have only to run this script to add the ad-domains to your hosts file or to update them."
    echo "Parameters:"
    echo "    -h    --help      show help"
    echo "    -s    --simulate  simulate, but don't replace hosts-file"
    echo ""
    exit 0

fi

# check root
if [ "$(id -u)" != "0" ] && [ "$1" != "-s" ] && [ "$1" != "--simulate" ] ; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# preparing temporary directory
if [ -d "${TMPDIR}" ]; then
    echo "[i] deleting directory ${TMPDIR}"
    rm -r "${TMPDIR}"
fi

echo "[i] creating temporary directory ${TMPDIR}"
mkdir -p "${TMPDIR}"

# add domains from hosts-server listet in hostssources.lst
while read src; do
    if [[ $src != "#*" ]] ; then
        # only insert entries redirecting to 127.0.0.1 or 0.0.0.0 (everything else might be a security nightmare)
        curl --progress-bar -L "${src}" | sed 's/\r/\n/' | sed 's/\s\+/\t/' | sed 's/0\.0\.0\.0/127.0.0.1/' | grep '127\.0\.0\.1' >> "${TMPDIR}/hosts.downloaded"
    else
        echo "[i] skipping $src"
    fi
done <hostssources.lst

# fists lines of hosts-file
echo "[i] add original hosts file from ${HOSTSORIG}"
cat << EOF > "${TMPDIR}/hosts"
# [!] This file will be updated by the ad-block-script called adaway-linux." >> "${TMPDIR}/hosts"
# [!] If you want to edit the hosts-file, please edit the original file in ${HOSTSORIG}." >> "${TMPDIR}/hosts"
# [!] Changes will be added to the top of this file." >> "${TMPDIR}/hosts"

EOF
cat "${HOSTSORIG}" >> "${TMPDIR}/hosts"
cat << EOF >> "${TMPDIR}/hosts"

# Ad Servers:

EOF

echo "[i] Cleanup ${TMPDIR}/hosts.downloaded and merge with original content"
uniq <(sort "${TMPDIR}/hosts.downloaded") >> "${TMPDIR}/hosts"

# replacing hosts-file
if [ "$1" != "-s" ] && [ "$1" != "--simulate" ] ; then

    echo "[i] moving new hosts file to /etc/hosts"
    mv "${TMPDIR}/hosts" /etc/hosts

    echo "[i] deleting directory ${TMPDIR}"
    rm -r "${TMPDIR}"

else
    echo "[i] skipping replacing the hosts-file. You can see the hosts file there: ${TMPDIR}/hosts"
fi

echo "[i] finished"
exit 0
