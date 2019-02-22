#!/usr/bin/env bash

# Docker for Mac/Windows install mode support
if [[ "$DOCKER_NATIVE" != "" ]]; then
	echo 'Enabling native mode (Docker for Mac/Windows)...'
	# Add the switch to the global docksal.env file
	mkdir -p ~/.docksal &&
		touch ~/.docksal/docksal.env &&
		echo 'DOCKER_NATIVE=1' >> ~/.docksal/docksal.env
fi

# Sandbox Server install mode support
if [[ "$CI" != "" ]]; then
	echo 'Enabling Sandbox Server installation mode...'
	# Add the switch to the global docksal.env file
	mkdir -p ~/.docksal &&
		touch ~/.docksal/docksal.env &&
		echo 'CI=1' >> ~/.docksal/docksal.env
fi

# Katacoda mode support
if [[ "$KATACODA" != "" ]]; then
	echo 'Enabling Katacoda installation mode...'
	# Add the switch to the global docksal.env file
	mkdir -p ~/.docksal &&
		touch ~/.docksal/docksal.env &&
		echo 'KATACODA=1' >> ~/.docksal/docksal.env
fi

# Allow installing a specific version
export DOCKSAL_VERSION="${DOCKSAL_VERSION:-master}"

is_sudo_granted () {
	# -S tells sudo to read password from stdin, -v just does "sudo nothing"
	# If sudo token is already generated this command will succeed
	# If no token is vaid, this command will fail since echo feeds empty password into sudo
	echo | sudo -Sv >/dev/null 2>&1
}

if ! is_sudo_granted; then
	echo "ATTENTION: Installer requires administrative privileges to continue with Docksal setup."
	echo "           On macOS and Linux please enter your current user password,"
	echo "           in Ubuntu App for Windows 10 use Linux user password in this step."
	echo "           For more information, see https://docs.docksal.io/getting-started/setup/."
	sleep 1
fi

sudo mkdir -p /usr/local/bin &&
	sudo curl -fsSL "https://raw.githubusercontent.com/docksal/docksal/${DOCKSAL_VERSION}/bin/fin" -o /usr/local/bin/fin &&
	sudo chmod +x /usr/local/bin/fin &&
	fin update
