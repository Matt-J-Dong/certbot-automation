#!/bin/bash

# Get path to script directory
if [ -n "${BASH_SOURCE[0]}" ]; then
    DIR=$(dirname "${BASH_SOURCE[0]}")
elif [ -n "${0}" ]; then
    DIR=$(dirname "$(readlink -f "$0")")
fi

# Include config
. "${DIR}/certbot.conf"

# Set Certbot directory
if [ -z ${CERTBOT_DIR+x} ]; then
    CERTBOT_DIR=$DIR
fi

# Set certificate key size
if [ -z ${KEYSIZE+x} ]; then
    KEYSIZE=4096
fi

# Set NGINX logfile
if [ -z ${NGINX_LOG_FILE+x} ]; then
    NGINX_LOG_FILE="${DIR}/nginx.log"
fi

# Load domains
readarray -t DOMAINS < "${DIR}/certbot.domains"

# Check all domains for renewal
for ((i=0;i<${#DOMAINS[*]};i++))
do
    # Certbot requests a new certificate, if the existing expires in less than two weeks
    docker run --rm --name certbot -v "${CERTBOT_DIR}/letsencrypt/:/etc/letsencrypt/" -v "${CERTBOT_DIR}/log/:/var/log/letsencrypt/" -v "${CERTBOT_DIR}/well-known/:/var/www/letsencrypt/" certbot/certbot certonly --agree-tos --email ${EMAIL} --keep --quiet --rsa-key-size ${KEYSIZE} --webroot -w /var/www/letsencrypt --cert-name ${DOMAINS[i]} -d ${DOMAINS[i]}
done

# Reload NGINX Docker container, if name is set and a certificate was renewed
if [ -n "${NGINX_CONTAINER_NAME}" ]; then
    for ((i=0;i<${#DOMAINS[*]};i++))
    do
        # A certificate was renewed
        if [ `find "${CERTBOT_DIR}/letsencrypt/live/${DOMAINS[i]}/cert.pem" -mmin -10` ]; then
            CHANGED=true
        fi
    done

    # Reload NGINX and check, if it's running after
    if [ "${CHANGED}" = true ]; then
        DATE=$(date +"%Y-%m-%d %H:%M:%S")
        RELOAD=$(docker exec ${NGINX_CONTAINER_NAME} bash service nginx reload)
        RESTART=$(docker exec ${NGINX_CONTAINER_NAME} bash service nginx status)
        echo "${DATE} | ${RELOAD} ${RESTART}" >> $NGINX_LOG_FILE
    fi
fi
