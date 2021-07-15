#!/bin/bash

function usage(){
  echo -e "\nUsage: "
  echo -e "sudo ./batch_translate.sh -h [Help]"
  echo -e "sudo ./batch_translate.sh --help [Help]"
  echo -e "\nFlags: "
  echo -e "-h | --help "
}

function install(){
  sudo "$(pwd)/manage_system.sh" -p -a tesseract,poppler-utils,ghostscript,enscript,translate-shell
}

function translate_text(){
  count=0
  for file in "${text_files[@]}"
  do
    file_type="$(echo "${file}" | sed 's/.*\.//')"
    file_name="$(echo "${file}" | sed 's/\..*$//')"
    echo -e "File: ${file} \nFile Name: ${file_name}\nFile Type: ${file_type}"
    percent_complete=$(((count/${#text_files[@]})*100))
    trans :en -brief -input "${file_name}.txt" -output "${file_name}-translated.txt"
    ((count++))
    percent_complete=$(((count/${#text_files[@]})*100))
    echo -e "Percent Complete: ${percent_complete} | Ratio: ${count}/${#text_files[@]} | Completed Extracting/Translating Text"
  done
}

function translate(){
  count=0
  for file in "${files[@]}"
  do
    file_type="$(echo "${file}" | sed 's/.*\.//')"
    file_name="$(echo "${file}" | sed 's/\..*$//')"
    echo -e "File: ${file} \nFile Name: ${file_name}\nFile Type: ${file_type}"
    percent_complete=$(((count/${#files[@]})*100))
    if [[ "${file_type}" == "png" ]] || [[ "${file_type}" == "PNG" ]] || [[ "${file_type}" == "jpg" ]] || \
    [[ "${file_type}" == "JPG" ]] || [[ "${file_type}" == "jpeg" ]] || [[ "${file_type}" == "jpeg" ]]; then
      echo -e "Percent Complete: ${percent_complete} | Ratio: ${count}/${#files[@]} | Processing Image File: ${file}"
      tesseract -l eng "${file}" "${file_name}-origin"
      trans :en -brief -input "${file_name}-origin.txt" -output "${file_name}-translated.txt"
    elif [[ "${file_type}" == "pdf" ]] || [[ "${file_type}" == "PDF" ]]; then
      echo -e "Percent Complete: ${percent_complete} | Ratio: ${count}/${#files[@]} | Processing PDF File: ${file}"
      pdftoppm -png "${file}" "${file_name}-origin"
      tesseract -l eng "${file_name}-origin.png" "${file_name}-origin"
      trans :en -brief -input "${file_name}-origin.txt" -output "${file_name}-translated.txt"
    else
      echo -e "Percent Complete: ${percent_complete} | Ratio: ${count}/${#files[@]} | File type not found: ${file}"
    fi
    ((count++))
    percent_complete=$(((count/${#files[@]})*100))
    echo -e "Percent Complete: ${percent_complete} | Ratio: ${count}/${#files[@]} | Completed Extracting/Translating Text                                               \r"
  done
}

computer_user=$(getent passwd {1000..6000} | awk -F: '{ print $1}')
os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"
architecture="$(uname -m)"
date=$(date +"%m-%d-%Y_%I-%M")

# Batch Rename Files:
# rename 's/.WEBRip.x264-ION10//' *

files=()
text_files=()
install_flag='false'
translate_flag='false'
translate_text_only='false'
log_flag='false'
log_dir='.'
log_file="batch-translate_${date}.log"

# Check if arguments were provided
if [ -z "$1" ]; then
  usage
  exit 0
fi

while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      echo -e "\n\nOperating System: ${os_version}"
      echo "Architecture: ${architecture}"
      echo "User: ${computer_user}"
      usage
      exit 0
      ;;
    a | -a | --applications)
      if [ "${2}" ]; then
        IFS=',' read -r -a apps <<< "$2"
        echo "Apps to install: ${apps[*]}"
        shift
      else
        echo 'ERROR: "-a | --applications" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    d | -d | --directories)
      if [ "${2}" ]; then
        IFS=',' read -r -a directories <<< "$2"
        echo "Directories to scan: ${directories[*]}"
        for directory in "${directories[@]}"
        do
          image_list=( "${image_list[@]}" "${directory}"/*.png "${directory}"/*.PNG "${directory}"/*.jpg "${directory}"/*.JPG "${directory}"/*.jpeg "${directory}"/*.JPEG )
          pdf_list=( "${pdf_list[@]}" "${directory}"/*.pdf "${directory}"/*.PDF )
          text_files=( "${text_files[@]}" "${directory}"/*.txt "${directory}"/*.TXT )
        done
        if [ ${#pdf_list[@]} -gt 0 ]; then
          files=( "${files[@]}" "${pdf_list[@]}" )
        fi
        if [ ${#image_list[@]} -gt 0 ]; then
          files=( "${files[@]}" "${image_list[@]}" )
        fi
        shift
      else
        echo 'ERROR: "-d | --directories" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    f | -f | --file)
      if [ "${2}" ]; then
        IFS=',' read -r -a files_read <<< "$2"
        files=( "${files[@]}" "${files_read[@]}" )
        shift
      else
        echo 'ERROR: "-f | --file" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    i | -i | --install | install)
      echo "Installing Dependencies"
      install_flag='true'
      shift
      ;;
    l | -l | --log)
      if [[ ${2:0:1} == "/" ]] || [[ ${2:0:1} == "." ]] || [[ ${2:0:1} == "~" ]]; then
        log_dir="${2}"
        shift
      elif [[ ${2:0:1} == "-" ]]; then
        echo "No log directory specified or it must start with / . or ~, using $(pwd) instead"
      else
        echo "No log directory specified or it must start with / . or ~, using $(pwd) instead"
      fi
      log_flag='true'
      shift
      ;;
    r | -r | --read-file)
      if [ "${2}" ]; then
        file="${2}"
        IFS=$'\n' read -d '' -r -a files_read < "${file}"
        files=( "${files[@]}" "${files_read[@]}" )
        shift
      else
        echo 'ERROR: "-f | --file" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    t | -t | --translate | translate)
      if [ "${2}" == "text" ]; then
        translate_text_only="true"
        shift
      elif [ "${2}" == "document" ]; then
        translate_flag="true"
        shift
      else
        echo 'ERROR: "-t | --translate" requires a non-empty option argument [text/document].'
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

if [ ${install_flag} == "true" ]; then
  if [ ${log_flag} == "true" ]; then
    install | sudo tee -a "${log_dir}/${log_file}"
  else
    install
  fi
fi

if [ ${translate_flag} == "true" ]; then
  if [ ${log_flag} == "true" ]; then
    echo "Translating PDF/JPG/PNG Files"
    translate | sudo tee -a "${log_dir}/${log_file}"
  else
    translate
  fi
fi

if [ ${translate_text_only} == "true" ]; then
  if [ ${log_flag} == "true" ]; then
    echo "Translating Text Files"
    translate_text | sudo tee -a "${log_dir}/${log_file}"
  else
    translate_text
  fi
fi