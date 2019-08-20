#!/bin/bash

# Include config
. ./certbot.conf

# Load domains
readarray -t DOMAINS < ./certbot.domains

LOG_FILE="${CERTBOT_PATH}${LOG_FILE}"

# Use default keysize, if not set
if [ -z ${KEYSIZE+x} ]; then
	KEYSIZE=4096
fi

# Check all domains for renewal
for ((i=0;i<${#DOMAINS[*]};i++))
do
	# Certbot requests a new certificate, if the existing expires in less than two weeks
	docker run --rm -it --name certbot -v "${CERTBOT_PATH}/letsencrypt/:/etc/letsencrypt/" -v "${CERTBOT_PATH}/log/:/var/log/letsencrypt/" -v "${CERTBOT_PATH}/well-known/:/var/www/letsencrypt/" certbot/certbot certonly --agree-tos --email ${EMAIL} --keep --quiet --rsa-key-size ${KEYSIZE} --webroot -w /var/www/letsencrypt --cert-name ${DOMAINS[i]} -d ${DOMAINS[i]}
done

# Reload NGINX Docker container, if set and a certificate was renewed
if [ -z ${NGINX_CONTAINER_NAME+x} ]; then
	for ((i=0;i<${#DOMAINS[*]};i++))
	do
		# A certificate was renewed
		if [ `find "${CERTBOT_PATH}/letsencrypt/live/${DOMAINS[i]}/cert.pem" -mmin -10` ]; then
			CHANGED=true
		fi
	done

	# Reload NGINX and check, if it's running after
	if [ "${CHANGED}" = true ]; then
		DATE=$(date +"%Y-%m-%d %H:%M:%S")
		RELOAD=$(docker exec ${NGINX_CONTAINER_NAME} bash service nginx reload)
		RESTART=$(docker exec ${NGINX_CONTAINER_NAME} bash service nginx status)
		echo "${DATE} | ${RELOAD} ${RESTART}" >> $LOG_FILE
	fi
fi
