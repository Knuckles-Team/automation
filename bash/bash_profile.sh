#!/bin/bash

echo "Adding Paths"
if grep -q "alias Development=" $HOME/.bashrc; then
  sed -i "s/alias Development=.*$/alias Development='cd /mnt/c/Users/knuck/Development'/" $HOME/.bashrc
else
  echo "alias Development='cd /mnt/c/Users/knuck/Development'" | tee -a $HOME/.bashrc
fi

echo "Setting bash ssh profiles"
alias=${1}
username=${2}
password=${3}
address=${4}

if grep -q "alias ${alias}=" $HOME/.bashrc; then
  sed -i "s/alias ${alias}=.*$/alias jumphost='sshpass -p '${password}' ssh -o stricthostkeychecking=no ${username}@${address}'/" $HOME/.bashrc
else
  echo "alias ${alias}='sshpass -p '${password}' ssh -o stricthostkeychecking=no ${username}@${address}'" | tee -a $HOME/.bashrc
fi

source $HOME/.bashrc
echo "Finished updating bash profile"