[![Release](https://img.shields.io/github/v/release/bloodhunterd/certbot-automation?style=for-the-badge)](https://github.com/bloodhunterd/certbot-automation/releases)
[![License](https://img.shields.io/github/license/bloodhunterd/certbot-automation?style=for-the-badge)](https://github.com/bloodhunterd/certbot-automation/blob/master/LICENSE)

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/bloodhunterd)

# Certbot Automation

Certbot Automation is a shell script to automatically request and renew Let's Encrypt SSL certificates based on the Certbot Docker image.

## Deployment

Place this script somewhere on your server. For example at **/srv/**.

### Download

Download and rename the configuration and domain distribution files.

[![Configuration](https://img.shields.io/github/size/bloodhunterd/certbot-automation/certbot.dist.conf?label=Configuration&style=for-the-badge)](https://github.com/bloodhunterd/certbot-automation/raw/master/certbot.dist.conf)
[![Domain list](https://img.shields.io/github/size/bloodhunterd/certbot-automation/certbot.dist.domains?label=Domain%20list&style=for-the-badge)](https://github.com/bloodhunterd/certbot-automation/raw/master/certbot.dist.domains)
[![Docker list](https://img.shields.io/github/size/bloodhunterd/certbot-automation/certbot.dist.docker?label=Docker%20list&style=for-the-badge)](https://github.com/bloodhunterd/certbot-automation/raw/master/certbot.dist.docker)

### Installation

Set up the configuration and write some domain names into the domain list.
If a certificate expires in less than from Let's encrypt defined renewal period, the certificate will be automatically renewed.

If one or more docker container should be restarted after a certificate was renewed, add the container name to the Docker list file.

Finally add an entry to the Cron table to execute this script periodically.

```bash
crontab -e
```

```bash
0 4 * * * /srv/certbot.sh
```

In this example the script runs every day at 4am.

## Build With

* [Bash](https://wiki.ubuntuusers.de/Bash/)
* [Docker](https://www.docker.com/)
* [Certbot](https://certbot.eff.org/)

## Authors

* [BloodhunterD](https://github.com/bloodhunterd)

## License

This project is licensed under the MIT - see [LICENSE.md](https://github.com/bloodhunterd/certbot-automation/blob/master/LICENSE) file for details.
