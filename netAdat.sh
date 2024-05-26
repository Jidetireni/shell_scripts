#!/bin/bash

VALUE=$(ip addr show | grep -v LOOPBACK | grep -ic mtu)

if [ $VALUE -eq 1 ]
then 
    echo "1 Active Network Interface found."
elif [ $VALUE -gt 1 ]
then
    echo "$VALUE active Network Interface Found."
else 
    echo "No Active interface found."
fi
