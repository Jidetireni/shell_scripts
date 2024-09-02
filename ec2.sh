#!/bin/bash

# Variables
REGION="us-east-1"
AMI_ID="ami-0a0e5d9c7acc336f1"
INSTANCE_TYPE="t2.micro"
KEY_NAME="cli-key"
SECURITY_GROUP_NAME="cli-sg"
SECURITY_GROUP_DESCRIPTION="Security group for my EC2 instance"
INSTANCE_COUNT=1

MY_IP=$(curl -s ifconfig.me)
SECURITY_GROUP_CIDR="${MY_IP}/32"

MY_IP=$(curl -s ifconfig.me)
CIDR="${MY_IP}/32"

# Create a key pair
echo "Creating key pair: $KEY_NAME"
aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > ${KEY_NAME}.pem
chmod 400 ${KEY_NAME}.pem
echo "Key pair created and saved to ${KEY_NAME}.pem"

# Create a security group
echo "Creating security group: $SECURITY_GROUP_NAME"
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "$SECURITY_GROUP_DESCRIPTION" --region $REGION --query 'GroupId' --output text)

# Allow SSH access in the security group
echo "Adding SSH rule to security group"
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr $CIDR --region $REGION

# Launch the EC2 instance
echo "Launching EC2 instance"
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count $INSTANCE_COUNT --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-group-ids $SECURITY_GROUP_ID --region $REGION --query 'Instances[0].InstanceId' --output text)

echo "EC2 instance launched with ID: $INSTANCE_ID"

echo "Tagging instance $INSTANCE_ID with name $INSTANCE_NAME"
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$INSTANCE_NAME --region $REGION

# Output instance details
echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

echo "Instance $INSTANCE_ID is now running."
