FROM ghcr.io/mhsanaei/3x-ui:v3.8.5

USER root

# The official image is Alpine-based. Nginx handles public HTTP/WebSocket
# traffic; Supervisor keeps both the panel and Nginx running in one container.
RUN apk add --no-cache nginx supervisor gettext

ENV PORT=8080 \
    XUI_PORT=20530 \
    XUI_ENABLE_FAIL2BAN=false

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisord.conf
COPY start-with-nginx.sh /usr/local/bin/start-with-nginx.sh

RUN chmod +x /usr/local/bin/start-with-nginx.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start-with-nginx.sh"]
