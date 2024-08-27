#!/bin/bash

# Exit on Any Error
set -e

# Update System Packages
sudo apt-get update

# Install PHP and Required Packages
sudo apt-get install php8.3 php8.3-dev php8.3-xml php-pear unixodbc-dev -y

# Add the PHP Repository
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update

# Install Packages Needed to Build PHP Extensions
sudo apt-get install unixodbc-dev gcc g++ make autoconf libc-dev pkg-config -y

# Install the SQL Server Driver for PHP
sudo pecl install sqlsrv
sudo pecl install pdo_sqlsrv

# Create and Enable `sqlsrv.ini` Configuration File
echo "extension=sqlsrv.so" | sudo tee /etc/php/8.3/mods-available/sqlsrv.ini

# Create and Enable `pdo_sqlsrv.ini` Configuration File
echo "extension=pdo_sqlsrv.so" | sudo tee /etc/php/8.3/mods-available/pdo_sqlsrv.ini

# Enable the Extensions in PHP
sudo phpenmod sqlsrv
sudo phpenmod pdo_sqlsrv

# Append Extensions to `php.ini` for PHP-FPM
echo "extension=sqlsrv.so" | sudo tee -a /etc/php/8.3/fpm/php.ini
echo "extension=pdo_sqlsrv.so" | sudo tee -a /etc/php/8.3/fpm/php.ini

# Verify the Installation
php -m | grep sqlsrv
php -m | grep pdo_sqlsrv

# Restart the Nginx and PHP-FPM
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm
