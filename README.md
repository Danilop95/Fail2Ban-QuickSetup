## Fail2Ban-QuickSetup

The Fail2Ban-QuickSetup provides a convenient way to install, uninstall, configure, and check the status of Fail2Ban on Linux systems. This script automates common administrative tasks related to Fail2Ban, enhancing server security and reducing manual configuration efforts.

### Execution Instructions (Online)
To execute the Fail2Ban-QuickSetup on your Linux system, you can use the curl command directly from the command line. Below is the command to download and run the script:

```bash
curl -sSL https://raw.githubusercontent.com/Danilop95/Fail2Ban-QuickSetup/main/setup-fail2ban.sh | bash
```

This command will automatically download the script from the online repository and execute it on your system.

### Execution Instructions (Local)
If you have cloned the Git repository and need to run the script locally, follow these steps:

1. Ensure you have administrative privileges on the system.
2. Open a terminal window.
3. Navigate to the directory where the script is located (`setup-fail2ban.sh`).
4. If the script does not have execution permissions, grant them with the following command:

```bash
chmod +x setup-fail2ban.sh
```

5. Run the script:

```bash
./setup-fail2ban.sh
```

### Supported Operating Systems
The Fail2Ban-QuickSetup is 100% compatible with the following operating systems:

| Operating System           | Compatibility |
|----------------------------|---------------|
| Ubuntu                     | ☑             |
| Debian                     | ☑             |
| CentOS                     | ☑             |
| Red Hat Enterprise Linux   | ☑             |

### Additional Information
- This script must be run as root to perform administrative tasks effectively.
- It detects the operating system and uses the appropriate package manager for installation and removal.
- After installation, Fail2Ban can be configured by editing the `jail.local` configuration file.
- The script provides options to install, uninstall, configure, and check the status of Fail2Ban.
- Always review the configuration to tailor Fail2Ban to your specific security requirements.
