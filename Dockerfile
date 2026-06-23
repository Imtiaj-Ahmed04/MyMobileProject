FROM php:8.2-apache

# Install system dependencies and PHP extensions required for Slim and MySQL
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install zip pdo pdo_mysql \
    && a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory directly to your www subfolder
WORKDIR /var/www/html

# Copy your whole repository over
COPY . .

# Move into the www folder where composer.json actually lives and run install
RUN cd www && composer install --no-dev --optimize-autoloader

# Make Apache look directly inside the www folder for incoming traffic
RUN sed -i 's|/var/www/html|/var/www/html/www|g' /etc/apache2/sites-available/000-default.conf

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80