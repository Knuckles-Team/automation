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
  echo "Download Status"
  echo "sudo ./ubuntu_transmission.sh status"
}

# Install Transmission.
function install() {
  echo "Installing Transmission"
  sudo apt update
  sudo apt install transmission-qt transmission-cli transmission-daemon -y
  mkdir ~/Torrents/ || echo "Directory ~/Torrents/ already exists"
  transmission-daemon --download-dir ~/Torrents/
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
  fi
}

args=("$@")
main
