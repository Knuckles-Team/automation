#!/bin/bash

# This script will retitle all .mkv/.mp4 metadata to their file names. Will also rename directories to the file name
function usage() {
  echo "Usage: "
  echo "Install Transmission"
  echo "sudo ./ubuntu_transmission.sh install"
  echo "Start the client"
  echo "sudo ./ubuntu_transmission.sh load"
  echo "Add Links [Magnet or Torrent] or File Locations"
  echo "sudo ./ubuntu_transmission.sh add <link>"
  echo "Remove Torrent"
  echo "sudo ./ubuntu_transmission.sh remove <#> (Run the status command to see the Torrent IDs)"
  echo "Change Download Directory"
  echo "sudo ./ubuntu_transmission.sh set_download_path"
  echo "Download Status"
  echo "sudo ./ubuntu_transmission.sh status"
  echo "Stop Daemon"
  echo "sudo ./ubuntu_transmission.sh stop"
}

# Install Transmission.
function install() {
  echo "Installing Transmission"
  sudo apt update
  sudo apt install transmission-qt transmission-cli transmission-daemon -y
  mkdir ~/Torrents/ || echo "Directory ~/Torrents/ already exists"
  #transmission-daemon --download-dir ~/Torrents/
  /etc/init.d/transmission-daemon stop
  sudo sed -i "s/\"download-dir\": \"\/var\/lib\/transmission-daemon\/downloads\"/\"download-dir\": \"\/media\/${USER}\/movies\/Torrents\/Complete\"/" /etc/transmission-daemon/settings.json
  sudo sed -i "s/\"incomplete-dir\": \"\/var\/lib\/transmission-daemon\/Downloads\"/\"incomplete-dir\": \"\/media\/${USER}\/movies\/Torrents\/Downloading\"/" /etc/transmission-daemon/settings.json
  sudo sed -i 's/"rpc-authentication-required": true/"rpc-authentication-required": false/' /etc/transmission-daemon/settings.json
  sudo mkdir -p /etc/systemd/system/transmission-daemon.service.d/
  printf "[Service]\nEnvironment=TRANSMISSION_HOME=/etc/transmission-daemon" | sudo tee -a /etc/systemd/system/transmission-daemon.service.d/override.conf
  /etc/init.d/transmission-daemon restart
  sudo systemctl daemon-reload
  transmission-remote -l
}

# Set Download Path
function set_download_path() {
  /etc/init.d/transmission-daemon stop
  sudo sed -i "s/\"download-dir\": \"\/var\/lib\/transmission-daemon\/downloads\"/\"download-dir\": ${1}/" /etc/transmission-daemon/settings.json
  sudo sed -i "s/\"incomplete-dir\": \"\/var\/lib\/transmission-daemon\/Downloads\"/\"incomplete-dir\": ${1}/" /etc/transmission-daemon/settings.json
  sudo sed -i 's/"rpc-authentication-required": true/"rpc-authentication-required": false/' /etc/transmission-daemon/settings.json
  /etc/init.d/transmission-daemon restart
  sudo systemctl daemon-reload
  transmission-remote -l
}

# Load Transmission Daemon
function load() {
  transmission-daemon
}

# Stop Transmission Daemon
function stop() {
  transmission-remote --exit
  killall transmission-daemon
}

# Add Torrent
function add() {
  load
  echo "Adding $1"
  transmission-remote -a "${1}"
}

# Remove Torrent
function remove() {
  echo "Removing $1"
  transmission-remote -t "${1}" -r
}

# Check Status of Torrents
function status() {
  transmission-remote -l
}

# Main Function
function main() {
  if [[ "${#args[@]}" -le 0 ]] ; then
    usage    
    exit 0
  elif [[ ${args[0]} == "install" ]] ; then
    install
  elif [[ ${args[0]} == "load" ]] ; then
    load
  elif [[ ${args[0]} == "add" ]] ; then
    add "${args[1]}"
  elif [[ ${args[0]} == "remove" ]] ; then
    remove "${args[1]}"
  elif [[ ${args[0]} == "status" ]] ; then
    status
  elif [[ ${args[0]} == "stop" ]] ; then
    stop
  elif [[ ${args[0]} == "set_download_path" ]] ; then
    set_download_path
  fi
}

args=("$@")
main
