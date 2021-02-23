#!/bin/bash

function usage(){
  echo -e "\nUsage: "
  echo "sudo ./provision_system.sh -h [Help]"
  echo "sudo ./provision_system.sh --help [Help]"
  echo "sudo ./provision_system.sh -p [Install and configure all available applications]"
  echo "sudo ./provision_system.sh --provision [Install and configure all available applications]"
  echo "sudo ./provision_system.sh provision [Install and configure all available applications]"
  echo "sudo ./provision_system.sh -p -a tmux,git,openssh [Install and configure applications]"
  echo "sudo ./provision_system.sh --provision --applications vlc,fstab,ffmpeg [Install and configure applications]"
  echo "sudo ./provision_system.sh -p -i -a tmux,git,openssh [Install only flag will only install, not configure applications]"
  echo "sudo ./provision_system.sh provision --install_only tmux,git,openssh [Install only flag will only install, not configure applications]"
  echo -e "\nFlags: "
  echo "-h | --help "
  echo "-i | --install_only "
  echo "-a | --aplications "
  echo "-d | --download-directory "
  echo -e "-p | --provision | provision \n"
}

function provision(){
  update
  for app in "${apps[@]}"
  do
    echo "Installing: ${app}"
    if [[ "${app}" == "adb" ]]; then
      adb_install
    elif [[ "${app}" == "chrome" ]]; then
      chrome_install
    elif [[ "${app}" == "docker" ]]; then
      docker_install
    elif [[ "${app}" == "dos2unix" ]]; then
      dos2unix_install
    elif [[ "${app}" == "ffmpeg" ]]; then
      ffmpeg_install
    elif [[ "${app}" == "fstab" ]]; then
      fstab_install
    elif [[ "${app}" == "gimp" ]]; then
      gimp_install
    elif [[ "${app}" == "git" ]]; then
      git_install
    elif [[ "${app}" == "gnome-theme" ]]; then
      gnome-theme_install
    elif [[ "${app}" == "gparted" ]]; then
      gparted_install
    elif [[ "${app}" == "hypnotix" ]]; then
      hypnotix_install
    elif [[ "${app}" == "kvm" ]]; then
      kvm_install
    elif [[ "${app}" == "nfs" ]]; then
      nfs_install
    elif [[ "${app}" == "openssh" ]]; then
      openssh_install
    elif [[ "${app}" == "phoronix" ]]; then
      phoronix_install
    elif [[ "${app}" == "python" ]]; then
      python_install
    elif [[ "${app}" == "pycharm" ]]; then
      pycharm_install
    elif [[ "${app}" == "redshift" ]]; then
      redshift_install
    elif [[ "${app}" == "rygel" ]]; then
      rygel_install
    elif [[ "${app}" == "steam" ]]; then
      steam_install
    elif [[ "${app}" == "startup-disk-creator" ]]; then
      startup-disk-creator_install
    elif [[ "${app}" == "tmux" ]]; then
      tmux_install
    elif [[ "${app}" == "transmission" ]]; then
      transmission_install
    elif [[ "${app}" == "vlc" ]]; then
      vlc_install
    elif [[ "${app}" == "wine" ]]; then
      wine_install
    elif [[ "${app}" == "wireshark" ]]; then
      wireshark_install
    elif [[ "${app}" == "youtube-dl" ]]; then
      youtube-dl_install
    else
      echo "ERROR: ${app} not found"
    fi
  done
}

function update(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		# Updating packages from repositories.
    sudo apt update
    # Install update manager
    sudo apt install update-manager-core -y

    # Upgrading Packages
    sudo apt upgrade -y

    # Upgrading Distrubution
    sudo apt dist-upgrade -y

    # House Cleaning
    # The first line will remove/fix any residual/broken packages if any.
    sudo apt --purge autoremove -y
    # The clean command removes all old .deb files from the apt cache (/var/cache/apt/archives)
    sudo apt clean all -y
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum check-update
		sudo yum install epel-release -y
    sudo yum update -y
    sudo yum upgrade
    sudo yum clean all
  else
    echo "Cannot update. ${os_version} not supported"
	fi
}

function chrome_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		if [[ "${architecture}" == "x86_64" ]]; then
      cd "${download_dir}" || echo "Directory not found or does not exist"
      sudo apt install curl wget -y
      wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
      sudo apt install "${download_dir}/google-chrome-stable_current_amd64.deb"
      rm -rf "${download_dir}/google-chrome-stable_current_amd64.deb"
    elif [[ "${architecture}" == "x86" ]]; then
      cd "${download_dir}" || echo "Directory not found or does not exist"
      sudo apt install curl wget -y
      wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
      sudo apt install "${download_dir}/google-chrome-stable_current_i386.deb"
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
    # Start Docker
    sudo systemctl start docker
    # Enable Docker at Startup
    sudo systemctl enable docker
    #Hello world
    sudo docker run hello-world
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function dos2unix_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y dos2unix
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y dos2unix
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function tmux_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y tmux
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y tmux
  else
    echo "Distribution ${os_version} not supported"
	fi
}

# Rygel (DLNA)
function rygel_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y rygel
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y rygel
  else
    echo "Distribution ${os_version} not supported"
	fi
	if [[ ${config_flag} == "true" ]]; then
	  echo "uris=/media/${computer_user}/Movies/Movies" | sudo tee -a /etc/rygel.conf
	fi
}

# FFMPEG
function ffmpeg_install(){
  echo "Installing FFMPEG"
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y ffmpeg
		echo "FFMPEG Installed!"
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum -y update
    # Install mlocate (Will be needed to locate pycharm.sh path
    sudo yum -y install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel
    # Add Repo
    sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    sudo yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
    sudo yum -y install http://rpmfind.net/linux/epel/7/x86_64/Packages/s/SDL2-2.0.10-1.el7.x86_64.rpm
    # Install FFmpeg
    sudo yum -y install ffmpeg ffmpeg-devel
    echo "FFMPEG Installed!"
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function fstab_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y ntfs-3g
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y ntfs-3g
  else
    echo "Distribution ${os_version} not supported"
	fi
	if [[ ${config_flag} == "true" ]]; then
	  sudo mkdir "/media/${computer_user}/hdd_storage"
    sudo mkdir "/media/${computer_user}/file_storage"
    sudo mkdir "/media/${computer_user}/windows"
    sudo mkdir "/media/${computer_user}/movies"
    sudo mkdir "/media/${computer_user}/games"

    # If these fstab directories exist, update them. Otherwise create an entry for them.
    sudo grep -q '^/dev/sda1' /etc/fstab && sudo sed -i "s#/dev/sda1.*#/dev/sda1 /media/${computer_user}/hdd_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sda1 /media/${computer_user}/hdd_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
    sudo grep -q '^/dev/sdb2' /etc/fstab && sudo sed -i "s#/dev/sdb2.*#/dev/sdb2 /media/${computer_user}/file_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sdb2 /media/${computer_user}/file_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
    sudo grep -q '^/dev/sdc4' /etc/fstab && sudo sed -i "s#/dev/sdc4.*#/dev/sdc4 /media/${computer_user}/windows ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sdc4 /media/${computer_user}/windows ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
    sudo grep -q '^/dev/sde2' /etc/fstab && sudo sed -i "s#/dev/sde2.*#/dev/sde2 /media/${computer_user}/movies ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sde2 /media/${computer_user}/movies ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
    sudo grep -q '^/dev/sdf2' /etc/fstab && sudo sed -i "s#/dev/sdf2 /media/${computer_user}/games ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sdf2 /media/${computer_user}/games ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
    sudo mount -a
	fi
}


function gimp_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y gimp
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y gimp
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function git_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y git
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y git
  else
    echo "Distribution ${os_version} not supported"
	fi
	if [[ ${config_flag} == "true" ]]; then
	  git config --global credential.helper store
	fi
}

function gnome-theme_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y snapd gnome-tweaks gnome-shell-extensions gnome-shell-extension-ubuntu-dock
		sudo snap install orchis-themes
	  for i in $(snap connections | grep gtk-common-themes:gtk-3-themes | awk '{print $2}'); do sudo snap connect $i orchis-themes:gtk-3-themes; done
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		echo "For Ubuntu Only, not compatible with CentOS"
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function gparted_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y gparted
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y gparted
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function hypnotix_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		hypnotix_git="https://github.com/linuxmint/hypnotix/releases/download/1.1/hypnotix_1.1_all.deb"
    wget -O /tmp/hypnotix.deb "${hypnotix_git}"
    sudo apt install /tmp/hypnotix.deb -y
    rm /tmp/hypnotix.deb
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		echo "No Installation Client for ${os_version} available yet"
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function kvm_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		# Install Dependencies
    sudo apt install curl wget bridge-utils cpu-checker qemu-kvm virtinst libvirt-daemon virt-manager -y
    kvm-ok

    # Enable libvirtd service
    sudo systemctl enable --now libvirtd
    lsmod | grep -i kvm

    # create the network.xml file
    sudo echo '<network>
    <name>vmbr0</name>
    <forward mode="route"/>
    <bridge name="vmbr0" stp="on" delay="0"/>
      <ip address="192.168.0.1" netmask="255.255.0.0">
        <dhcp>
          <range start="192.168.0.2" end="192.168.255.254"/>
        </dhcp>
      </ip>
    </network>' >> network.xml

    sudo cp ./network.xml /root/
    cat /root/network.xml
    # will define, create, and start our new network.
    sudo virsh net-define /root/network.xml
    sudo virsh net-autostart vmbr0
    sudo virsh net-start vmbr0
    # delete the default private network, this is not required but you can if you prefer to delete it
    #sudo virsh net-destroy default
    #sudo virsh net-undefine default
    # restart the libvirt daemon.
    sudo systemctl restart libvirtd.service
    # Enable IPv4 and IPv6 packet forwarding!
    sudo sed -i "/net.ipv4.ip_forward=1/ s/# *//" /etc/sysctl.conf
    sudo sed -i "/net.ipv6.conf.all.forwarding=1/ s/# *//" /etc/sysctl.conf
    # Reload sysctl for the packet forwarding changes to be applied.
    sudo sysctl -p

    vm=c8-02g ; time sudo virt-install --name "${vm}" \
    --memory 2048 \
    --vcpus=1 \
    --os-variant=centos7.0 \
    --accelerate \
    --graphics none \
    --disk path=/var/lib/libvirt/images/"${vm}".qcow2,size=10 \
    --location /home/mrdr/Downloads/CentOS-8.2.2004-x86_64-dvd1.iso \
    --initrd-inject=/home/mrdr/Documents/automation/bash/Ubuntu/ks.cfg \
    --debug \
    --network bridge=vmbr0 \
    --console pty,target_type=serial \
    --extra-args "console=ttyS0,115200n8 serial auto=true priority=critical ks=file:/ks.cfg SERVERNAME=${vm} net.ifnames=0 biosdevname=0"
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		yum -y install @virt* dejavu-lgc-* xorg-x11-xauth tigervnc \ libguestfs-tools policycoreutils-python bridge-utils

    # Set Sellinux context
    semanage fcontext -a -t virt_image_t "/vm(/.*)?"; restorecon -R /vm

    # Allow packet forwarding
    sed -i 's/^\(net.ipv4.ip_forward =\).*/\1 1/' /etc/sysctl.conf; sysctl -p

    # Configure libvirtd
    chkconfig libvirtd on; shutdown -r now
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function nfs_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y curl wget nfs-common nfs-kernel-server net-tools
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y nfs-utils nfs-utils-lib
  else
    echo "Distribution ${os_version} not supported"
	fi
	if [[ ${config_flag} == "true" ]]; then
	  # Create directory
    nfs_directory="/mnt/nfs/"
    sudo mkdir ${nfs_directory} -p
    ls -la ${nfs_directory}
    sudo chown -R nobody:nogroup ${nfs_directory}
    sudo chmod 777 ${nfs_directory}

    # Acquire My IP address for the NFS Server
    my_interface=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1{split($2,a," ");print a[1]}')
    my_ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
    my_netmask=$(/sbin/ifconfig "${my_interface}" | awk '/inet /{ print $4;} ')
    my_ip_subnet=$(ip -o -f inet addr show | awk '/scope global/ {print $2 " " $4}' | grep "${my_interface}" | awk '{print $2}')
    printf "${my_interface} \n${my_ip} \n${my_netmask} \n${my_ip_subnet}\n\n\n\n"

    # Add the directory desired to /etc/exports file
    echo "${nfs_directory}  *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports

    # Export the NFS Share Directory
    sudo exportfs -a

    # Restart NFS Kernel Server
    sudo systemctl restart nfs-kernel-server
    sudo systemctl enable nfs-kernel-server

    # Fix Firewall (IF ACTIVE)
    #sudo ufw status
    #sudo ufw allow from client_ip to any port nfs
    #sudo ufw status
	fi
}

function openssh_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y nmap openssh-server

    # Start SSH
    /etc/init.d/ssh start || echo "Already Started"

    # Create Firewall Rule for SSH
    sudo ufw allow ssh
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum –y install openssh-server openssh-clients
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function phoronix_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y phoronix-test-suite
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y wget php-cli php-xml bzip2 json php-pear php-devel gcc make php-pecl-json
		# Download Phoronix rpm
    cd /tmp || echo "Could not find /tmp directory"
    wget https://phoronix-test-suite.com/releases/phoronix-test-suite-9.8.0.tar.gz
    # Unzip in Downloads
    sudo tar xvfz phoronix-test*.tar.gz
    cd phoronix-test-suite || echo "Could not find phoronix directory"
    sudo ./install-sh
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function python_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y mlocate
		sudo updatedb
    # Install Python 3.X and 3.8
    sudo apt install -y python3 python3-pip build-essential python3-pil python3-pil.imagetk zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev python-tk python3-tk tk-dev gcc git tcl-thread snapd
    # Update PIP
    sudo python3 -m pip install --upgrade pip
    # Install Python Packages
  	sudo python3 -m pip install autoconf setuptools wheel git+https://github.com/nficano/pytube regex requests tqdm selenium mutagen tkthread pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle pypyodbc sqlalchemy pyhive ffmpeg-python m3u8 aiohttp
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
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
    sudo yum install gcc git python3-devel python3-pil.imagetk python38-devel openssl-devel tcl-thread xz-libs bzip2-devel libffi-devel python3-tkinter python38-tkinter -y
    # Set Git Credential Store Globally
    sudo git config --global credential.helper store
    # Install Python Packages
    sudo python3 -m pip install autoconf setuptools wheel pytube3 regex requests tqdm selenium mutagen tkthread Pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle pypyodbc sqlalchemy pyhive cx_freeze ffmpeg-python m3u8 aiohttp
    sudo python3.8 -m pip install autoconf setuptools wheel pytube3 regex requests tqdm selenium mutagen tkthread Pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle pypyodbc sqlalchemy pyhive cx_freeze ffmpeg-python m3u8 aiohttp
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function pycharm_install(){
	if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y mlocate
		sudo updatedb
    # Install Python 3.X and 3.8
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
	elif [[ "${os_version}" == "CentOS Linux" ]] ; then
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
  else
    echo "Distribution ${os_version} not supported"
	fi
	if [[ ${config_flag} == "true" ]]; then
	  git config --global credential.helper store
	fi
}

function redshift_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y redshift redshift-gtk
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y redshift redshift-gtk
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function software-updater_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y update-manager synaptic
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		echo "For Ubuntu Only, not compatible with CentOS"
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function startup-disk-creator_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y usb-creator-gtk
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		echo "For Ubuntu Only, not compatible with CentOS"
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function steam_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y steam
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-0.2.noarch.rpm -y
    sudo yum install http://download1.rpmfusion.org/free/fedora/releases/19/Everything/i386/os/libtxc_dxtn-1.0.0-3.fc19.i686.rpm -y
    sudo yum --enablerepo=steam_fedora19 install steam -y
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function transmission_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y transmission-qt transmission-cli transmission-daemon
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y transmission-qt transmission-cli transmission-daemon
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function youtube-dl_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y youtube-dl
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y youtube-dl
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function vlc_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y vlc
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    sudo yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
    sudo yum -y install vlc
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function wine_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		sudo apt install -y wine
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y wine
  else
    echo "Distribution ${os_version} not supported"
	fi
}

function wireshark_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
		echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
	  sudo DEBIAN_FRONTEND=noninteractive apt install wireshark -y
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
		sudo yum install -y wireshark wireshark-qt
  else
    echo "Distribution ${os_version} not supported"
	fi
}

computer_user=$(getent passwd {1000..6000} | awk -F: '{ print $1}')
apps=( "adb" "chrome" "docker" "dos2unix" "ffmpeg" "fstab" "gimp" "git" "gnome-theme" "gparted" "hypnotix" "kvm" "nfs" "openssh" "openvpn" "phoronix" "python" "pycharm" "redshift" "rygel" "steam" "startup-disk-creator" "tmux" "transmission" "vlc" "wine" "wireshark" "youtube-dl" )
config_flag='true'
provision_flag='false'
download_dir="/tmp"
os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"
architecture="$(uname -m)"

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
    i | -i | --install_only | install_only)
      echo "Installing only, not configuring any applications"
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
      shift
      ;;
    a | -a | --applications)
      if [ ${2} ]; then
        IFS=',' read -r -a apps <<< "$2"
        echo "Apps to install: ${apps[*]}"
        shift
      else
        echo 'ERROR: "-a | --applications" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    p | -p | --provision | provision)
      echo "Provisioning System"
      echo "Operating System: ${os_version}"
      echo "Architecture: ${architecture}"
      echo "User: ${computer_user}"
      provision_flag='true'
      shift
      ;;
    --)# End of all options.
      echo "test 1"
      shift
      break
      ;;
    -?*)
      printf 'WARNING: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *)
      echo "test 2"
      shift
      break
      ;;
  esac
done

if [ ${provision_flag} == "true" ]; then
  provision
else
  exit 0
fi