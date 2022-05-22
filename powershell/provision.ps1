# Run this to enable PowerShell scripts:
# Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
# Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function InstallFeature($name){
  Write-Host "adding Windows 10 feature $name";
  Enable-WindowsOptionalFeature -Online -FeatureName $name -NoRestart
}

function CheckWindowsFeature() {
  [CmdletBinding()]
  param(
    [Parameter(Position=0,Mandatory=$true)] [string]$FeatureName
  )
  if((Get-WindowsOptionalFeature -FeatureName $FeatureName -Online).State -eq "Enabled") {
    Write-Host "$FeatureName already enabled!"
  }
  else {
    InstallFeature $FeatureName
  }
}

function EnableFeatures(){
  CheckWindowsFeature Microsoft-Hyper-V-All
  CheckWindowsFeature Microsoft-Hyper-V
  CheckWindowsFeature Microsoft-Hyper-V-Management-PowerShell
  CheckWindowsFeature Microsoft-Hyper-V-Hypervisor
  CheckWindowsFeature Microsoft-Hyper-V-Management-Clients
  CheckWindowsFeature Microsoft-Hyper-V-Services
  CheckWindowsFeature Microsoft-Hyper-V-Tools-All
  CheckWindowsFeature ServicesForNFS-ClientOnly
  CheckWindowsFeature ClientForNFS-Infrastructure
  CheckWindowsFeature NFS-Administration
  CheckWindowsFeature TFTP
  CheckWindowsFeature Containers
  CheckWindowsFeature SmbDirect
  CheckWindowsFeature SMB1Protocol
  CheckWindowsFeature SMB1Protocol-Client
  CheckWindowsFeature SMB1Protocol-Server
  CheckWindowsFeature SMB1Protocol-Deprecation
  CheckWindowsFeature Containers-DisposableClientVM
  CheckWindowsFeature HypervisorPlatform
  CheckWindowsFeature VirtualMachinePlatform
  CheckWindowsFeature Microsoft-Windows-Subsystem-Linux
  CheckWindowsFeature MicrosoftWindowsPowerShellV2
  CheckWindowsFeature MicrosoftWindowsPowerShellV2Root
}

function InstallChocolatey(){
  Write-Host "Installing Chocolatey"
  Set-ExecutionPolicy AllSigned
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
  Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
}

function InstallOpenSSH() {
  # Install OpenSSH Client and Server
  Write-Host "Installing OpenSSH"
  # Find latest version
  Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

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

function InstallFonts(){
  $Path = $env:TEMP;
  Invoke-WebRequest "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip" -OutFile "$Path\Hack.zip";
  Expand-Archive "$Path\Hack.zip" -DestinationPath "$Path\Hack"
  Set-Location "$Path\Hack"
  $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
  foreach ($file in Get-ChildItem *.ttf)
  {
    $fileName = $file.Name
    if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
      Write-Output $fileName
      Get-ChildItem $file | ForEach-Object{ $fonts.CopyHere($_.fullname) }
    }
  }
  Copy-Item *.ttf c:\windows\fonts\
  Remove-Item "$Path\Hack.zip"
}

function ProvisionSystem() {
  Install-Module -Name z -Force -AllowClobber
  Install-Module -Name PSReadLine -Force -SkipPublisherCheck
  Install-Module -Name PSFzf -Force
  Choco Install 7zip.install audacity audacity-lame audacity-ffmpeg battle.net curl discord docker-desktop fzf epicgameslauncher gimp git.install goggalaxy googlechrome jq k-litecodecpackfull libreoffice-fresh powershell-core msys2 neovim notepadplusplus.install microsoft-windows-terminal mpc-be nuget.commandline oh-my-posh openssl.light origin putty pycharm-edu python steam-client terminal-icons.powershell transmission virtualbox vlc vscode vcredist140 winscp.install wireshark wget wsl-ubuntu-2004 zoom -y
  New-Item -ItemType SymbolicLink -Path (Join-Path -Path $Env:USERPROFILE -ChildPath Documents) -Name PowerShell -Target (Join-Path -Path $Env:USERPROFILE -ChildPath Documents\WindowsPowerShell)
  Remove-Item -r $env:TEMP;
}

function SetStartupPrograms(){
  $StartUpDirectory = "%SystemDrive%\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
  $TaskManagerShortcut = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\Task Manager"
  Copy-Item $TaskManagerShortcut -Destination $StartUpDirectory
}

function UpgradeApplications() {
  choco upgrade all -y
}

function Main {
  InstallChocolatey
  EnableFeatures
  InstallFonts
  InstallOpenSSH
  ProvisionSystem
  SetStartupPrograms
  UpgradeApplications
}

Main
