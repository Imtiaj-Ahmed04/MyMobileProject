FROM php:8.2-apache

# Install dependencies and both PDO extensions cleanly
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git \
    && docker-php-ext-install zip pdo pdo_mysql \
    && a2enmod rewrite

# Setup Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# Check both paths to make sure dependencies install no matter what
RUN if [ -f "composer.json" ]; then composer install --no-dev --optimize-autoloader; \
    elif [ -f "www/composer.json" ]; then cd www && composer install --no-dev --optimize-autoloader; \
    else echo "No composer.json found"; exit 1; fi

# Force Apache to serve files directly out of the www subfolder
RUN sed -i 's|/var/www/html|/var/www/html/www|g' /etc/apache2/sites-available/000-default.conf

RUN chown -R www-data:www-data /var/www/html
EXPOSE 80