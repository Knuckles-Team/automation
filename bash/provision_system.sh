#!/bin/bash

function usage(){
  echo "Used this way"
}

function provision(){
  for app in "${apps[@]}"
  do
    echo "Installing: ${app}"
    if [[ "${app}" == "chrome" ]]; then
      chrome_install
    elif [[ "${app}" == "adb" ]]; then
      adb_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "dos2unix" ]]; then
      dos2unix_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    fi
  done
}

function chrome_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		if [[ "${architecture}" == "x86_64" ]]; then
      cd "${download_dir}" || echo "Directory not found or does not exist"
      sudo apt update
      sudo apt install curl wget -y
      wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
      sudo apt install "${download_dir}/google-chrome-stable_current_amd64.deb"
      sudo apt update
      rm -rf "${download_dir}/google-chrome-stable_current_amd64.deb"
    elif [[ "${architecture}" == "x86" ]]; then
      cd "${download_dir}" || echo "Directory not found or does not exist"
      sudo apt update
      sudo apt install curl wget -y
      wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
      sudo apt install "${download_dir}/google-chrome-stable_current_i386.deb"
      sudo apt update
      rm -rf "${download_dir}/google-chrome-stable_current_i386.deb"
    elif [[ "${architecture}" == "aarch64" ]] || [[ "${architecture}" == "aarch32" ]]; then
      sudo apt install -y chromium-browser
    fi
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		cd "${download_dir}" || echo "Directory not found or does not exist"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    sudo yum install "${download_dir}/google-chrome-stable_current_x86_64.rpm"
    rm -rf "${download_dir}/google-chrome-stable_current_amd64.rpm"
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function adb_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install android-tools-adb android-tools-fastboot -y
	  adb version
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install epel-release -y
    sudo yum install snapd -y
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap
    sudo snap install android-adb --edge
    adb version
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function docker_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt update
    sudo apt install -y containerd docker.io docker-compose
    sudo docker run hello-world
    # Start Docker
    sudo systemctl start docker
    # Enable Docker at Startup
    sudo systemctl enable docker
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install docker-ce docker-ce-cli containerd.io -y
    sudo docker run hello-world
    # Start Docker
    sudo systemctl start docker
    # Enable Docker at Startup
    sudo systemctl enable docker
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function dos2unix_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install  -y dos2unix
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y dos2unix
  else
    echo "Distribution ${os_version} not supported"
	fi
}

apps=( "chrome" "adb" "tmux" "dos2unix" "dlna" "docker" "ffmpeg" "gimp" "git" "gparted" "hypnotix" "kvm" "nfs" "openssh" "openvpn" "phoronix" "python" "steam" "transmission" "video_tools" "vlc" "wine" "wireshark" )
config_flag='true'
download_dir="/tmp"
os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"
architecture="$(uname -m)"
echo "Operating System: ${os_version}"
echo "Architecture: ${architecture}"

while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      usage
      exit 0
      ;;
    i | -i | --install_only | install_only)
      config_flag='false'
      shift
      ;;
    d | -d | --download-directory)
      if [ ${2} ]; then
        download_dir="${2}"
        shift
      else
        echo 'ERROR: "-d | --download-directory" requires a non-empty option argument.'
        exit 0
      fi
      ;;
    a | -a | --applications)
      if [ ${2} ]; then
        IFS=',' read -r -a apps <<< "$2"
        echo "LINKS: ${apps[*]}"
        shift
      else
        echo 'ERROR: "-a | --applications" requires a non-empty option argument.'
        exit 0
      fi
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
  shift
done

provision