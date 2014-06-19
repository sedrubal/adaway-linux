#!/bin/bash

#settings
hostsorig="/etc/.hosts.original"
srclst="hostssources.lst"
#

#store arguments
ARG1="$1"
#

#uninstall
if [ "$ARG1" == "-u" ] || [ "$ARG" == "--uninstall" ] ; then
  read -p "[?] Do you really want to uninstall adaway-linux and restore the original hosts-file? [Y/n] " REPLY
  case "$REPLY" in
  "YES" | "Yes" | "yes" | "Y" | "y" | "" )
    echo "[i] Restoring /etc/hosts"
    sudo mv "$hostsorig" /etc/hosts
    echo "[!] If you added a cronjob, please remove it by yourself."
    echo "[i] finished"
    exit 1
    ;;
  "NO" | "No" | "no" | "N" | "n" )
    echo "[i] cancelled"
    exit 0
    ;;
  esac
  exit 0
fi
#

echo "Welcome to the install-script for adaway-linux."
echo "[!] Please run this only ONCE! Cancel, if you already modified /etc/hosts by adaway-linux.sh."
read -p "[?] Proceed? [Y/n] " REPLY
case "$REPLY" in
"YES" | "Yes" | "yes" | "Y" | "y" | "" )
  #check if script wasn't started with the -f option
  if [ "$ARG1" != "-f" ] && [ "$ARG1" != "--force" ] ; then
    #backup hosts-file
    echo "[i] First I will backup the original hosts-file to $hostsorig."
    sudo cp /etc/hosts "$hostsorig"

    #check whether backup was succesfully
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
  exit 1
  ;;
"NO" | "No" | "no" | "N" | "n" )
  echo "[i] cancelled"
  exit 0
  ;;
esac
