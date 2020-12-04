[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Installing VLC"
# Download VLC to c:/temp/
$Path = $env:TEMP; 
$Installer = "vlc_installer.exe"; 
Invoke-WebRequest "https://ftp.osuosl.org/pub/videolan/vlc/3.0.11/win64/vlc-3.0.11-win64.exe" -OutFile $Path\$Installer; 
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item $Path\$Installer
Write-Host "VLC Installed Successfully"