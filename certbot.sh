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

# Set Certbot image
if [ -z ${CERTBOT_IMAGE+x} ]; then
  CERTBOT_IMAGE='certbot/certbot'
fi

# Set logfile
if [ -z ${LOG_FILE+x} ]; then
  LOG_FILE="${DIR}/certbot.log"
fi

# Set elliptic curve
if [ -z ${ELLIPTIC_CURVE+x} ]; then
  ELLIPTIC_CURVE='secp256r1'
fi

# Set key size
if [ -z ${KEY_SIZE+x} ]; then
  KEY_SIZE=4096
fi

# Set key type
if [ -z ${KEY_TYPE+x} ]; then
  KEY_TYPE='rsa'
fi

# Load domains
readarray -t DOMAINS < "${DIR}/certbot.domains"

# Issue certificates
for ((i=0;i<${#DOMAINS[*]};i++))
do

  # Issue RSA certificate
  if [ "${KEY_TYPE}" = 'rsa' ] || [ "${KEY_TYPE}" = 'both' ]; then
    docker run --rm --name certbot \
      -v "${CERTBOT_DIR}/letsencrypt/:/etc/letsencrypt/" \
      -v "${CERTBOT_DIR}/log/:/var/log/letsencrypt/" \
      -v "${CERTBOT_DIR}/well-known/:/var/www/letsencrypt/" \
      "${CERTBOT_IMAGE}" certonly \
      --agree-tos \
      --cert-name "${DOMAINS[i]}" \
      --domains "${DOMAINS[i]}" \
      --email "${EMAIL}" \
      --keep \
      --key-type rsa \
      --quiet \
      --rsa-key-size "${KEY_SIZE}" \
      --non-interactive \
      --webroot \
      -w /var/www/letsencrypt

    # Mark webserver for restart
    if [ "$(find "${CERTBOT_DIR}/letsencrypt/live/${DOMAINS[i]}/cert.pem" -mmin -10)" ]; then
      CHANGED=true
    fi
  fi

  # Issue ECDSA certificate
  if [ "${KEY_TYPE}" = 'ecdsa' ] || [ "${KEY_TYPE}" = 'both' ]; then
    docker run --rm --name certbot \
      -v "${CERTBOT_DIR}/letsencrypt/:/etc/letsencrypt/" \
      -v "${CERTBOT_DIR}/log/:/var/log/letsencrypt/" \
      -v "${CERTBOT_DIR}/well-known/:/var/www/letsencrypt/" \
      "${CERTBOT_IMAGE}" certonly \
      --agree-tos \
      --cert-name "${DOMAINS[i]}"-ecdsa \
      --domains "${DOMAINS[i]}" \
      --elliptic-curve "${ELLIPTIC_CURVE}" \
      --email "${EMAIL}" \
      --keep \
      --key-type ecdsa \
      --quiet \
      --non-interactive \
      --webroot \
      -w /var/www/letsencrypt

    # Mark webserver for restart
    if [ "$(find "${CERTBOT_DIR}/letsencrypt/live/${DOMAINS[i]}-ecdsa/cert.pem" -mmin -10)" ]; then
      CHANGED=true
    fi
  fi
done

# Restart Docker containers, if set and a certificate was renewed
if [ "${CHANGED}" = true ]; then
  # Load docker containers
  readarray -t CONTAINERS < "${DIR}/certbot.docker"

  for ((i=0;i<${#CONTAINERS[*]};i++))
  do
    DATE=$(date +"%Y-%m-%d %H:%M:%S")

    docker restart "${CONTAINERS[i]}"

    # Check, if they're running
    if [ "$(docker inspect -f '{{.State.Running}}' "${CONTAINERS[i]}")" = "true" ]; then
      STATUS="successfully restarted"
    else
      STATUS="failed to restart"
    fi

    echo "${DATE} | Docker container ${CONTAINERS[i]} ${STATUS}" >> "${LOG_FILE}"
  done
fi
