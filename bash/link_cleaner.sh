#!/bin/bash

function usage() {
  echo "Usage: "
  echo "sudo ./link_cleaner.sh -c <input_file> <output_file>"
  echo "sudo ./link_cleaner.sh --clean ./input_file.txt ./export_file.txt"
  echo "sudo ./link_cleaner.sh clean ./input_file.txt ./export_file.txt"
}

function clean_links() {
  # Cat the file
  cat "${input_file}"

  # Copy the original file
  cp "${input_file}" "${output_file}"

  # Remove Chrome Tabs
  sed -i 's/^chrome:.*$//g' "${output_file}"
  sed -i 's/^chrome-native:.*$//g' "${output_file}"

  # Remove Facebook Sites
  sed -i 's/^.*facebook.*$//g' "${output_file}"
  # Remove Generic voat tabs
  sed -i 's/^.*voat.co.$//g' "${output_file}"
  sed -i 's/^.*voat.co..page=.*$//g' "${output_file}"
  # Convert Mobile Youtube to Regular
  sed -i 's/m\.youtube/www\.youtube/g' "${output_file}"
  # Convert Mobile Twitter to Regular
  sed -i 's/mobile\.twitter/twitter/g' "${output_file}"

  # Convert most mobile to regular links
  sed -i 's/\/\/m\./www\./g' "${output_file}"
  sed -i 's/\/\/mobile\./www\./g' "${output_file}"

  # Remove Empty Newlines
  sed -i '/^ *$/d' "${output_file}"

  # Alphabetically sort and remove duplicates in sorted_links file.
  sort -u -o "${output_file}" "${output_file}"

  # Cat finished file
  cat "${output_file}"
}

computer_user=$(getent passwd {1000..6000} | awk -F: '{ print $1}')
os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"
architecture="$(uname -m)"
clean_flag='false'

# Check if arguments were provided
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
    c | -c | --clean | clean)
      echo "Cleaning Links"
      if [ ${2} ] && [ ${3} ]; then
        clean_flag='true'
        input_file="${1}"
        output_file="${2}"
        shift
        shift
      else
        echo 'ERROR: "-a | --applications" requires a non-empty option argument.'
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

if [ ${clean_flag} == "true" ]; then
  clean_links
fi


