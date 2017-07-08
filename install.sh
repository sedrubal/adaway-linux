#!/bin/bash
###########################################################
# adaway-linux                                            #
# Remove ads system-wide in Linux                         #
###########################################################
# authors:      sedrubal, diy-electronics                 #
# version:      v3.0                                      #
# licence:      CC BY-SA 4.0                              #
# github:       https://github.com/sedrubal/adaway-linux  #
###########################################################

# settings
HOSTS_ORIG="/etc/.hosts.original"
SRCLST="hostssources.lst"
VERSION="3.0"
#

case "${1}" in
    "-u" | "--uninstall" )
        # uninstall
        read -p "[?] Do you really want to uninstall adaway-linux and restore the original /etc/hosts? [Y/n] " REPLY
        case "${REPLY}" in
            "YES" | "Yes" | "yes" | "Y" | "y" | "" )
                echo "[i] Restoring /etc/hosts"
                sudo mv "${HOSTS_ORIG}" /etc/hosts
                echo "[!] If you added a cronjob, please remove it yourself."
                echo "[i] finished"
                exit 0
                ;;
            "NO" | "No" | "no" | "N" | "n" )
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
        read -p "[?] Proceed? [Y/n] " REPLY
        case "${REPLY}" in
            "YES" | "Yes" | "yes" | "Y" | "y" | "" )
                # check if script wasn't started with the -f option
                if [ "$2" != "-f" ] && [ "$ARG1" != "--force" ] ; then
                    # backup /etc/hosts
                    echo "[i] First I will backup the original /etc/hosts to ${HOSTS_ORIG}."
                    sudo cp /etc/hosts "${HOSTS_ORIG}"
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
http://adaway.org/hosts.txt
http://hosts-file.net/ad_servers.asp
http://winhelp2002.mvps.org/hosts.txt
EOF
                echo "[i] File created."

                # add cronjob
                read -p "[?] Create a cronjob which updates /etc/hosts with new adservers every 5 days? [Y/n] " REPLY
                case "${REPLY}" in
                    "YES" | "Yes" | "yes" | "Y" | "y" | "" )
                        echo "[i] Creating cronjob..."
                        line="1 12 */5 * * ${PWD}/adaway-linux.sh"
                        (sudo crontab -u root -l; echo "$line" ) | sudo crontab -u root -
                        ;;
                    "NO" | "No" | "no" | "N" | "n" )
                        echo "[i] No cronjob created."
                        ;;
                esac

                echo "[i] finished. For uninstall, please run ${0} -u"
                exit 0
                ;;
            "NO" | "No" | "no" | "N" | "n" )
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
