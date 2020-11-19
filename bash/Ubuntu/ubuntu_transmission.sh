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
  echo "sudo ./ubuntu_transmission.sh remove 1,4,6,9 (Run the status command to see the Torrent IDs)"
  echo "Remove Completed Torrent"
  echo "sudo ./ubuntu_transmission.sh remove_complete"
  echo "Change Download Directory"
  echo "sudo ./ubuntu_transmission.sh set_download_path <fullpath_download_directory> <optional_incomplete_download_directory>"
  echo "Download Status"
  echo "sudo ./ubuntu_transmission.sh status"
  echo "Constant Status Update"
  echo "watch ./ubuntu_transmission.sh status"
  echo "Stop Daemon"
  echo "sudo ./ubuntu_transmission.sh stop"
}

# Install Transmission.
function install() {
  echo "Installing Transmission"
  sudo apt update
  sudo apt install transmission-qt transmission-cli transmission-daemon -y
  mkdir /home/${USER}/Torrents/ || echo "Directory /home/${USER}/Torrents/ already exists"
  #transmission-daemon --download-dir ~/Torrents/
  sudo /etc/init.d/transmission-daemon stop
  sudo sed -i "s/\"download-dir\": \"\/var\/lib\/transmission-daemon\/downloads\"/\"download-dir\": \"\/media\/${USER}\/movies\/Torrents\/Complete\"/" /etc/transmission-daemon/settings.json
  sudo sed -i "s/\"incomplete-dir\": \"\/var\/lib\/transmission-daemon\/Downloads\"/\"incomplete-dir\": \"\/media\/${USER}\/movies\/Torrents\/Downloading\"/" /etc/transmission-daemon/settings.json
  sudo sed -i 's/"rpc-authentication-required": true/"rpc-authentication-required": false/' /etc/transmission-daemon/settings.json
  sudo mkdir -p /etc/systemd/system/transmission-daemon.service.d/
  printf "[Service]\nEnvironment=TRANSMISSION_HOME=/etc/transmission-daemon" | sudo tee -a /etc/systemd/system/transmission-daemon.service.d/override.conf
  sudo transmission-remote -w "/home/${USER}/Torrents"
  # Add User to the debian-transmission group
  sudo usermod -a -G debian-transmission ${USER}
  # Change the folder ownership
  sudo chgrp debian-transmission /home/${USER}/Torrents
  # Grant write access to the group
  sudo chmod 770 /home/${USER}/Torrents
  sudo service transmission-daemon stop
  sudo sed -i 's/"umask": 18/"umask": 2/' /etc/transmission-daemon/settings.json
  sudo /etc/init.d/transmission-daemon restart
  sudo systemctl daemon-reload
  sudo adduser debian-transmission users
  sudo service transmission-daemon start
  sudo transmission-remote -l
}

# Set Download Path
function set_download_path() {
  if [[ "${#download_args[@]}" -le 1 ]] ; then    
    incomplete_dir=$1   
  else
    incomplete_dir=$2  
  fi
  download_dir=$1
  echo "Setting download directory ${download_dir}"
  #sudo /etc/init.d/transmission-daemon stop || echo "Already Stopped"
  sudo sed -i "s#download-dir[\"].*#download-dir\": \"${download_dir}\",#" /etc/transmission-daemon/settings.json
  sudo sed -i "s#incomplete-dir[\"].*#incomplete-dir\": \"${incomplete_dir}\",#" /etc/transmission-daemon/settings.json
  sudo transmission-remote -w "${download_dir}"
  echo 'Successfully updated download directory/(ies)'
  sudo /etc/init.d/transmission-daemon restart
  sudo systemctl daemon-reload
  sudo transmission-remote -l
}

# Load Transmission Daemon
function load() {
  sudo transmission-daemon
}

# Stop Transmission Daemon
function stop() {
  sudo transmission-remote --exit
  killall transmission-daemon
}

# Add Torrent
function add() {
  echo "Adding $1"
  sudo transmission-remote -a "${1}"
}

# Remove Torrent
function remove() {
  echo "Removing $1"
  sudo transmission-remote -t "${1}" -r
}

# Remove Torrent
function remove_complete() {
  echo "Removing Completed Torrents"
  sudo transmission-remote -t "${1}" -r
}

# Check Status of Torrents
function status() {
  sudo transmission-remote -l
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
  elif [[ ${args[0]} == "remove_complete" ]] ; then
    remove_complete
  elif [[ ${args[0]} == "status" ]] ; then
    status
  elif [[ ${args[0]} == "stop" ]] ; then
    stop
  elif [[ ${args[0]} == "set_download_path" ]] ; then
    set_download_path "${args[1]}" "${args[2]}"
  else
    usage
  fi
}

args=("$@")
main
