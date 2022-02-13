#!/bin/bash

# This script will retitle all .mkv/.mp4 metadata to their file names. Will also rename directories to the file name
function usage() {
  echo -e "
Flags:
-h | h | --help             \t Show Usage and Flags
-i | i | --install          \t Install all install_dependencies
-a | a | --auto-rename      \t Rename the file based on regex matching
-r | r | --rename-directory \t Rename the directory based off the file name
-c | c | --clean            \t Clean a single file
-b | b | --batch-clean      \t Clean all files within a directory

Usage:
./video_rename.sh -i
./video_rename.sh --install
./video_rename.sh install
./video_rename.sh --clean <filename>
./video_rename.sh -c <filename.mp4> -auto-rename
./video_rename.sh --batch-clean <directory_to_search>
./video_rename.sh --batch-clean \"$(pwd)\" --rename-directory --auto-rename
./video_rename.sh -b \"$(pwd)\" -r -a
"
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
  apt update
  apt install -y mkvtoolnix atomicparsley mediainfo rename
}

function centos_install(){
  yum update -y
  yum install mkvtoolnix atomicparsley mediainfo rename -y
}

function install_dependencies() {
  printf "Installing Dependencies..."
  detect_os
  printf "Successfully Installed Dependencies"
}

function file_rename() {
  #set -x
  file=$1
  file_type=$2
  if [[ "${auto_file_rename_flag}" == "true" ]]; then
    local_filename="$(basename "${file}")"
    file_directory="$(dirname "${file}")"
    # echo "Cleaning: ${file_directory} File: ${local_filename}"
    # Filters
    pushd "${file_directory}"
      new_local_filename=$(echo "${local_filename}" | sed "s/1080p.*.${file_type}$/1080p.${file_type}/;
                                                           s/720p.*.${file_type}$/720p.${file_type}/;
                                                           s/PROPER\.REMASTERED\.//;
                                                           s/PROPER\.//;
                                                           s/\[.*\]//g;
                                                           s/\./ /g;
                                                           s/ ${file_type}/.${file_type}/")
      if [[ "${new_local_filename}" != "${local_filename}" ]]; then
        mv "${file}" "${file_directory}/${new_local_filename}"
        echo "Auto-generated Filename: ${new_local_filename}"
        file="${file_directory}/${new_local_filename}"
      else
        echo "Auto-generated Filename The Same: ${new_local_filename}"
      fi
    popd
    # Cleaning extraneous Files
    rm -f ${file_directory}/*.txt
    rm -f ${file_directory}/*.exe
  fi
  #title=${file%.file_type##*/}
  y="${file%.file_type}"
  title=${y##*/}
  current_title=$(mediainfo "${file}" | grep -e "Movie name" | awk -F  ":" '{print $2}' | sed 's/^ *//')
  current_track_title=$(mediainfo "${file}" | grep "Title" | head -n 1 | awk -F  ":" '{print $2}' | sed 's/^ *//')
  echo -e "Current Title: ${current_title}\nCurrent Track Title: ${current_track_title}\nProposed Title: ${title}\nFile: ${file}\n"
  if [[ "${title}" != "${current_title}" ]] || [[ "${title}" != "${current_track_title}" ]]; then
    if [[ "${file_type}" == "mkv" ]]; then
      #echo -e "Modifying ${file}\n\n"
      mkvpropedit "${file}" -e info -s title="${title}" -e track:1 -s name="${title}" > /dev/null 2>&1
      #echo "Modified ${file} with mkvpropedit"
    elif [[ "${file_type}" == "webm" ]]; then
      #echo "Modifying ${file}"
      mkvpropedit "${file}" -e info -s title="${title}" -e track:1 -s name="${title}" > /dev/null 2>&1
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
    directory="$(dirname "${file}")"
    echo "Renaming directory ${directory} - ${title}"
    rename_directory "${directory}" "${title}"
  else
    echo "Skipping Renaming of Directory"
  fi
}

function find_files() {
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
  echo "All files: ${all_files_list}"
  # shellcheck disable=SC1036
  # shellcheck disable=SC1072
  eval files_list=($(printf "%q\n" "${all_files_list[@]}" | sort -u))
  
  for file in "${files_list[@]}"
  do
    file_type=$(echo "${file}" | sed 's/^.*\.//')
    x="${file}"
    #echo "File Type: ${file_type} File ${file}"
    if [[ "${file_type}" == "mkv" ]]; then
      y="${x%.mkv}"
      echo "Filename: ${file}"
      ((count++))
      total_files=${#files_list[@]}
      percent_complete=$(( (count / total_files) * 100 ))
      echo -e "Percent Complete: ${percent_complete} | Ratio: ${count}/${#files_list[@]} | Processing Media File: ${file}"
      file_rename "${file}" "${file_type}"
    elif [[ "${file_type}" == "mp4" ]]; then
      y="${x%.mp4}"
      echo "Filename: ${file}"
      ((count++))
      total_files=${#files_list[@]}
      percent_complete=$(( (count / total_files) * 100 ))
      echo -e "Percent Complete: ${percent_complete} | Ratio: ${count}/${#files_list[@]} | Processing Media File: ${file}"
      file_rename "${file}" "${file_type}"
    elif [[ "${file_type}" == "webm" ]]; then
      y="${x%.webm}"
      echo "Filename: ${file}"
      ((count++))
      total_files=${#files_list[@]}
      percent_complete=$(( (count / total_files) * 100 ))
      echo -e "Percent Complete: ${percent_complete} | Ratio: ${count}/${#files_list[@]} | Processing Media File: ${file}"
      file_rename "${file}" "${file_type}"
    fi
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
auto_file_rename_flag="false"
file=""
batch_clean="false"
single_clean="false"
# To rename multiple files with pattern:
# rename 's/^\[MKV\] //' *

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
    a | -a | --auto-rename)
      auto_file_rename_flag="true"
      shift
      ;;
    i | -i | --install | install)
      install_dependencies
      exit 0
      ;;
    b | -b | --batch-clean)
      if [[ "${2}" ]]; then
        relative_directory="${2}"
        batch_clean="true"
        echo "Relative Directory passed: ${relative_directory}"
        shift
      else
        echo 'ERROR: "-b | --batch-clean" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    c | -c | --clean)
      if [[ "${2}" ]]; then
        file="${2}"
        single_clean="true"
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

if [[ "${batch_clean}" == "true" ]]; then
  clean_files
fi

if [[ "${single_clean}" == "true" ]]; then
  file_rename "${file}"
fi


