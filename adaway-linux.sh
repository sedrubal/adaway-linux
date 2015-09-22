#!/bin/bash
###########################################################
# adaway-linux						  #
# Remove ads system-wide in Linux			  #
###########################################################
# authors:	sedrubal, diy-electronics		  #
# version:	v1.0					  #
# licence:	CC BY-SA 4.0				  #
# github:	https://github.com/sedrubal/adaway-linux  #
###########################################################

#settings
hostsorig="/etc/.hosts.original"
tmpdir="/tmp/adaway-linux/"
#

#show help
if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then

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

#check root
if [ "$(id -u)" != "0" ] && [ "$1" != "-s" ] && [ "$1" != "--simulate" ] ; then
echo "This script must be run as root" 1>&2
exit 1
fi

#preparing temporary directory
if [ -d "$tmpdir" ]; then
  echo "[i] deleting directory $tmpdir"
  rm -r "$tmpdir"
fi

echo "[i] creating temporary directory $tmpdir"
mkdir "$tmpdir"
touch "$tmpdir"hosts

#fists lines of hosts-file
echo "[i] add original hosts file from $hostsorig"
echo "#[!] This file will be updated by the ad-block-script called adaway-linux." >> "$tmpdir"hosts
echo -e "#[!] If you want to edit the hosts-file, please edit the original file in $hostsorig." >> "$tmpdir"hosts
echo -e "#[!] Changes will be added to the top of this file.\n\n" >> "$tmpdir"hosts
cat "$hostsorig" >> "$tmpdir"hosts

#add domains from hosts-server listet in hostssources.lst
i=0
while read src; do
  if [[ $src != "#*" ]] ; then
    wget -O "$tmpdir$i" $src
    echo -e "\n---------------------------------\n" >> "$tmpdir"hosts 
    cat "$tmpdir$((i++))" >> "$tmpdir"hosts
  else
    echo "[i] skipping $src"
  fi
done <hostssources.lst

#replacing hosts-file
if [ "$1" != "-s" ] && [ "$1" != "--simulate" ] ; then

  echo "[i] removing old hosts file"
  rm /etc/hosts

  echo "[i] moving new hosts file to /etc/hosts"
  mv "$tmpdir"hosts /etc/hosts

  echo "[i] deleting directory $tmpdir"
  rm -r "$tmpdir"

else
  echo "[i] skipping replacing the hosts-file. You can see the hosts file there: $tmpdir"hosts
fi

echo "[i] finished"
exit 0
