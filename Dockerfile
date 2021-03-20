FROM nginx:1.19

EXPOSE 80 443

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
