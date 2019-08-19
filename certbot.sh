#!/bin/bash

# Include config
. ./certbot.conf

LOG_FILE="${CERTBOT_PATH}${LOG_FILE}"

# Include domains from external file
. $CERTBOT_PATH/domains.list

for ((i=0;i<${#DOMAIN[*]};i++))
do
	# Certbox requests a new certificate, if the existing expires in less than two weeks
	docker run --rm -it --name certbot -v "${CERTBOT_PATH}/letsencrypt/:/etc/letsencrypt/" -v "${CERTBOT_PATH}/log/:/var/log/letsencrypt/" -v "${CERTBOT_PATH}/well-known/:/var/www/letsencrypt/" certbot/certbot certonly --agree-tos --email ${EMAIL} --keep --quiet --rsa-key-size ${KEYSIZE} --webroot -w /var/www/letsencrypt --cert-name ${DOMAIN[i]} -d ${DOMAIN[i]}
done

for ((i=0;i<${#DOMAIN[*]};i++))
do
	# A new certificate was created
	if [ `find "${CERTBOT_PATH}/letsencrypt/live/${DOMAIN[i]}/cert.pem" -mmin -5` ]; then
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