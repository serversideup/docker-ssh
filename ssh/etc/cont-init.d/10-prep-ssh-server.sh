#!/usr/bin/with-contenv bash

#########################################
# Prep SSHD configuration
#
echo "🔐 Setting SSHD configuration..."
echo "Port $SSH_PORT" > /etc/ssh/sshd_config.d/custom.conf
echo "PermitRootLogin no" >> /etc/ssh/sshd_config.d/custom.conf
echo "DebianBanner no" >> /etc/ssh/sshd_config.d/custom.conf
echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config.d/custom.conf
echo "MaxAuthTries 5" >> /etc/ssh/sshd_config.d/custom.conf
echo "LoginGraceTime 20" >> /etc/ssh/sshd_config.d/custom.conf
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config.d/custom.conf
echo "KerberosAuthentication no" >> /etc/ssh/sshd_config.d/custom.conf
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config.d/custom.conf
echo "X11Forwarding no" >> /etc/ssh/sshd_config.d/custom.conf
echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config.d/custom.conf
echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config.d/custom.conf
echo "PermitTunnel yes" >> /etc/ssh/sshd_config.d/custom.conf
echo "HostKey $SSH_HOST_KEY_DIR/ssh_host_rsa_key" >> /etc/ssh/sshd_config.d/custom.conf
echo "HostKey $SSH_HOST_KEY_DIR/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config.d/custom.conf
echo "HostKey $SSH_HOST_KEY_DIR/ssh_host_ed25519_key" >> /etc/ssh/sshd_config.d/custom.conf


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
