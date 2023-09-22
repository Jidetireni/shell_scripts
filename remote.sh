#!/bin/bash
# This is a scripts to remotely execute commands on other machines
# Check for the correct number of arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <user> <target_ip> <target_user> <command>"
    exit 1
fi

user="$1"
target_ip="$2"
target_user="$3"
command_to="$4"

echo "$target_ip $target_user" | sudo tee -a /etc/hosts
if [ $? -eq 0 ]; then
	# SSH into the target host and run the command
	ssh "$user@$target_user" "$command_to"
else
	echo "Not able to write hosts in /etc/hosts file"
fi
# Check the exit status of the SSH command
if [ $? -eq 0 ]; then
    # Optional: Generate an SSH key
    ssh-keygen

    # Optional: Copy the SSH key to the target host
    ssh-copy-id "$user"@"$target_user"

    # Optional: SSH into the target host
    ssh "$user@$target_user" "$command_to"
else
    echo "Unable to SSH into the target machine."
fi

