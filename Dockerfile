FROM php:8.3-fpm-alpine AS app

ARG APP_ENV=production

LABEL maintainer="Geezap"
LABEL description="Geezap Laravel Application"

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    mysql-client \
    nodejs \
    npm \
    supervisor \
    bash

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    opcache

# Install Redis extension
RUN apk add --no-cache pcre-dev $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis

# Copy PHP configuration
COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Set composer environment variables
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_NO_INTERACTION=1
ENV COMPOSER_MEMORY_LIMIT=-1

# Copy all application files first
COPY . /var/www/html

# Create .env file for build time (required for artisan commands)
RUN cp .env.example .env || echo "APP_KEY=" > .env

# Install Composer dependencies (includes autoload generation)
RUN composer install --no-scripts --no-interaction --ignore-platform-reqs 2>&1 | tee /tmp/composer-output.log || \
    (cat /tmp/composer-output.log && exit 1)

# Install NPM dependencies and build assets
RUN npm ci && npm run build && npm cache clean --force

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 9000
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]

# Nginx stage for serving the application
FROM nginx:alpine AS nginx

# Copy nginx configuration
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy public files from app stage
COPY --from=app /var/www/html/public /var/www/html/public
COPY --from=app /var/www/html/storage/app/public /var/www/html/storage/app/public
