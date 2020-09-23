ARG PHP_VERSION
FROM php:${PHP_VERSION}

# 替换源来加速
COPY ./resources/sources.list /etc/apt/

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get install -qq git curl libmcrypt-dev libjpeg-dev libpng-dev libfreetype6-dev libbz2-dev libzip-dev unzip openssl libssl-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/  --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_mysql zip gd bcmath pcntl sockets mysqli

WORKDIR /tmp

ADD ./resources/redis-5.1.1.tgz .
COPY ./resources/swoole-src-4.5.4.tar.gz .

# 安装 redis 扩展
RUN mkdir -p /usr/src/php/ext \
    && mv /tmp/redis-5.1.1 /usr/src/php/ext/redis \
    && docker-php-ext-install redis

# 安装 swoole 
 RUN cd /tmp && tar -xvf swoole-src-4.5.4.tar.gz \
    # && mv swoole-src* swoole-src && cd swoole-src \
    && cd swoole-src-4.5.4 \
    && phpize \
    && ./configure  --enable-openssl  --enable-http2 \
    && make && make install && rm -rf /tmp/swoole*

ADD ./resources/mcrypt-1.0.3.tgz .
ADD ./resources/mongodb-1.6.0.tgz .
ADD ./resources/xdebug-2.8.0.tgz .

# 安装Swoole Loader
ADD ./resources/swoole_loader71.so /usr/local/lib/php/extensions/no-debug-non-zts-20160303

RUN cd /tmp/mcrypt-1.0.3 && phpize && ./configure && make && make install && rm -rf /tmp/mcrypt-1.0.3
RUN cd /tmp/mongodb-1.6.0 && phpize && ./configure && make && make install && rm -rf /tmp/mongodb-1.6.0
RUN cd /tmp/xdebug-2.8.0 && phpize && ./configure && make && make install && rm -rf /tmp/xdebug-2.8.0

CMD php-fpm
