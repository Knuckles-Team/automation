#!/bin/bash

# This script will retitle all .mkv/.mp4 metadata to their file names. Will also rename directories to the file name
function usage() {
  echo "Usage: "
  echo "sudo ./video_rename.sh -i"
  echo "sudo ./video_rename.sh --install"
  echo "sudo ./video_rename.sh install"
  echo "sudo ./video_rename.sh -c <directory_to_search>"
  echo "sudo ./video_rename.sh --clean \"$(pwd)\""
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
  sudo apt install -y mkvtoolnix atomicparsley mediainfo
}

function centos_install(){
  sudo yum update -y
  sudo yum install mkvtoolnix atomicparsley mediainfo -y
}

function install_dependencies() {
  printf "Installing Dependencies..."
  detect_os
  printf "Successfully Installed Dependencies"
}

function file_rename() {
  list=$1
  file_type=$2
  if [[ -n "${list}" ]]
  then
    for file in "${list[@]}"
    do
      #printf "Checking Filetype: ${file_type}\n File: ${file}\n"
      x="${file}"
      if [[ "${file_type}" == "mkv" ]]; then
        y="${x%.mkv}"
      elif [[ "${file_type}" == "mp4" ]]; then
        y="${x%.mp4}"
      elif [[ "${file_type}" == "webm" ]]; then
        y="${x%.webm}"
      fi      
      title=${y##*/}
      current_title=$(mediainfo "${file}" | grep -e "Movie name" | awk -F  ":" '{print $2}' | sed 's/^ *//')
      if [[ "${title}" != "${current_title}" ]]; then
#        printf "Current Title: ${current_title}\nProposed Title: ${title}\n"
#        sleep 10
        if [[ "${file_type}" == "mkv" ]]; then
          mkvpropedit "${file}" -e info -s title="${title}" #> /dev/null 2>&1
#          printf "Complete!\nCleaned ${file_type} Title: ${title}\n"
#          sleep 10
        elif [[ "${file_type}" == "webm" ]]; then
          mkvpropedit "${file}" -e info -s title="${title}" > /dev/null 2>&1
          #printf "Complete!\nCleaned ${file_type} Title: ${title}\n"
        elif [[ "${file_type}" == "mp4" ]]; then
          AtomicParsley "${file}" --title "${title}" --comment "" --overWrite > /dev/null 2>&1
          #printf "Complete!\nCleaned ${file_type} Title: ${title}\n"
        fi
#     else
#       printf "Titles already the same, no need to update: ${file}\n"
      fi    
      # Rename Directory of Folder
      rename_directory "${directory}" "${title}"
    done
  fi
}

function find_files() {
  count=0
  for directory in "${directories[@]}"
  do
    mp4_list=("${directory}"/*.mp4)
    mkv_list=("${directory}"/*.mkv)
    webm_list=("${directory}"/*.webm)
    percent_complete=$(((count/${#directories[@]})*100))
    clear
    if [[ -n "${mkv_list}" ]]
    then
      echo -ne "Percent Complete: ${percent_complete} | Ratio: ${count}/${#directories[@]} | Processing MKV Files: ${directory} \r"
      file_rename "${mkv_list}" "mkv"
    else
      echo -ne "Percent Complete: ${percent_complete} | Ratio: ${count}/${#directories[@]} | Found no MKV Files: ${directory} \r"
    fi
    if [[ -n "${mp4_list}" ]]
    then
      echo -ne "Percent Complete: ${percent_complete} | Ratio: ${count}/${#directories[@]} | Processing MP4 Files: ${directory} \r"
      file_rename "${mp4_list}" "mp4"
    else
      echo -ne "Percent Complete: ${percent_complete} | Ratio: ${count}/${#directories[@]} | Found no MP4 Files: ${directory} \r"
    fi
    if [[ -n "${webm_list}" ]]
    then
      echo -ne "Percent Complete: ${percent_complete} | Ratio: ${count}/${#directories[@]} | Processing WEBM Files: ${directory} \r"
      file_rename "${webm_list}" "webm"
    else
      echo -ne "Percent Complete: ${percent_complete} | Ratio: ${count}/${#directories[@]} | Found no WEBM Files: ${directory} \r"
    fi
    ((count++))
    percent_complete=$(((count/${#directories[@]})*100))
    echo -ne "Percent Complete: ${percent_complete} | Ratio: ${count}/${#directories[@]} | Completed File Renaming                                               \r"
  done
}

function find_directories() {
  shopt -s dotglob
  shopt -s nullglob
  i=0
  
  while read line
  do
    #printf "LINE: ${line}\n"
    if [ -d "${line}" ]
    then
      directories[ $i ]="${line}" 
      #echo "Found Valid Directory: ${directories[i]} Count: ${i}"
      (( i++ ))
    #else
      #echo "Did not find a directory at: ${line} Count: ${i}"
    fi    
  done < <(find "${relative_directory}" -maxdepth 2 -type d -print0 | while read -d '' -r dir; do echo "${dir}"; done)  
  #printf 'Directories: %s\n' "${directories[@]}"
}

function rename_directory() {
  parentdir="$(dirname "${1}")"
  original_directory="${1}"
  proposed_directory="${parentdir}/${2}"
  #printf "Original Direcotry: ${original_directory}\nNew Directory: ${proposed_directory}"
  if [[ "${original_directory}" != "${proposed_directory}" ]]
  then    
    sudo mv "${1}" "${parentdir}/${2}"
    #echo "Renamed folder: ${parentdir}/${2}"
  #else
    #echo "Folder name looks good to go! No changes needed"
  fi 
}

# Clean function clean will take the directory where this script is called from and 
function clean_files() {  
  find_directories
  find_files
  #echo && echo -e "Done Changing Titles\n"
}

computer_user=$(getent passwd {1000..6000} | awk -F: '{ print $1}')
os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"
architecture="$(uname -m)"

if [ -z "$1" ]; then
  usage
  exit 0
fi

while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      echo "Operating System: ${os_version}"
      echo "Architecture: ${architecture}"
      echo "User: ${computer_user}"
      usage
      exit 0
      ;;
    i | -i | --install | install)
      install_dependencies
      exit 0
      ;;
    c | -c | --clean)
      if [ ${2} ]; then
        relative_directory="${2}"
        shift
      else
        echo 'ERROR: "-c | --clean" requires a non-empty option argument.'
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

clean_files