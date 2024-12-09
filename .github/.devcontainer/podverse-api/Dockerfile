FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm
# TODO switch to this before merging
# FROM ghcr.io/podverse/podverse-web-dev:latest

# Update the package listing, so we know what package exist:
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends podman slirp4netns systemd uidmap \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Create symbolic link so docker commands are handled as podman commands
RUN ln -s /usr/bin/podman /usr/bin/docker

# create api_user but don't set the container user
RUN adduser --disabled-login --gecos api_user api_user

LABEL org.opencontainers.image.source=https://github.com/podverse/podverse-ops
LABEL org.opencontainers.image.description="Podverse API Devcontainer"
LABEL org.opencontainers.image.licenses=AGPLv3
