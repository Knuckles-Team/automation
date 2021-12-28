#!/bin/bash

# This script installs i7z on Ubuntu or CentOS
# Source: https://code.google.com/archive/p/i7z/
# Man Page: http://manpages.ubuntu.com/manpages/trusty/man1/i7z.1.html
os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"

if [[ "${os_version}" == "Ubuntu" ]] ; then
  apt update
  apt install -y libncurses5-dev libncursesw5-dev msr-tools
  apt install -y i7z
  wget -nc --directory-prefix "./" http://i7z.googlecode.com/svn/trunk/i7z_rw_registers.rb
  sudo modprobe msr
elif [[ "${os_version}" == "CentOS Linux" ]] ; then
  yum install -y wget gcc make git ncurses-devel msr-tools
  if [[ -d "i7z" ]]; then
    echo "i7z exists on your filesystem."
  else
    git clone https://github.com/ajaiantilal/i7z.git
  fi
  cd i7z || echo "i7z was not cloned"
  make
  wget -nc --directory-prefix "./" http://i7z.googlecode.com/svn/trunk/i7z_rw_registers.rb
  sudo modprobe msr
else
  echo "Distribution ${os_version} not supported"
fi

log="cpu_freq_log_dual.txt"
i7z --write a --nogui --logfile "${log}"
