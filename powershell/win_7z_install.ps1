[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Download Chrome to c:/temp/
$Path = $env:TEMP; 
$Installer = "7z_installer.exe";
Invoke-WebRequest "https://www.7-zip.org/a/7z1900-x64.exe" -OutFile $Path\$Installer;
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item $Path\$Installer

