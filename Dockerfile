FROM php:8.2-apache

# Install tools and MySQL drivers
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git \
    && docker-php-ext-install zip pdo pdo_mysql \
    && a2enmod rewrite

# Setup Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# Run composer directly inside the www folder so vendor is created right next to index.php
RUN cd www && composer init --name="app/mymobileproject" --require="slim/slim:4.*" --require="slim/psr7:1.*" -n \
    && composer install --no-dev --optimize-autoloader

# Tell Apache to look directly inside the www folder for incoming traffic
RUN sed -i 's|/var/www/html|/var/www/html/www|g' /etc/apache2/sites-available/000-default.conf

RUN chown -R www-data:www-data /var/www/html
EXPOSE 80