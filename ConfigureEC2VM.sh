#!/bin/bash

# Installs docker and starts the container where this script is ran. Exposes the application on port 8080

# Unoffical Strict Mode
set -euo pipefail

# Update VM
sudo yum update -y

# Install docker
sudo amazon-linux-extras install docker -y

# Start docker daemon
sudo service docker start

# Add ec2-user to docker Group
sudo usermod -a -G docker ec2-user

sudo docker run -d -p 8080:8080 <repo-url-here>:latest

