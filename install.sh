#!/bin/bash

#settings
hostsorig="$HOME/.hosts.original"
srclst="hostssources.lst"
#

#uninstall
if [ "$1" == "-u" ] || [ "$1" == "--uninstall" ] ; then
  echo "[?] Do you really want to uninstall adaway-linux and restore the host-file? [yes]" 
  read REPLY
  if [ "$REPLY" == "yes" ] ; then
    echo "[i] restoring /etc/hosts"
    sudo mv $hostsorig /etc/hosts
    echo "[!] if you added a cronjob, pleas remove it yourself!."
  fi

  echo "[i] finished"
  exit 0
fi
#


echo "Welcome to the install-script for adaway-linux."

#backup hosts-file
echo "[i] First I will backup the original hosts-file to $hostsorig."
echo "[!] Please run this only ONCE! Abboard, if you modified /etc/hosts by adaway-linux.sh [Enter]"
read
sudo cp /etc/hosts ~/.hosts.original
echo "[!] Please check, if this worked!"
echo "[!] If this worked, please type yes. Remember that thise file is hidden!"
read REPLY
if [ "$REPLY" != "yes" ] ; then
  echo "[!] Please backup it manually and save it as $hostsorig."
  exit 1
fi

#create default hostsources.lst
echo "[i] Now I will create the $srclst file. There you can add urls, where I can fetch  parts of the hostfile."
touch "$srclst"
echo "http://adaway.org/hosts.txt" >> "$srclst"
echo "http://hosts-file.net/ad_servers.asp" >> "$srclst"
echo "http://winhelp2002.mvps.org/hosts.txt" >> "$srclst"

#add cronjob
echo "[?] If you want, I create a cronjob ever 5 days. [y]"
read REPLY
if [ "$REPLY" == "y" ] ; then
  echo "[i] Ok, I'll write in root's cron tab."
  line="1 12 */5 * * $PWD/adaway-linux.sh"
  (sudo crontab -u root -l; echo "$line" ) | sudo crontab -u root -
fi

echo "[i] finished. For uninstall, please run ./install.sh -u"
exit 1
