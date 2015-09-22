#!/bin/bash
###########################################################
# adaway-linux                                            #
# Remove ads system-wide in Linux                         #
###########################################################
# authors:      sedrubal, diy-electronics                 #
# version:      v1.0                                      #
# licence:      CC BY-SA 4.0                              #
# github:       https://github.com/sedrubal/adaway-linux  #
###########################################################

#settings
hostsorig="/etc/.hosts.original"
srclst="hostssources.lst"
version="1.0"
#

case "$1" in
  "-u" | "--uninstall" )
    #uninstall
    read -p "[?] Do you really want to uninstall adaway-linux and restore the original hosts-file? [Y/n] " REPLY
    case "$REPLY" in
      "YES" | "Yes" | "yes" | "Y" | "y" | "" )
        echo "[i] Restoring /etc/hosts"
        sudo mv "$hostsorig" /etc/hosts
        echo "[!] If you added a cronjob, please remove it by yourself."
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
    #
  "-i" | "--install" )
    echo "Welcome to the install-script for adaway-linux."
    echo "[!] Please run this only ONCE! Cancel, if you already modified /etc/hosts by adaway-linux.sh."
    read -p "[?] Proceed? [Y/n] " REPLY
    case "$REPLY" in
      "YES" | "Yes" | "yes" | "Y" | "y" | "" )
	#check if script wasn't started with the -f option
	if [ "$2" != "-f" ] && [ "$ARG1" != "--force" ] ; then
	  #backup hosts-file
	  echo "[i] First I will backup the original hosts-file to $hostsorig."
	  sudo cp /etc/hosts "$hostsorig"
	  #check if backup was succesfully
	  if [ ! -e "$hostsorig" ] ; then
	    echo "[!] Backup of /etc/hosts failed. Please backup this file manually and bypass this check by using the -f parameter."
	    exit 1
	  fi
	fi

      	#create default hostsources.lst
      	echo "[i] Now I will create the default hostsources-file. You can add urls by editing this file manually."
      	touch "$srclst"
      	echo "http://adaway.org/hosts.txt" >> "$srclst"
    	echo "http://hosts-file.net/ad_servers.asp" >> "$srclst"
    	echo "http://winhelp2002.mvps.org/hosts.txt" >> "$srclst"
    	echo "[i] File created."

    	#add cronjob
    	read -p "[?] Create a cronjob which updates /etc/hosts with new adservers every 5 days? [Y/n] " REPLY
    	case "$REPLY" in
      	  "YES" | "Yes" | "yes" | "Y" | "y" | "" )
            echo "[i] Creating cronjob..."
            line="1 12 */5 * * ""$PWD""adaway-linux.sh"
    	    (sudo crontab -u root -l; echo "$line" ) | sudo crontab -u root -
    	    ;;
          "NO" | "No" | "no" | "N" | "n" )
    	    echo "[i] No cronjob created."
    	    ;;
        esac

    	echo "[i] finished. For uninstall, please run ./install.sh -u"
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
    echo "Version: $version"
    exit 0
    ;;
  "-h" | "--help" )
    #show help
    echo "Usage: ./install.sh [OPTION]"
    echo ""
    echo "  -i,  --install	install all things needed by adaway-linux"
    echo "  			-f,  --force	force the installation"
    echo "  -u,  --uninstall	remove all changes made by this script"
    echo "  -v,  --version	show current version of this script"
    echo "  -?,  --help		show this help"
    echo ""
    echo "Please report bugs at https://github.com/sedrubal/adaway-linux/issues"
    #
    exit 1
    ;;
  * )
    echo "install.sh: unknown option $1"
    echo -e "Run »./install.sh -h« or »./install.sh --help« to get further \ninformation."
esac
