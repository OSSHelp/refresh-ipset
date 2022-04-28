# refresh-ipset

[![Build Status](https://drone.osshelp.ru/api/badges/OSSHelp/refresh-ipset/status.svg)](https://drone.osshelp.ru/OSSHelp/refresh-ipset)

## About

This script performs automatic updates of ipset lists and ACL for Nginx/Monit. It supports lists of commercial services IPs, such as:

- bitbucket-v4 - Bitbucket IPv4
- cf-v4 and cf-v6 - CloudFlare IPv4 and IPv6
- github-v4 and github-v6 - GitHub IPv4 and IPv6
- ovh-v4 - OVH IPv4
- scake-v4 - StatusCake IPv4
- fh-* - [FireHOL](http://iplists.firehol.org/) lists
- do-v4 and do-v6 - DigitalOcean IPv4 and IPv6
- ur-v4 and ur-v6 - [UptimeRobot](https://uptimerobot.com/) lists

Also, it supports adding custom ipset lists and some internal OSSHelp ipset lists.

## Usage

## Installation

To install refresh-ipset script, use the following command:

```shell
curl -s https://oss.help/scripts/tools/ipset/install.sh | bash
```

This will install the main script and add the symlink to `cron-daily` folder. Or you can use the same install and update scripts from this repository.

### Support lists

If want to use the script for commercial services, mentioned above, you need to:

1. Install the refresh-ipset script as described previously
1. Create empty ipset lists, that you need (see Example section below)
1. Run `custom.refresh-ipset` manually and check that the ipset lists have been refreshed (i.e. `ipset list`)
1. Check ipset lists in `/etc/network/ipset.list` (for Ubuntu/Debian) or in `/etc/sysconfig/ipset` (for CentOS)
1. Add the ipset lists file to autoload (via `/etc/network/interfaces`, ifup-scripts, systemd-unit, etc)

### Custom lists

If you want to add custom ipset list, you need to do this:

1. Install the refresh-ipset script as described previously
1. Add to `/usr/local/etc/refresh-ipset/` file named as an ipset list
1. Place an URL for a remote list into the created file (this will be the source of addresses)
1. Add ipset list into `/etc/network/ipset.list` for Ubuntu/Debian or into `/etc/sysconfig/ipset` for CentOS
1. Run `custom.refresh-ipset` manually and check that the ipset lists have been refreshed (i.e. `ipset list`)
1. Check ipset lists in `/etc/network/ipset.list` (for Ubuntu/Debian) or in `/etc/sysconfig/ipset` (for CentOS)

Please note, that custom ipset lists must be provided in these formats:

```shell
1.6.2.3
1.6.2.3/32
1.9.5.94/24
```

```shell
2a01:4ee:a0:3159::2
2a01:4ee:a0:3159::2/128
2a01:4ee:10:9343::69/64
```

## Example

This example shows how to create ipset lists for CloudFlare addresses. Create lists with these commands first:

```shell
create cf-v4 hash:net family inet hashsize 1024 maxelem 65536
create cf-v6 hash:net family inet6 hashsize 1024 maxelem 65536
```

Then run `custom.refresh-ipset`. After this please check `ipset list` and the following files:

- `/etc/network/ipset.list` fror Debian or Ubuntu
- `/etc/sysconfig/ipset` for CentOS or Fedore

## FAQ

### How it works

1. If `/usr/local/etc/refresh-ipset.override` is present, then script is using it as a list for updating
1. If `/usr/local/etc/refresh-ipset.override` is absent, script searches for lists in output of `ipset save` command
or in file `/etc/network/ipset.list` (for Ubuntu/Debian in CentOS it checks `/etc/sysconfig/ipset` instead)
1. Next it updates ipset lists if they were found in previous steps and not found in `/usr/local/etc/refresh-ipset.ignore`
1. In the end script saves all ipset lists in `/etc/network/ipset.list` or `/etc/sysconfig/ipset`

### ACL for Monit and Nginx

This script can generate ACL lists for Monit and Nginx:

- for Monit lists are being added into `/etc/monit.d/access/` folder
- for Nginx lists are being added into `/etc/nginx/access/` folder

If you want to use generated ACL list in Monit, add it to httpd section in the Monit config file:

```shell
include /etc/monit/access/listname-v4
```

If you want to use generated ACL list in Nginx, add it in the server section:

```shell
include /etc/nginx/access/oss-v4.conf;
```

## Author

OSSHelp Team, see <https://oss.help>
