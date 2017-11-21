#!/bin/bash
###########################################################
# adaway-linux                                            #
# Remove ads system-wide in Linux                         #
###########################################################
# authors:      sedrubal, diy-electronics                 #
# version:      v4.0                                      #
# licence:      CC BY-SA 4.0                              #
# github:       https://github.com/sedrubal/adaway-linux  #
###########################################################

# settings
HOSTS_ORIG="/etc/.hosts.original"
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"  # Gets the location of the script
SRCLST="${SCRIPT_DIR}/hostssources.lst"
VERSION="4.0"
SYSTEMD_DIR="/etc/systemd/system"
#

set -e

case "${1}" in
    "-u" | "--uninstall" )
        # uninstall

        # check root
        if [ "${UID}" != "0" ] ; then
          echo "[!] For this action the script must be run as root." 1>&2
          exit 1
        fi

        read -r -p "[?] Do you really want to uninstall adaway-linux and restore the original /etc/hosts? [Y/n] " REPLY
        case "${REPLY}" in
            [Yy][Ee][Ss] | [Yy] | "" ) # YES, Y, NULL

                # check if cronjob was installed
                if [[ $(sudo crontab -u root -l | grep 'adaway-linux.sh') ]] ; then
                  echo "[i] Removing cronjob..."
                  crontab -u root -l | grep -v 'adaway-linux.sh' |  crontab -u root - # Gets cronjob but ignores the line with adaway-linux.sh and then reinstalls cronjob
                else
                  echo "[i] No cronjob installed. Skipping..."
                fi

                # check if systemd services are installed
                if [ -e "${SYSTEMD_DIR}/adaway-linux.timer" ] || [ -e "${SYSTEMD_DIR}/adaway-linux.service" ] ; then

                  echo "[!] Removing systemd service..."
                  # Unhooking the systemd service
                  systemctl stop adaway-linux.timer && systemctl disable adaway-linux.timer || echo "[!] adaway-linux.timer is missing. Have you removed it?"
                  systemctl stop adaway-linux.service && systemctl disable adaway-linux.service || echo "[!] adaway-linux.service is missing. Have you removed it?"
                  rm "${SYSTEMD_DIR}"/adaway-linux.*
                else
                  echo "[i] No systemd service installed. Skipping..."
                fi
                # Checks if /etc/.hosts.orginal exist
                if [ ! -e "${HOSTS_ORIG}" ] ; then
                  echo "[!] Backup of /etc/hosts does not exist. To install run: »${0} -i« or restore it manually."
                  exit 1
                else
                  echo "[i] Restoring /etc/hosts"
                  mv "${HOSTS_ORIG}" /etc/hosts
                fi
                echo "[i] Finished."
                exit 0
                ;;
            * )
                echo "[i] Uninstallation cancelled."
                exit 1
                ;;
        esac
        exit 1
        ;;
        # install
        "-i" | "--install" )
        echo "Welcome to the install-script for adaway-linux."
        # check root
        if [ "${UID}" != "0" ] ; then
          echo "[!] For this action the script must be run as root." 1>&2
          exit 1
        fi
        echo "[!] Please run this only ONCE! Cancel, if you already modified /etc/hosts by adaway-linux.sh."
        read -r -p "[?] Proceed? [Y/n] " REPLY
        case "${REPLY}" in
            [Yy][Ee][Ss] | [Yy] | "" ) # YES, Y, NULL

                # check if script wasn't started with the -f option
                if [ "${2}" != "-f" ] && [ "${2}" != "--force" ] ; then
                    # backup /etc/hosts
                    echo "[i] First I will backup the original /etc/hosts to ${HOSTS_ORIG}."
                    # checks if /etc/.hosts.original already exist
                    if [ -e "${HOSTS_ORIG}" ] ; then
                      echo "[!] Backup of /etc/hosts already exist. To uninstall run: »${0} -u«"
                      exit 1
                    fi
                    cp /etc/hosts "${HOSTS_ORIG}"
                    # check if backup was succesfully
                    if [ ! -e "${HOSTS_ORIG}" ] ; then
                        echo "[!] Backup of /etc/hosts failed. Please backup this file manually and bypass this check by using the -f parameter."
                        exit 1
                    fi
                else
                  rm -f "${HOSTS_ORIG}"
                fi

                # create default hostsources.lst
                echo "[i] Now I will create the default hostsources-file: ${SRCLST}."
                echo "[i] You can add urls by editing this file manually."
                cat << EOF > "${SRCLST}"
https://adaway.org/hosts.txt
https://hosts-file.net/ad_servers.txt
https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext
https://www.malwaredomainlist.com/hostslist/hosts.txt
EOF
                echo "[i] File created."

                # add cronjob
                read -r -p "[?] Create a cronjob/systemd-service which updates /etc/hosts with new adservers once a week? [systemd/cronjob/N] " REPLY
                case "${REPLY}" in
                    [Cc][Rr][Oo][Nn][Jj][Oo][Bb] | [Cr][Rr][Oo][Nn][Tt][Aa][Bb] | [Cc][Rr][Oo][Nn] | [Cc] ) # CRONJOB, CRONTAB, CRON, C
                        echo "[i] Creating cronjob..."
                        line="1 12 */5 * * ${SCRIPT_DIR}/adaway-linux.sh"
                        (crontab -u root -l; echo "${line}" ) | crontab -u root -
                        ;;
                    [Ss][Yy][Ss][Tt][Ee][Mm][Dd] | [Ss][Yy][Ss] | [Ss] ) # SYSTEMD, SYS, S
                        echo "[i] Creating systemd service..."

                        # create .service file
                        cat > "${SYSTEMD_DIR}/adaway-linux.service" <<EOL
[Unit]
Description=Service to run adaway-linux weekly
Documentation=https://github.com/sedrubal/adaway-linux/
After=network.target

[Service]
ExecStart=${SCRIPT_DIR}/adaway-linux.sh
EOL

                        # create .timer file
                        cat > "${SYSTEMD_DIR}/adaway-linux.timer" <<EOL
[Unit]
Description=Timer that runs adaway-linux.service weekly
Documentation=https://github.com/sedrubal/adaway-linux/
After=network.target

[Timer]
OnCalendar=weekly
Persistent=true
Unit=adaway-linux.service

[Install]
WantedBy=timers.target
EOL
                        chmod u=rw,g=r,o=r "${SYSTEMD_DIR}/adaway-linux."*

                        # Enable the schedule
                        systemctl enable adaway-linux.timer && systemctl start adaway-linux.timer && echo "[i] Systemd service succesfully initialized."
                        ;;
                    * )
                        echo "[i] No schedule created."
                        ;;
                esac

                echo "[i] Finished. For uninstall, please run »${0} -u«"
                exit 0
                ;;
            * )
                echo "[i] Installation cancelled."
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
        echo "  -i,  --install    install all things needed by adaway-linux (requires root)"
        echo "  -f,  --force      force the installation (requires root)"
        echo "  -u,  --uninstall  remove all changes made by this script (requires root)"
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
