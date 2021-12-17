#!/bin/bash

function usage(){
  echo "download_series.sh --download-directory '~/Downloads' --file 'video_links.csv' --tv '9' -ts '+3.0 seconds'"
  echo "CSV Format: "
  echo "<Title>,<Video Link>,<Subtitle Link>"
}

function clean_series(){
  index=0
  while IFS=, read -r title video_link subtitle_link
  do
    (
    subtitle_files+=("${download_dir}/${title}.srt")
    video_files+=("${download_dir}/${title}.mp4")
    ./video_download.sh --links "${video_link}" --title "${title}" --download-directory "${download_dir}"
    wget --output-document "${subtitle_files[${index}]}" "${subtitle_link}"
    sed -i 's/WEBVTT//' "${subtitle_files[${index}]}"
    sed -i 's/^.*FILIMO.*$/./g' "${subtitle_files[${index}]}"
    sed -i 's/^.*Supervisor of Translators:.*$/./g' "${subtitle_files[${index}]}"
    # Trim the beginning of the video
    ffmpeg -nostdin -i "${video_files[${index}]}" -ss "${trim_video}" -vcodec copy -acodec copy "output-${video_files[${index}]}"
    rm -f "${video_files[${index}]}"
    mv "output-${video_files[${index}]}" "${video_files[${index}]}"
    # Shift subtitles
    shift_subtitle.sh -f "${subtitle_files[${index}]}" -s "${trim_subtitle}"
    # Add subtitles to video
    add_subtitles.sh -s "${subtitle_files[${index}]}" -v "${video_files[${index}]}"
    ) &
    index=${index}+1
  done < "${file}"
}

if [ -z "$1" ]; then
  usage
  exit 0
fi

file=""
download_dir="."
subtitle_files=()
video_files=()
trim_video="15"
trim_subtitle="-18.0 seconds"
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

clean_series
