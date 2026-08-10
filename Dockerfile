FROM openresty/openresty:alpine

# Install dependencies and OpenResty Lua modules
RUN apk add --no-cache gettext perl curl \
    && opm get SkyLothar/lua-resty-jwt \
    && opm get ledgetech/lua-resty-http \
    && find /usr/local/openresty -name "*.lua" -exec sed -i 's/EVP_MD_CTX_create/EVP_MD_CTX_new/g' {} + \
    && find /usr/local/openresty -name "*.lua" -exec sed -i 's/EVP_MD_CTX_destroy/EVP_MD_CTX_free/g' {} +

# Copy Nginx master configuration and virtual hosts
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY lua/ /etc/nginx/lua/
COPY certs/ /etc/nginx/certs/

EXPOSE 80 443

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
