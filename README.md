adaway-linux
============

a small script to add domains hosting ads to the hosts file to block them in your whole system.

Operation
---------
All domains will be listet in /etc/hosts and so each request to them will be redirected to a other IP (127.0.0.1, 0.0.0.0, ...)

Features
--------
+ install-script (also supports uninstall)
+ update hosts from hosts-servers (like http://adaway.org/hosts.txt)
+ cronjob support
+ gefrickelt ;)

Efficiency
----------
+ Theoretical it should work fine, but it's difficult to get all domains, hosting ads.
+ /etc/hosts file may be verry confusing.
+ If you want to change something, you have to do this in the backuped file.
+ Maybe PlugIns like AdBlock will work better...

Usage
-----
- 0) choose a directory and put the two scripts in it
- 1) Please familiarize yourself with the script to prevent your System for damage. (Obacht Frickeley)
- 2) First run ./install.sh
  - This will create the hostssources.lst, where you can add your own domains, offering parts of a hosts file
  - It will also backup the /etc/hosts into your homedirectory
  - If you want, you can add a cronjob

- 3) now you can run 
  - ./adaway-linux.sh --help
   to watch the help and then
  - ./adaway-linux.sh --simulate
   to check if you understood, what this script will do.

- 4) If you now know, what you do run
  - ./adaway-linux.sh
      
Please report bugs or fork this repo and help to improve this script.
Thank you ;)
