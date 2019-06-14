#!/usr/bin/env bash

set -e  # Fail on errors

# Ensure config folder and file exist
DOCKSAL_GLOBAL_CONFIG=~/.docksal/docksal.env
mkdir -p $(dirname ${DOCKSAL_GLOBAL_CONFIG})
touch ${DOCKSAL_GLOBAL_CONFIG}

# Check whether a global variable has been already set
is_conf_set () {
	grep -q "$1" ${DOCKSAL_GLOBAL_CONFIG}
}

# Docker for Mac/Windows install mode support
if [[ "$DOCKER_NATIVE" != "" ]] && ! is_conf_set "DOCKER_NATIVE"; then
	echo 'Enabling native mode (Docker for Mac/Windows)...'
	echo 'DOCKER_NATIVE=1' >> ${DOCKSAL_GLOBAL_CONFIG}
fi

# Sandbox Server install mode support
if [[ "$CI" != "" ]] && ! is_conf_set "CI"; then
	echo 'Enabling Sandbox Server installation mode...'
	echo 'CI=1' >> ${DOCKSAL_GLOBAL_CONFIG}
fi

# Katacoda mode support
if [[ "$KATACODA" != "" ]] && ! is_conf_set "KATACODA"; then
	echo 'Enabling Katacoda installation mode...'
	echo 'KATACODA=1' >> ${DOCKSAL_GLOBAL_CONFIG}
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
	echo "           For more information, see https://docs.docksal.io/getting-started/setup/#install"
	sleep 1
fi

sudo mkdir -p /usr/local/bin &&
	sudo curl -fsSL "https://raw.githubusercontent.com/docksal/docksal/${DOCKSAL_VERSION}/bin/fin?r=${RANDOM}" -o /usr/local/bin/fin &&
	sudo chmod +x /usr/local/bin/fin &&
	fin update
