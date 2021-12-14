#!/usr/bin/with-contenv bash

#########################################
# Prep SSHD configuration
#
echo "🔐 Setting SSHD configuration..."
{
  echo "Port ${SSH_PORT}"
  echo "PermitRootLogin no"
  echo "DebianBanner no"
  echo "PermitEmptyPasswords no"
  echo "MaxAuthTries 5"
  echo "LoginGraceTime 20"
  echo "ChallengeResponseAuthentication no"
  echo "KerberosAuthentication no"
  echo "GSSAPIAuthentication no"
  echo "X11Forwarding no"
  echo "AllowAgentForwarding yes"
  echo "AllowTcpForwarding yes"
  echo "PermitTunnel yes"
  echo "HostKey ${SSH_HOST_KEY_DIR}/ssh_host_rsa_key"
  echo "HostKey ${SSH_HOST_KEY_DIR}/ssh_host_ecdsa_key"
  echo "HostKey ${SSH_HOST_KEY_DIR}/ssh_host_ed25519_key"
} > /etc/ssh/sshd_config.d/custom.conf

#########################################
# Prep authentication 
#

## Example variables
# AUTHORIZED_KEYS="ssh-ed25519 123456789098765432asdfghjklkjhgfd myuser"
# ALLOWED_IPS="AllowUsers *@192.168.1.0/24 *@172.16.0.1 *@10.0.*.1"

# Exit if there are not any Authorized Keys defined
if [ -z "${AUTHORIZED_KEYS}" ]; then
  echo "🚨 AUTHORIZED_KEYS environment variable is not set. Exiting..."
  exit 1
fi

# Make the SSH directory 
mkdir $SSH_USER_HOME/.ssh/

echo "🔐 Setting authorized keys (from AUTHORIZED_KEYS variable)..."
echo "${AUTHORIZED_KEYS}" > /home/tunnel/.ssh/authorized_keys

# Secure the authorized keys file
chmod 700 $SSH_USER_HOME/.ssh/authorized_keys

# Set proper permissions
chown -R $SSH_USER:$SSH_GROUP $SSH_USER_HOME/.ssh/

#########################################
# Set allowed IPs
#

# Exit if there are not any Authorized Keys defined
if [ -z "${ALLOWED_IPS}" ]; then
  echo "🚨 ALLOWED_IPS environment variable is not set. Exiting..."
  exit 1
fi

echo "🔐 Setting allowed IPs (from ALLOWED_IPS variable) ..."
echo "${ALLOWED_IPS}" >> /etc/ssh/sshd_config.d/custom.conf
