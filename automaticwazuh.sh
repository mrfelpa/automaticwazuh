#!/bin/bash

# Wazuh version
WAZUH_VERSION="4.2.5"

# Define your manager IP or hostname here
MANAGER_IP="your_manager_ip_or_hostname"

# Elasticsearch and Kibana version
ELK_VERSION="7.15.0"

# Elasticsearch and Kibana authentication credentials
ELK_USERNAME="your_elk_username"
ELK_PASSWORD="your_elk_password"

# Install pre-requisites
echo "Installing pre-requisites..."
sudo apt update
sudo apt install -y curl apt-transport-https lsb-release

# Add Wazuh GPG key and repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo apt-key add -
echo "deb https://packages.wazuh.com/${WAZUH_VERSION}/xUbuntu_$(lsb_release -cs)/ ./" | sudo tee /etc/apt/sources.list.d/wazuh.list

# Add Elasticsearch GPG key and repository
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/${ELK_VERSION}/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

# Update package list
sudo apt update

# Install Wazuh manager
echo "Installing Wazuh manager..."
sudo apt install -y wazuh-manager

# Install Wazuh API
echo "Installing Wazuh API..."
sudo apt install -y wazuh-api

# Install Filebeat (for log forwarding)
echo "Installing Filebeat..."
curl -s https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://packages.elastic.co/beats/apt stable main" | sudo tee /etc/apt/sources.list.d/beats.list
sudo apt update
sudo apt install -y filebeat

# Install and configure the Wazuh agent
echo "Installing and configuring Wazuh agent..."

# Download the agent package for your OS from https://packages.wazuh.com
# Example: wget https://packages.wazuh.com/${WAZUH_VERSION}/apt/wazuh-agent_${WAZUH_VERSION}-1_amd64.deb
# sudo dpkg -i wazuh-agent_${WAZUH_VERSION}-1_amd64.deb

# Configure the agent to connect to the manager
echo "Setting up agent configuration..."
sudo sed -i "s/MANAGER_IP/${MANAGER_IP}/" /var/ossec/etc/ossec.conf
sudo /var/ossec/bin/ossec-control restart

# Start and enable services
sudo systemctl enable wazuh-manager
sudo systemctl enable wazuh-api
sudo systemctl enable filebeat
sudo systemctl start wazuh-manager
sudo systemctl start wazuh-api
sudo systemctl start filebeat

# Install and configure Elasticsearch and Kibana
echo "Installing and configuring Elasticsearch and Kibana..."
sudo apt install -y elasticsearch kibana
sudo systemctl enable elasticsearch
sudo systemctl enable kibana
sudo systemctl start elasticsearch
sudo systemctl start kibana

# Set up Elasticsearch authentication
echo "Setting up Elasticsearch authentication..."
echo "xpack.security.enabled: true" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
sudo service elasticsearch restart

# Set Elasticsearch password for built-in user 'elastic'
echo "Setting Elasticsearch password for 'elastic' user..."
sudo /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto -u "https://localhost:9200"

# Configure Kibana authentication
echo "Configuring Kibana authentication..."
sudo /usr/share/kibana/bin/kibana-keystore create
echo "${ELK_USERNAME}" | sudo /usr/share/kibana/bin/kibana-keystore add elasticsearch.username --stdin
echo "${ELK_PASSWORD}" | sudo /usr/share/kibana/bin/kibana-keystore add elasticsearch.password --stdin

# Restart Kibana
sudo service kibana restart

# Configure Filebeat to forward Wazuh alerts
echo "Configuring Filebeat to forward Wazuh alerts..."
sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak
cat <<EOL | sudo tee /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/ossec/logs/alerts/alerts.json
output.elasticsearch:
  hosts: ["localhost:9200"]
  protocol: "https"
  username: "${ELK_USERNAME}"
  password: "${ELK_PASSWORD}"
EOL

# Restart Filebeat
sudo systemctl restart filebeat

echo "Wazuh setup completed. Your system is now configured for host-based monitoring with Wazuh, Elasticsearch, and Kibana."
