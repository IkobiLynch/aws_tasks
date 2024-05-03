#!/bin/bash

# Used to create a VPC, 1 subnet, 1 Internet GW, 1 Route table, 1 Security Group  that allows ssh (port 22)  and http (port 8080), a ssh key pair named IkobiKeyPair and an EC2 instance. The script also attaches everything  



# Set UnOfficial Strict Mode
set -euo pipefail

# Set variables for later use
REGION="eu-north-1"
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"

# Create VPC
# VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.Vpc.ID' --output text)

# Did not have IAM permissions to make VPC so using default vpc provided in AWS
VPC_ID=vpc-94b824fd

# Create Subnet
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --query 'Subnet.SubnetId' --output text)

# Create Internet Gateway & Attach to VPC
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayID' --ouput text)
aws ec2 attach-internet-gateay --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# Create Route Table and associate with Subnet
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableID' --output text)
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID --subnet-id $SUBNET_ID

# Create Security Group
SG_ID=$(aws ec2 create-security-group --group-name mySecurityGroup --description "Ikobi security group" --vpc-id $VPC_ID --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 8080 --cidr 0.0.0.0/0

# Create Key Pair
aws ec2 create-key-pair --key-name ilynchKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem

# Create EC2 Instance 
INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0c55b159cbfafe1f0 --count 1 --instance-type t3.micro --key-name ilynchKeyPair --security-group-ids $SG_ID --subnet-id $SUBNET_ID --associate-public-ip-address --query 'Instances[0].InstanceId' --output text)

echo "VPC ID: $VPC_ID"
echo "Subnet ID: $SUBNET_ID"
echo "Security Group ID: $SG_ID"
echo "Instance ID: $INSTANCE_ID"
