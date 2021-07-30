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
  sudo apt install -y mkvtoolnix atomicparsley mediainfo rename
}

function centos_install(){
  sudo yum update -y
  sudo yum install mkvtoolnix atomicparsley mediainfo rename -y
}

function install_dependencies() {
  printf "Installing Dependencies..."
  detect_os
  printf "Successfully Installed Dependencies"
}

function file_rename() {
  #set -x
  file=$1
  file_type=$(echo "${file}" | sed 's/^.*\.//')
  x="${file}"
  #echo "File Type: ${file_type} File ${file}"
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
      #echo "Modifying ${file}"
      mkvpropedit "${file}" -e info -s title="${title}" #> /dev/null 2>&1
      #echo "Modified ${file} with mkvpropedit"
    elif [[ "${file_type}" == "webm" ]]; then
      #echo "Modifying ${file}"
      mkvpropedit "${file}" -e info -s title="${title}" > /dev/null 2>&1
      #echo "Modified ${file} with mkvpropedit"
      #printf "Complete!\nCleaned ${file_type} Title: ${title}\n"
    elif [[ "${file_type}" == "mp4" ]]; then
      #echo "Modifying ${file}"
      AtomicParsley "${file}" --title "${title}" --comment "" --overWrite > /dev/null 2>&1
      #echo "Modified ${file} with atomicparsley"
      #printf "Complete!\nCleaned ${file_type} Title: ${title}\n"
    else
      echo "No Video File found"
    fi
  fi

  # Rename Directory of Folder
  if [[ "${rename_directory_flag}" == "true" ]]; then
    for directory in "${directories[@]}"
    do
      echo "Renaming directory"
      rename_directory "${directory}" "${title}"
    done
  else
    echo "Skipping Renaming of Directory"
  fi
}

function find_files(){
  count=0
  all_files_list=()
  #echo "All Directories checked Files Found: ${directories[*]}"
  for directory in "${directories[@]}"
  do
    readarray -d '' mkv_list < <(find "${directory}" -maxdepth 2 -name "*.mkv" -print0)
    readarray -d '' mp4_list < <(find "${directory}" -maxdepth 2 -name "*.mp4" -print0)
    readarray -d '' webm_list < <(find "${directory}" -maxdepth 2 -name "*.webm" -print0)
    all_files_list=( "${all_files_list[@]}" "${mp4_list[@]}" "${mkv_list[@]}" "${webm_list[@]}" )
  done

  # shellcheck disable=SC1036
  # shellcheck disable=SC1072
  eval files_list=($(printf "%q\n" "${all_files_list[@]}" | sort -u))
  for file in "${files_list[@]}"
  do
    echo "Filename: ${file}"
    ((count++))
    total_files=${#files_list[@]}
    percent_complete=$(( (count / total_files) * 100 ))
    echo -e "Percent Complete: ${percent_complete} | Ratio: ${count}/${#files_list[@]} | Processing Media File: ${file} in: ${directory}"
    file_rename "${file}"
  done
}

function find_directories() {
  # Look for directories.
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
rename_directory_flag="false"
# To rename multiple files with pattern:
# rename ${filename} | sed 's/^\[MKV\] //' | sed 's/\[Multi Subs\]//'

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
      if [[ "${2}" ]]; then
        relative_directory="${2}"
        echo "Relative Directory passed: ${relative_directory}"
        shift
      else
        echo 'ERROR: "-c | --clean" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    r | -r | --rename-directory)
      rename_directory_flag="true"
      shift
      ;;
    --)# End of all options.
      shift
      break
      ;;
    -?*)
      printf 'WARNING: Unknown option (ignored): %s\n' "$1"
      ;;
    *)
      shift
      break
      ;;
  esac
done

clean_files
