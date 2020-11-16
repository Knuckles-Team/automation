[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Download Steam to c:/temp/
$Path = $env:TEMP; 
$Installer = "gimp_installer.exe";
Invoke-WebRequest "https://download.gimp.org/mirror/pub/gimp/v2.10/windows/gimp-2.10.22-setup.exe" -OutFile $Path\$Installer;
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item $Path\$Installer
