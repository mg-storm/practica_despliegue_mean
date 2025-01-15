#!/bin/bash
# Update packages
sudo apt-get update -y

# Install MongoDB
sudo apt-get install -y mongodb

# Start MongoDB service
sudo service mongodb start

# Enable MongoDB to start on boot
sudo systemctl enable mongodb

sudo ufw allow 27017/tcp
sudo ufw enable