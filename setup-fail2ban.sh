#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo -e "\e[31mThis script must be run as root\e[0m" 1>&2
   exit 1
fi

# Global Variables
LOGFILE="/var/log/fail2ban_quicksetup.log"
EDITOR="nano -l"  # Nano with line numbers

# Log function
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> $LOGFILE
}

# Install Nano if not installed
ensure_nano_installed() {
    if ! command -v nano &>/dev/null; then
        echo -e "\e[34mInstalling Nano...\e[0m"
        apt-get install -y nano >/dev/null 2>&1 || yum install -y nano >/dev/null 2>&1
        log "Nano has been installed."
    fi
    EDITOR="nano -l"  # Nano with line numbers
}

# Determine OS and package manager
determine_os() {
    if [ -f /etc/debian_version ]; then
        INSTALL_CMD="apt-get install -y"
        UPDATE_CMD="apt-get update"
        REMOVE_CMD="apt-get remove --purge -y"
    elif [ -f /etc/redhat-release ]; then
        INSTALL_CMD="yum install -y"
        UPDATE_CMD="yum update"
        REMOVE_CMD="yum remove -y"
    else
        echo -e "\e[31mUnsupported distribution!\e[0m"
        exit 1
    fi
}

# Install Fail2Ban
install_fail2ban() {
    echo -e "\e[34mInstalling Fail2Ban...\e[0m"
    $UPDATE_CMD
    $INSTALL_CMD fail2ban
    if [ $? -eq 0 ]; then
        echo -e "\e[32mFail2Ban has been installed.\e[0m"
        log "Fail2Ban installed successfully."
    else
        echo -e "\e[31mFailed to install Fail2Ban.\e[0m"
        log "Failed to install Fail2Ban."
    fi
}

# Uninstall Fail2Ban
uninstall_fail2ban() {
    echo -e "\e[33mUninstalling Fail2Ban...\e[0m"

    # Confirm before proceeding
    read -p "Are you sure you want to uninstall Fail2Ban? (y/N): " confirm
    if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
        echo -e "\e[36mUninstallation canceled.\e[0m"
        return
    fi

    # Stop Fail2Ban service first
    systemctl stop fail2ban
    if [ $? -eq 0 ]; then
        echo -e "\e[32mFail2Ban service stopped successfully.\e[0m"
        log "Fail2Ban service stopped."
    else
        echo -e "\e[31mFailed to stop Fail2Ban service. Please check its status.\e[0m"
        log "Failed to stop Fail2Ban service."
        return
    fi

    # Remove Fail2Ban package
    $REMOVE_CMD fail2ban
    if [ $? -eq 0 ]; then
        echo -e "\e[32mFail2Ban package removed successfully.\e[0m"
        log "Fail2Ban package removed."
    else
        echo -e "\e[31mFailed to remove Fail2Ban package.\e[0m"
        log "Failed to remove Fail2Ban package."
        return
    fi

    # Remove configuration files and logs
    echo "Removing configuration files and logs..."
    rm -rf /etc/fail2ban /var/log/fail2ban
    if [ $? -eq 0 ]; then
        echo -e "\e[32mConfiguration files and logs removed.\e[0m"
        log "Configuration files and logs removed."
    else
        echo -e "\e[31mFailed to remove configuration files and logs.\e[0m"
        log "Failed to remove configuration files and logs."
    fi

    echo -e "\e[32mFail2Ban has been completely removed from your system.\e[0m"
    log "Fail2Ban completely uninstalled."
}

# Configure Fail2Ban
configure_fail2ban() {
    echo -e "\e[34mConfiguring Fail2Ban...\e[0m"
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    $EDITOR /etc/fail2ban/jail.local
    log "Fail2Ban configuration opened for editing."
}

# Check the status of Fail2Ban
check_status() {
    echo -e "\e[34mChecking the status of Fail2Ban...\e[0m"
    systemctl status fail2ban | grep Active
    log "Checked Fail2Ban status."
}

# Display menu for user interaction
show_menu() {
    clear
    echo -e "\e[36mFail2Ban-QuickSetup\e[0m"
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
        *) echo -e "\e[31mInvalid option, please choose between 1-5.\e[0m"
           pause
    esac
}

# Function to pause the menu until the user is ready
pause() {
    read -p "Press [Enter] key to continue..." fackEnterKey
}

# Main logic
ensure_nano_installed
determine_os

# Loop to show menu repeatedly until exit
while true
do
    show_menu
    pause
done
