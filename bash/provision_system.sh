#!/bin/bash

function provision(){
  readarray -d '' install_scripts < <(find . -name "*_install.sh" -print0)
  readarray -d '' upgrade_scripts < <(find . -name "os_upgrade.sh" -print0)
  run_scripts=( "${upgrade_scripts[@]}" "${install_scripts[@]}" )
  echo "Upgrade OS & Installing all applications"
  for ((script=0;script<${#run_scripts[*]};script++))
  do
    echo "Running ${script}"
    sudo "${run_scripts[script]}"
  done
  echo "System Provisioned Successfully"
}

provision
