#!/bin/bash

# Actualiza los paquetes del sistema
echo "Actualizando paquetes del sistema..."
sudo apt update && sudo apt upgrade -y

# Instala Fail2Ban
echo "Instalando Fail2Ban..."
sudo apt install fail2ban -y

# Copia el archivo de configuración predeterminado
echo "Configurando Fail2Ban..."
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configura Fail2Ban (modifica según tus necesidades)
sudo bash -c 'cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1
bantime = 600
findtime = 300
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 600
EOF'

# Reinicia Fail2Ban para aplicar la configuración
echo "Reiniciando Fail2Ban..."
sudo systemctl restart fail2ban

echo "Fail2Ban ha sido configurado correctamente."
