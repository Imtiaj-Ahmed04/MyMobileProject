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

# Initialize composer in the root folder so vendor lands exactly at /var/www/html/vendor
RUN composer init --name="app/mymobileproject" --require="slim/slim:4.*" --require="slim/psr7:1.*" -n \
    && composer install --no-dev --optimize-autoloader

# Point Apache directly to your www folder
RUN sed -i 's|/var/www/html|/var/www/html/www|g' /etc/apache2/sites-available/000-default.conf

RUN chown -R www-data:www-data /var/www/html
EXPOSE 80