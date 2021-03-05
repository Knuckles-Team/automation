#!/bin/bash

function usage(){
  echo "Usage:"
  echo "sudo ./stat_log.sh install"
  echo "sudo ./stat_log.sh -r <*optional* runtime (seconds)>"
  echo "Example:"
  echo "sudo ./stat_log.sh -r"
  echo "sudo ./stat_log.sh --run 600"
}

function detect_os(){
  os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  os_version="${os_version:1:-1}"
  echo "${os_version}"
  if [[ $os_version = "Ubuntu" ]] ; then
    echo "Installing for Ubuntu"
    ubuntu_install
  elif [[ $os_version = "CentOS Linux" ]] ; then
    echo "Installing for CentOS"
    centos_install
  else 
    echo "Distribution ${os_version} not supported"
  fi
}

function ubuntu_install(){
  sudo apt update
  sudo apt install sysstat net-tools dos2unix -y

}

function centos_install(){
  sudo yum install epel-release -y
  sudo yum install sysstat net-tools dos2unix -y
}

function backup_logs(){
  echo "Backing up previous logs..."
  if [ -e "${vmstat_log}" ]
  then
    mv "${vmstat_log}" "${vmstat_log}.bak"
    echo "Successfully backed up vmstat log"
  else
    echo "Previous vmstat log does not exist"
  fi
  if [ -e "${iostat_log}" ]
  then
    mv "${iostat_log}" "${iostat_log}.bak"
    echo "Successfully backed up iostat log"
  else
    echo "Previous iostat log does not exist"
  fi
  if [ -e "${turbostat_log}" ]
  then
    mv "${turbostat_log}" "${turbostat_log}.bak"
    echo "Successfully backed up turbostat log"
  else
    echo "Previous turbostat log does not exist"
  fi
  if [ -e "${numastat_log}" ]
  then
    mv "${numastat_log}" "${numastat_log}.bak"
    echo "Successfully backed up numastat log"
  else
    echo "Previous numastat log does not exist"
  fi
  if [ -e "${mpstat_log}" ]
  then
    mv "${mpstat_log}" "${mpstat_log}.bak"
    echo "Successfully backed up mpstat log"
  else
    echo "Previous mpstat log does not exist"
  fi
  if [ -e "${netstat_log}" ]
  then
    mv "${netstat_log}" "${netstat_log}.bak"
    echo "Successfully backed up netstat log"
  else
    echo "Previous netstat log does not exist"
  fi
}

function display_logs(){
  cat "${vmstat_log}"
  cat "${iostat_log}"
  cat "${turbostat_log}"
  cat "${numastat_log}"
  cat "${mpstat_log}"
  cat "${netstat_log}"
}

function clean_logs(){
  dos2unix -f "${vmstat_log}"
  dos2unix -f "${iostat_log}"
  dos2unix -f "${turbostat_log}"
  dos2unix -f "${numastat_log}"
  dos2unix -f "${mpstat_log}"
  dos2unix -f "${netstat_log}"
}

function show_processes(){
  ps -a
  echo "vmstat pid: ${vmstat_pid}"
  echo "iostat pid: ${iostat_pid}"
  echo "turbostat pid: ${turbostat_pid}"
  echo "numastat pid: ${numastat_pid}"
  echo "mpstat pid: ${mpstat_pid}"
  echo "netstat pid: ${netstat_pid}"
}

function create_files(){
  echo "Creating new logfiles..."
  echo -e "User: ${computer_user}\nDate: ${date}\nOperating System: ${os_version}\nArchitecture: ${architecture}" >> "${log_dir}/${vmstat_log}"
  echo -e "User: ${computer_user}\nDate: ${date}\nOperating System: ${os_version}\nArchitecture: ${architecture}" >> "${log_dir}/${iostat_log}"
  echo -e "User: ${computer_user}\nDate: ${date}\nOperating System: ${os_version}\nArchitecture: ${architecture}" >> "${log_dir}/${turbostat_log}"
  echo -e "User: ${computer_user}\nDate: ${date}\nOperating System: ${os_version}\nArchitecture: ${architecture}" >> "${log_dir}/${numastat_log}"
  echo -e "User: ${computer_user}\nDate: ${date}\nOperating System: ${os_version}\nArchitecture: ${architecture}" >> "${log_dir}/${mpstat_log}"
  echo -e "User: ${computer_user}\nDate: ${date}\nOperating System: ${os_version}\nArchitecture: ${architecture}" >> "${log_dir}/${netstat_log}"
  echo "Logfiles created successfully"
}

function log_stat(){
  backup_logs
  create_files

  # vmstat
  #script -c 'vmstat -t 10' -f "${vmstat_log}" &
  vmstat -t 10 >> "${log_dir}/${vmstat_log}" &
  vmstat_pid="${!}"

  # iostat
  #script -c 'iostat -t 10' -f "${iostat_log}" &
  iostat -t 10 >> "${log_dir}/${iostat_log}" &
  iostat_pid="${!}"

  # turbostat
  #script -c 'turbostat --debug --interval 10' -f "${turbostat_log}" &
  turbostat --debug --interval 10 >> "${log_dir}/${turbostat_log}" &
  turbostat_pid="${!}"

  # mpstat
  #script -c 'mpstat -P ALL' -f "${vmstat_log}" &
  mpstat -P ALL >> "${log_dir}/${vmstat_log}" &
  mpstat_pid="${!}"

  # Run for schedule time
  for ((t=1; t<=${run_time}; t++))
  do
    if (( ${t} % 10 == 0 )) && [ ${t} -ge 10 ]; then
      # numastat
      #script -c 'numastat' -f "${numastat_log}" &
      numastat >> "${log_dir}/${numastat_log}" &
      numastat_pid="${!}"
      # netstat
      #script -c 'netstat' -f "${netstat_log}" &
      netstat >> "${log_dir}/${netstat_log}" &
      netstat_pid="${!}"
    fi
    loading_message "${run_time}" "${t}"
    if [[ "${t}" = "${run_time}" ]]; then
      show_processes
      kill -9 "${vmstat_pid}"
      kill -9 "${iostat_pid}"
      kill -9 "${turbostat_pid}"
      kill -9 "${numastat_pid}"
      kill -9 "${mpstat_pid}"
      kill -9 "${netstat_pid}"
      show_processes
    fi
    sleep 1
  done

#  clean_logs
#  display_logs
}

function loading_message(){
  # Usage: loading_message <total> <iteration>
  time_left=$( echo "${1}-${2}" | bc -l )
  percent_left=$(echo "${2}/${1}*100" | bc -l)
  percent_left=$(echo "${percent_left}" | cut -c1-5)
  loading_bar_percentage=$(( $(printf "%.*f\n" "0" "${percent_left}")/10 ))
  loading_bar=""
  for ((x=1;x<=10;x++))
  do
    if [[ "${x}" -le "${loading_bar_percentage}" ]]; then
      loading_bar="${loading_bar}#"
    else
      loading_bar="${loading_bar} "
    fi
  done
  echo -ne "Time Remaining: ${time_left} | Remaining: ${2}/${1} | Percent Complete: ${percent_left} | [${loading_bar}] \r"
}

date=$(date +"%m-%d-%Y_%I-%M")
computer_user=$(getent passwd {1000..6000} | awk -F: '{ print $1}')
os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"
architecture="$(uname -m)"
log_dir="$(pwd)/logs"
log_file="stat_log_${date}.log"
vmstat_log="vmstat_${date}.log"
iostat_log="iostat_${date}.log"
turbostat_log="turbostat_${date}.log"
numastat_log="numastat_${date}.log"
mpstat_log="mpstat_${date}.log"
netstat_log="netstat_${date}.log"
run_flag="false"

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
    l | -l | --log)
      if [[ ${2:0:1} == "/" ]] || [[ ${2:0:1} == "." ]] || [[ ${2:0:1} == "~" ]]; then
        log_dir="${2}"
        shift
      elif [[ ${2:0:1} == "-" ]]; then
        echo "No log directory specified or it must start with / . or ~, using $(pwd)/log instead"
      else
        echo "No log directory specified or it must start with / . or ~, using $(pwd)/log instead"
      fi
      shift
      ;;
    r | -r | --run)
      if [[ "${2}" ]] ; then
        run_time="${2}"
        shift
      else
        run_time="30"
      fi
      run_flag='true'
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

if [ ${run_flag} == "true" ]; then
  mkdir -p "${log_dir}"
  log_stat | sudo tee -a "${log_dir}/${log_file}"
else
  exit 0
fi
