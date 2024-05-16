#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update package lists
sudo apt update

# Install necessary packages
sudo apt install apache2 ghostscript libapache2-mod-php mysql-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip -y

# Create directory for WordPress
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www

# Download and extract WordPress
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

# Create Apache configuration for WordPress
sudo bash -c 'cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF'

# Enable the WordPress site and required Apache modules
sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default

# Setup MySQL database for WordPress
sudo mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE wordpress;
CREATE USER wordpress@localhost IDENTIFIED BY 'admin123';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Configure WordPress to connect to the database
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/admin123/' /srv/www/wordpress/wp-config.php

# Restart MySQL and Apache services
sudo systemctl restart mysql
sudo systemctl restart apache2

echo "WordPress installation and configuration complete."
