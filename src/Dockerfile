####################################################
# Server Side Up -  Docker Utility Image
#####################################################

ARG UPSTREAM_CHANNEL=''
ARG BASE_OS_FLAVOR='ubuntu'
ARG BASE_OS_VERSION='20.04'
ARG BASE_IMAGE="serversideup/s6-overlay:${UPSTREAM_CHANNEL}${BASE_OS_FLAVOR}-${BASE_OS_VERSION}"

FROM ${BASE_IMAGE}
LABEL maintainer="Jay Rogers (@jaydrogers)"

# Make sure we keep apt silent during installs
ENV DEBIAN_FRONTEND=noninteractive \
    PUID=9999 \
    PGID=9999 \
    SSH_USER="tunnel" \
    SSH_GROUP="tunnelgroup" \
    SSH_USER_HOME="/home/tunnel" \
    SSH_PORT="2222" \
    SSH_HOST_KEY_DIR="/etc/ssh/ssh_host_keys" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"

# Install SSH server and ping command
RUN apt-get update \
    && echo "Install requirements..." \
    && apt-get -y --no-install-recommends install \
        openssh-server \
        iputils-ping \
        locales \
        locales-all \
    && echo "Create run directory..." \
    && mkdir /run/sshd \
    && echo "Configure our SSH user" \
    && groupadd -r -g $PGID $SSH_GROUP \
    && useradd --no-log-init -m -r -s /usr/bin/bash -d $SSH_USER_HOME -u $PUID -g $PGID $SSH_USER \
    && echo "Clean up after ourselves..." \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "Ensure generated keys are removed at this stage..." \
    && rm -rf /etc/ssh/ssh_host_*

# Copy over S6 configurations
COPY etc/cont-init.d/ /etc/cont-init.d/

#Expose the SSH port
EXPOSE 2222

#Configure S6 to drop priveleges
ENTRYPOINT ["/init"]

# -D in CMD below prevents sshd from becoming a daemon. -e is to log everything to stderr.
CMD ["/usr/sbin/sshd", "-D", "-e"]