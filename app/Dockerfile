FROM nginx:1.27.5-alpine

ARG BUILD_SHA=local
ENV BUILD_SHA=${BUILD_SHA}

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

RUN sed -i "s|__BUILD_SHA__|${BUILD_SHA}|g" /usr/share/nginx/html/index.html \
    && chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/run \
    && touch /var/run/nginx.pid \
    && chown nginx:nginx /var/run/nginx.pid

USER nginx
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
