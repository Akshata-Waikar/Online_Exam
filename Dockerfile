# Base image
FROM php:8.2-apache

# Copy project files to web root
COPY . /var/www/html/

# Install dependencies (example)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Expose port
EXPOSE 80
