FROM nginx:1.19-alpine

EXPOSE 80 443

COPY cert/* /etc/nginx/
RUN cat /etc/nginx/server.pem /etc/nginx/chain.pem > /etc/nginx/server.chained.pem
