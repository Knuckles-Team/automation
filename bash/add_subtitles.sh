#!/bin/bash

function usage(){
  echo "add_subtitles.sh -s 'subtitle.srt' -v 'video.mp4'"
}

function add_subtitle(){
  # For language codes, use ISO 639-2
  ffmpeg -i "${video_file}" -f srt -i "${subtitle_file}" -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 language=eng "${video_file::-4}-output.mp4"
  if [[ "${backup}" == "true" ]]; then
    cp "${video_file}" "${video_file::-4}-unsubtitled-backup.mp4"
  else
    # rm -f "${subtitle_file}"
    echo "subtitle added to video, backup not requested."
  fi
  rm -f "${video_file}"
  mv "${video_file::-4}-output.mp4" "${video_file}"
}

if [ -z "$1" ]; then
  usage
  exit 0
fi

subtitle_file="subtitle.srt"
video_file="video.mp4"
backup="false"
while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      usage
      exit 0
      ;;
    b | -b | --backup)
      backup="true"
      shift
      ;;
    s | -s | --subtitle-file)
      if [ "${2}" ]; then
        subtitle_file="${2}"
        shift
      else
        echo 'ERROR: "-s | --subtitle-file" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    v | -v | --video-file)
      if [ "${2}" ]; then
        video_file="${2}"
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

add_subtitle