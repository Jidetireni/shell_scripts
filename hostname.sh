#!/bin/bash

adduser(){
    USERS="$@"
    for usr in $USERS
    do 
        echo "Adding user $usr."
        useradd $usr
        id $usr
        echo "########################################################"
    done
}

change_hostname() {
    read -p "Enter the new hostname: " new_hostname
    sudo hostnamectl set-hostname "$new_hostname"
    echo "hostname has changed to $new_hostname"
}

if [ $# -lt 1 ]
then 
    echo "Usage: $0 user1 [user2 user3 ...]"
    exit 1
fi

adduser "$@"
change_hostname
