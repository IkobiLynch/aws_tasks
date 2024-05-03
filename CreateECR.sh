#!/bin/bash 

# Creates an AWS ECR, builds docker image, Authenticate to ECR, Tag image and push it 

# Set Unofficial Strict Mode
set -euo pipefail

# Variables
REPOSITORY_NAME="spring-petclinic"
REGION="eu-north-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Create ECR 
aws ecr create-repository --repository-name $REPOSITORY_NAME --region $REGION

# Build the Docker image
docker build -t $REPOSITORY_NAME .

# Authenticate to ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Tag the Docker image
docker tag $REPOSITORY_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest

# Push the Docker image
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest
