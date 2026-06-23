FROM php:8.2-apache
COPY . /var/www/
RUN mv /var/www/html /var/www/html_old && ln -s /var/www/www /var/www/html
EXPOSE 80