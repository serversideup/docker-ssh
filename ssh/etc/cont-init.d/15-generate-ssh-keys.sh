#!/usr/bin/with-contenv bash

# Check if SSH host keys are missing
if [ ! -f $SSH_HOST_KEY_DIR/ssh_host_* ]; then
  echo "🏃‍♂️ Generating SSH keys for you..."
  dpkg-reconfigure openssh-server
  find /etc/ssh/ -type f -name "ssh_host_*" -exec mv -t $SSH_HOST_KEY_DIR "{}" \;
fi
