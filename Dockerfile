# Use PHP 8.3 FPM Base Image with Ubuntu 22.04
FROM php:8.3-fpm-bullseye

# Install Nginx and Other Necessary Packages
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
       nginx \
       bash \
       curl \
       git \
       unzip \
       zip \
       libzip-dev \
       libpng-dev \
       libjpeg-dev \
       libfreetype6-dev \
       apt-transport-https \
       locales \
       gcc \
       g++ \
       make \
       autoconf \
       build-essential \
       unixodbc \
       unixodbc-dev \
       gnupg \
       ca-certificates \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Microsoft ODBC Driver 18 for SQL Server and Tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Install PHP ODBC Drivers
RUN pecl install sqlsrv-5.10.1 \
    && pecl install pdo_sqlsrv-5.10.1 \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

# # Add Self-Signed Certificate to the Trusted Certificates
# COPY path/to/self-signed-certificate.crt /usr/local/share/ca-certificates/self-signed-certificate.crt
# RUN update-ca-certificates

# Copy Custom Nginx Configuration
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./default.conf /etc/nginx/conf.d/default.conf

# Set Working Directory
WORKDIR /var/www/html

# Copy Application Files
COPY . .

# Install PHP Dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Copy .env.example to .env and generate Laravel application key
RUN cp .env.example .env \
    && php artisan key:generate

# Ensure Proper Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Expose the Port 80 on Container
EXPOSE 80

# Start PHP-FPM and Nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
