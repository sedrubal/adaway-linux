#!/bin/bash
###########################################################
# adaway-linux                                            #
# Remove ads system-wide in Linux                         #
###########################################################
# authors:      sedrubal, diy-electronics                 #
# version:      v3.2                                      #
# licence:      CC BY-SA 4.0                              #
# github:       https://github.com/sedrubal/adaway-linux  #
###########################################################

# settings
HOSTS_ORIG="/etc/.hosts.original"
SYSTEMD_DIR="/etc/systemd/system"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # Gets the location of the script
SRCLST="$DIR/hostssources.lst"
VERSION="3.2"
#


set -e

# check root
if [ "$(id -u)" != "0" ] ; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

case "${1}" in
    "-u" | "--uninstall" )
        # uninstall
        read -r -p "[?] Do you really want to uninstall adaway-linux and restore the original /etc/hosts? [Y/n] " REPLY
        case "${REPLY}" in
            "YES" | "Yes" | "yes" | "Y" | "y" | "" )
                if [ -e ${SYSTEMD_DIR}/adaway-linux.timer ] || [ -e ${SYSTEMD_DIR}/adaway-linux.service ] ; then
                  echo "[!] Removing services..."
                  # Unhooking the systemd service
                  systemctl disable adaway-linux.service || echo "[!] adaway-linux.service is missing. Have you removed it?"
                  systemctl disable adaway-linux.timer || echo "[!] adaway-linux.timer is missing. Have you removed it?"
                  rm ${SYSTEMD_DIR}/adaway-linux.*
                else
                  echo "[i] No adaway service installed. Skipping.."
                fi
                echo "[i] Restoring /etc/hosts"
                mv "${HOSTS_ORIG}" /etc/hosts || echo "[!] Couldn't restore original hosts file."

                echo "[i] finished"
                exit 0
                ;;
            * | "NO" | "No" | "no" | "N" | "n" )
                echo "[i] cancelled"
                exit 1
                ;;
        esac
        exit 1
        ;;
        # install
        "-i" | "--install" )
        echo "Welcome to the install-script for adaway-linux."
        echo "[!] Please run this only ONCE! Cancel, if you already modified /etc/hosts by adaway-linux.sh."
        read -r -p "[?] Proceed? [Y/n] " REPLY
        case "${REPLY}" in
            "YES" | "Yes" | "yes" | "Y" | "y" | "" )
                # check if script wasn't started with the -f option
                if [ "$2" != "-f" ] && [ "$ARG1" != "--force" ] ; then
                    # backup /etc/hosts
                    echo "[i] First I will backup the original /etc/hosts to ${HOSTS_ORIG}."
                    cp /etc/hosts "${HOSTS_ORIG}"
                    # check if backup was succesfully
                    if [ ! -e "${HOSTS_ORIG}" ] ; then
                        echo "[!] Backup of /etc/hosts failed. Please backup this file manually and bypass this check by using the -f parameter."
                        exit 1
                    fi
                fi

                # create default hostsources.lst
                echo "[i] Now I will create the default hostsources-file: ${SRCLST}."
                echo "[i] You can add urls by editing this file manually."
                cat << EOF > "${SRCLST}"
https://adaway.org/hosts.txt
https://hosts-file.net/ad_servers.txt
https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext
EOF
                echo "[i] File created."

                # add systemd service
                read -r -p "[?] Create a systemd service which updates /etc/hosts with new adservers every week? [Y/n] " REPLY
                case "${REPLY}" in
                    "YES" | "Yes" | "yes" | "Y" | "y" | "" )
                        echo "[i] Creating service..."

                        # create .service file
                        cat > "${SYSTEMD_DIR}/adaway-linux.service" <<EOL
[Unit]
Description=Service to run adaway-linux weekly

[Service]
ExecStart=$DIR/adaway-linux.sh
EOL

                        # create .timer file
                        cat > "${SYSTEMD_DIR}/adaway-linux.timer" <<EOL
[Unit]
Description=Run adaway-linux weekly

[Timer]
OnCalendar=weekly
Persistent=true
Unit=adaway-linux.service

[Install]
WantedBy=timers.target
EOL
                        chmod 755 ${SYSTEMD_DIR}/adaway-linux.*

                        # Enable the schedule
                        systemctl enable adaway-linux.timer && echo "[i] Service succesfully installed."

                        ;;
                      * | "NO" | "No" | "no" | "N" | "n" )
                        echo "[i] No service created."
                        ;;
                esac

                echo "[i] finished. For uninstall, please run ${0} -u"
                exit 0
                ;;
            * | "NO" | "No" | "no" | "N" | "n" )
                echo "[i] cancelled"
                exit 1
                ;;
        esac
        exit 0
        ;;
    "-v" | "--version" )
        echo "Version: ${VERSION}"
        exit 0
        ;;
    "-h" | "--help" )
        # show help
        echo "Usage: ${0} [OPTION]"
        echo ""
        echo "  -i,  --install    install all things needed by adaway-linux"
        echo "  -f,  --force      force the installation"
        echo "  -u,  --uninstall  remove all changes made by this script"
        echo "  -v,  --version    show current version of this script"
        echo "  -h,  --help       show this help"
        echo ""
        echo "Please report bugs at https://github.com/sedrubal/adaway-linux/issues"
        #
        exit 1
        ;;
    * )
        echo "${0}: unknown option ${1}"
        echo "Run »${0} -h« or »${0} --help« to get further information."
esac
