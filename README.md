adaway-linux
============

A small script to block ad-containing sites in your whole Linux system.

Features
--------
+ install-script (also supports uninstall)
+ update hosts from hosts-servers (like http://adaway.org/hosts.txt)
+ cronjob support

Usage
-----
- 0) choose a directory and put the two scripts in it
- 1) please familiarize yourself with the script to prevent your system from damage (Obacht Frickelei)
- 2) run `./install.sh`
  - this will create ./hostssources.lst, where you can add your own domains offering lists with adservers
  - it will also backup /etc/hosts to ~/.hosts.original 
  - if you want, you can add a cronjob

- 3) run `./adaway-linux.sh --help` and find out which options are available - 4) run `./adaway-linux.sh --simulate` to check whether you 
understood what this script will do - 4) if you're sure you want to proceed, run `./adaway-linux.sh`

Operation
---------
All domains will be listed in /etc/hosts and therefore any request to them will be redirected to localhost or a dummy IP (127.0.0.1, 0.0.0.0, ...)

Efficiency
----------
+ theoretical it should work fine, but it's difficult to get all domains witch host advertisements
+ /etc/hosts file may be very confusing
+ if you want to add or remove something manually from /etc/hosts, you have to do this in the backupfile
+ maybe plugins like AdBlock will work better...

Please report bugs or fork this repo and help to improve this script.
Thank you ;)
