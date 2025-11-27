#!/bin/bash

# Update packages
apt-get update -y

# Install required dependencies
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add Docker repository
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update after adding repo
apt-get update -y

# Install Docker
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add admin user to Docker group
usermod -aG docker azureuser   # <-- CHANGE THIS ONE WORD
