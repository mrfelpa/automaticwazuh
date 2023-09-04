# AutomaticWazuh

This script streamlines the installation and configuration process for the Wazuh manager, Wazuh agents, Elasticsearch, Kibana, and Filebeat. It offers a comprehensive solution for centralized log storage, analysis, and visualization.

# Prerequisites

*- A appropriately Linux system (such as Ubuntu).*

*- Sudo privileges on the target system.*

# Installation

`git clone https://github.com/0x5FE/automaticwazuh.git`

`cd repo`

Make the script executable:

`chmod +x .sh`

- Edit the script to configure your specific settings: Replace **"your_manager_ip_or_hostname"** with the IP address or hostname of your Wazuh manager.   

- Replace **"your_elastic_password"** with the desired password for Elasticsearch and Kibana.

Execute the script to effortlessly set up Wazuh and its associated components

`./ -wazuh.sh`

# Configuration

Once you have executed the script, your Wazuh environment will be fully set up, encompassing the manager, agents, Elasticsearch, Kibana, and Filebeat. Now, let's delve into some essential configuration steps that you may want to undertake:

Wazuh Agent Configuration: Enhance your monitoring capabilities by installing and configuring the Wazuh agent on additional hosts. 

This will enable you to keep a vigilant eye on more systems. Simply modify the agent configuration to direct it towards your Wazuh manager's IP or hostname.

Elasticsearch and Kibana Configuration: Tailor the configurations of Elasticsearch and Kibana to suit your specific requirements. This includes fine-tuning security settings, establishing data retention policies, and crafting captivating visualizations.

Wazuh Rules and Policies: Empower your organization's security by customizing Wazuh rules and policies. Align them with your unique security requirements to ensure comprehensive protection. Feel free to add or modify rules in `/var/ossec/etc/rules` and policies in `/var/ossec/etc/policies`.

By following these configuration steps, you will fortify your Wazuh environment, bolstering its effectiveness and adaptability. 

Take charge of your security infrastructure and unleash the full potential of Wazuh.

# Usage

Once the setup is complete, your Wazuh environment will be fully prepared for host-based monitoring. 

You can access the Kibana web interface to visualize and analyze security data. 

Here are some useful URLs:

**- Kibana: http://your-server-ip-or-hostname:5601**

**- Elasticsearch: http://your-server-ip-or-hostname:9200**

For additional usage and customization details, refer to [the Wazuh documentation](https://documentation.wazuh.com/current/) 

# Contributing

Contributions to this project are welcome. If you find any issues or want to improve the script, feel free to open an issue or create a pull request.
