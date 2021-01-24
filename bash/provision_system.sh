#!/bin/bash

function loading_message(){
	# Usage: loading_message <total> <iteration>
	additional_message="${3}"
	if [[ "${additional_message}" ]]; then
    additional_message="| ${additional_message}"
  fi
	total_left=$( echo "${1}-${2}" | bc -l )
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
	echo -ne "Total Remaining: ${total_left} | Ratio: ${2}/${1} | Percent Complete: ${percent_left} | [${loading_bar}] ${additional_message}\r"
}

function provision(){
  #set -x
  provision_log="./provision_log.txt"
  readarray -d '' install_scripts < <(find . -name "*_install.sh" -print0)
  readarray -d '' upgrade_scripts < <(find . -name "os_upgrade.sh" -print0)
  run_scripts=( "${upgrade_scripts[@]}" "${install_scripts[@]}" )
  echo "Upgrade OS & Installing all applications"
  for ((script=0;script<${#run_scripts[*]};script++))
  do
    #loading_message "${run_scripts[script]}" "$((script+1))" "Running ${script}"
    echo "Running ${script}"
    sudo "${run_scripts[script]}" #>> "${provision_log}"
  done
  echo "System Provisioned Successfully"
}

provision
