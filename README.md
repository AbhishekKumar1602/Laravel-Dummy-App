# Laravel Dummy App

## Overview
This repository features a Laravel dummy application designed to demonstrate deployment on an Ubuntu server using Nginx and PHP-FPM. It also includes Docker configuration files for containerizing the application. While the application itself is a basic example without database connectivity, it provides a sample configuration for connecting to an MSSQL Server, anticipating future integration with an external MSSQL Server.

## Features

- **Laravel Application**: A simple Laravel app with Welcome Page.
- **Docker Integration**: Dockerfile and configuration files for containerizing the application.
- **Nginx and PHP-FPM**: Configuration files for setting up Nginx and PHP-FPM.

## Files Included

- `Dockerfile`: Configuration for creating the Docker image.
- `default.conf`: Nginx configuration file for the Laravel application.
- `nginx.conf`: Main Nginx configuration file.

## Prerequisites

1. **Ubuntu Server**: Ensure you have an Ubuntu 22.04 server running.
2. **Docker**: Install Docker on your server. [Docker Installation Guide](https://docs.docker.com/engine/install/ubuntu/)

## Steps: On Ubuntu Server with Nginx and PHP-FPM

### 1. Install Nginx and PHP-FPM

**1.1 Update Your System**
- Ensure Your System Packages are Current:
  ```bash
  sudo apt update -y && sudo apt upgrade -y
  ```

**1.2 Install Essential Dependencies**
- Install Necessary Build Tools and Libraries:
  ```bash
  sudo apt install -y build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev
  ```

**1.3 Install Nginx**
- Download and Extract the Latest Stable Version of Nginx:
  ```bash
  wget https://nginx.org/download/nginx-1.26.1.tar.gz
  tar -zxvf nginx-1.26.1.tar.gz
  cd nginx-1.26.1
  ```

- Set Up the Build Configuration:
  ```bash
  ./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
      --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module
  ```

- Compile the Source Code and Install Nginx:
  ```bash
  make && sudo make install
  ```

**1.4 Configure Nginx as a Systemd Service**
- Create a Systemd Service File:
  ```bash
  sudo nano /lib/systemd/system/nginx.service
  ```

- Add the Following Content:
  ```ini
  [Unit]
  Description=The NGINX HTTP and reverse proxy server
  After=syslog.target network.target remote-fs.target nss-lookup.target

  [Service]
  Type=forking
  PIDFile=/var/run/nginx.pid
  ExecStartPre=/usr/bin/nginx -t
  ExecStart=/usr/bin/nginx
  ExecReload=/bin/kill -s HUP $MAINPID
  ExecStop=/bin/kill -s QUIT $MAINPID
  PrivateTmp=true

  [Install]
  WantedBy=multi-user.target
  ```

- Reload Systemd, Enable, and Start Nginx:
  ```bash
  sudo systemctl daemon-reload && sudo systemctl enable nginx && sudo systemctl start nginx
  ```

- Verify that Nginx is Running:
  ```bash
  sudo systemctl status nginx
  ```

**1.5 Install PHP-FPM**
- Install PHP-FPM and Necessary PHP Extensions:
  ```bash
  sudo apt install -y php-fpm php8.3-fpm php8.3-dom php8.3-curl php-gd
  ```

- Start and Enable PHP-FPM:
  ```bash
  sudo systemctl start php8.3-fpm && sudo systemctl enable php8.3-fpm
  ```
  
- Verify that PHP-FPM is Running:
  ```bash
  sudo systemctl status php8.3-fpm
  ```

### 2. Set Up Your Laravel Project

**2.1 Clone the Laravel Project**
- Clone Laravel Repository in Root Directory:
  ```bash
  cd /var/www/
  git clone https://github.com/AbhishekKumar1602/Laravel-Dummy-App.git
  ```

**2.2 Install Composer**
- Download and Install Composer:
  ```bash
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
  ```

**2.3 Install Additional PHP Extensions**
- Install Additional PHP Extensions and Libraries:
  ```bash
  sudo apt-get install -y unzip zip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev
  ```

**2.4 Set Permissions for the Project Directory**
- Adjust Ownership and Permissions:
  ```bash
  sudo chown -R www-data:www-data /var/www/Laravel-Dummy-App
  sudo chmod -R 755 /var/www/Laravel-Dummy-App
  ```

**2.5 Install Project Dependencies**
- Navigate to the Project Directory and Install Dependencies:
  ```bash
  cd /var/www/Laravel-Dummy-App
  composer install
  ```

**2.6 Set Up Environment File**
- Copy the Example Environment File and Generate the Application Key:
  ```bash
  cp .env.example .env
  php artisan key:generate
  ```

### 3. Configure Nginx for Laravel

**3.1 Create and Configure Server Block for the Laravel Dummy App**
- Create a Server Block for the Laravel Dummy App:
```bash
sudo nano /etc/nginx/sites-available/Laravel-Dummy-App
```
- Add the Following Configuration:
```nginx
server {
    listen 80;

    root /var/www/Laravel-Dummy-App/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location /public/assets/ {
        alias /var/www/html/public/assets/;
        try_files $uri $uri/ =404;
        access_log off; 
        expires max;
    }

    location /public/assets/css/ {
        alias /var/www/html/public/assets/css/;
        try_files $uri $uri/ =404;
        access_log off;  
        expires max;
    }

    location /public/assets/js/ {
        alias /var/www/html/public/assets/js/;
        try_files $uri $uri/ =404;
        access_log off;  
        expires max;
    }

    location /public/assets/images/ {
        alias /var/www/html/public/assets/images/;
        try_files $uri $uri/ =404;
        access_log off; 
        expires max;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**3.3 Create the `sites-enabled` Directory**
- Create the `sites-enabled` Directory if Not Exist:
```bash
sudo mkdir /etc/nginx/sites-enabled/
```

**3.4 Enable the Server Block**
- Create a Symbolic Link to Enable the Server Block:
```bash
sudo ln -s /etc/nginx/sites-available/Laravel-Dummy-App /etc/nginx/sites-enabled/
```

**3.5 Edit Nginx Configuration**
- Edit the Main Nginx Configuration File:
```bash
sudo nano /etc/nginx/nginx.conf
```

- Use the Following Configuration:
```nginx
user www-data;

events {
    worker_connections 1024; 
}

http {
    include mime.types;
    default_type application/octet-stream;
    include /etc/nginx/sites-enabled/*;
}
```

**3.6 Reload Nginx**
- Apply the new configuration:
```bash
sudo nginx -s reload
```

### 4. Configure Database Connection

**4.1 Configure ODBC Driver**
- Run the MSSQLServerODBCDriver.sh Script:
```
sudo bash MSSQLServerODBCDriver.sh
```

**4.2 Configure PHP Extention**
- Run the MSSQLServerPHPExtention.sh Script:
```
sudo bash MSSQLServerPHPExtention.sh
```

**4.3 Configure Laravel to Use MSSQL Server**
- Update .env file in your Laravel project with MSSQL connection details. 
```
DB_CONNECTION=sqlsrv
DB_HOST=your_mssql_server_host
DB_PORT=your_mssql_server_port
DB_DATABASE=your_database_name
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

## Steps: On Dcoker with Nginx and PHP-FPM

**1.Create `Dockerfile` in Root Directory of Project and Add the Below Configurations**
```
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
```

**2.Create `nginx.conf` in Root Directory of Project and Add the Below Configurations**
```nginx
user www-data;

events {
    worker_connections 1024; 
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    include /etc/nginx/conf.d/*.conf;
}
```

**3.Create `default.conf` in Root Directory of Project and Add the Below Configurations**
```nginx
server {
    listen 80;

    root /var/www/html/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location /public/assets/ {
        alias /var/www/html/public/assets/;
        try_files $uri $uri/ =404;
        access_log off;  # Consider enabling this for debugging
        expires max;
    }

    location /public/assets/css/ {
        alias /var/www/html/public/assets/css/;
        try_files $uri $uri/ =404;
        access_log off;  # Consider enabling this for debugging
        expires max;
    }

    location /public/assets/js/ {
        alias /var/www/html/public/assets/js/;
        try_files $uri $uri/ =404;
        access_log off;  # Consider enabling this for debugging
        expires max;
    }

    location /public/assets/images/ {
        alias /var/www/html/public/assets/images/;
        try_files $uri $uri/ =404;
        access_log off;  # Consider enabling this for debugging
        expires max;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass localhost:9000;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**2. Build the Docker Image**
```
docker build -t laravel-dummy-app .
```
**3. Run the Docker Container**
```
docker run -d -p 80:80 laravel-dummy-app
```