
# language=golang
## IMAGE ARGS

FROM docker.io/composer/composer:1.10.26 as composer

FROM docker.io/library/php:7.4.33-fpm-bullseye as env
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN curl -L https://github.com/tangx/envsubst2/releases/download/v0.1.10/envsubst2-linux-amd64 -o /usr/bin/envsubst2 && chmod +x /usr/bin/envsubst2

# RUN sed -i "s/deb.debian.org/mirrors.aliyun.com/" /etc/apt/sources.list \
#   && sed -i "s/security.debian.org/mirrors.aliyun.com/" /etc/apt/sources.list 

# install extensions: oniguruma & mbstring
RUN apt update \
    && apt install -y \
        # 安全补丁
        curl openssl binutils patch m4 perl re2c \
        # 工具
        bash \
        # 安装 nginx
        nginx \
        ## 删除默认配置
        && rm -rf /etc/nginx/sites-available  \
                /etc/nginx/sites-enabled  \
        ## 日志地址
        && ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /dev/stderr /var/log/nginx/error.log \
    # 安装 mbstring 依赖
    && apt install -y libonig-dev \
        && docker-php-ext-install mbstring \
    # 清理缓存
    && rm -rf /var/lib/apt/lists/*

### 本地配置
FROM env as builder
WORKDIR /var/www/html/
COPY --chown=www-data:www-data . .

RUN composer install

COPY ./conf.d/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./conf.d/nginx/default.conf /etc/nginx/conf.d/default.conf.tmpl

COPY ./bin/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT [ "/usr/bin/docker-entrypoint.sh" ]

