####################################################
# Server Side Up -  Docker Utility Image
#####################################################

FROM ubuntu:20.04

LABEL maintainer="Jay Rogers <jay@serversideup.net>"

# Install SSH server
RUN apt-get update \
    && echo "Install requirements..." \
    && apt-get -y --no-install-recommends install \
        openssh-server \
        iputils-ping \
    && echo "Create run directory..." \
    && mkdir /run/sshd \
    && echo "Configure SSH..." \
    && echo "Port 2222" > /etc/ssh/sshd_config.d/custom.conf  \
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "DebianBanner no" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "MaxAuthTries 5" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "LoginGraceTime 20" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "KerberosAuthentication no" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "X11Forwarding no" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "PermitTunnel yes" >> /etc/ssh/sshd_config.d/custom.conf  \
    && echo "Configure our SSH user" \
    && useradd -m -s /bin/bash -d /home/tunnel tunnel \
    && mkdir /home/tunnel/.ssh/ \
    && echo "Clean up after ourselves..." \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY docker-entrypoint.sh /

#Expose the SSH port
EXPOSE 2222

ENTRYPOINT ["/docker-entrypoint.sh"]

# -D in CMD below prevents sshd from becoming a daemon. -e is to log everything to stderr.
CMD ["/usr/sbin/sshd", "-D", "-e"]