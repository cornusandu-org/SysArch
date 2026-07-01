#!/usr/bin/env bash
set -e

#pacman -S libcap

useradd -m -s /bin/bash sysadmin
echo 'sysadmin:1234' | chpasswd

chown -R sysadmin:sysadmin /home/sysadmin

useradd -m -s /bin/bash SYSTEM
sudo usermod -aG root SYSTEM
chown -R SYSTEM:SYSTEM /home/SYSTEM
chown SYSTEM:root /etc/shadow  && chmod u=rwx,g=rwx,o= /etc/shadow
echo 'SYSTEM:SYSTEM_' | chpasswd  # This can NOT be logged into after boot

if ! grep -q "secure_su_denylist" /etc/pam.d/su; then
    # Inserts a rule at the top of /etc/pam.d/su to block matching users
    sed -i '1s/^/auth       required   pam_listfile.so item=user sense=deny file=\/etc\/secure_su_denylist onerr=succeed\n/' /etc/pam.d/su
fi

# System files. The system administrator can override this anyways by using SYSTEM
useradd -m -s /usr/bin/nologin SysInstaller
chown SysInstaller:SysInstaller /etc/passwd  && chmod u=rwx,g=rx,o=rwx /etc/passwd
chown SysInstaller:SysInstaller /usr  && chmod u=rwx,g=rwx,o=rx /usr && chmod +t /usr
chown SysInstaller:SysInstaller /etc  && chmod u=rwx,g=rx,o=rx /etc && chmod +t /etc

for dir in /usr/*; do
    # Filter out files and symlinks; grab directories only
    if [ -d "$dir" ] && [ ! -L "$dir" ]; then
        chown SysInstaller:SysInstaller "$dir"
        chmod u=rwx,g=rwx,o=rx "$dir"
        chmod +t "$dir"
    fi
done

setfacl -d -m u:sysadmin:rwx /etc/

cat << 'EOF' > /etc/sudoers.d/10-sysadmin-system
# Require a password each time
Defaults:sysadmin timestamp_timeout=0

# Default target to SYSTEM and force target password validation
Defaults:sysadmin runas_default=SYSTEM, targetpw

# Dont allow interactive login
Defaults:sysadmin noexec

# Allow sysadmin to execute commands AS SYSTEM
sysadmin ALL=(SYSTEM) ALL

# Allow pacman specifically as root
Defaults!/usr/bin/pacman runas_default=root
Defaults!/usr/bin/pacman !targetpw
Defaults!/usr/bin/pacman !noexec
sysadmin ALL=(root) /usr/bin/pacman
Defaults!/usr/bin/pacman-key runas_default=root
Defaults!/usr/bin/pacman-key !targetpw
Defaults!/usr/bin/pacman-key !noexec
sysadmin ALL=(root) /usr/bin/pacman-key
EOF

# 2. Secure the drop-in file permissions (Sudo completely ignores files if permissions are wrong)
chmod 0440 /etc/sudoers.d/10-sysadmin-system


touch /var/lib/first-boot-done

systemctl disable first-boot.service
