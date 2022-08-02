#!/bin/bash

function usage(){
  echo "download_series.sh --download-directory '~/Downloads' --file 'video_links.csv' --trim-video '9' --trim-subtitle '+3.0 seconds'"
  echo "CSV Format: "
  echo "<Title>,<Video Link>,<Subtitle Link>"
}

function install(){
  os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  os_version="${os_version:1:-1}"
  echo "${os_version}"
  if [[ $os_version = "Ubuntu" ]] ; then
    apt update
    apt install ffmpeg python3 python3-pip wget -y
    python3 -m pip install --upgrade pip
    python3 -m pip install youtube-dl
  elif [[ $os_version = "CentOS Linux" ]] ; then
    yum install ffmpeg python3 wget -y
  else
    echo "Distribution ${os_version} not supported"
  fi
  "${script_dir}/video_download.sh" --install
  "${script_dir}/video_rename.sh" --install
}

function clean_series(){
  index=0
  while IFS=, read -r title video_link subtitle_link
  do
    echo -e "Reading: \nTitle: ${title}\nVideo Link: ${video_link}\nSubtitle Link: ${subtitle_link}"
    subtitle_files+=("${download_dir}/Subs/${title}/${title} English.srt")
    video_files+=("${download_dir}/${title}.mp4")
    (
    if [[ ! -f "${video_files[${index}]}" ]]; then
      echo "Downloading Subtitle: ${subtitle_files[${index}]} ..."
      mkdir -p "${download_dir}/Subs/${title}"
      wget -O "${subtitle_files[${index}]}" "${subtitle_link}"
      echo "Downloading Video: ${video_files[${index}]} ..."
      "${script_dir}/video-downloader" --links "${video_link}" --title "${title}" --download-directory "${download_dir}"
      sed -i 's/WEBVTT//' "${subtitle_files[${index}]}"
      sed -i 's/^.*FILIMO.*$/./g' "${subtitle_files[${index}]}"
      sed -i 's/^.*Filimo.*$/./g' "${subtitle_files[${index}]}"
      sed -i 's/^Filimo.*$/./g' "${subtitle_files[${index}]}"
      sed -i 's/^.*the most exciting movies.*$//g' "${subtitle_files[${index}]}"
      sed -i 's/^.*Supervisor of Translators:.*$/./g' "${subtitle_files[${index}]}"
      sed -i 's/^Supervisor of Translators:.*$/./g' "${subtitle_files[${index}]}"
      "${script_dir}/video-manager" -c "${video_files[${index}]}"
    else
      echo "Skipping ${video_files[${index}]}, already downloaded..."
    fi
    ) &
    index=${index}+1
  done < "${file}"
}

if [ -z "$1" ]; then
  usage
  exit 0
fi

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
file=""
download_dir="."
subtitle_files=()
video_files=()
install_flag="false"
while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      usage
      exit 0
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
    f | -f | --file)
      if [ "${2}" ]; then
        file="${2}"
        shift
      else
        echo 'ERROR: "-f | --file" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    i | -i | --install)
      install_flag="true"
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

if [[ "${install_flag}" == "true" ]]; then
  install
fi
clean_series
