[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Installing VLC"
# Download VLC to c:/temp/
$Path = $env:TEMP; 
$Installer = "vlc_installer.exe"; 
Invoke-WebRequest "https://get.videolan.org/vlc/3.0.11/win32/vlc-3.0.11-win32.exe" -OutFile $Path\$Installer; 
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item $Path\$Installer
Write-Host "VLC Installed Successfully"