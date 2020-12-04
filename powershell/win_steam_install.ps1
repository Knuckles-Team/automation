[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Installing Steam"
# Download Steam to c:/temp/
$Path = $env:TEMP; 
$Installer = "steam_installer.exe"; 
Invoke-WebRequest "https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe" -OutFile $Path\$Installer; 
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item $Path\$Installer
Write-Host "Steam Installed Successfully"