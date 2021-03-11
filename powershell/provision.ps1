# Run this to enable PowerShell scripts:
# Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
# Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function InstallFeature($name){
  Write-Host "adding Windows 10 feature $name";
  Enable-WindowsOptionalFeature -Online -FeatureName $name -NoRestart
}

function EnableFeatures(){
  InstallFeature Microsoft-Hyper-V-All
  InstallFeature Microsoft-Hyper-V
  InstallFeature Microsoft-Hyper-V-Management-PowerShell
  InstallFeature Microsoft-Hyper-V-Hypervisor
  InstallFeature Microsoft-Hyper-V-Management-Clients
  InstallFeature Microsoft-Hyper-V-Services
  InstallFeature Microsoft-Hyper-V-Tools-All
  InstallFeature ServicesForNFS-ClientOnly
  InstallFeature ClientForNFS-Infrastructure
  InstallFeature NFS-Administration
  InstallFeature TFTP
  InstallFeature Containers
  InstallFeature SmbDirect
  InstallFeature SMB1Protocol
  InstallFeature SMB1Protocol-Client
  InstallFeature SMB1Protocol-Server
  InstallFeature SMB1Protocol-Deprecation
  InstallFeature Containers-DisposableClientVM
  InstallFeature HypervisorPlatform
  InstallFeature VirtualMachinePlatform
  InstallFeature Microsoft-Windows-Subsystem-Linux
  InstallFeature MicrosoftWindowsPowerShellV2
  InstallFeature MicrosoftWindowsPowerShellV2Root
}

function ChromeInstall() {
  Write-Host "Installing Chrome"
  $Path = $env:TEMP;
  $Installer = "chrome_installer.exe";
  Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Path\$Installer;
  Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
  Remove-Item $Path\$Installer
  Write-Host "Chrome Installed Successfully"
}

function 7zipInstall() {
  Write-Host "Installing 7Zip"
  $Path = $env:TEMP;
  $Installer = "7z_installer.exe";
  Invoke-WebRequest "https://www.7-zip.org/a/7z1900-x64.exe" -OutFile $Path\$Installer;
  Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
  Remove-Item $Path\$Installer
  Write-Host "7Zip Installed Successfully"
}

function DockerInstall() {
  Write-Host "Installing Docker"
  $Path = $env:TEMP;
  $Installer = "docker_installer.exe";
  Invoke-WebRequest "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile $Path\$Installer;
  Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
  Remove-Item $Path\$Installer
  Write-Host "Docker Installed Successfully"
}

function GimpInstall() {
  Write-Host "Installing Gimp"
  $Path = $env:TEMP;
  $Installer = "gimp_installer.exe";
  Invoke-WebRequest "https://download.gimp.org/mirror/pub/gimp/v2.10/windows/gimp-2.10.22-setup.exe" -OutFile $Path\$Installer;
  Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
  Remove-Item $Path\$Installer
  Write-Host "Gimp Installed Successfully"
}

function GitInstall() {
  Write-Host "Installing Git"
  $Path = $env:TEMP;
  $Installer = "git_installer.exe";
  Invoke-WebRequest "https://github.com/git-for-windows/git/releases/download/v2.29.2.windows.2/Git-2.29.2.2-64-bit.exe" -OutFile $Path\$Installer;
  Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
  Remove-Item $Path\$Installer
  Write-Host "Git Installed Successfully"
}

function OpenSSHInstall() {
  # Install OpenSSH Client and Server
  Write-Host "Installing OpenSSH"
  # Find latest version
  Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'

  # Install the OpenSSH Client
  Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

  # Install the OpenSSH Server
  Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

  Start-Service sshd
  # OPTIONAL but recommended:
  Set-Service -Name sshd -StartupType 'Automatic'
  # Confirm the Firewall rule is configured. It should be created automatically by setup.
  Get-NetFirewallRule -Name *ssh*
  # There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled
  # If the firewall does not exist, create one
  New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
  Write-Host "OpenSSH Installed Successfully"
}

function PythonInstall(){
  Write-Host "Installing Python"
  # Download Python 3.8 to c:/temp/
  mkdir C:\temp\
  Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe" -OutFile "C:/temp/python-installer.exe"
  #Invoke-WebRequest -Uri "https://github.com/serwy/tkthread/files/4258625/thread2.8.4.zip" -OutFile "C:/temp/tkthread.zip"

  $location = Get-Location
  $tkthread_path = "$location\thread2.8.4.zip"

  # Install exes
  C:/temp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
  # Unzip tkthread and install
  Expand-Archive -LiteralPath $tkthread_path -DestinationPath "C:\Program Files\Python38\tcl\tcl8.6\thread2.8.4"
  # Sleep for 30 seconds to install Python
  Start-Sleep -s 30
  # Reload Environment Variables when installing something during script
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
  # Update Pip
  python -m pip install --upgrade pip
  # Install Python Dependencies
  python -m pip install autoconf setuptools wheel pytubex regex requests tqdm selenium mutagen tkthread pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle sqlalchemy pyhive cx_freeze ffmpeg-python m3u8 aiohttp
  # Remove downloaded files and directory
  rm -r C:\temp\
  Write-Host "Python Environment Installed Successfully"
}

function PycharmInstall(){
  Write-Host "Installing Pycharm"
  # Download Python 3.8 to c:/temp/
  mkdir C:\temp\
  Invoke-WebRequest -Uri "https://download.jetbrains.com/python/pycharm-community-2020.2.4.exe" -OutFile "C:/temp/pycharm.exe"

  $location = Get-Location
  $tkthread_path = "$location\thread2.8.4.zip"

  # Install exes
  C:/temp/pycharm.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
  # Reload Environment Variables when installing something during script
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
  # Remove downloaded files and directory
  rm -r C:\temp\
  Write-Host "Pycharm Installed Successfully"
}

function SourceTreeInstall() {
  Write-Host "Installing SourceTree"
  $Path = $env:TEMP;
  $Installer = "sourcetree_installer.exe";
  Invoke-WebRequest "https://product-downloads.atlassian.com/software/sourcetree/windows/ga/SourceTreeSetup-3.3.9.exe" -OutFile $Path\$Installer;
  Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
  Remove-Item $Path\$Installer
  Write-Host "SourceTree Installed Successfully"
}

function SteamInstall() {
  Write-Host "Installing Steam"
  $Path = $env:TEMP;
  $Installer = "steam_installer.exe";
  Invoke-WebRequest "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe" -OutFile $Path\$Installer;
  Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
  Remove-Item $Path\$Installer
  Write-Host "Steam Installed Successfully"
}

function TransmissionInstall() {
  Write-Host "Installing Transmission"
  $Path = $env:TEMP;
  $Installer = "transmission-qt_installer.exe";
  Invoke-WebRequest "https://github.com/transmission/transmission-releases/raw/master/transmission-3.00-x64.msi" -OutFile $Path\$Installer;
  Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
  Remove-Item $Path\$Installer
  Write-Host "Transmission Installed Successfully"
}

function VLCInstall() {
  Write-Host "Installing VLC"
  $Path = $env:TEMP;
  $Installer = "vlc_installer.exe";
  Invoke-WebRequest "https://ftp.osuosl.org/pub/videolan/vlc/3.0.11/win64/vlc-3.0.11-win64.exe" -OutFile $Path\$Installer;
  Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
  Remove-Item $Path\$Installer
  Write-Host "VLC Installed Successfully"
}

function WSLInstall() {
  # Enable Ubuntu and Fedora Linux and set Ubuntu default user to root
  Write-Host "Enabling WSL2"
  # Enable WSL2
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

  # Download Ubuntu
  $Path = $env:TEMP;
  $Ubuntu_Installer = "Ubuntu.appx";
  $Fedora_Installer = "Fedora.appx";
  Invoke-WebRequest -Uri "https://aka.ms/wslubuntu2004" -OutFile $Path\$Ubuntu_Installer -UseBasicParsing;
  Invoke-WebRequest -Uri "https://github.com/WhitewaterFoundry/WSLFedoraRemix/releases/" -OutFile $Path\$Fedora_Installer -UseBasicParsing;

  Add-AppxPackage .\$Ubuntu_Installer
  Add-AppxPackage .\$Fedora_Installer
  Remove-Item $Path\$Ubuntu_Installer
  Remove-Item $Path\$Fedora_Installer

  ubuntu config --default-user root
  Write-Host "WSL2 Enabled Successfully"
}

#Main-function
function Main {
  ChromeInstall
  EnableFeatures
  7zipInstall
  DockerInstall
  GimpInstall
  GitInstall
  OpenSSHInstall
  PythonInstall
  PycharmInstall
  SourceTreeInstall
  SteamInstall
  TransmissionInstall
  VLCInstall
  WSLInstall
}

Main