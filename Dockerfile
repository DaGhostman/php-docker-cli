FROM php:7-zts-alpine
LABEL maintainer "daghostman.dd@gmail.com"

RUN apk add --no-cache $PHPIZE_DEPS tar xz --virtual .build-deps
RUN apk add --no-cache postgresql-dev && \
    pecl install apcu igbinary xdebug && \
    docker-php-ext-enable apcu igbinary xdebug && \
    docker-php-ext-install pdo_pgsql

WORKDIR /tmp

RUN pecl download redis && \
    export REDIS=$(find ./ -type f -name "redis-*") && \
    mkdir redis && \
    tar -xzf $REDIS -C redis/ && rm $REDIS && \
    cd $(find ./ -type d -name "redis-*") && \
    phpize && ./configure --enable-redis-igbinary && make && make test && make install && \
    docker-php-ext-enable redis

RUN apk del .build-deps
