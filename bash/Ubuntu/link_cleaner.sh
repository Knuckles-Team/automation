#!/bin/bash

function usage() {
  echo "Usage: "
  echo "sudo ./ubuntu_link_cleaner.sh clean <input_file> <output_file>"
  echo "sudo ./ubuntu_link_cleaner.sh clean ./input_file.txt ./export_file.txt"
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

function main() {
  echo "0 ${args[0]}" 
  echo "1 ${args[1]}" 
  echo "2 ${args[2]}" 
  
  if [[ "${#args[@]}" -le 1 ]] ; then
    usage    
    exit 0
  elif [[ ${args[0]} == "clean" ]] ; then
    input_file="${args[1]}"
    output_file="${args[2]}" 
    clean_links
  fi
}

args=("$@")
main
