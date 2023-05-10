#!/bin/bash

set -ex

ENVSUBST2="envsubst2 --force-replace=false"

# 渲染配置
{

    ### nginx
    if [ -z ${PORT} ]; then
        {
            export PORT=80
        }
    fi

    ${ENVSUBST2} --input /etc/nginx/conf.d/default.conf.tmpl --output /etc/nginx/conf.d/default.conf
}

# 后台启动 nginx

ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
nginx -c /etc/nginx/nginx.conf

# 前台启动 php-fpm
php-fpm -c /usr/local/etc/php-fpm.conf
