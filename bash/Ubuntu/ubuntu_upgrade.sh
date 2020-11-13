#!/bin/bash

# Updating packages from repositories.
sudo apt update
# Install update manager
sudo apt install update-manager-core
# Upgrading Packages.
sudo apt dist-upgrade -y

# House Cleaning
# The first line will remove/fix any residual/broken packages if any.
sudo apt --purge autoremove
# The clean command removes all old .deb files from the apt cache (/var/cache/apt/archives)
sudo apt clean all
# Removes package configurations left over from packages that have been removed (but not purged).
sudo apt purge $(dpkg -l | awk '/^rc/ { print $2 }')

# Upgrading OS
sudo do-release-upgrade