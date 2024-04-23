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
        SERVICE_CMD="systemctl"
    elif [ -f /etc/redhat-release ]; then
        INSTALL_CMD="yum install -y"
        UPDATE_CMD="yum update"
        REMOVE_CMD="yum remove -y"
        SERVICE_CMD="systemctl"
    else
        echo -e "\e[31mUnsupported distribution!\e[0m"
        exit 1
    fi
}

# Install Fail2Ban
install_fail2ban() {
    echo -e "\e[34mInstalling Fail2Ban...\e[0m"
    # Update package lists
    echo "Updating package lists..."
    $UPDATE_CMD
    if [ $? -ne 0 ]; then
        echo -e "\e[31mFailed to update package lists. Please check your package manager settings.\e[0m"
        log "Failed to update package lists."
        return 1
    fi
    
    # Check if Fail2Ban is already installed
    if command -v fail2ban-server &>/dev/null; then
        echo -e "\e[33mFail2Ban is already installed.\e[0m"
        return 0
    fi

    # Proceed with installation
    echo "Proceeding with Fail2Ban installation..."
    $INSTALL_CMD fail2ban
    if [ $? -eq 0 ]; then
        echo -e "\e[32mFail2Ban has been installed successfully.\e[0m"
        log "Fail2Ban installed successfully."
    else
        echo -e "\e[31mFailed to install Fail2Ban. Please check your network connection and repository configuration.\e[0m"
        log "Failed to install Fail2Ban."
        return 1
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

# Start Fail2Ban service
start_fail2ban() {
    echo -e "\e[34mStarting Fail2Ban service...\e[0m"
    # Attempt to start the service
    $SERVICE_CMD start fail2ban
    if [ $? -eq 0 ]; then
        echo -e "\e[32mFail2Ban service has been started successfully.\e[0m"
        log "Fail2Ban service started successfully."
        
        # Optionally, check and display the status of Fail2Ban to confirm
        echo "Verifying Fail2Ban service status..."
        $SERVICE_CMD status fail2ban | grep "Active"
        if grep -q "running" <<< $($SERVICE_CMD status fail2ban); then
            echo -e "\e[32mConfirmation: Fail2Ban service is active and running.\e[0m"
        else
            echo -e "\e[31mWarning: Fail2Ban service is not running. Please check the logs.\e[0m"
        fi
    else
        echo -e "\e[31mFailed to start Fail2Ban service. Please check the system logs for more information.\e[0m"
        log "Failed to start Fail2Ban service."
    fi
}

# Stop Fail2Ban service
stop_fail2ban() {
    echo -e "\e[34mStopping Fail2Ban service...\e[0m"
    $SERVICE_CMD stop fail2ban
    log "Fail2Ban service stopped."
}

# Check the status of Fail2Ban
check_status() {
    echo -e "\e[34mChecking the status of Fail2Ban...\e[0m"
    # Execute the command to check the service status
    status_output=$($SERVICE_CMD status fail2ban)
    
    # Log the check
    log "Checked Fail2Ban status."

    # Display the output to the user
    echo "$status_output"

    # Check if the service is active and running
    if echo "$status_output" | grep -q "active (running)"; then
        echo -e "\e[32mFail2Ban service is active and running.\e[0m"
    elif echo "$status_output" | grep -q "inactive (dead)"; then
        echo -e "\e[33mFail2Ban service is inactive.\e[0m"
    elif echo "$status_output" | grep -q "failed"; then
        echo -e "\e[31mFail2Ban service has failed. Please check the logs for more details.\e[0m"
    else
        echo -e "\e[33mFail2Ban service status is uncertain. Please investigate further.\e[0m"
    fi
}


# Display menu for user interaction
show_menu() {
    clear
    echo -e "\e[36mFail2Ban-QuickSetup\e[0m"
    echo "-------------------------"
    echo "1. Install Fail2Ban"
    echo "2. Uninstall Fail2Ban"
    echo "3. Configure Fail2Ban"
    echo "4. Start Fail2Ban Service"
    echo "5. Stop Fail2Ban Service"
    echo "6. Check Fail2Ban Status"
    echo "7. Exit"
    echo ""
    echo -n "Enter your choice [1-7]: "
    read choice
    echo ""
    case $choice in
        1) install_fail2ban ;;
        2) uninstall_fail2ban ;;
        3) configure_fail2ban ;;
        4) start_fail2ban ;;
        5) stop_fail2ban ;;
        6) check_status ;;
        7) exit 0 ;;
        *) echo -e "\e[31mInvalid option, please choose between 1-7.\e[0m"
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
