#!/bin/bash

#./shift_subtitle.sh "+3.0 seconds" < bmt.srt

set -o errexit -o noclobber -o nounset -o pipefail

function usage(){
  echo "shift_subtitle.sh -f 'subtitle.srt' -s '+3.0 seconds'"
}

function shift_date() {
  date --date="${1} ${date_offset}" +%T,%N | cut -c 1-12
}

function shift_subtitle(){
  while read -r line
  do
    if [[ ${line} =~ ^[0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]\ --\>\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9],[0-9][0-9][0-9]$ ]]; then
      read -r start_date separator end_date <<< "${line}"
      new_start_date="$(shift_date "${start_date}")"
      new_end_date="$(shift_date "${end_date}")"
      printf "%s %s %s\n" "${new_start_date}" "${separator}" "${new_end_date}"
      echo "New date"
    else
      printf "%s\n" "${line}"
    fi
  done < "${subtitle_file}"
}

function generate_subtitle(){
  shift_subtitle | tee "output-${subtitle_file}"
  mv "${subtitle_file}" "backup-${subtitle_file}"
  mv "output-${subtitle_file}" "${subtitle_file}"
}

if [ -z "$1" ]; then
  usage
  exit 0
fi

date_offset="+3.0 seconds"
subtitle_file="subtitle.srt"
while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      usage
      exit 0
      ;;
    s | -s | --seconds)
      if [ "${2}" ]; then
        date_offset="${2}"
        shift
      else
        echo 'ERROR: "-s | --seconds" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    f | -f | --file)
      if [ "${2}" ]; then
        subtitle_file="${2}"
        shift
      else
        echo 'ERROR: "-f | --file" requires a non-empty option argument.'
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

generate_subtitle
