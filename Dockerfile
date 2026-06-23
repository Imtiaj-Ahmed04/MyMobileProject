FROM php:8.2-apache

# Install zip utility needed for Composer
RUN apt-get update && apt-get install -y libzip-dev zip && docker-php-ext-install zip

# Install Composer automatically
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy all project files into the container
COPY . /var/www/

# Run composer install to generate the missing vendor folder
WORKDIR /var/www
RUN composer install --no-interaction --optimize-autoloader

# Route Apache traffic to your www folder
RUN mv /var/www/html /var/www/html_old && ln -s /var/www/www /var/www/html

EXPOSE 80