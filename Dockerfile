FROM nginx:1.28-alpine

COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV CERT_PEM_SRC=https://local-ip.medicmobile.org/cert
ENV CERT_CHAIN_SRC=https://local-ip.medicmobile.org/chain
ENV CERT_KEY_SRC=https://local-ip.medicmobile.org/key
ENV DOMAIN=local-ip.medicmobile.org

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
