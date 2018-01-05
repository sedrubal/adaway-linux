#!/bin/bash
#############################################################
# adaway-linux                                              #
# Remove ads system-wide in Linux                           #
#############################################################
# authors:  sedrubal, diy-electronics                       #
# version:  v4.0                                            #
# licence:  CC BY-SA 4.0                                    #
# github:   https://github.com/sedrubal/adaway-linux        #
#############################################################

# settings
readonly HOSTSORIG="/etc/.hosts.original"
readonly TMPDIR="/tmp/adaway-linux"
readonly DL_TIMEOUT="20"
readonly DL_RETRIES="2"
#

readonly SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"  # Gets the location of the script

set -e

# show help
if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then

    echo "Welcome to adaway-linux, a small script to add domains hosting ads to the hosts file to block them."
    echo ""
    echo "[!] Please run ./install.sh before using this! It will backup your original /etc/hosts"
    echo ""
    echo "Usage:"
    echo "You have only to run this script to add the ad-domains to your hosts file or to update them."
    echo "Parameters:"
    echo "    -h    --help      show help"
    echo "    -s    --simulate  simulate, but don't replace /etc/hosts"
    echo ""
    exit 0

fi

# check root
if [ "${UID}" != "0" ] && [ "${1}" != "-s" ] && [ "${1}" != "--simulate" ] ; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

# preparing temporary directory
if [ -d "${TMPDIR}" ]; then
    echo "[i] Deleting directory ${TMPDIR}"
    rm -r "${TMPDIR}"
fi

echo "[i] Creating temporary directory ${TMPDIR}"
mkdir -p "${TMPDIR}"

# add domains from hosts-server listet in hostssources.lst
while read src; do
    if [[ "${src}" != "#"* ]] ; then
        echo "[i] Downloading and cleaning up ${src}"
        set +e

        if type curl 1>/dev/null 2>&1; then
          DOWNLOAD_CMD=$(curl --progress-bar -L --connect-timeout ${DL_TIMEOUT} --retry ${DL_RETRIES} "${src}")
        else
          DOWNLOAD_CMD=$(wget "${src}" -nv --show-progress --read-timeout=${DL_TIMEOUT} --timeout=${DL_TIMEOUT} -t ${DL_RETRIES} -L -O - )
        fi

        set -e
        # download and cleanup:
        # - replace \r\n to unix \n
        # - remove leading whitespaces
        # - replace 127.0.0.1 with 0.0.0.0 (shorter, unspecified)
        # - use only host entries redirecting to 0.0.0.0 (no empty line, no comment lines, no dangerous redirects to other sites
        # - remove additional localhost entries possibly picked up from sources
        # - remove remaining comments
        # - split all entries with one tab
        echo "${DOWNLOAD_CMD}" \
          | sed 's/\r/\n/' \
          | sed 's/^\s\+//' \
          | sed 's/^127\.0\.0\.1/0.0.0.0/' \
          | grep '^0\.0\.0\.0' \
          | grep -v '\slocalhost\s*' \
          | sed 's/\s*\#.*//g' \
          | sed 's/\s\+/\t/g' \
          >> "${TMPDIR}/hosts.downloaded"
    else
        echo "[i] Skipping ${src}"
    fi
done < "${SCRIPT_DIR}/hostssources.lst"

# checks if any sources where downloaded
if [ ! -e "${TMPDIR}/hosts.downloaded" ] || [ ! -s "${TMPDIR}/hosts.downloaded" ]; then
  echo "[!] No data obtained. Exiting..." 1>&2
  exit 1
fi

uniq <(sort "${TMPDIR}/hosts.downloaded") > "${TMPDIR}/hosts.adservers"

# fists lines of /etc/hosts
echo "[i] Adding original hosts file from ${HOSTSORIG}"
cat >> "${TMPDIR}/hosts.header" <<EOF
# [!] This file will be updated by the ad-block-script called adaway-linux.
# [!] If you want to edit /etc/hosts, please edit the original file in ${HOSTSORIG}.
# [!] Content from there will be added to the top of this file.

EOF
cat "${HOSTSORIG}" >> "${TMPDIR}/hosts.header"
cat >> "${TMPDIR}/hosts.header" <<EOF

# Ad Servers: added with ${SCRIPT_DIR}/adaway-linux.sh

EOF
cat "${TMPDIR}/hosts.header" "${TMPDIR}/hosts.adservers" > "${TMPDIR}/hosts"

# replacing /etc/hosts
if [ "${1}" != "-s" ] && [ "${1}" != "--simulate" ] ; then

    echo "[i] Moving new hosts file to /etc/hosts"
    mv "${TMPDIR}/hosts" /etc/hosts

    echo "[i] Deleting directory ${TMPDIR}/"
    rm -r "${TMPDIR}"

else
    echo "[i] Skipping replacing /etc/hosts. You can see the hosts file there: ${TMPDIR}/hosts"
fi

echo "[i] Finished"
exit 0
