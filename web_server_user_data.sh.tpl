#!/bin/bash

# Update package lists
sudo apt update -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_15.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt install build-essential -y


# Install PM2
sudo apt install npm -y 
sudo npm install -g pm2 

# Install NGINX
sudo apt-get install nginx -y
sudo systemctl enable nginx

# Configure NGINX
cat > /etc/nginx/sites-available/node << 'EOF'
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_set_header   X-Forwarded-For $remote_addr;
        proxy_set_header   Host $http_host;
        proxy_pass         http://127.0.0.1:8080;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/node /etc/nginx/sites-enabled/node
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# Setup firewall
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Prepare directory for app
mkdir -p ~/code/app-dist

# Write hello.js
cat > ~/code/app-dist/hello.js << EOF
const http = require('http');

const hostname = 'localhost';
const port = 8080;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end("Hello world tengo conexion con \nConnection string to MongoDb: mongodb://${mongo_private_ip}:27017");
});

server.listen(port, hostname, () => {
  console.log("Server running at http://" + hostname + ":" + port + "/");
});
EOF

# Start hello.js with PM2
cd ~/code/app-dist/
sudo pm2 start hello.js
sudo pm2 startup systemd
sudo pm2 save