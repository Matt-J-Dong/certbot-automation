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
if [ -z ${LOG_FILE+x} ]; then
    LOG_FILE="${DIR}/certbot.log"
fi

# Load domains
readarray -t DOMAINS < "${DIR}/certbot.domains"

# Check all domains for renewal
for ((i=0;i<${#DOMAINS[*]};i++))
do
    # Certbot requests a new certificate, if the existing expires in less than two weeks
    docker run --rm --name certbot -v "${CERTBOT_DIR}/letsencrypt/:/etc/letsencrypt/" -v "${CERTBOT_DIR}/log/:/var/log/letsencrypt/" -v "${CERTBOT_DIR}/well-known/:/var/www/letsencrypt/" certbot/certbot certonly --agree-tos --email ${EMAIL} --keep --quiet --rsa-key-size ${KEYSIZE} --webroot -w /var/www/letsencrypt --cert-name ${DOMAINS[i]} -d ${DOMAINS[i]}

    # A certificate was renewed
    if [ `find "${CERTBOT_DIR}/letsencrypt/live/${DOMAINS[i]}/cert.pem" -mmin -10` ]; then
        CHANGED=true
    fi
done

# Restart Docker containers, if set and a certificate was renewed
if [ "${CHANGED}" = true ]; then
    # Load docker containers
    readarray -t CONTAINERS < "${DIR}/certbot.docker"

    for ((i=0;i<${#CONTAINERS[*]};i++))
    do
        DATE=$(date +"%Y-%m-%d %H:%M:%S")

        docker restart ${CONTAINERS[i]}

        # Check, if they're running
        if [ "$(docker inspect -f '{{.State.Running}}' ${CONTAINERS[i]})" = "true" ]; then
            STATUS="successfully restarted"
        else
            STATUS="failed to restart"
        fi

        echo "${DATE} | Docker container ${CONTAINERS[i]} ${STATUS}" >> $LOG_FILE
    done
fi
