FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    mariadb-client \
    && docker-php-ext-install pdo pdo_mysql mysqli gd zip

RUN docker-php-ext-enable pdo_mysql

WORKDIR /var/www/html
