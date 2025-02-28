FROM php:8.1-apache

# Ensure necessary extensions are installed
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    mariadb-client \
    && docker-php-ext-install pdo pdo_mysql mysqli gd zip

RUN docker-php-ext-enable pdo_mysql

# Set the working directory inside the container
WORKDIR /var/www/html

# Ensure the directory exists
RUN mkdir -p /var/www/html

# Set permissions (optional, but can help)
RUN chown -R www-data:www-data /var/www/html

# Enable Apache mod_rewrite if needed
RUN a2enmod rewrite
