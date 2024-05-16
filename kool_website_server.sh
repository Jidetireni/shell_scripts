#!/bin/bash

# Update package index
apt-get update

# Install NGINX and unzip
apt-get install nginx unzip -y

# Start NGINX service
sudo systemctl start nginx

# Enable NGINX to start on boot
sudo systemctl enable nginx

# Create directory for temporary files
sudo mkdir -p /tmp/kool

# Download web template
wget -P /tmp/kool https://www.tooplate.com/zip-templates/2136_kool_form_pack.zip

# Unzip web template
unzip -o /tmp/kool/2136_kool_form_pack.zip -d /tmp/kool

# Copy files to NGINX web server directory
sudo cp -r /tmp/kool/2136_kool_form_pack/* /var/www/html/

# Restart NGINX service
sudo systemctl restart nginx

# Clean up
rm -rf /tmp/kool
