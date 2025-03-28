# Use official PHP image with Apache
FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Install required PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy composer files first for caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN apt-get update && apt-get install -y unzip \
    && composer install --no-dev --optimize-autoloader \
    && rm -rf /var/lib/apt/lists/*

# Copy Laravel application files AFTER installing dependencies
COPY . .

# Copy custom Apache config
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/vendor

# Run Laravel-specific commands
RUN php artisan config:cache && php artisan route:cache && php artisan view:cache

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
