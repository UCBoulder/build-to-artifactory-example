#!/command/with-contenv /bin/bash

#Default runtime variables if none supplied with -e
NGINX_CLIENT_MAX_BODY_SIZE=${NGINX_CLIENT_MAX_BODY_SIZE:='1M'}
NGINX_KEEPALIVE_TIMEOUT=${NGINX_KEEPALIVE_TIMEOUT:='65'}
NGINX_SSL_SESSION_CACHE=${NGINX_SSL_SESSION_CACHE:='none'}
NGINX_SSL_SESSION_TIMEOUT=${NGINX_SSL_SESSION_TIMEOUT:='5m'}
SERVER_NAME=${SERVER_NAME:="$(hostname)"}

printf "$(basename $0): info: Running container startup script...\n"

ls -A /tmp/.dockersetupdone &> /dev/null
if ! [ $? -ne 0 ]; then
    printf "$(basename $0): info: .dockersetupdone found, exiting startup script...\n"
  exit 0
fi

printf "$(basename $0): info: --env NGINX_CLIENT_MAX_BODY_SIZE set as $NGINX_CLIENT_MAX_BODY_SIZE\n"
printf "$(basename $0): info: --env NGINX_KEEPALIVE_TIMEOUT set as $NGINX_KEEPALIVE_TIMEOUT\n"
printf "$(basename $0): info: --env NGINX_SSL_SESSION_CACHE set as $NGINX_SSL_SESSION_CACHE\n"
printf "$(basename $0): info: --env NGINX_SSL_SESSION_TIMEOUT set as $NGINX_SSL_SESSION_TIMEOUT\n"
printf "$(basename $0): info: --env SERVER_NAME set as $SERVER_NAME\n"

printf "$(basename $0): info: Generate DH Parameters...\n"
openssl dhparam 2048 -out /etc/pki/tls/certs/dhparam.pem &> /dev/null
printf "$(basename $0): info: Done Generate DH Parameters.\n"

printf "$(basename $0): info: Generate Snakeoil...\n"
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/$SERVER_NAME.key -out /etc/pki/tls/certs/$SERVER_NAME.pem -subj "/CN=$SERVER_NAME" &> /dev/null
printf "$(basename $0): info: Done Generate Snakeoil.\n"

# Cause nginx to never start properly resulting in container never becoming healthy
rm -v /etc/pki/tls/private/$SERVER_NAME.key

printf "$(basename $0): info: Configure nginx...\n"
sed -i "/types_hash_max_size 4096;/a \    client_max_body_size $NGINX_CLIENT_MAX_BODY_SIZE;" /etc/opt/rh/rh-nginx120/nginx/nginx.conf
sed -i "s/keepalive_timeout  65;/keepalive_timeout  $NGINX_KEEPALIVE_TIMEOUT;/g" /etc/opt/rh/rh-nginx120/nginx/nginx.conf
sed -i "s/ssl_session_cache    none;/ssl_session_cache    $NGINX_SSL_SESSION_CACHE;/g" /etc/opt/rh/rh-nginx120/nginx/nginx.conf
sed -i "s/ssl_session_timeout  5m;/ssl_session_timeout  $NGINX_SSL_SESSION_TIMEOUT;/g" /etc/opt/rh/rh-nginx120/nginx/nginx.conf
sed -i "s/SED_SERVER_NAME/$SERVER_NAME/g" /etc/opt/rh/rh-nginx120/nginx/nginx.conf

touch /tmp/.dockersetupdone
printf "$(basename $0): info: End container startup script. Saved .dockersetupdone breadcrumb to /tmp/.dockersetupdone prevent rerun.\n"

exit 0
