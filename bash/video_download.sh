#!/bin/bash

# This script will retitle all .mkv/.mp4 metadata to their file names. Will also rename directories to the file name
function usage(){
  echo -e "
Information:
This script will download videos from YouTube, Rumble, BitChute, Twitter, Televika, and other websites.

Flags:
-h | h | --help                           Show Usage and Flags
-i | i | --install                        Install all dependencies
-d | d | --download-directory <directory> Rename the file based on regex matching
-f | f | --file <FILENAME.txt>            Read links from textfile
-l | l | --links <LINK1,LINK2,LINK3>      Read links from command prompt
-a | a | --audio                          Downloads audio only

Usage:
./video_download.sh -i
./video_download.sh --install
./video_download.sh install
./video_download.sh --file <FILE>
./video_download.sh --links <LINK1,LINK2,LINK3>
./video_download.sh -l <LINK1, LINK2> -f <FILE> -d \"~/Downloads\""
}

function install_dependencies(){
  os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  os_version="${os_version:1:-1}"
  echo "${os_version}"
  if [[ $os_version = "Ubuntu" ]] ; then
    echo "Installing for Ubuntu"
    sudo apt update
    sudo apt install -y python3 python3-pip
    python3 -m pip install --upgrade pip
    python3 -m pip install youtube-dl
  elif [[ $os_version = "CentOS Linux" ]] ; then
    echo "Installing for CentOS"
    sudo yum update -y
    sudo yum install youtube-dl -y
  else 
    echo "Distribution ${os_version} not supported"
  fi
  sudo python3 -m pip install youtube-dl
}

function download(){
  link="${1}"
  if [[ -n $( echo "${link}" | grep 'https://rumble.com' ) ]]; then
    #echo "Downloading Rumble Video: ${link}"
    if [[ "${audio_flag}" == "true" ]]; then
      youtube-dl -x --audio-format mp3 --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" -f best/bestaudio "$(curl -s "${link}" | tr -d '\n'|awk -F "embedUrl" '{print $2}'|awk -F '"' '{print $3}')" >> /dev/null || youtube-dl -x --audio-format mp3 --no-check-certificate -o "${download_dir}/%(id)s.%(ext)s" -f best/bestaudio "$(curl -s "${link}" | tr -d '\n'|awk -F "embedUrl" '{print $2}'|awk -F '"' '{print $3}')" >> /dev/null
    else
      youtube-dl --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" -f mp4-1080p/mp4-720p/mp4-480p/webm-480p/mp4-360p/ "$(curl -s "${link}" | tr -d '\n'|awk -F "embedUrl" '{print $2}'|awk -F '"' '{print $3}')" >> /dev/null || youtube-dl --no-check-certificate -o "${download_dir}/%(id)s.%(ext)s" -f mp4-1080p/mp4-720p/mp4-480p/webm-480p/mp4-360p/ "$(curl -s "${link}" | tr -d '\n'|awk -F "embedUrl" '{print $2}'|awk -F '"' '{print $3}')" >> /dev/null
    fi
  elif [[ -n $( echo "${link}" | grep 'youtube' ) ]] || [[ -n $( echo "${link}" | grep 'https://www.youtube.com' ) ]] ; then
    #echo "Downloading YouTube Video: ${link}"
    if [[ "${audio_flag}" == "true" ]]; then
      youtube-dl -x --audio-format mp3 -f best/bestaudio --write-description --write-info-json --write-annotations --write-sub --write-thumbnail --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" >> /dev/null || youtube-dl -x --audio-format mp3 -f best/bestaudio --write-description --write-info-json --write-annotations --write-sub --write-thumbnail --no-check-certificate -o "${download_dir}/%(id)s.%(ext)s" "${link}" >> /dev/null
    else
      youtube-dl -f best --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" >> /dev/null || youtube-dl -f best --no-check-certificate -o "${download_dir}/%(id)s.%(ext)s" "${link}" >> /dev/null
    fi
  elif [[ -n $( echo "${link}" | grep 'bitchute' ) ]] || [[ -n $( echo "${link}" | grep 'https://www.bitchute.com' ) ]] ; then
    #echo "Downloading YouTube Video: ${link}"
    if [[ "${audio_flag}" == "true" ]]; then
      youtube-dl -x --audio-format mp3 -f best/bestaudio --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" >> /dev/null || youtube-dl -f best --no-check-certificate  -o "${download_dir}/%(id)s.%(ext)s" "${link}" >> /dev/null
    else
      youtube-dl -f best --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" >> /dev/null || youtube-dl -f best --no-check-certificate -o "${download_dir}/%(id)s.%(ext)s" "${link}" >> /dev/null
    fi
  elif [[ -n $( echo "${link}" | grep 'twitter' ) ]] || [[ -n $( echo "${link}" | grep 'https://www.twitter.com' ) ]] ; then
    #echo "Downloading YouTube Video: ${link}"
    if [[ "${audio_flag}" == "true" ]]; then
      youtube-dl -x --audio-format mp3 -f best/bestaudio --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" >> /dev/null || youtube-dl -x --audio-format mp3 -f best/bestaudio--no-check-certificate  -o "${download_dir}/%(id)s.%(ext)s" "${link}" >> /dev/null
    else
      youtube-dl -f best --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" >> /dev/null || youtube-dl -f best --no-check-certificate  -o "${download_dir}/%(id)s.%(ext)s" "${link}" >> /dev/null
    fi
  else
    if [[ "${title}" == "" ]]; then
      youtube-dl -f best --no-check-certificate -o "${download_dir}/%(title)s.%(ext)s" "${link}" >> /dev/null
    else
      youtube-dl -f best --no-check-certificate -o "${download_dir}/${title}.%(ext)s" "${link}" >> /dev/null
    fi
  fi
}

# initialize a semaphore with a given number of tokens
open_sem(){
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}

# run the given command asynchronously and pop/push tokens
run_with_lock(){
    local x
    # this read waits until there is something to read
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
     ( "$@"; )
    # push the return code of the command to the semaphore
    printf '%.3d' $? >&3
    )&
}

function download_parallel(){
  count=0
  padlimit=$(tput cols)
  total_links=${#links[@]}
  line=$(printf '%*s' "$padlimit")
  line=${line// /-}
  N=4
  open_sem ${N}
  for link in "${links[@]}"; do
    ((count++))
    percent_complete=$(bc <<< "scale=2; ($count/$total_links)*100")
    printf "%.$((padlimit - 18))s %s %s\n" " $(echo -e '\U2714') ${link}" "${line:${#link}+${#percent_complete}+15}" "${percent_complete}% (${count}/${#links[@]})"
    run_with_lock download "${link}"
  done && wait
  echo "Complete 100.00%"
}


if [ -z "$1" ]; then
  usage
  exit 0
fi

links=()
audio_flag='false'
install_dependencies_flag='false'
download_dir="$HOME/Downloads"
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
      install_dependencies_flag='true'
      exit 0
      shift
      ;;
    d | -d | --download-directory)
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

if [[ ${install_dependencies_flag} == 'true' ]]; then
  install_dependencies
fi

echo -e ""
download_parallel

