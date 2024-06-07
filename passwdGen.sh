#!/bin/bash

echo "Welcome to password generator"
echo "Please enter the lenght of the password"

read -p "Enter Password:" PASS_LENGTH

if ! [[ $PASS_LENGTH =~ ^[0-9]+$ ]]; then
    echo "Error: Please enter a valid number ."
    exit 1
fi

passwords=()

for p in $(seq 1 3);
do
    passwords+=("$(openssl rand -base64 48 | cut -c1-$PASS_LENGTH)")
done

echo "Here are the generated passwords:"
for password in "${passwords[@]}"; do
    echo "Generated password: $password"
done 

echo "Do you want to save these password to a file? (y/n)"
read choice

if [ "$choice" = "y" ]; then
    for pass in "${passwords[@]}"; do
        echo "$password" | ccrypt -e -K "PASSPHRASE" > "passwords.txt.cpt"
    done
    echo "Passwords saved securely to passwords.txt.cpt"
elif [ "choice" = "n" ]; then
    echo "passwords not saved"
fi 

