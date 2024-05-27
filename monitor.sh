#!/bin/bash

if [ -z "$1" ]
then
    echo "Usage: $0 <service_name>"
    exit 1
fi

SERVICE=$1
echo "#################################################################"
date

systemctl is-active --quiet "$SERVICE"

if [ $? -eq 0 ]
then
    echo "$SERVICE process is running"
else
    echo "$SERVICE process is NOT Running."
    echo "Starting the process"
    systemctl start "$SERVICE"

    if [ $? -eq 0 ]
    then
    	echo " $SERVICE Process started successfully."
    else
    	echo "Process Starting Failed, contact the admin."
    fi
fi

echo "#####################################################"
echo 
