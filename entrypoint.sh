#!/bin/bash

if [ "$APP_URL" != "" ]; then
  echo -e "$0: \033[1;1m\$APP_URL\033[0m set to \033[4;1m$APP_URL\033[0m"
else
  echo -e "$0: \033[1;31mERROR\033[0m The environment variable \033[1;1m\$APP_URL\033[0m needs to be set with the URL to serve, eg. http://192.168.0.28:5988" >&2
  exit -2
fi

# SSL certificate files and source URLs
CERT_PEM='/etc/nginx/server.pem'
CERT_PEM_SRC='http://local-ip.co/cert/server.pem'
CERT_KEY='/etc/nginx/server.key'
CERT_KEY_SRC='http://local-ip.co/cert/server.key'
CERT_CHAIN='/etc/nginx/chain.pem'
CERT_CHAIN_SRC='http://local-ip.co/cert/chain.pem'
CERT_CHAINED='/etc/nginx/server.chained.pem'

CURL_CMD='curl -sS'

install_certs () {
  echo "$0: Downloading '$CERT_PEM_SRC' ..."
  $CURL_CMD "$CERT_PEM_SRC" -o "$CERT_PEM"

  echo "$0: Downloading '$CERT_KEY_SRC' ..."
  $CURL_CMD "$CERT_KEY_SRC" -o "$CERT_KEY"

  echo "$0: Downloading '$CERT_CHAIN_SRC' ..."
  $CURL_CMD "$CERT_CHAIN_SRC" -o "$CERT_CHAIN"

  echo "$0: Creating chained cert file '$CERT_CHAINED' ..."
  cat "$CERT_PEM" "$CERT_CHAIN" > "$CERT_CHAINED"
}

DOWNLOAD="false"
if [ -f "$CERT_PEM" -a -f "$CERT_KEY"  -a -f "$CERT_CHAIN" ]; then
  echo "$0: SSL certificate files /etc/nginx/server.* found"
else
  echo "$0: SSL certificate files /etc/nginx/server.* not found. Installing ..."
  DOWNLOAD="true"
  install_certs
fi

CERT_EXP_DATE=$(openssl x509 -enddate -noout -in $CERT_PEM | grep -oP 'notAfter=\K.+')
CERT_EXP_DATE_ISO=$(date -d "$CERT_EXP_DATE" '+%Y-%m-%d')

TODAY_ISO=$(date '+%Y-%m-%d')
if [[ "$CERT_EXP_DATE_ISO" < "$TODAY_ISO" ]]; then
  if [ "$DOWNLOAD" == "false" ]; then
    echo "$0: SSL certificate expired! Installing new certificate files ..."
    install_certs
  else
    echo -e "$0: \033[1;31mERROR\033[0m SSL certificate files have been downloaded but expired since: $CERT_EXP_DATE" >&2
    exit -1
  fi
else
  echo "$0: SSL certificate OK. Expire after: $CERT_EXP_DATE"
fi

. /docker-entrypoint.sh

exec "$@"
