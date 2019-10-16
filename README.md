# Certbot Automation

[![Release](https://img.shields.io/github/v/release/bloodhunterd/certbot-automation?include_prereleases&style=for-the-badge)](https://github.com/bloodhunterd/certbot-automation/releases)

A simple script which is meant to be executed by a daily cron to request SSL certificates from Let's Encrypt using the Certbot Docker container.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

The script requires a [Debian](https://www.debian.org/index.de.html) based system and a working Docker environment.

### Installing

Place this script somewhere on your server. For example at **/srv/**.

## Deployment

Setup the configuration and write some domain names into the **.domains** file.
If a certificate expires in less than 2 weeks, the certificate will automatically renewed.
Finally add an entry to the Cron table to execute this script periodically.

```bash
0 4 * * * /srv/certbot.sh
```

In this example the script runs every day at 4am.

## Build With

* [Bash](https://wiki.ubuntuusers.de/Bash/)
* [Docker](https://www.docker.com/)
* [Certbot](https://certbot.eff.org/) - To request SSL certificates

## Authors

* [BloodhunterD](https://github.com/bloodhunterd)

## License

This project is licensed under the Unlicense License - see [LICENSE.md](https://github.com/bloodhunterd/certbot-automation/blob/master/LICENSE) file for details.
