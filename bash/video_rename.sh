#!/bin/bash

# This script will retitle all .mkv/.mp4 metadata to their file names. Will also rename directories to the file name
function usage() {
  echo -e "
Information:
This script will rename a video file's title metadata to match the filename. The filename can also be cleaned automatically.

Flags:
-h | h | --help             \t Show Usage and Flags
-i | i | --install          \t Install all dependencies
-a | a | --auto-rename      \t Rename the file based on regex matching
-r | r | --rename-directory \t Rename the directory based off the file name
-c | c | --clean            \t Clean a single file
-b | b | --batch-clean      \t Clean all files within a directory
-m | m | --move             \t Move the file's directory to specified directory

Usage:
./video_rename.sh -i
./video_rename.sh --install
./video_rename.sh install
./video_rename.sh --clean <filename>
./video_rename.sh -c <filename.mp4> -auto-rename
./video_rename.sh --batch-clean <directory_to_search>
./video_rename.sh --batch-clean \"$(pwd)\" --rename-directory --auto-rename
./video_rename.sh -b \"$(pwd)\" -r -a -m \"$HOME/Videos\"
"
}

function install_dependencies() {
  printf "Installing Dependencies..."
  os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  os_version="${os_version:1:-1}"
  echo "${os_version}"
  if [[ $os_version = "Ubuntu" ]] ; then
    echo "Installing for Ubuntu"
    apt update
    apt install -y mkvtoolnix atomicparsley mediainfo rename
  elif [[ $os_version = "CentOS Linux" ]] ; then
    echo "Installing for CentOS"
    yum update -y
    yum install mkvtoolnix atomicparsley mediainfo rename -y
  else
    echo "Distribution ${os_version} not supported"
  fi
  printf "Successfully Installed Dependencies"
}

function file_rename() {
  #set -x
  file=$1
  file_type=$(echo "${file}" | sed 's/^.*\.//')
  local_filename="$(basename "${file}")"
  file_directory="$(dirname "${file}")"
  if [[ "${auto_file_rename_flag}" == "true" ]]; then
    # Filters
    pushd "${file_directory}" >> /dev/null
      new_local_filename=$(echo "${local_filename}" | sed "s/2160p.*.${file_type}$/2160p.${file_type}/;
                                                           s/1080p.*.${file_type}$/1080p.${file_type}/;
                                                           s/720p.*.${file_type}$/720p.${file_type}/;
                                                           s/480p.*.${file_type}$/480p.${file_type}/;
                                                           s/REMASTERED.//;
                                                           s/RESTORED.//;
                                                           s/UNCUT.//;
                                                           s/GERMAN/German/;
                                                           s/SWEDISH/Swedish/;
                                                           s/FRENCH/French/;
                                                           s/JAPANESE/Japanese/;
                                                           s/CHINESE/Chinese/;
                                                           s/KOREAN/Korean/;
                                                           s/ITALIAN/Italian/;
                                                           s/EXTENDED.//;
                                                           s/PROPER.//;
                                                           s/THEATRICAL.//;
                                                           s/\[.*\]//g;
                                                           s/\./ /g;
                                                           s/ ${file_type}/.${file_type}/")
      if [[ "${new_local_filename}" != "${local_filename}" ]]; then
        mv "${file}" "${file_directory}/${new_local_filename}"
        #echo "Auto-generated Filename: ${new_local_filename}"
        file="${file_directory}/${new_local_filename}"
      fi
    popd >> /dev/null
  fi
  # Cleaning extraneous Files
  rm -f ${file_directory}/*.txt >> /dev/null
  rm -f ${file_directory}/*.exe >> /dev/null
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
  current_track_title=$(mediainfo "${file}" | grep "Title" | head -n 1 | awk -F  ":" '{print $2}' | sed 's/^ *//')
  if [[ "${title}" != "${current_title}" ]] || [[ "${title}" != "${current_track_title}" ]]; then
    if [[ "${file_type}" == "mkv" ]]; then
      mkvpropedit "${file}" -e info -s title="${title}" -e track:1 -s name="${title}" > /dev/null 2>&1
    elif [[ "${file_type}" == "webm" ]]; then
      mkvpropedit "${file}" -e info -s title="${title}" -e track:1 -s name="${title}" > /dev/null 2>&1
    elif [[ "${file_type}" == "mp4" ]]; then
      AtomicParsley "${file}" --title "${title}" --comment "" --overWrite > /dev/null 2>&1
    else
      echo "No Video File found"
      rename_directory_flag="false"
    fi
  fi
  # Rename Directory of Folder
  if [[ "${rename_directory_flag}" == "true" ]]; then
    directory="$(dirname "${file}")"
    parent_directory="$(dirname "${directory}")"
    proposed_directory="${parent_directory}/${title}"
    if [[ "${directory}" != "${proposed_directory}" ]]
    then
      sudo mv "${directory}" "${parent_directory}/${title}"
    fi
  fi
  # Move folder to directory specified
  if [[ "${move_flag}" == "true" ]]; then
    directory="$(dirname "${file}")"
    sudo mv "${directory}" "${move_directory}"
  fi
  printf "%.$((padlimit - 21))s %s %s\n" " $(echo -e '\U2714') ${title}" "${line:${#title}+${#percent_complete}+18}" "${percent_complete}% (${count}/${#files_list[@]})"
}

function find_files() {
  count=0
  all_files_list=()
  for directory in "${directories[@]}"
  do
    readarray -d '' mkv_list < <(find "${directory}" -maxdepth 2 -name "*.mkv" -print0)
    readarray -d '' mp4_list < <(find "${directory}" -maxdepth 2 -name "*.mp4" -print0)
    readarray -d '' webm_list < <(find "${directory}" -maxdepth 2 -name "*.webm" -print0)
    all_files_list=( "${all_files_list[@]}" "${mp4_list[@]}" "${mkv_list[@]}" "${webm_list[@]}" )
  done
  eval files_list=($(printf "%q\n" "${all_files_list[@]}" | sort -u))

  padlimit=$(tput cols)
  line=$(printf '%*s' "$padlimit")
  line=${line// /-}
  total_files=${#files_list[@]}
  echo -e "\nProcessing files...\n"
  for file in "${files_list[@]}"
  do
    ((count++))
    percent_complete=$(bc <<< "scale=2; ($count/$total_files)*100")
    local_filename="$(basename "${file}")"
    file_rename "${file}"
  done
  echo -e "\nComplete 100.00%"
}

function find_directories() {
  # Look for directories.
  shopt -s dotglob
  shopt -s nullglob
  i=0

  while read line
  do
    if [ -d "${line}" ]
    then
      directories[ $i ]="${line}"
      (( i++ ))
    fi
  done < <(find "${relative_directory}" -maxdepth 2 -type d -print0 | while read -d '' -r dir; do echo "${dir}"; done)

  find_files
}

count=0
percent_complete=0
computer_user=$(getent passwd {1000..6000} | awk -F: '{ print $1}')
os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"
architecture="$(uname -m)"
rename_directory_flag="false"
auto_file_rename_flag="false"
move_flag="false"
move_directory=""
file=""
batch_clean="false"
single_clean="false"

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
        if [[ -d "${2}" ]]; then
          relative_directory="${2}"
        else
          echo "Directory entered not found: ${2}"
          exit 0
        fi
        batch_clean="true"
        #echo "Relative Directory passed: ${relative_directory}"
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
    m | -m | --move)
      if [[ "${2}" ]]; then
        if [[ -d "${2}" ]]; then
          move_directory="${2}"
        else
          echo "Directory entered not found: ${2}"
          exit 0
        fi
        move_flag="true"
        shift
      else
        echo 'ERROR: "-b | --batch-clean" requires a non-empty option argument.'
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

echo -e ""
if [[ "${batch_clean}" == "true" ]]; then
  find_directories
fi

if [[ "${single_clean}" == "true" ]]; then
  file_rename "${file}"
fi


