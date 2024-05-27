#!/bin/bash

# Define the Tomcat URL
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz"

# Install necessary packages
apt-get update
apt-get -y install openjdk-11-jdk git maven wget

# Download and extract Tomcat
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=$(tar xzvf tomcatbin.tar.gz)
TOMDIR=$(echo $EXTOUT | head -1 | cut -d '/' -f1)

# Create a tomcat user with no login shell
useradd --shell /usr/sbin/nologin tomcat

# Synchronize the extracted Tomcat directory to /usr/local/tomcat
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat/

# Change ownership to the tomcat user
chown -R tomcat:tomcat /usr/local/tomcat

# Create the systemd service file for Tomcat
rm -rf /etc/systemd/system/tomcat.service

cat <<EOT > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat

# Environment variables
Environment=JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat

ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOT

# Reload the systemd daemon and start Tomcat service
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# Clone the project repository and build it with Maven
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mvn install

# Deploy the built WAR file to Tomcat
systemctl stop tomcat
sleep 20
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat
sleep 20

# Disable and stop the firewall
ufw disable

# Restart Tomcat service
systemctl restart tomcat

