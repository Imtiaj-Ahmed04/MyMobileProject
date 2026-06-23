FROM php:8.2-apache

# Install the PDO MySQL driver extensions cleanly without composer
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git \
    && docker-php-ext-install zip pdo pdo_mysql \
    && a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy your whole repository straight into the container
COPY . .

# Force Apache to serve files directly out of your www subfolder where index.php lives
RUN sed -i 's|/var/www/html|/var/www/html/www|g' /etc/apache2/sites-available/000-default.conf

RUN chown -R www-data:www-data /var/www/html
EXPOSE 80