#!/bin/bash

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
	# Update Packages
	sudo apt -y update
	# Install mlocate (Will be needed to locate pycharm.sh path
	sudo apt -y install mlocate
	sudo updatedb
	# Install Python 3.X and 3.8
	sudo apt install python3 python3-pip python3-tk -y
	# Update PIP
	sudo python3 -m pip install --upgrade pip
	# Install Python Depedencies
	sudo apt install gcc git tcl-thread -y 
	# Set Git Credential Store Globally
	sudo git config --global credential.helper store
	# Install Python Packages
	sudo python3 -m pip install autoconf setuptools wheel git+https://github.com/nficano/pytube regex requests tqdm selenium mutagen tkthread pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle pypyodbc sqlalchemy pyhive cx_freeze ffmpeg-python m3u8 aiohttp
	# Add EPEL repository
	# Install snapd package manager (Contains all depedencies packaged together)
	sudo apt install snapd -y
	# Systemmd unit that managed the main snap communication sockets needs to be enabled.
	sudo systemctl enable --now snapd.socket
	# Sleep for 5 seconds to allow for system link creation.
	date +"%H:%M:%S"
	sleep 5
	date +"%H:%M:%S"
	# To enable classic snap support, this creates a symbolic link between /var/lib/snapd/snap and /snap
	sudo ln -s /var/lib/snapd/snap /snap
	# Install PyCharm CE
	sudo snap install pycharm-community --classic
	# Locate PyCharm Installation Path 
	sudo updatedb
	pycharm_path=$(sudo locate pycharm.sh)
	# Launch PyCharm as Root
	echo $pycharm_path
}

function centos_install(){
	# Update Packages
	sudo yum -y update
	# Install mlocate (Will be needed to locate pycharm.sh path
	sudo yum -y install mlocate
	sudo updatedb
	# Install Python 3.X and 3.8
	sudo yum install python3 -y
	sudo yum install python38 -y
	# Update PIP
	sudo python3 -m pip install --upgrade pip
	sudo python3.8 -m pip install --upgrade pip
	# Install Python Depedencies
	sudo yum install gcc git python3-devel python38-devel openssl-devel tcl-thread xz-libs bzip2-devel libffi-devel python3-tkinter python38-tkinter -y 
	# Set Git Credential Store Globally
	sudo git config --global credential.helper store
	# Install Python Packages
	sudo python3 -m pip install autoconf setuptools wheel pytube3 regex requests tqdm selenium mutagen tkthread pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle pypyodbc sqlalchemy pyhive cx_freeze ffmpeg-python m3u8 aiohttp
	sudo python3.8 -m pip install autoconf setuptools wheel pytube3 regex requests tqdm selenium mutagen tkthread pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle pypyodbc sqlalchemy pyhive cx_freeze ffmpeg-python m3u8 aiohttp
	# Add EPEL repository
	sudo yum install epel-release -y
	# Install snapd package manager (Contains all depedencies packaged together)
	sudo yum install snapd -y
	# Systemmd unit that managed the main snap communication sockets needs to be enabled.
	sudo systemctl enable --now snapd.socket
	# Sleep for 5 seconds to allow for system link creation.
	date +"%H:%M:%S"
	sleep 5
	date +"%H:%M:%S"
	# To enable classic snap support, this creates a symbolic link between /var/lib/snapd/snap and /snap
	sudo ln -s /var/lib/snapd/snap /snap
	# Install PyCharm CE
	sudo snap install pycharm-community --classic
	# Locate PyCharm Installation Path 
	sudo updatedb
	pycharm_path=$(sudo locate pycharm.sh)
	# Launch PyCharm as Root
	echo $pycharm_path
}

function main(){
  detect_os
}

main
