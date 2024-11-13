# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv
FROM debian:bookworm-slim

ENV ALLOWED_IPS="AllowUsers tunnel" \
    DEBUG_MODE="false" \
    DEBIAN_FRONTEND=noninteractive \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    PGID=9999 \
    PUID=9999 \
    SSH_HOST_KEY_DIR="/etc/ssh/ssh_host_keys" \
    SSH_PORT="2222" \
    SSH_USER="tunnel"

ARG PACKAGE_DEPENDENCIES="openssh-server,iputils-ping,locales,tini"

COPY --chown=root:root --chmod=755 src/rootfs /

RUN serversideup-dep-install-debian ${PACKAGE_DEPENDENCIES} && \
    \
    # Generate required locales
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8 && \
    \
    # Create unprivileged user
    serversideup-create-unprivileged-user "$SSH_USER" "${PUID}" "${PGID}" && \
    \
    # Set proper permissions
    mkdir -p /home/$SSH_USER/.ssh $SSH_HOST_KEY_DIR && \
    chown -R $SSH_USER:$SSH_USER $SSH_HOST_KEY_DIR /home/$SSH_USER/.ssh && \
    chmod 700 /home/$SSH_USER/.ssh && \
    \
    # Create run directory
    mkdir -p /run/sshd

# Expose the SSH port
EXPOSE 2222

LABEL org.opencontainers.image.title="serversideup/docker-ssh" \
    org.opencontainers.image.description="Simple SSH container. Great for secure connections into clusters." \
    org.opencontainers.image.url="https://github.com/serversideup/docker-ssh" \
    org.opencontainers.image.source="https://github.com/serversideup/docker-ssh" \
    org.opencontainers.image.documentation="https://github.com/serversideup/docker-ssh" \
    org.opencontainers.image.vendor="ServerSideUp" \
    org.opencontainers.image.authors="Jay Rogers (@jaydrogers)" \
    org.opencontainers.image.version="${REPOSITORY_BUILD_VERSION}" \
    org.opencontainers.image.licenses="GPL-3.0-or-later"


ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]