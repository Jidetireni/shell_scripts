#!/bin/bash

# Set the database root password
DATABASE_PASS='admin123'

# Update all installed packages to the latest version
sudo apt-get update -y
sudo apt-get upgrade -y

# Install git, zip, unzip, and MariaDB server
sudo apt-get install -y git zip unzip mariadb-server

# Start and enable MariaDB service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Clone the project repository from GitHub
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git

# Secure the MariaDB installation
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Create a new database and user
sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"

# Restore the database from the backup file
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart the MariaDB service to apply changes
sudo systemctl restart mariadb

# Configure the firewall to allow MariaDB traffic on port 3306
sudo ufw allow 3306/tcp
sudo ufw reload
sudo ufw enable
sudo systemctl restart mariadb

