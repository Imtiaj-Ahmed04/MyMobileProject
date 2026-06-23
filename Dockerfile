FROM php:8.2-apache

# Install dependencies and extensions
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git \
    && docker-php-ext-install zip pdo pdo_mysql \
    && a2enmod rewrite

# Setup Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# Initialize composer right here in the root folder alongside index.php
RUN composer init --name="app/mymobileproject" --require="slim/slim:4.*" --require="slim/psr7:1.*" -n \
    && composer install --no-dev --optimize-autoloader

# Make sure Apache default root is clean and simple
RUN sed -i 's|/var/www/html/www|/var/www/html|g' /etc/apache2/sites-available/000-default.conf

RUN chown -R www-data:www-data /var/www/html
EXPOSE 80