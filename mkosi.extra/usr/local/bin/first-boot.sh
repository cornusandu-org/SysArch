#!/usr/bin/env bash
set -e

useradd -m -s /bin/bash sysadmin
echo 'sysadmin:1234' | chpasswd

mkdir -p /home/sysadmin/projects
chown -R sysadmin:sysadmin /home/sysadmin

touch /var/lib/first-boot-done