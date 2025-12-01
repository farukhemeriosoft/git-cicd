## Multi-stage build: Composer for vendor deps, PHP-Apache for serving app
FROM composer/composer:2.8 AS vendor

WORKDIR /app

# Copy only composer files first to leverage Docker layer caching
COPY composer.json composer.lock ./

# Install PHP dependencies without running scripts (avoids artisan during build)
RUN composer install \
    --no-interaction \
    --no-ansi \
    --no-progress \
    --prefer-dist \
    --no-dev \
    --no-scripts \
    --optimize-autoloader


# Runtime image with Apache serving Laravel from /public
FROM php:8.2-apache

# Install system deps and PHP extensions commonly required by Laravel and dompdf
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
 && docker-php-ext-configure gd --with-jpeg --with-webp \
 && docker-php-ext-install -j"$(nproc)" \
    pdo_mysql \
    bcmath \
    exif \
    zip \
    gd \
 && apt-get purge -y --auto-remove \
    libzip-dev libpng-dev libjpeg-dev libwebp-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite and set DocumentRoot to /public with proper override
RUN a2enmod rewrite headers \
 && sed -ri 's!DocumentRoot /var/www/html!DocumentRoot /var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
 && printf "<Directory /var/www/html/public>\n\tAllowOverride All\n</Directory>\n" > /etc/apache2/conf-available/laravel.conf \
 && a2enconf laravel

WORKDIR /var/www/html

# Copy application code
COPY ./ ./

# Copy vendor from composer stage
COPY --from=vendor /app/vendor ./vendor

# Ensure correct permissions for storage and cache
RUN chown -R www-data:www-data storage bootstrap/cache \
 && find storage -type d -exec chmod 775 {} \; \
 && find storage -type f -exec chmod 664 {} \; \
 && chmod -R 775 bootstrap/cache

# Create storage symlink (safe even if it already exists)
RUN php artisan storage:link || true

# Persist the storage directory as a volume as requested
VOLUME ["/var/www/html/storage"]

EXPOSE 80

# Healthcheck: basic PHP-FPM/Apache response from public/index.php route
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD curl -f http://localhost/ || exit 1

# Use the default Apache foreground start
CMD ["apache2-foreground"]


