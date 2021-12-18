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
    subtitle_files+=("${download_dir}/${title}.srt")
    video_files+=("${download_dir}/${title}.mp4")
    (
    if [[ ! -f "${video_files[${index}]}" ]]; then
      echo "Downloading Subtitle: ${subtitle_files[${index}]} ..."
      wget --output-document "${subtitle_files[${index}]}" "${subtitle_link}"
      echo "Downloading Video: ${video_files[${index}]} ..."
      "${script_dir}/video_download.sh" --links "${video_link}" --title "${title}" --download-directory "${download_dir}"
      sed -i 's/WEBVTT//' "${subtitle_files[${index}]}"
      sed -i 's/^.*FILIMO.*$/./g' "${subtitle_files[${index}]}"
      sed -i 's/^.*Supervisor of Translators:.*$/./g' "${subtitle_files[${index}]}"
      # Trim the beginning of the video
      if [[ "${trim_video}" == "0" ]]; then
        echo "Skipping trimming video for ${video_files[${index}]}"
      else
        ffmpeg -nostdin -i "${video_files[${index}]}" -ss "${trim_video}" -vcodec copy -acodec copy "${video_files[${index}]::-4}-output.mp4"
        rm -f "${video_files[${index}]}"
        mv "${video_files[${index}]::-4}-output.mp4" "${video_files[${index}]}"
      fi
      # Shift subtitles
      if [[ "${trim_subtitle}" == "" ]]; then
        echo "Skipping trimming subtitle for ${video_files[${index}]}"
      else
        "${script_dir}/shift_subtitle.sh" -f "${subtitle_files[${index}]}" -s "${trim_subtitle}"
      fi
      # Add subtitles to video
      "${script_dir}/add_subtitles.sh" -s "${subtitle_files[${index}]}" -v "${video_files[${index}]}"
      # Set Title for Video
      "${script_dir}/video_rename.sh" -c "${video_files[${index}]}"
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
trim_video="0"
trim_subtitle=""
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
    ts | -ts | --trim-subtitle)
      if [ "${2}" ]; then
        trim_subtitle="${2}"
        shift
      else
        echo 'ERROR: "-v | --video-file" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    tv | -tv | --trim-video)
      if [ "${2}" ]; then
        trim_video="${2}"
        shift
      else
        echo 'ERROR: "-v | --video-file" requires a non-empty option argument.'
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

if [[ "${install_flag}" == "true" ]]; then
  install
fi
clean_series
