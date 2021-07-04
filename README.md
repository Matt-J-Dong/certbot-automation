[![Release](https://img.shields.io/github/v/release/bloodhunterd/certbot?style=for-the-badge)](https://github.com/bloodhunterd/certbot/releases)
[![License](https://img.shields.io/github/license/bloodhunterd/certbot?style=for-the-badge)](https://github.com/bloodhunterd/certbot/blob/master/LICENSE)

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/bloodhunterd)

# Certbot

Certbot is a shell script to automatically request and renew Let's Encrypt SSL certificates based on the Certbot Docker image.

## Deployment

Place this script somewhere on your server. For example at **/srv/**.

Download and rename the Docker and domain distribution files.

[![Domain list](https://img.shields.io/github/size/bloodhunterd/certbot/certbot.dist.domains?label=Domain%20list&style=for-the-badge)](https://github.com/bloodhunterd/certbot/raw/master/certbot.dist.domains)
[![Docker list](https://img.shields.io/github/size/bloodhunterd/certbot/certbot.dist.docker?label=Docker%20list&style=for-the-badge)](https://github.com/bloodhunterd/certbot/raw/master/certbot.dist.docker)

Set up the configuration and write some domain names into the domain list.
If a certificate expires in less than from Let's encrypt defined renewal period, the certificate will be automatically renewed.

If one or more docker container should be restarted after a certificate was renewed, add the container name to the Docker list file.

Finally, add an entry to the Cron table to execute this script periodically.

```bash
crontab -e
```

```bash
0 4 * * * /srv/certbot.sh
```

In this example the script runs every day at 4am.

### Configuration

| ENV | Default | Required | Description
| ------ | ---- | :------: | -----------
| CERTBOT_DIR | The script directory | &#10006; | The script directory will be automatically detected by default.
| CERTBOT_IMAGE | `certbot/certbot` | &#10006; | The certbot image which will be used.
| EMAIL |  | &#10004; | A valid email address for [Let's Encrypt](https://letsencrypt.org/) to notify you about your certificates.
| ELLIPTIC_CURVE | `secp256r1` | &#10006; | A valid [Elliptic Curve DSA](https://de.wikipedia.org/wiki/Elliptic_Curve_DSA). Concerns only `ecdsa` key type.
| LOG_FILE | `certbot.log` | &#10006; | Log output file.
| KEY_SIZE | `4096` | &#10006; | Certificate strength in bits. Concerns only `rsa` key type.
| KEY_TYPE | `rsa` | &#10006; | Valid key types are `rsa`, `ecdsa` or `both`.

To configure Certbot, create a file named `certbot.conf` in the Certbot directory and add the settings like this:

~~~dotenv
EMAIL=certbot@example.com
KEY_SIZE=2048
~~~

## Build with

* [Bash](https://wiki.ubuntuusers.de/Bash/)
* [Docker](https://www.docker.com/)
* [Certbot](https://certbot.eff.org/)

## Authors

* [BloodhunterD](https://github.com/bloodhunterd)

## License

This project is licensed under the MIT - see [LICENSE.md](https://github.com/bloodhunterd/certbot/blob/master/LICENSE) file for details.
