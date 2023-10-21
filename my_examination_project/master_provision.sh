#!/bin/bash

# Update and upgrade packages
sudo apt update -y
sudo apt upgrade -y

# Install LAMP stack
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql

# Clone Laravel from GitHub
git clone https://github.com/laravel/laravel /var/www/html/laravel

# Configure Apache
sudo a2dissite 000-default
sudo cp /var/www/html/laravel/.env.example /var/www/html/laravel/.env
sudo chown -R www-data:www-data /var/www/html/laravel/storage
sudo a2enmod rewrite
sudo systemctl restart apache2

# Set up MySQL database (modify as needed)
mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE laravel_db;
CREATE USER 'laravel_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON laravel_db.* TO 'laravel_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Start and enable services
sudo systemctl enable apache2
sudo systemctl enable mysql
sudo systemctl start apache2
sudo systemctl start mysql

# Cron job for uptime check
(crontab -l 2>/dev/null; echo "0 0 * * * /usr/bin/uptime >> /var/www/html/laravel/uptime.log") | crontab -