# Certbot Automation

A script which is ment to be executed by a daily cron to request SSL certificates from Let's Encrypt by the Certbot Docker container.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Comming soon

### Installing

Place this script somewhere on your disk.

## Deployment

Add an entry into the crontab to execute this script periodically.

```bash
0 4 * * * /anywhere/on/your/disk/certbot.sh
```

In this example the script would run every day at 4am.

## Build With

* [Bash](https://wiki.ubuntuusers.de/Bash/)
* [Docker](https://www.docker.com/)
* [Certbot](https://certbot.eff.org/) - To request SSL certificates

## Authors

* [BloodhunterD](https://github.com/bloodhunterd)

## License

This project is licensed under the Unlicense License - see [LICENSE.md](https://github.com/bloodhunterd/certbot-automation/blob/master/LICENSE) file for details.
