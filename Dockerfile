FROM php:8.2-apache

# 1. Install system utilities needed for downloading PHP libraries
RUN apt-get update && apt-get install -y libzip-dev zip git && docker-php-ext-install zip

# 2. Install the Composer tool
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Create a workspace folder and copy your project code into it
WORKDIR /var/www
COPY . /var/www/

# 4. Initialize a clean project and download Slim Framework directly inside the container
RUN composer init --no-interaction --name="my/mobileproject" --type="project" && \
    composer require slim/slim:"4.*" slim/psr7:"1.*" --no-interaction

# 5. Route all public web server traffic directly to your www folder
RUN mv /var/www/html /var/www/html_old && ln -s /var/www/www /var/www/html

EXPOSE 80