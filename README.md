# Prerequisites

      A appropriately Linux system (such as Ubuntu).

      Sudo privileges on the target system.

      curl

      apt-transport-https

      lsb-release


# Installation


    Clone the repository or download the script wazuh_setup.sh to your local machine.

    Open a terminal and navigate to the location where you saved the script.

    Make the script executable by running the command: chmod +x wazuh_setup.sh.

    Run the script with root privileges: sudo ./wazuh_setup.sh.


# Possible Errors and Troubleshooting

***Error: Dependency not found***

If a required dependency is not found, the script will display an error message indicating which dependency is missing. To fix this error, install the missing dependency using the package manager for your system. For example, on Ubuntu, you can use the following command to install a missing package:

`sudo apt install <package_name>`

Replace <package_name> with the name of the missing package.


***Error: Failed to install package***


If the script fails to install a package, it may be due to network issues or package repository problems. To troubleshoot this error, try the following steps:

Check your internet connection.


Update the package repository by running: ***sudo apt update.***


Retry running the script.


If the error persists, you can manually install the failed package using the package manager for your system. For example, on Ubuntu, you can use the following command to install a package:


`sudo apt install <package_name>`


Replace <package_name> with the name of the package that failed to install.


***Error: Failed to configure agent***

If the script fails to configure the Wazuh agent, it may be due to incorrect configuration parameters. Make sure you have correctly set the ***MANAGER_IP*** variable in the script to the IP address or hostname of your Wazuh manager. Double-check that the agent package is correctly downloaded and installed for your OS.

***Error: Failed to start service***

If a service fails to start, it may be due to a service configuration issue or a conflict with another service. To troubleshoot this error, try the following steps:


    Check the service logs for any error messages. For example, to view the Wazuh manager logs, run: sudo journalctl -u wazuh-manager.

    Verify that the required configuration files for the service are present and correctly set.

    Restart the service manually using the appropriate command for your system. For example, to restart the Wazuh manager, run: 
    
    sudo systemctl restart wazuh-manager.


If the error persists, you may need to consult the official documentation or seek assistance from the Wazuh community for further troubleshooting.



For additional usage and customization details, refer to [the Wazuh documentation](https://documentation.wazuh.com/current/) 


# Disclaimer

This script is provided as-is, without any warranties or guarantees. Use it at your own risk. Always review and understand the script before running it on your system. Make sure to backup any important data before making changes to your system.


# Contributing

Contributions to this project are welcome. If you find any issues or want to improve the script, feel free to open an issue or create a pull request.

