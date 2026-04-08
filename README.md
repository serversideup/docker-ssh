<p align="center">
		<img src="https://raw.githubusercontent.com/serversideup/docker-ssh/main/.github/header.png" width="1200" alt="Docker Images Logo">
</p>
<p align="center">
	<a href="https://actions-badge.atrox.dev/serversideup/docker-ssh/goto?ref=main"><img alt="Build Status" src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fserversideup%2Fdocker-ssh%2Fbadge%3Fref%3Dmain&style=flat" /></a>
	<a href="https://github.com/serversideup/docker-ssh/blob/main/LICENSE" target="_blank"><img src="https://badgen.net/github/license/serversideup/docker-ssh" alt="License"></a>
	<a href="https://github.com/sponsors/serversideup"><img src="https://badgen.net/badge/icon/Support%20Us?label=GitHub%20Sponsors&color=orange" alt="Support us"></a>
	<a href="https://community.serversideup.net"><img alt="Discourse users" src="https://img.shields.io/discourse/users?color=blue&server=https%3A%2F%2Fcommunity.serversideup.net"></a>
  <a href="https://serversideup.net/discord"><img alt="Discord" src="https://img.shields.io/discord/910287105714954251?color=blueviolet"></a>
</p>

## Introduction
`serversideup/docker-ssh` is a hardened SSH server container based on Debian. It works great if you need to create a secure tunnel into your cluster.

## Features
- 🐧 **Debian-based** - Get a lightweight experience, while still having Bash
- 🤝 **Key-based auth via ENV** - Grant access with the `AUTHORIZED_KEYS` environment variable
- ⛔️ **Block IPs via ENV** - Block access with the `ALLOWED_IPS` environment variable
- 🔒 **Unprivileged user** - All SSH connections are made as an unprivileged user
- 🔑 **Set your own PUID and PGID** - Have the PUID and PGID match your host user
- 🔐 **Hardened SSH** - Prevent bot attacks and ensure quality security
- 📦 **DockerHub and GitHub Container Registry** - Choose where you'd like to pull your image from
- 🤖 **Multi-architecture** - Every image ships with x86_64 and arm64 architectures

## Usage
This is a list of the docker images this repository creates:

| Image | Image Size | Description |
| --------- | -------------------- | ----------- |
| `serversideup/docker-ssh` |[![DockerHub serversideup/docker-ssh](https://img.shields.io/docker/image-size/serversideup/docker-ssh/latest?label=latest)](https://hub.docker.com/r/serversideup/docker-ssh) | A hardened SSH server based on Debian Bookworm. |

## Usage instructions
All variables are documented here:

**🔀 Variable Name**|**📚 Description**|**#️⃣ Default Value**
:-----:|:-----:|:-----:
ALLOWED_IPS| Content of allowed IP addresses (see below)| `AllowUsers tunnel` (allow the `tunnel` user from any IP) |
AUTHORIZED_KEYS|🚨 <b>Required to be set by you.</b> Content of your authorized keys file (see below)|  |
DEBUG|Display a bunch of helpful content for debugging.|false
PGID|Group ID the SSH user should run as.|9999
PUID|User ID the SSH user should run as.|9999
SSH_GROUP|Group name used for our SSH user.|`tunnelgroup`
SSH_HOST_KEY_DIR|Location of where the SSH host keys should be stored.|`/etc/ssh/ssh_host_keys/`
SSH_PORT|Listening port for SSH server (on container only. You'll still need to publish this port).|`2222`
SSH_USER|Username for the SSH user that other users will connect into as.|`tunnel`


### 1. Set your `AUTHORIZED_KEYS` environment variable or provide a `/authorized_keys` file
You can provide multiple keys by loading the contents of a file into an environment variable.
```
AUTHORIZED_KEYS="$(cat .ssh/my_many_ssh_public_keys_in_one_file.txt)"
```

Or you can provide the `authorized_keys` file via a volume. Ensure the volume references matches the path of `/authorized_keys`. The image will automatically take the file from `/authorized_keys` and configure it for use with your selected user.

ℹ️ **NOTE:** If both a file and variable are provided, the image will respect the value of the **variable _over_ the file**.

### 2. Set your `ALLOWED_IPS` environment variable
Set this in the same context of [AllowUsers](https://www.ssh.com/academy/ssh/sshd_config)This example shows a few scenarios you can do:
```
ALLOWED_IPS="AllowUsers *@192.168.1.0/24 *@172.16.0.1 *@10.0.*.1"
```

### 3. Forward your external port to `2222` on the container
You can see I'm forwarding `12345` to `2222`.
```
docker run --rm --name=ssh --network=web -p 12345:2222 localhost/ssh
```
This means I would connect with:
```
ssh -p 12345 tunnel@myserver.test
```

# Working example with MariaDB + SSH + Docker Swarm
Here's a perfect example how you can use it with MariaDB. This allows you to use Sequel Pro or TablePlus to connect securely into your database server 🥳

### Example using `ALLOWED_IPS` variable:
```yaml
services:
  mariadb:
    image: mariadb:10.11
    networks:
      - database
    environment:
        MARIADB_ROOT_PASSWORD: "myrootpassword"
  ssh:
    image: serversideup/docker-ssh
    ports:
      - target: 2222
        published: 2222
        mode: host
    # Set the Authorized Keys of who can connect
    environment:
      AUTHORIZED_KEYS: >
        "# Start Keys
         ssh-ed25519 1234567890abcdefghijklmnoqrstuvwxyz user-a
         ssh-ed25519 abcdefghijklmnoqrstuvwxyz1234567890 user-b
         # End Keys"
      # Lock down the access to certain IP addresses
      ALLOWED_IPS: "AllowUsers tunnel@1.2.3.4"
    networks:
        - database

networks:
  database:
```

### Example using `$SSH_USER_HOME/.ssh/authorized_keys` file:
```yaml
services:
  mariadb:
    image: mariadb:10.11
    networks:
      - database
    environment:
        MARIADB_ROOT_PASSWORD: "myrootpassword"

  ssh:
    image: serversideup/docker-ssh
    ports:
      - target: 2222
        published: 2222
        mode: host
    # Set the Authorized Keys of who can connect
    environment:
      # Lock down the access to certain IP addresses
      ALLOWED_IPS: "AllowUsers tunnel@1.2.3.4"
    configs:
      - source: ssh_authorized_keys
        # Mount the file to "/authorized_keys". The image will handle everything else
        target: /authorized_keys
        mode: 0600
    networks:
        - database

# Define the config to be used
configs:
  ssh_authorized_keys:
    file: ./authorized_keys

networks:
  database:
```

## Resources
- **[DockerHub](https://hub.docker.com/r/serversideup/ansible)** to browse the images.
- **[Discord](https://serversideup.net/discord)** for friendly support from the community and the team.
- **[GitHub](https://github.com/serversideup/docker-ssh)** for source code, bug reports, and project management.
- **[Get Professional Help](https://serversideup.net/professional-support)** - Get video + screen-sharing help directly from the core contributors.

## Contributing
As an open-source project, we strive for transparency and collaboration in our development process. We greatly appreciate any contributions members of our community can provide. Whether you're fixing bugs, proposing features, improving documentation, or spreading awareness - your involvement strengthens the project. Please review our [code of conduct](./.github/code_of_conduct.md) to understand how we work together respectfully.

- **Bug Report**: If you're experiencing an issue while using these images, please [create an issue](https://github.com/serversideup/docker-ssh/issues/new/choose).
- **Feature Request**: Make this project better by [submitting a feature request](https://github.com/serversideup/docker-ssh/discussions/).
- **Documentation**: Improve our documentation by [submitting a documentation change](./README.md).
- **Community Support**: Help others on [GitHub Discussions](https://github.com/serversideup/docker-ssh/discussions) or [Discord](https://serversideup.net/discord).
- **Security Report**: Report critical security issues via [our responsible disclosure policy](https://www.notion.so/Responsible-Disclosure-Policy-421a6a3be1714d388ebbadba7eebbdc8).

Need help getting started? Join our Discord community and we'll help you out!

<a href="https://serversideup.net/discord"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/join-discord.svg" title="Join Discord"></a>

## Our Sponsors
All of our software is free an open to the world. None of this can be brought to you without the financial backing of our sponsors.

<p align="center"><a href="https://github.com/sponsors/serversideup"><img src="https://521public.s3.amazonaws.com/serversideup/sponsors/sponsor-box.png" alt="Sponsors"></a></p>

### Black Level Sponsors
<a href="https://sevalla.com"><img src="https://serversideup.net/wp-content/uploads/2024/10/sponsor-image.png" alt="Sevalla" width="546px"></a>

#### Bronze Sponsors
<!-- bronze -->No bronze sponsors yet. <a href="https://github.com/sponsors/serversideup">Become a sponsor →</a><!-- bronze -->

#### Individual Supporters
<!-- supporters --><a href="https://github.com/aagjalpankaj"><img src="https://github.com/aagjalpankaj.png" width="40px" alt="aagjalpankaj" /></a>&nbsp;&nbsp;<!-- supporters -->

## About Us
We're [Dan](https://twitter.com/danpastori) and [Jay](https://twitter.com/jaydrogers) - a two person team with a passion for open source products. We created [Server Side Up](https://serversideup.net) to help share what we learn.

<div align="center">

| <div align="center">Dan Pastori</div>                  | <div align="center">Jay Rogers</div>                                 |
| ----------------------------- | ------------------------------------------ |
| <div align="center"><a href="https://twitter.com/danpastori"><img src="https://serversideup.net/wp-content/uploads/2023/08/dan.jpg" title="Dan Pastori" width="150px"></a><br /><a href="https://twitter.com/danpastori"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/twitter.svg" title="Twitter" width="24px"></a><a href="https://github.com/danpastori"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/github.svg" title="GitHub" width="24px"></a></div>                        | <div align="center"><a href="https://twitter.com/jaydrogers"><img src="https://serversideup.net/wp-content/uploads/2023/08/jay.jpg" title="Jay Rogers" width="150px"></a><br /><a href="https://twitter.com/jaydrogers"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/twitter.svg" title="Twitter" width="24px"></a><a href="https://github.com/jaydrogers"><img src="https://serversideup.net/wp-content/themes/serversideup/images/open-source/github.svg" title="GitHub" width="24px"></a></div>                                       |

</div>

### Find us at:

* **📖 [Blog](https://serversideup.net)** - Get the latest guides and free courses on all things web/mobile development.
* **🙋 [Community](https://community.serversideup.net)** - Get friendly help from our community members.
* **🤵‍♂️ [Get Professional Help](https://serversideup.net/professional-support)** - Get video + screen-sharing support from the core contributors.
* **💻 [GitHub](https://github.com/serversideup)** - Check out our other open source projects.
* **📫 [Newsletter](https://serversideup.net/subscribe)** - Skip the algorithms and get quality content right to your inbox.
* **🐥 [Twitter](https://twitter.com/serversideup)** - You can also follow [Dan](https://twitter.com/danpastori) and [Jay](https://twitter.com/jaydrogers).
* **❤️ [Sponsor Us](https://github.com/sponsors/serversideup)** - Please consider sponsoring us so we can create more helpful resources.

## Our products
If you appreciate this project, be sure to check out our other projects.

### 📚 Books
- **[The Ultimate Guide to Building APIs & SPAs](https://serversideup.net/ultimate-guide-to-building-apis-and-spas-with-laravel-and-nuxt3/)**: Build web & mobile apps from the same codebase.
- **[Building Multi-Platform Browser Extensions](https://serversideup.net/building-multi-platform-browser-extensions/)**: Ship extensions to all browsers from the same codebase.

### 🛠️ Software-as-a-Service
- **[Bugflow](https://bugflow.io/)**: Get visual bug reports directly in GitHub, GitLab, and more.
- **[SelfHost Pro](https://selfhostpro.com/)**: Connect Stripe or Lemonsqueezy to a private docker registry for self-hosted apps.

### 🌍 Open Source
- **[AmplitudeJS](https://521dimensions.com/open-source/amplitudejs)**: Open-source HTML5 & JavaScript Web Audio Library.
- **[Spin](https://serversideup.net/open-source/spin/)**: Laravel Sail alternative for running Docker from development → production.
- **[Financial Freedom](https://github.com/serversideup/financial-freedom)**: Open source alternative to Mint, YNAB, & Monarch Money.
