FROM openresty/openresty:alpine

# Install envsubst or lua-cjson if needed
RUN apk add --no-cache gettext

# Copy Nginx master configuration and virtual hosts
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY lua/ /etc/nginx/lua/
COPY certs/ /etc/nginx/certs/

EXPOSE 80 443

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
