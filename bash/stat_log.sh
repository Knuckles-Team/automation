#!/bin/bash

function usage(){
	echo "Usage:"	
	echo "sudo ./stat_log.sh install"
	echo "sudo ./stat_log.sh run <*optional* runtime (seconds)>"
	echo "Example:"
	echo "sudo ./stat_log.sh run"
	echo "sudo ./stat_log.sh run 600"
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
	cat "${mpstat_log}"
	cat "${netstat_log}"
}

function clean_logs(){
	dos2unix -f "${vmstat_log}"
	dos2unix -f "${iostat_log}"
	dos2unix -f "${mpstat_log}"
	dos2unix -f "${netstat_log}"
}

function show_processes(){
	ps -a
	echo "vmstat pid: ${vmstat_pid}"			
	echo "iostat pid: ${iostat_pid}"	
	echo "mpstat pid: ${mpstat_pid}"	
	echo "netstat pid: ${netstat_pid}"	
}

function create_files(){
	mkdir -p "${log_dir}"
	echo "Creating new logfiles..."
	touch "${vmstat_log}"
	touch "${iostat_log}"
	touch "${mpstat_log}"
	touch "${netstat_log}"	
	echo "Logfiles created successfully"
}

function log_stat(){
	backup_logs
	create_files
	
	# vmstat	
	#script -t -c 'vmstat -t 10' > "${vmstat_log}" &
	#vmstat_pid="${!}"
	
	# iostat	
	#script -t -c 'iostat -t 10' > "${iostat_log}" &
	#iostat_pid="${!}"

	# mpstat	
	#script -t -c 'mpstat -P ALL' > "${mpstat_log}" &
	#mpstat_pid="${!}"
	show_processes
	# Run for schedule time	
	for ((t=1; t<=${run_time}; t++))
	do
		loading_message "${run_time}" "${t}"
		if (( ${t} % 10 == 0 )) && [ ${t} -ge 10 ] || [ ${t} -eq 0 ] ; then
			# netstat	
			script -t -c 'netstat' > "${netstat_log}" &
			netstat_pid="${!}"
		fi		
		if [[ "${t}" = "${run_time}" ]]; then 
			show_processes
			kill -9 "${vmstat_pid}"			
			kill -9 "${iostat_pid}"	
			kill -9 "${mpstat_pid}"	
			kill -9 "${netstat_pid}"	
		fi
		sleep 1
	done

	clean_logs
	#display_logs
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
	if [[ "${2}" -eq "${1}" ]]; then
		echo -ne "| Time Remaining: ${time_left} | Remaining: ${2}/${1} | Percent Complete: ${percent_left} | [${loading_bar}] | \n" 
	else
		echo -ne "| Time Remaining: ${time_left} | Remaining: ${2}/${1} | Percent Complete: ${percent_left} | [${loading_bar}] | \r" 
	fi
	
}

function main(){
	log_dir="/media/${USER}/file_storage/Documents/automation/bash/logs"	
	vmstat_log="${log_dir}/vmstat.txt"
	iostat_log="${log_dir}/iostat.txt"
	mpstat_log="${log_dir}/mpstat.txt"
	netstat_log="${log_dir}/netstat.txt"	
	run_time="${args[1]}"
	echo "${args[0]} ${args[1]} ${args[2]}"
	
	if [[ "${#args[@]}" -le 0 ]] ; then
    usage    
    exit 0
	elif [[ "${args[0]}" == "install" ]] ; then
		detect_os
  elif [[ "${args[0]}" == "run" ]] ; then
		# Check runtime; Run with default time if none was specified
		if [[ "${run_time}" -le "0" ]] ; then
			run_time="30"
		fi
    log_stat 
	else
		usage
		exit 0
	fi
}

args=${@}
main

