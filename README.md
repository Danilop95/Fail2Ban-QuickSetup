## Fail2Ban-QuickSetup

Fail2Ban-QuickSetup provides a streamlined solution for installing, uninstalling, configuring, and monitoring Fail2Ban on Linux systems. This script automates routine administrative tasks associated with Fail2Ban, enhancing server security and reducing manual configuration overhead.

### Execution Instructions (Online)
To execute Fail2Ban-QuickSetup on your Linux system, you can use the following command with curl directly from your terminal:

```bash
bash <(curl -s https://raw.githubusercontent.com/Danilop95/Fail2Ban-QuickSetup/main/setup-fail2ban.sh)
```

> [!NOTE]  
> This command retrieves the script from the online repository and seamlessly executes it on your system.

### Execution Instructions (Local)
If you have cloned the Git repository and need to run the script locally, follow these steps:

1. Ensure you have administrative privileges on the system.
2. Open a terminal window.
3. Navigate to the directory containing the script (`setup-fail2ban.sh`).
4. Grant execution permissions to the script if it doesn't have them already:

```bash
chmod +x setup-fail2ban.sh
```

5. Run the script:

```bash
./setup-fail2ban.sh
```

### Supported Operating Systems
Fail2Ban-QuickSetup is fully compatible with the following operating systems:

- ![Ubuntu](https://img.shields.io/badge/Ubuntu-✔-green)
- ![Debian](https://img.shields.io/badge/Debian-✔-green)
- ![CentOS](https://img.shields.io/badge/CentOS-✔-green)
- ![Red Hat Enterprise Linux](https://img.shields.io/badge/Red_Hat_Enterprise_Linux-✔-green)

> [!NOTE]  
> It automatically detects the operating system and uses the appropriate package manager for installation and removal.

### Additional Information
- **Run this script with root privileges** to perform administrative tasks effectively.
- After installation, Fail2Ban can be customized by editing the `jail.local` configuration file.
- The script offers options to install, uninstall, configure, and monitor the status of Fail2Ban.
- Always review the configuration to tailor Fail2Ban according to your specific security requirements.
