#!/bin/bash

function usage(){
  echo -e "\nUsage: "
  echo -e "sudo ./provision_system.sh -h [Help]"
  echo -e "sudo ./provision_system.sh --help [Help]"
  echo -e "sudo ./provision_system.sh -p [Install and configure all available applications]"
  echo -e "sudo ./provision_system.sh --provision [Install and configure all available applications]"
  echo -e "sudo ./provision_system.sh provision [Install and configure all available applications]"
  echo -e "sudo ./provision_system.sh -u [Update and upgrade computer]"
  echo -e "sudo ./provision_system.sh --update [Update and upgrade computer]"
  echo -e "sudo ./provision_system.sh -u -l [Update and upgrade computer and save results to log file]"
  echo -e "sudo ./provision_system.sh --update --log /home/${computer_user}/Desktop [Update and upgrade computer and save results to /home/${computer_user}/Desktop/provision_log_${date}.log]"
  echo -e "sudo ./provision_system.sh -u -p -a tmux,git,openssh [Update, Upgrade, then Install and configure applications]"
  echo -e "sudo ./provision_system.sh --update --provision --applications vlc,fstab,ffmpeg [Update, Upgrade, then Install and configure applications]"
  echo -e "sudo ./provision_system.sh -p -i -c -a tmux,git,openssh [Install only flag will only install, not configure applications]"
  echo -e "sudo ./provision_system.sh provision --install-only tmux,git,openssh [Install only flag will only install, not configure applications]"
  echo -e "\nFlags: "
  echo -e "-a | --aplications [Optional Parameter; Can specify specific applications to install]"
  echo -e "-c | --clean [Optional Parameter; Will clean the trash bin]"
  echo -e "-d | --download-directory [Optional Parameter; Must specify download directory - Default is /tmp]"
  echo -e "-i | --install-only | install-only [Optional Parameter; Will not configure any applications]"
  echo -e "-h | --help "
  echo -e "-l | --log [Optional Parameter; Can specify directory to store log]"
  echo -e "-p | --provision | provision [Optional Parameter; Will provision system with all applications or those specified]"
  echo -e "-u | --update | update [Optional Parameter; Will update system with the latest versions of OS and Apps]"
  echo -e "\nApps: \n${apps[*]} \n"
}

function clean_system(){
  trash-cli_install
  echo "Trash: "
  trash-list
  echo "Emptying recycling bin"
  trash-empty
}

# testing with server user provisioning
function server_provision(){
  set -euo pipefail
  # https://www.digitalocean.com/community/tutorials/automating-initial-server-setup-with-ubuntu-18-04
  ########################
  ### SCRIPT VARIABLES ###
  ########################

  # Name of the user to create and grant sudo privileges
  USERNAME=sammy

  # Whether to copy over the root user's `authorized_keys` file to the new sudo
  # user.
  COPY_AUTHORIZED_KEYS_FROM_ROOT=true

  # Additional public keys to add to the new sudo user
  # OTHER_PUBLIC_KEYS_TO_ADD=(
  #     "ssh-rsa AAAAB..."
  #     "ssh-rsa AAAAB..."
  # )
  OTHER_PUBLIC_KEYS_TO_ADD=(
  )

  ####################
  ### SCRIPT LOGIC ###
  ####################

  # Add sudo user and grant privileges
  useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"

  # Check whether the root account has a real password set
  encrypted_root_pw="$(grep root /etc/shadow | cut --delimiter=: --fields=2)"

  if [ "${encrypted_root_pw}" != "*" ]; then
    # Transfer auto-generated root password to user if present
    # and lock the root account to password-based access
    echo "${USERNAME}:${encrypted_root_pw}" | chpasswd --encrypted
    passwd --lock root
  else
    # Delete invalid password for user if using keys so that a new password
    # can be set without providing a previous value
    passwd --delete "${USERNAME}"
  fi

  # Expire the sudo user's password immediately to force a change
  chage --lastday 0 "${USERNAME}"

  # Create SSH directory for sudo user
  home_directory="$(eval echo ~${USERNAME})"
  mkdir --parents "${home_directory}/.ssh"

  # Copy `authorized_keys` file from root if requested
  if [ "${COPY_AUTHORIZED_KEYS_FROM_ROOT}" = true ]; then
    cp /root/.ssh/authorized_keys "${home_directory}/.ssh"
  fi

  # Add additional provided public keys
  for pub_key in "${OTHER_PUBLIC_KEYS_TO_ADD[@]}"; do
    echo "${pub_key}" >> "${home_directory}/.ssh/authorized_keys"
  done

  # Adjust SSH configuration ownership and permissions
  chmod 0700 "${home_directory}/.ssh"
  chmod 0600 "${home_directory}/.ssh/authorized_keys"
  chown --recursive "${USERNAME}":"${USERNAME}" "${home_directory}/.ssh"

  # Disable root SSH login with password
  sed --in-place 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
  if sshd -t -q; then
    systemctl restart sshd
  fi

  # Add exception for SSH and then enable UFW firewall
  ufw allow OpenSSH
  ufw --force enable
}

function provision(){
  for app in "${apps[@]}"
  do
    echo "Installing: ${app}"
    #"${app}_install"
    if [[ "${app}" == "adb" ]]; then
      adb_install
    elif [[ "${app}" == "audacity" ]]; then
      audacity_install
    elif [[ "${app}" == "android-studio" ]]; then
      android-studio_install
    elif [[ "${app}" == "atomicparsley" ]]; then
      atomicparsley_install
    elif [[ "${app}" == "chrome" ]]; then
      chrome_install
    elif [[ "${app}" == "chrome-remote-desktop" ]]; then
      chrome-remote-desktop_install
    elif [[ "${app}" == "dialog" ]]; then
      dialog_install
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
    elif [[ "${app}" == "gnome" ]]; then
      gnome_install
    elif [[ "${app}" == "gnome-theme" ]]; then
      gnome-theme_install
    elif [[ "${app}" == "gnucobol" ]]; then
      gnucobol_install
    elif [[ "${app}" == "ghostscript" ]]; then
      ghostscript_install
    elif [[ "${app}" == "gparted" ]]; then
      gparted_install
    elif [[ "${app}" == "hypnotix" ]]; then
      hypnotix_install
    elif [[ "${app}" == "kexi" ]]; then
      kexi_install
    elif [[ "${app}" == "kvm" ]]; then
      kvm_install
    elif [[ "${app}" == "nfs" ]]; then
      nfs_install
    elif [[ "${app}" == "neofetch" ]]; then
      neofetch_install
    elif [[ "${app}" == "openjdk" ]]; then
      openjdk_install
    elif [[ "${app}" == "openssh" ]]; then
      openssh_install
    elif [[ "${app}" == "mediainfo" ]]; then
      mediainfo_install
    elif [[ "${app}" == "mkvtoolnix" ]]; then
      mkvtoolnix_install
    elif [[ "${app}" == "phoronix" ]]; then
      phoronix_install
    elif [[ "${app}" == "powershell" ]]; then
      powershell_install
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
    elif [[ "${app}" == "stat_log" ]]; then
      stat_log_install
    elif [[ "${app}" == "startup-disk-creator" ]]; then
      startup-disk-creator_install
    elif [[ "${app}" == "sudo" ]]; then
      sudo_install
    elif [[ "${app}" == "scrcpy" ]]; then
      scrcpy_install
    elif [[ "${app}" == "tesseract" ]]; then
      tesseract_install
    elif [[ "${app}" == "tigervnc" ]]; then
      tigervnc_install
    elif [[ "${app}" == "tmux" ]]; then
      tmux_install
    elif [[ "${app}" == "transmission" ]]; then
      transmission_install
    elif [[ "${app}" == "trash-cli" ]]; then
      trash-cli_install
    elif [[ "${app}" == "translate-shell" ]]; then
      translate-shell_install
    elif [[ "${app}" == "udisks2" ]]; then
      udisks2_install
    elif [[ "${app}" == "vlc" ]]; then
      vlc_install
    elif [[ "${app}" == "wine" ]]; then
      wine_install
    elif [[ "${app}" == "wireshark" ]]; then
      wireshark_install
    elif [[ "${app}" == "youtube-dl" ]]; then
      youtube-dl_install
    elif [[ "${app}" == "xdotool" ]]; then
      xdotool_install
    elif [[ "${app}" == "xsel" ]]; then
      xsel_install
    else
      echo "ERROR: ${app} not found"
    fi
  done
}

function update(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" update
    sudo "${pkg_mgr}" autoremove -y
    sudo "${pkg_mgr}" install update-manager-core -y
    sudo "${pkg_mgr}" upgrade -y
    sudo "${pkg_mgr}" dist-upgrade -y
    sudo "${pkg_mgr}" --purge autoremove -y
    sudo "${pkg_mgr}" clean all -y
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" check-update
    sudo "${pkg_mgr}" install epel-release -y
    sudo "${pkg_mgr}" update -y
    sudo "${pkg_mgr}" upgrade
    sudo "${pkg_mgr}" clean all
  else
    echo "Cannot update. ${os_version} not supported"
  fi
}

function adb_install(){
  if ! command -v adb &> /dev/null; then
    echo -e "ADB could not be found \nInstalling..."
    if [[ "${os_version}" == "Ubuntu" ]] ; then
      sudo "${pkg_mgr}" install android-tools-adb android-tools-fastboot -y
      adb version
    elif [[ "${os_version}" == "CentOS Linux" ]] ; then
      sudo "${pkg_mgr}" install epel-release -y
      sudo "${pkg_mgr}" install snapd -y
      sudo systemctl enable --now snapd.socket
      sudo ln -s /var/lib/snapd/snap /snap
      sudo snap install android-adb --edge
      adb version
    else
      echo "Distribution ${os_version} not supported"
    fi
  else
    echo -e "ADB already installed! \nSkipping..."
  fi
}

function android-studio_install(){
  sudo snap install android-studio --classic
}

function atomicparsley_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install atomicparsley -y
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" install atomicparsley -y
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function audacity_install(){
  if ! command -v audacity &> /dev/null; then
    echo -e "Audacity could not be found \nInstalling..."
    if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo add-apt-repository -y ppa:ubuntuhandbook1/audacity
    sudo "${pkg_mgr}" update
    sudo "${pkg_mgr}" install -y audacity
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" install epel-release
    sudo "${pkg_mgr}" install snapd
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap
    sudo snap install audacity -y
  else
    echo "Distribution ${os_version} not supported"
  fi
  else
    echo -e "Audacity already installed! \nSkipping..."
  fi
}

function chrome_install(){
  if ! command -v google-chrome &> /dev/null; then
    echo -e "Chrome could not be found \nInstalling..."
    if [[ "${os_version}" == "Ubuntu" ]] ; then
      if [[ "${architecture}" == "x86_64" ]]; then
        cd "${download_dir}" || echo "Directory not found or does not exist"
        sudo "${pkg_mgr}" install curl wget -y
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo "${pkg_mgr}" install "${download_dir}/google-chrome-stable_current_amd64.deb"
        rm -rf "${download_dir}/google-chrome-stable_current_amd64.deb"
      elif [[ "${architecture}" == "x86" ]]; then
        cd "${download_dir}" || echo "Directory not found or does not exist"
        sudo "${pkg_mgr}" install curl wget -y
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
        sudo "${pkg_mgr}" install "${download_dir}/google-chrome-stable_current_i386.deb"
        rm -rf "${download_dir}/google-chrome-stable_current_i386.deb"
      elif [[ "${architecture}" == "aarch64" ]] || [[ "${architecture}" == "aarch32" ]]; then
        sudo "${pkg_mgr}" install -y chromium-browser
      fi
    elif [[ "${os_version}" == "CentOS Linux" ]] ; then
      cd "${download_dir}" || echo "Directory not found or does not exist"
      wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
      sudo "${pkg_mgr}" install "${download_dir}/google-chrome-stable_current_x86_64.rpm"
      rm -rf "${download_dir}/google-chrome-stable_current_amd64.rpm"
    else
      echo "Distribution ${os_version} not supported"
    fi
  else
    echo -e "Chrome already installed! \nSkipping..."
  fi
}

function chrome-remote-desktop_install(){
  if ! command -v google-chrome-remote &> /dev/null; then
    echo -e "Chrome remote desktop could not be found \nInstalling..."
    wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb -P /tmp
    sudo "${pkg_mgr}" install -y /tmp/chrome-remote-desktop_current_amd64.deb
    mkdir -p ~/.config/chrome-remote-desktop
  else
    echo -e "Chrome remote desktop already installed! \nSkipping..."
  fi
}

function dialog_install(){
  sudo "${pkg_mgr}" install -y dialog
}

function docker_install(){
  if ! command -v docker &> /dev/null; then
    echo -e "Docker could not be found \nInstalling..."
    if [[ "${os_version}" == "Ubuntu" ]] ; then
      sudo "${pkg_mgr}" install -y containerd docker.io docker-compose
      sudo docker run hello-world
      sudo groupadd docker
      sudo usermod -aG docker ${computer_user}
      # Start Docker
      sudo systemctl start docker
      # Enable Docker at Startup
      sudo systemctl enable docker
    elif [[ "${os_version}" == "CentOS Linux" ]] ; then
      sudo "${pkg_mgr}" install -y yum-utils
      sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sudo "${pkg_mgr}" install docker-ce docker-ce-cli containerd.io -y
      sudo groupadd docker
      sudo usermod -aG docker ${computer_user}
      # Start Docker
      sudo systemctl start docker
      # Enable Docker at Startup
      sudo systemctl enable docker
      #Hello world
      sudo docker run hello-world
    else
      echo "Distribution ${os_version} not supported"
    fi
  else
    echo -e "Docker already installed! \nSkipping..."
  fi
}

function dos2unix_install(){
  sudo "${pkg_mgr}" install -y dos2unix
}

function tmux_install(){
  sudo "${pkg_mgr}" install -y tmux
}

# Rygel (DLNA)
function rygel_install(){
  if ! command -v rygel &> /dev/null; then
    echo -e "Rygel could not be found \nInstalling..."
    sudo "${pkg_mgr}" install -y rygel
    if [[ ${config_flag} == "true" ]]; then
      echo "uris=/media/${computer_user}/Movies/Movies" | sudo tee -a /etc/rygel.conf
    fi
  else
    echo -e "Rygel already installed! \nSkipping..."
  fi
}

# FFMPEG
function ffmpeg_install(){
  if ! command -v ffpmeg &> /dev/null; then
    echo -e "FFMPEG could not be found \nInstalling..."
    echo "Installing FFMPEG"
    if [[ "${os_version}" == "Ubuntu" ]] ; then
      sudo "${pkg_mgr}" install -y ffmpeg
      echo "FFMPEG Installed!"
    elif [[ "${os_version}" == "CentOS Linux" ]] ; then
      sudo "${pkg_mgr}" -y update
      # Install mlocate (Will be needed to locate pycharm.sh path
      sudo "${pkg_mgr}" -y install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel
      # Add Repo
      sudo "${pkg_mgr}" -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
      sudo "${pkg_mgr}" -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
      sudo "${pkg_mgr}" -y install http://rpmfind.net/linux/epel/7/x86_64/Packages/s/SDL2-2.0.10-1.el7.x86_64.rpm
      # Install FFmpeg
      sudo "${pkg_mgr}" -y install ffmpeg ffmpeg-devel
      echo "FFMPEG Installed!"
    else
      echo "Distribution ${os_version} not supported"
    fi
  else
    echo -e "FFMPEG already installed! \nSkipping..."
  fi
}

function fstab_install(){
  if ! command -v ntfs-3g &> /dev/null; then
    echo -e "FSTAB could not be found \nInstalling..."
    if [[ "${os_version}" == "Ubuntu" ]] ; then
      sudo "${pkg_mgr}" install -y ntfs-3g
    elif [[ "${os_version}" == "CentOS Linux" ]] ; then
      sudo "${pkg_mgr}" install -y ntfs-3g
    else
      echo "Distribution ${os_version} not supported"
    fi
    if [[ ${config_flag} == "true" ]]; then
      sudo mkdir -p "/media/${computer_user}/hdd_storage"
      sudo mkdir -p "/media/${computer_user}/file_storage"
      sudo mkdir -p "/media/${computer_user}/windows"
      sudo mkdir -p "/media/${computer_user}/movies"
      sudo mkdir -p "/media/${computer_user}/games"

      # If these fstab directories exist, update them. Otherwise create an entry for them.
      sudo grep -q '^/dev/sda1' /etc/fstab && sudo sed -i "s#/dev/sda1.*#/dev/sda1 /media/${computer_user}/hdd_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sda1 /media/${computer_user}/hdd_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
      sudo grep -q '^/dev/sdb2' /etc/fstab && sudo sed -i "s#/dev/sdb2.*#/dev/sdb2 /media/${computer_user}/file_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sdb2 /media/${computer_user}/file_storage ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
      sudo grep -q '^/dev/sdc4' /etc/fstab && sudo sed -i "s#/dev/sdc4.*#/dev/sdc4 /media/${computer_user}/windows ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sdc4 /media/${computer_user}/windows ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
      sudo grep -q '^/dev/sde2' /etc/fstab && sudo sed -i "s#/dev/sde2.*#/dev/sde2 /media/${computer_user}/movies ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sde2 /media/${computer_user}/movies ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
      sudo grep -q '^/dev/sdf2' /etc/fstab && sudo sed -i "s#/dev/sdf2 /media/${computer_user}/games ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0#" /etc/fstab || echo -e "/dev/sdf2 /media/${computer_user}/games ntfs-3g rw,auto,user,permissions,uid=1000,gid=1000,umask=0000,noatime,nodiratime,nofail,nodev,nosuid,exec 0 0" | sudo tee -a /etc/fstab
      sudo mount -a
    fi
  else
    echo -e "FSTAB already installed! \nSkipping..."
  fi
}

function gimp_install(){
  sudo "${pkg_mgr}" install -y gimp
}

function git_install(){
  sudo "${pkg_mgr}" install -y git
  if [[ ${config_flag} == "true" ]]; then
    git config --global credential.helper store
  fi
}

function gnome_install(){
  sudo "${pkg_mgr}" install -y gnome-shell ubuntu-gnome-desktop
}

function gnome-theme_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y snapd gnome-tweaks gnome-shell-extensions gnome-shell-extension-ubuntu-dock
    sudo snap install orchis-themes
    for i in $(snap connections | grep gtk-common-themes:gtk-3-themes | awk '{print $2}'); do sudo snap connect $i orchis-themes:gtk-3-themes; done
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    echo "For Ubuntu Only, not compatible with CentOS"
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function gnucobol_install(){
  sudo "${pkg_mgr}" install -y gnucobol
}

function ghostscript_install(){
  sudo "${pkg_mgr}" install -y ghostscript
}

function gparted_install(){
  sudo "${pkg_mgr}" install -y gparted
}

function hypnotix_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    hypnotix_git="https://github.com/linuxmint/hypnotix/releases/download/1.1/hypnotix_1.1_all.deb"
    wget -O /tmp/hypnotix.deb "${hypnotix_git}"
    sudo "${pkg_mgr}" install /tmp/hypnotix.deb -y
    rm /tmp/hypnotix.deb
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    echo "No Installation Client for ${os_version} available yet"
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function kexi_install(){
  sudo "${pkg_mgr}" install -y kexi
}

function kvm_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    # Install Dependencies
    sudo "${pkg_mgr}" install curl wget bridge-utils cpu-checker qemu-kvm virtinst libvirt-daemon virt-manager -y
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
    </network>' sudo tee -a ./network.xml

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
    sudo "${pkg_mgr}" -y install @virt* dejavu-lgc-* xorg-x11-xauth tigervnc \ libguestfs-tools policycoreutils-python bridge-utils

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

function neofetch_install(){
  sudo "${pkg_mgr}" install -y neofetch
}

function nfs_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y curl wget nfs-common nfs-kernel-server net-tools
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" install -y nfs-utils nfs-utils-lib
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

function openjdk_install(){
  sudo "${pkg_mgr}" install -y openjdk-8-jdk
}

function openssh_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y nmap openssh-server

    # Start SSH
    /etc/init.d/ssh start || echo "Already Started"

    # Create Firewall Rule for SSH
    sudo ufw allow ssh
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" -y install openssh-server openssh-clients
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function mkvtoolnix_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y mkvtoolnix
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" -y install mkvtoolnix
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function mediainfo_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y mediainfo
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" -y install mediainfo
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function phoronix_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y phoronix-test-suite
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" install -y wget php-cli php-xml bzip2 json php-pear php-devel gcc make php-pecl-json
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

function powershell_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    # Install pre-requisite packages.
    sudo "${pkg_mgr}" install -y wget apt-transport-https software-properties-common
    # Navigate to tmp directory
    cd /tmp || echo "Could not find /tmp directory"
    # Download the Microsoft repository GPG keys
    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
    # Register the Microsoft repository GPG keys
    sudo dpkg -i packages-microsoft-prod.deb
    # Update the list of products
    sudo "${pkg_mgr}" update
    # Enable the "universe" repositories
    sudo add-apt-repository -y universe
    # Install PowerShell
    sudo "${pkg_mgr}" install -y powershell
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" install -y wget curl
    # Register the Microsoft RedHat repository
    curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
    # Install PowerShell
    sudo yum install -y powershell
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function python_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y mlocate
    sudo updatedb
    # Install Python 3.X and 3.8
    sudo "${pkg_mgr}" install -y qtbase5-examples qt5-doc-html qtbase5-doc-html qt5-doc qtcreator build-essential libglu1-mesa-dev mesa-common-dev qt5-default python3 python3-pip build-essential python3-pil python3-pil.imagetk zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev python-tk python3-tk tk-dev gcc git tcl-thread snapd
    # Update PIP
    sudo python3 -m pip install --upgrade pip
    # Install Python Packages
    sudo python3 -m pip install autoconf setuptools wheel git+https://github.com/nficano/pytube regex requests tqdm selenium mutagen tkthread pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle pypyodbc sqlalchemy pyhive ffmpeg-python m3u8 aiohttp
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    # Install mlocate (Will be needed to locate pycharm.sh path
    sudo "${pkg_mgr}" -y install mlocate
    sudo updatedb
    # Install Python 3.X and 3.8
    sudo "${pkg_mgr}" install python3 -y
    sudo "${pkg_mgr}" install python38 -y
    # Update PIP
    sudo python3 -m pip install --upgrade pip
    sudo python3.8 -m pip install --upgrade pip
    # Install Python Depedencies
    sudo "${pkg_mgr}" install qt5-default gcc git python3-devel python3-pil.imagetk python38-devel openssl-devel tcl-thread xz-libs bzip2-devel libffi-devel python3-tkinter python38-tkinter -y
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
    sudo "${pkg_mgr}" install -y mlocate
    sudo updatedb
    # Install Python 3.X and 3.8
    sudo "${pkg_mgr}" install snapd -y
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
    sudo "${pkg_mgr}" install snapd -y
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
  sudo "${pkg_mgr}" install -y redshift redshift-gtk
}

function software-updater_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y update-manager synaptic
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    echo "For Ubuntu Only, not compatible with CentOS"
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function stat_log_install(){
  sudo "${pkg_mgr}" install -y sysstat net-tools numactl linux-tools-common
}

function startup-disk-creator_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y usb-creator-gtk
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    echo "For Ubuntu Only, not compatible with CentOS"
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function steam_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y steam
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" install http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-0.2.noarch.rpm -y
    sudo "${pkg_mgr}" install http://download1.rpmfusion.org/free/fedora/releases/19/Everything/i386/os/libtxc_dxtn-1.0.0-3.fc19.i686.rpm -y
    sudo "${pkg_mgr}" --enablerepo=steam_fedora19 install steam -y
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function sudo_install(){
  sudo "${pkg_mgr}" install -y sudo
}

function scrcpy_install(){
  sudo "${pkg_mgr}" install -y scrcpy
}

function tesseract_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y tesseract-ocr libtesseract-dev tesseract-ocr-eng
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" install epel-release -y
    sudo "${pkg_mgr}" install tesseract-devel leptonica-devel -y
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function tigervnc_install(){
  sudo "${pkg_mgr}" install -y tigervnc-standalone-server
}

function transmission_install(){
  sudo "${pkg_mgr}" install -y transmission-qt transmission-cli transmission-daemon
}

function trash-cli_install(){
  sudo "${pkg_mgr}" install -y trash-cli
}

function translate-shell_install(){
  git clone https://github.com/soimort/translate-shell
  cd translate-shell/
  make
  sudo make install
}

function udisks2_install(){
  sudo "${pkg_mgr}" install -y udisks2
}

function youtube-dl_install(){
  sudo "${pkg_mgr}" install -y youtube-dl
}

function vlc_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    sudo "${pkg_mgr}" install -y vlc
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    sudo "${pkg_mgr}" -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
    sudo "${pkg_mgr}" -y install vlc
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function wine_install(){
  sudo "${pkg_mgr}" install -y wine
}

function wireshark_install(){
  if [[ "${os_version}" == "Ubuntu" ]] ; then
    echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive "${pkg_mgr}" install wireshark -y
  elif [[ "${os_version}" == "CentOS Linux" ]] ; then
    sudo "${pkg_mgr}" install -y wireshark wireshark-qt
  else
    echo "Distribution ${os_version} not supported"
  fi
}

function xdotool_install(){
  sudo "${pkg_mgr}" install -y xdotool
}

function xsel_install(){
  sudo "${pkg_mgr}" install -y xsel
}

computer_user=$(getent passwd {1000..6000} | awk -F: '{ print $1}')
os_version=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
os_version="${os_version:1:-1}"
architecture="$(uname -m)"
private_ip=$(ip addr show enp0s31f6 | awk '/inet /{print $2}' )
private_ip=${private_ip::-3}
public_ip=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com)
public_ip=${public_ip:1:-1}
date=$(date +"%m-%d-%Y_%I-%M")
apps=( "adb" "android-studio" "atomicparsley" "audacity" "chrome" "chrome-remote-desktop" "dialog" "docker" "dos2unix" \
"ffmpeg" "fstab" "gimp" "git" "gnome" "gnome-theme" "gnucobol" "ghostscript" "gparted" "hypnotix" "kexi" "kvm" \
"mediainfo" "mkvtoolnix" "neofetch" "nfs" "openjdk" "openssh" "openvpn" "phoronix" "powershell" "python" "pycharm" \
"redshift" "rygel" "scrcpy" "statlog" "steam" "startup-disk-creator" "sudo" "tesseract" "tigervnc" "tmux" \
"transmission" "translate-shell" "trash-cli" "udisks2" "vlc" "wine" "wireshark" "youtube-dl" "xdotool" "xsel" )
pi_apps=( "atomicparsley" "audacity" "chrome" "chrome-remote-desktop" "docker" "dos2unix" "ffmpeg" "gimp" "git" \
"gnome" "gnome-theme" "gnucobol" "ghostscript" "gparted" "hypnotix" "kvm" "mediainfo" "mkvtoolnix" "nfs" "openjdk" \
"openssh" "powershell" "python" "pycharm" "redshift" "statlog" "sudo" "scrcpy" "tesseract" "tmux" "transmission" \
"translate-shell" "trash-cli" "udisks2" "vlc" "wine" "wireshark" "youtube-dl" )
config_flag='true'
clean_flag='false'
provision_flag='false'
update_flag='false'
log_flag='false'
log_dir='.'
log_file="provision_log_${date}.log"
download_dir="/tmp"

# Check if arguments were provided
if [ -z "$1" ]; then
  usage
  exit 0
fi

# Check if OS is supported
if [[ "${os_version}" == "Ubuntu" ]] ; then
  pkg_mgr='apt-get'
elif [[ "${os_version}" == "CentOS Linux" ]] ; then
  pkg_mgr='yum'
else
  pkg_mgr='na'
  echo "Distribution ${os_version} not supported"
  exit 0
fi

# Check if device is a Raspberry Pi, or other ARM devices
if [[ "${architecture}" == "aarch64" ]] || [[ "${architecture}" == "aarch32" ]]; then
  echo "Selecting apps for Raspberry Pi or other ARM Devices"
  apps=("${pi_apps[@]}")
fi

while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      echo -e "\n\nOperating System: ${os_version}"
      echo "Architecture: ${architecture}"
      echo "User: ${computer_user}"
      echo "Private IP: ${private_ip}"
      echo "Public IP: ${public_ip}"
      usage
      exit 0
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
    c | -c | --clean)
      clean_flag='true'
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
    i | -i | --install-only | install-only)
      echo "Installing only, not configuring any applications"
      config_flag='false'
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
    p | -p | --provision | provision)
      echo "Provisioning System"
      provision_flag='true'
      shift
      ;;
    u | -u | --update | update)
      echo "Updating System"
      update_flag='true'
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

if [ ${log_flag} == "true" ]; then
  [ ! -d "${log_dir}" ] && echo "Creating log directory" && mkdir -p "${log_dir}"
fi

if [ ${update_flag} == "true" ]; then
  if [ ${log_flag} == "true" ]; then
    update | sudo tee -a "${log_dir}/${log_file}"
  else
    update
  fi
fi

if [ ${provision_flag} == "true" ]; then
  if [ ${log_flag} == "true" ]; then
    provision | sudo tee -a "${log_dir}/${log_file}"
  else
    provision
  fi
else
  exit 0
fi

if [ ${clean_flag} == "true" ]; then
  if [ ${log_flag} == "true" ]; then
    clean_system | sudo tee -a "${log_dir}/${log_file}"
  else
    clean_system
  fi
else
  exit 0
fi
