#!/bin/bash

# This script will retitle all .mkv/.mp4 metadata to their file names. Will also rename directories to the file name
function usage(){
  echo -e "Flags:\n"
  echo -e "-h | --help [Help]\n-i | --install [Install dependencies]\n-d | --download_directory [Set the download directory]\n-f | --file <FILE> [Read links from textfile]\n-l | --links <LINK1, LINK2, LINK3> [Read links from command prompt]\n-a | --audio [Downloads audio only]"
  echo -e "\nUsage: \nHelp: "
  echo "./video_download.sh -h"
  echo "./video_download.sh --help"
  echo -e "\nInstall:"
  echo "sudo ./video_download.sh -i"
  echo "sudo ./video_download.sh --install"
  echo -e "\nDownload with file: "
  echo "./video_download.sh -f <FILE>"
  echo "./video_download.sh --file <FILE>"
  echo -e "\nDownload with links: "
  echo "./video_download.sh -l <LINK1,LINK2,LINK3>"
  echo "./video_download.sh -l <LINK1, LINK2, LINK3>"
  echo "./video_download.sh --links <LINK1,LINK2,LINK3>"
  echo "./video_download.sh --links <LINK1, LINK2, LINK3>"
  echo -e "\nSet Download Directory: "
  echo -e "./video_download.sh -l <LINK1, LINK2> -f <FILE> -d \"~/Downloads\"\n"
}

function detect_os(){
  os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  os_version="${os_version:1:-1}"
  echo "${os_version}"
  if [[ $os_version = "Ubuntu" ]] ; then
    echo "Installing for Ubuntu"
    ubuntu_install
  elif [[ $os_version = "CentOS Linux" ]] ; then
    echo "Installing for CentOS"
    centos_install
  else 
    echo "Distribution ${os_version} not supported"
  fi
}

function ubuntu_install(){
  sudo apt update
  sudo apt install -y youtube-dl
}

function centos_install(){
  sudo yum update -y
  sudo yum install youtube-dl -y
}

function python_install(){
  sudo pip3 install youtube-dl
}

function download(){
  echo "Beginning downloading"
  for link in "${links[@]}"
  do
    if [[ -n $( echo "${link}" | grep 'https://rumble.com' ) ]]; then
      echo "Downloading Rumble Video: ${link}"
      if [[ "${audio_flag}" == "true" ]]; then
        youtube-dl -x --audio-format mp3 --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" -f best/bestaudio "$(curl -s "${link}" | tr -d '\n'|awk -F "embedUrl" '{print $2}'|awk -F '"' '{print $3}')" &
      else
        youtube-dl --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" -f mp4-1080p/mp4-720p/mp4-480p/webm-480p/mp4-360p/ "$(curl -s "${link}" | tr -d '\n'|awk -F "embedUrl" '{print $2}'|awk -F '"' '{print $3}')" &
      fi
    elif [[ -n $( echo "${link}" | grep 'youtube' ) ]] || [[ -n $( echo "${link}" | grep 'https://www.youtube.com' ) ]] ; then
      echo "Downloading YouTube Video: ${link}"
      if [[ "${audio_flag}" == "true" ]]; then
        youtube-dl -x --audio-format mp3 -f best/bestaudio --write-description --write-info-json --write-annotations --write-sub --write-thumbnail --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" &
      else
        youtube-dl -f best --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" &
      fi
    elif [[ -n $( echo "${link}" | grep 'bitchute' ) ]] || [[ -n $( echo "${link}" | grep 'https://www.bitchute.com' ) ]] ; then
      echo "Downloading YouTube Video: ${link}"
      if [[ "${audio_flag}" == "true" ]]; then
        youtube-dl -x --audio-format mp3 -f best/bestaudio --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" &
      else
        youtube-dl -f best --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" &
      fi
    elif [[ -n $( echo "${link}" | grep 'twitter' ) ]] || [[ -n $( echo "${link}" | grep 'https://www.twitter.com' ) ]] ; then
      echo "Downloading YouTube Video: ${link}"
      if [[ "${audio_flag}" == "true" ]]; then
        youtube-dl -x --audio-format mp3 -f best/bestaudio --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" &
      else
        youtube-dl -f best --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" || youtube-dl -f best --no-check-certificate  -o "${download_dir}/%(id)s.%(ext)s" "${link}" &
      fi
    else
      if [[ "${title}" == "" ]]; then
        youtube-dl -f best --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" &
      else
        youtube-dl -f best --no-check-certificate -o "${download_dir}/${title}.%(ext)s" "${link}" &
      fi
    fi
  done
}

if [ -z "$1" ]; then
  usage
  exit 0
fi

links=[]
audio_flag='false'
download_dir="~/Downloads"
title=""
while test -n "$1"; do
  case "$1" in
    a | -a | --audio)
      audio_flag='true'
      shift
      ;;
    h | -h | --help)
      usage
      exit 0
      ;;
    i | -i | --install)
      echo "Installing"
      detect_os
      exit 0
      shift
      ;;
    d | -d | --download-directory)
      echo -e "1: ${1}\n2: ${2}"
      if [ "${2}" ]; then
        download_dir="${2}"
        shift
      else
        echo 'ERROR: "-d | --download-directory" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    l | -l | --links)
      echo -e "1: $1\n2: $2"
      if [ "${2}" ]; then
        IFS=',' read -r -a links_direct2 <<< "${2}"
        links=( "${links_direct1[@]}" "${links_direct2[@]}" )
        shift
      else
        echo 'ERROR: "-l | --links" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    f | -f | --file)
      if [ "${2}" ]; then
        file="${2}"
        IFS=$'\n' read -d '' -r -a file_links < "${file}"
        links=( "${links[@]}" "${file_links[@]}" )
        shift
      else
        echo 'ERROR: "-f | --file" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    t | -t | --title)
      if [ "${2}" ]; then
        title="${2}"
        shift
      else
        echo 'ERROR: "-t | --title" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    --)# End of all options.
      shift
      break
      ;;
    -?*)
      printf 'WARNING: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *)
      shift
      break
      ;;
  esac
done

download
