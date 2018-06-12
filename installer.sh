#!/usr/bin/env sh

# Docker for Mac/Windows install mode support
if [ "$DOCKER_NATIVE" != "" ]; then
	echo 'Enabling native mode (Docker for Mac/Windows)...'
	# Add the switch to the global docksal.env file
	mkdir -p ~/.docksal &&
		touch ~/.docksal/docksal.env &&
		echo 'DOCKER_NATIVE=1' >> ~/.docksal/docksal.env
fi

# Sandbox Server install mode support
if [ "$CI" != "" ]; then
	echo 'Enabling Sandbox Server installation mode...'
	# Add the switch to the global docksal.env file
	mkdir -p ~/.docksal &&
		touch ~/.docksal/docksal.env &&
		echo 'CI=1' >> ~/.docksal/docksal.env
fi

# Katacoda mode support
if [ "$KATACODA" != "" ]; then
	echo 'Enabling Katacoda installation mode...'
	# Add the switch to the global docksal.env file
	mkdir -p ~/.docksal &&
		touch ~/.docksal/docksal.env &&
		echo 'KATACODA=1' >> ~/.docksal/docksal.env
fi

# Allow installing a specific version
export DOCKSAL_VERSION="${DOCKSAL_VERSION:-master}"

sudo mkdir -p /usr/local/bin &&
	sudo curl -fsSL "https://raw.githubusercontent.com/docksal/docksal/${DOCKSAL_VERSION}/bin/fin" -o /usr/local/bin/fin &&
	sudo chmod +x /usr/local/bin/fin &&
	fin update
