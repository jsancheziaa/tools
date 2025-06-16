#!/bin/bash

# Update packages and install dependencies
sudo apt -y update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg-agent

# Add Docker's official GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt -y update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Verify Docker service status (optional)
# sudo systemctl status docker

# Add current user to the 'docker' group (to run Docker without sudo)
sudo usermod -aG docker ${USER}
# Add current user to the 'docker' group (to run Docker without sudo)
sudo usermod -aG docker ubuntu

# Install Docker Compose (latest stable release)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create a symbolic link for global access (optional)
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installations
echo -e "\n\e[1;32mDocker version:\e[0m"
docker --version
echo -e "\n\e[1;32mDocker Compose version:\e[0m"
docker-compose --version

# Final instructions
echo -e "\n\e[1;32mInstallation complete!\e[0m"
echo -e "To apply group changes, log out and back in or run: \e[1;33mnewgrp docker\e[0m\n"
