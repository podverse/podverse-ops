FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# Update the package listing, so we know what package exist:
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends podman slirp4netns systemd uidmap \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Create symbolic link so docker commands are handled as podman commands
RUN ln -s /usr/bin/podman /usr/bin/docker

RUN adduser --disabled-login --gecos api_user api_user