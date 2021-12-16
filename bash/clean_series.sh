#!/bin/bash

function usage(){
  echo "clean_series.sh -v 'video.mp4' -s 'subtitle.srt' -tv '9' -ts '+3.0 seconds'"
}

function clean_series(){
  sed -i 's/ [0-9][0-9]* /\n\n&\n/g' "${subtitle_file}"
  sed -i 's/^ //g' "${subtitle_file}"
  sed -i 's/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9] /&\n/g' "${subtitle_file}"
  sed -i 's/^.*FILIMO.*$/./g' "${subtitle_file}"
  sed -i 's/^.*Supervisor of Translators:.*$/./g' "${subtitle_file}"
  ffmpeg -i "${video_file}" -ss "${trim_video}" -vcodec copy -acodec copy "output-${video_file}"
  shift_subtitle.sh -f "${subtitle_file}" -s "${trim_subtitle}"
  ffmpeg -i "output-${video_file}" -f srt -i "${subtitle_file}" -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 language=eng "output-tr.mp4"
  mv "${video_file}" "backup-${video_file}"
  mv "output-tr.mp4" "${video_file}"
}

if [ -z "$1" ]; then
  usage
  exit 0
fi

subtitle_file="subtitle.srt"
video_file="movie.mp4"
trim_video="9"
trim_subtitle="-3.0 seconds"
while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      usage
      exit 0
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
    v | -v | --video-file)
      if [ "${2}" ]; then
        subtitle_file="${2}"
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
