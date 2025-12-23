#!/bin/bash

# Define the desired Node.js major version
NODE_MAJOR=16
# Update local package index
sudo apt-get update
# Install necessary packages for downloading and verifying new repository information
sudo apt-get install -y ca-certificates curl gnupg
# Create a directory for the new repository's keyring, if it doesn't exist
sudo mkdir -p /etc/apt/keyrings
# Download the new repository's GPG key and save it in the keyring directory
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
# Add the new repository's source list with its GPG key for package verification
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
# Update local package index to recognize the new repository
sudo apt-get update
# Install Node.js from the new repository
sudo apt-get install -y nodejs



#install PM2 to support NodeJS application run-as-service
sudo npm install -g pm2
#start TodoList app as a service
cd /vagrant
npm install --no-bin-links        #restore application dependencies
pm2 start ecosystem.config.js     #start the application with PM2
pm2 save                          #save the current config for restarts
pm2 startup                       #enable PM2 startup system
#add PM2 configuration to systemd to restart application on reboot
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u vagrant --hp /home/vagrant
#wait for service start
while ! nc -z localhost 3000; do   
  sleep 0.1 # wait for 1/10 of the second before the next check
done
#seed tasks
curl -X POST \
  http://localhost:3000/tasks \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Postman-Token: 02a2e24a-5e6e-7612-82a1-0e3d3338eb2c' \
  -d name=Finish%20Vagrant%20Videos