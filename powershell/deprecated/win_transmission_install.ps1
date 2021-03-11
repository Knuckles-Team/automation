[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Installing Transmission"
# Download Chrome to c:/temp/
$Path = $env:TEMP; 
$Installer = "transmission-qt_installer.exe";
Invoke-WebRequest "https://github.com/transmission/transmission-releases/raw/master/transmission-3.00-x64.msi" -OutFile $Path\$Installer;
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item $Path\$Installer
Write-Host "Transmission Installed Successfully"