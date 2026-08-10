FROM openresty/openresty:alpine

# Install dependencies and OpenResty Lua modules with resilient GitHub fallback
RUN apk add --no-cache gettext perl curl git \
    && (opm get SkyLothar/lua-resty-jwt || ( \
        mkdir -p /usr/local/openresty/site/lualib/resty && \
        git clone --depth 1 https://github.com/cdbattags/lua-resty-jwt.git /tmp/lua-resty-jwt && \
        cp -r /tmp/lua-resty-jwt/lib/resty/* /usr/local/openresty/site/lualib/resty/ && \
        rm -rf /tmp/lua-resty-jwt \
    )) \
    && (opm get ledgetech/lua-resty-http || ( \
        mkdir -p /usr/local/openresty/site/lualib/resty && \
        git clone --depth 1 https://github.com/ledgetech/lua-resty-http.git /tmp/lua-resty-http && \
        cp -r /tmp/lua-resty-http/lib/resty/* /usr/local/openresty/site/lualib/resty/ && \
        rm -rf /tmp/lua-resty-http \
    )) \
    && find /usr/local/openresty -name "*.lua" -exec sed -i 's/EVP_MD_CTX_create/EVP_MD_CTX_new/g' {} + \
    && find /usr/local/openresty -name "*.lua" -exec sed -i 's/EVP_MD_CTX_destroy/EVP_MD_CTX_free/g' {} +

# Copy Nginx master configuration and virtual hosts
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY lua/ /etc/nginx/lua/
COPY certs/ /etc/nginx/certs/

EXPOSE 80 443

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
