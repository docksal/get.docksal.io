#!/usr/bin/env sh

# Dependency versions
DOCKER_VERSION='17.06.0-ce'
DOCKER_COMPOSE_VERSION='1.14.0'
DOCKER_MACHINE_VERSION='0.12.0'
VBOX_VERSION='5.1.26'
VBOX_BUILD="${VBOX_VERSION}-117224"
BABUN_VERSION='1.2.0'
WINPTY_VERSION='0.4.3'
WINPTY_CYGWIN_VERSION='2.8.0'

# Image versions
DOCKSAL_IMAGE_DNS='docksal/dns:1.0'
DOCKSAL_IMAGE_SSH_AGENT='docksal/ssh-agent:1.0'
DOCKSAL_IMAGE_VHOST_PROXY='docksal/vhost-proxy:1.1'
DOCKSAL_IMAGE_WEB='docksal/web:2.1-apache2.4'
DOCKSAL_IMAGE_DB='docksal/db:1.1-mysql-5.6'
DOCKSAL_IMAGE_CLI='docksal/cli:1.3-php7'

# Console colors
red='\033[0;91m'
green='\033[0;32m'
yellow='\033[1;33m'
NC='\033[0m'

echo_red () { echo "${red}$1${NC}"; }
echo_green () { echo "${green}$1${NC}"; }
echo_yellow () { echo "${yellow}$1${NC}"; }

# macOS dependencies list
read -r -d '' deps_mac <<EOF
http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VirtualBox-${VBOX_BUILD}-OSX.dmg
https://download.docker.com/mac/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz
https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Darwin-x86_64
https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-Darwin-x86_64
EOF

# Windows dependencies list
read -r -d '' deps_win <<EOF
http://dl.bintray.com/tombujok/babun/babun-${BABUN_VERSION}-dist.zip
http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VirtualBox-${VBOX_BUILD}-Win.exe
https://download.docker.com/win/static/stable/x86_64/docker-${DOCKER_VERSION}.zip
https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Windows-x86_64.exe
https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-Windows-x86_64.exe
https://github.com/rprichard/winpty/releases/download/${WINPTY_VERSION}/winpty-${WINPTY_VERSION}-cygwin-${WINPTY_CYGWIN_VERSION}-ia32.tar.gz
EOF

# Common dependencies list
read -r -d '' deps_common <<EOF
https://github.com/boot2docker/boot2docker/releases/download/v${DOCKER_VERSION}/boot2docker.iso
EOF

# System image list
read -r -d '' images_system <<EOF
${DOCKSAL_IMAGE_DNS}
${DOCKSAL_IMAGE_SSH_AGENT}
${DOCKSAL_IMAGE_VHOST_PROXY}
EOF

# Default stack image list
read -r -d '' images_stack <<EOF
${DOCKSAL_IMAGE_WEB}
${DOCKSAL_IMAGE_DB}
${DOCKSAL_IMAGE_CLI}
EOF

# Download a list of files
# param $1 list of files (one per line)
download ()
{
	local filename
	while read -r item; do
		filename=$(basename ${item})
		if [[ ! -f ${filename} ]]; then
			echo "${filename}..."
			curl -fLO# "${item}"
		else
			echo_yellow "${filename} exists, skipping."
		fi
	done <<< "$1"
}

# Pull a list of images from Docker Hub
# param $1 list of images (one per line)
pull ()
{
	while read -r item; do
		fin docker pull ${item}
	done <<< "$1"
}

# Allow skipping this step (curl -L get.docksal.io | SKIP_DEPS=1 sh)
if [[ "$SKIP_DEPS" == "" ]]; then
	echo_green "Downloading macOS dependencies"
	download "$deps_mac"
	echo_green "Downloading Windows dependencies"
	download "$deps_win"
	echo_green "Downloading common dependencies"
	download "$deps_common"
fi

# Allow skipping this step (curl -L get.docksal.io | SKIP_IMAGES=1 sh)
if [[ "$SKIP_IMAGES" == "" ]]; then
	echo_green "Pulling Docksal system images..."
	pull "$images_system"
	echo_green "Pulling Docksal default stack images..."
	pull "$images_stack"

	echo_green "Saving Docksal system images..."
	fin docker save $(echo "$images_system" | tr '\n' ' ') -o docksal-system-images.tar
	echo_green "Saving Docksal default stack images..."
	fin docker save $(echo "$images_stack" | tr '\n' ' ') -o docksal-default-images.tar
fi
