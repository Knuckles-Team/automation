# Enable Ubuntu and Fedora Linux and set Ubuntu default user to root
# Enable WSL2
Write-Output y | Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

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