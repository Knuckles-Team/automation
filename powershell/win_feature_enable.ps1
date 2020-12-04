# Enable Ubuntu and Fedora Linux and set Ubuntu default user to root
# Get Features 
# dism /online /Get-Features

# Install windows features function
function InstallFeature($name){
  Write-Host "adding Windows 10 feature $name";
  Enable-WindowsOptionalFeature -Online -FeatureName $name -NoRestart
}

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