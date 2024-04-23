#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Determine OS and package manager
determine_os() {
    if [ -f /etc/debian_version ]; then
        INSTALL_CMD="apt-get"
        UPDATE_CMD="apt-get update"
        REMOVE_CMD="apt-get remove --purge -y"
    elif [ -f /etc/redhat-release ]; then
        INSTALL_CMD="yum"
        UPDATE_CMD="yum update"
        REMOVE_CMD="yum remove -y"
    else
        echo "Unsupported distribution!"
        exit 1
    fi
}

# Function to install Fail2Ban
install_fail2ban() {
    echo "Installing Fail2Ban..."
    $UPDATE_CMD
    $INSTALL_CMD install -y fail2ban
    if [ $? -eq 0 ]; then
        echo "Fail2Ban has been installed."
    else
        echo "Failed to install Fail2Ban."
    fi
}

# Function to uninstall Fail2Ban
uninstall_fail2ban() {
    echo "Uninstalling Fail2Ban..."
    sudo systemctl stop fail2ban
    $REMOVE_CMD fail2ban
    sudo rm -rf /etc/fail2ban
    echo "Fail2Ban has been uninstalled."
}

# Function to configure Fail2Ban
configure_fail2ban() {
    echo "Configuring Fail2Ban..."
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    echo "The configuration file has been copied to jail.local. You can now edit it with your preferred text editor."
}

# Function to check the status of Fail2Ban
check_status() {
    echo "Checking the status of Fail2Ban..."
    sudo systemctl status fail2ban | grep Active
}

# Display menu for user interaction
show_menu() {
    clear
    echo "Fail2Ban Management Script"
    echo "-------------------------"
    echo "1. Install Fail2Ban"
    echo "2. Uninstall Fail2Ban"
    echo "3. Configure Fail2Ban"
    echo "4. Check Fail2Ban Status"
    echo "5. Exit"
    echo ""
    echo -n "Enter your choice [1-5]: "
    read choice
    echo ""
    case $choice in
        1) install_fail2ban ;;
        2) uninstall_fail2ban ;;
        3) configure_fail2ban ;;
        4) check_status ;;
        5) exit 0 ;;
        *) echo "Invalid option, please choose between 1-5."
           pause
    esac
}

# Function to pause the menu until the user is ready
pause() {
    read -p "Press [Enter] key to continue..." fackEnterKey
}

# Main logic
determine_os

# Loop to show menu repeatedly until exit
while true
do
    show_menu
    pause
done
