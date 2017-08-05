# adaway-linux

A small script to block ad-containing sites in your whole Linux system.

## Features
* install-script (also supports uninstall)
* update hosts from hosts-servers (like https://adaway.org/hosts.txt)
* cron job support

## Usage
* install.sh:
```
Usage: ./install.sh [OPTION]

  -i,  --install    install all things needed by adaway-linux
  -f,  --force      force the installation
  -u,  --uninstall  remove all changes made by this script
  -v,  --version    show current version of this script
  -h,  --help       show this help

Please report bugs at https://github.com/sedrubal/adaway-linux/issues
```
* adaway-linux:
```
Welcome to adaway-linux, a small script to add domains hosting ads to the hosts file to block them.

[!] Please run ./install.sh before using this! It will backup your original /etc/hosts

Usage:
You have only to run this script to add the ad-domains to your hosts file or to update them.
Parameters:
    -h    --help      show help
    -s    --simulate  simulate, but don't replace /etc/hosts
```

## How it works
All ad hosting domains will be listed in `/etc/hosts` and therefore any request to them will be redirected to a dummy IP (`0.0.0.0`).
The list of blocked domains is fetched and can be updated from servers listed in `./hostssources.lst`.

## Drawbacks
+ theoretical it should work fine, but it's difficult to get all domains witch host advertisements
+ `/etc/hosts` file may be very confusing
+ if you want to add or remove something manually from `/etc/hosts`, you have to do this in the backup file (`/etc/.hosts.original`)
+ maybe plugins like [uBlock origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin) will work better as they remove placeholders, too.

## LICENSE
- [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

Please report bugs or fork this repo and help to improve this script.
Thank you ;)
