#!/usr/bin/env bash
set -e

# Example variables
# AUTHORIZED_KEYS="ssh-ed25519 123456789098765432asdfghjklkjhgfd myuser"
# ALLOWED_IPS="AllowUsers *@192.168.1.0/24 *@172.16.0.1 *@10.0.*.1"

#########################################
# Prep authentication 
#

# Exit if there are not any Authorized Keys defined
if [ -z "${AUTHORIZED_KEYS}" ]; then
  echo "🚨 AUTHORIZED_KEYS envioronment variable is not set. Exiting..."
  exit 1
fi

echo "🔐 Setting authorized keys (from AUTHORIZED_KEYS variable) ..."
echo "${AUTHORIZED_KEYS}" > /home/tunnel/.ssh/authorized_keys

# Secure the directory
chmod 700 /home/tunnel/.ssh/authorized_keys

# Set proper permissions
chown -R tunnel:tunnel /home/tunnel/.ssh/

#########################################
# Set allowed IPs
#

# Exit if there are not any Authorized Keys defined
if [ -z "${ALLOWED_IPS}" ]; then
  echo "🚨 ALLOWED_IPS envioronment variable is not set. Exiting..."
  exit 1
fi

echo "🔐 Setting allowed IPs (from ALLOWED_IPS variable) ..."
echo "${AUTHORIZED_KEYS}" > /home/tunnel/.ssh/authorized_keys

# Secure the directory
chmod 700 /home/tunnel/.ssh/authorized_keys

# Set proper permissions
chown -R tunnel:tunnel /home/tunnel/.ssh/

#########################################
# Launch SSH
#

# Execute the CMD from the Dockerfile:
exec "$@"
