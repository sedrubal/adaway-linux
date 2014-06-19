adaway-linux
============

A small script to block ad-containing sites in your whole Linux system.

Features
--------
* install-script (also supports uninstall)
* update hosts from hosts-servers (like http://adaway.org/hosts.txt)
* cronjob support

Usage
-----
* install.sh:
```
Usage: ./install.sh [OPTION]

  -i,  --install        install all things needed by adaway-linux
                        -f,  --force    force the installation
  -u,  --uninstall      remove all changes made by this script
  -v,  --version        show current version of this script
  -?,  --help           show this help
```
* adaway-linux:
```
You only have to run this script to add the ad-domains to your hosts file or to update them.
Parameters:
    -h    --help      show help
    -s    --simulate  simulate, but don't replace hosts-file
```

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
