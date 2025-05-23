#!/bin/sh

if [ "$APP_URL" != "" ]; then
  echo -e "$0: \033[1;1m\$APP_URL\033[0m set to $APP_URL"
else
  echo -e "$0: \033[1;31mERROR\033[0m The environment variable \033[1;1m\$APP_URL\033[0m needs to be set with the URL to serve, eg. http://192.168.0.28:5988" >&2
  exit -2
fi

# SSL certificate files and source URLs
CERT_PEM='/etc/nginx/server.pem'
CERT_KEY='/etc/nginx/server.key'
CERT_CHAIN='/etc/nginx/chain.pem'
CERT_CHAINED='/etc/nginx/server.chained.pem'

CURL_CMD='curl -sS --max-time 15'

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

HTTPS_URL=$(echo "$APP_URL" | sed 's/http:/https:/' | sed 's/\./-/g' | sed -r "s/\:[0-9]+/.${DOMAIN}/g")
if [[ "$HTTPS_URL" != *".${DOMAIN}" ]]; then
  # When $APP_URL does not have port at the end (port 80), the last `sed` expression above is not applied
  HTTPS_URL="$HTTPS_URL.${DOMAIN}"
fi
if [[ "$HTTPS" != "443" && "$HTTPS" != "" ]]; then
  HTTPS_URL="$HTTPS_URL:$HTTPS"
fi

echo    "$0:"
echo -e "    \033[1;1m--------------------------------------\033[0m"
echo -e "    \033[1;1mnginx-local-ip URL:\033[0m"
echo -e "    \033[4;32m$HTTPS_URL\033[0m"
echo -e "    \033[1;1m--------------------------------------\033[0m"

. /docker-entrypoint.sh

exec "$@"
