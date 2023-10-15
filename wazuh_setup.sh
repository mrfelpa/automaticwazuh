#!/bin/bash

WAZUH_VERSION="4.2.5"

# Define your manager IP or hostname here
MANAGER_IP="your_manager_ip_or_hostname"

ELK_VERSION="7.15.0"

# Elasticsearch and Kibana authentication credentials
ELK_USERNAME="your_elk_username"
ELK_PASSWORD="your_elk_password"


handle_error() {
  echo "Error: $1"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

check_dependencies() {
  echo "Checking dependencies..."
  
  
  local packages=("curl" "apt-transport-https" "lsb-release")

  for package in "${packages[@]}"; do
    if ! command_exists "$package"; then
      handle_error "$package is not installed. Please install it before running this script."
    fi
  done
}

install_prerequisites() {
  echo "Installing pre-requisites..."
  sudo apt update || handle_error "Failed to update package repository."
  sudo apt install -y curl apt-transport-https lsb-release || handle_error "Failed to install pre-requisite packages."
}

# Add Wazuh GPG key and repository
add_wazuh_repository() {
  echo "Adding Wazuh repository..."
  curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo apt-key add - || handle_error "Failed to add Wazuh GPG key."
  echo "deb https://packages.wazuh.com/${WAZUH_VERSION}/xUbuntu_$(lsb_release -cs)/ ./" | sudo tee /etc/apt/sources.list.d/wazuh.list || handle_error "Failed to add Wazuh repository."
}

# Add Elasticsearch GPG key and repository
add_elasticsearch_repository() {
  echo "Adding Elasticsearch repository..."
  curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - || handle_error "Failed to add Elasticsearch GPG key."
  echo "deb https://artifacts.elastic.co/packages/${ELK_VERSION}/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list || handle_error "Failed to add Elasticsearch repository."
}

# Install Wazuh manager
install_wazuh_manager() {
  echo "Installing Wazuh manager..."
  sudo apt update || handle_error "Failed to update package repository."
  sudo apt install -y wazuh-manager || handle_error "Failed to install Wazuh manager."
}

# Install Wazuh API
install_wazuh_api() {
  echo "Installing Wazuh API..."
  sudo apt install -y wazuh-api || handle_error "Failed to install Wazuh API."
}

# Install Filebeat
install_filebeat() {
  echo "Installing Filebeat..."
  curl -s https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - || handle_error "Failed to add Filebeat GPG key."
  echo "deb https://packages.elastic.co/beats/apt stable main" | sudo tee /etc/apt/sources.list.d/beats.list || handle_error "Failed to add Filebeat repository."
  sudo apt update || handle_error "Failed to update package repository."
  sudo apt install -y filebeat || handle_error "Failed to install Filebeat."
}

# Configure Wazuh agent
configure_wazuh_agent() {
  echo "Configuring Wazuh agent..."
  # Download the agent package for your OS from https://packages.wazuh.com
  # Example: wget https://packages.wazuh.com/${WAZUH_VERSION}/apt/wazuh-agent_${WAZUH_VERSION}-1_amd64.deb
  # sudo dpkg -i wazuh-agent_${WAZUH_VERSION}-1_amd64.deb
  
  # Configure the agent to connect to the manager
  echo "Setting up agent configuration..."
  sudo sed -i "s/MANAGER_IP/${MANAGER_IP}/" /var/ossec/etc/ossec.conf || handle_error "Failed to configure agent."
  sudo /var/ossec/bin/ossec-control restart || handle_error "Failed to restart Wazuh agent."
}

start_services() {
  echo "Starting and enabling services..."
  sudo systemctl enable wazuh-manager || handle_error "Failed to enable Wazuh manager service."
  sudo systemctl enable wazuh-api || handle_error "Failed to enable Wazuh API service."
  sudo systemctl enable filebeat || handle_error "Failed to enable Filebeat service."
  sudo systemctl start wazuh-manager || handle_error "Failed to start Wazuh manager service."
  sudo systemctl start wazuh-api || handle_error "Failed to start Wazuh API service."
  sudo systemctl start filebeat || handle_error "Failed to start Filebeat service."
}

# Install and configure Elasticsearch and Kibana
install_configure_elasticsearch_kibana() {
  echo "Installing and configuring Elasticsearch and Kibana..."
  sudo apt install -y elasticsearch kibana || handle_error "Failed to install Elasticsearch and Kibana."
  sudo systemctl enable elasticsearch || handle_error "Failed to enable Elasticsearch service."
  sudo systemctl enable kibana || handle_error "Failed to enable Kibana service."
  sudo systemctl start elasticsearch || handle_error "Failed to start Elasticsearch service."
  sudo systemctl start kibana || handle_error "Failed to start Kibana service."
}

# Set up Elasticsearch authentication
setup_elasticsearch_authentication() {
  echo "Setting up Elasticsearch authentication..."
  echo "xpack.security.enabled: true" | sudo tee -a /etc/elasticsearch/elasticsearch.yml || handle_error "Failed to set Elasticsearch authentication."
  sudo service elasticsearch restart || handle_error "Failed to restart Elasticsearch service."
}

# Set Elasticsearch password for built-in user 'elastic'
set_elasticsearch_password() {
  echo "Setting Elasticsearch password for 'elastic' user..."
  sudo /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto -u "https://localhost:9200" || handle_error "Failed to set Elasticsearch password."
}

# Configure Kibana authentication
configure_kibana_authentication() {
  echo "Configuring Kibana authentication..."
  sudo /usr/share/kibana/bin/kibana-keystore create || handle_error "Failed to create Kibana keystore."
  echo "${ELK_USERNAME}" | sudo /usr/share/kibana/bin/kibana-keystore add elasticsearch.username --stdin || handle_error "Failed to add Kibana Elasticsearch username."
  echo "${ELK_PASSWORD}" | sudo /usr/share/kibana/bin/kibana-keystore add elasticsearch.password --stdin || handle_error "Failed to add Kibana Elasticsearch password."
  sudo service kibana restart || handle_error "Failed to restart Kibana service."
}

# Configure Filebeat to forward Wazuh alerts
configure_filebeat() {
  echo "Configuring Filebeat to forward Wazuh alerts..."
  sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak || handle_error "Failed to backup Filebeat configuration."
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
  sudo systemctl restart filebeat || handle_error "Failed to restart Filebeat service."
}


check_dependencies

install_prerequisites

add_wazuh_repository
add_elasticsearch_repository

# Install Wazuh manager, API, Filebeat
install_wazuh_manager
install_wazuh_api
install_filebeat

# Configure Wazuh agent
configure_wazuh_agent

# Start and enable services
start_services

# Install and configure Elasticsearch and Kibana
install_configure_elasticsearch_kibana

# Set up Elasticsearch authentication
setup_elasticsearch_authentication

# Set Elasticsearch password for built-in user 'elastic'
set_elasticsearch_password

# Configure Kibana authentication
configure_kibana_authentication

# Configure Filebeat
configure_filebeat

echo "Wazuh setup completed. Your system is now configured for host-based monitoring with Wazuh, Elasticsearch, and Kibana."
