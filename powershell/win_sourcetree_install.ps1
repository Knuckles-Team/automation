[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Installing SourceTree"
# Download Chrome to c:/temp/
$Path = $env:TEMP; 
$Installer = "sourcetree_installer.exe";
Invoke-WebRequest "https://product-downloads.atlassian.com/software/sourcetree/windows/ga/SourceTreeSetup-3.3.9.exe" -OutFile $Path\$Installer;
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item $Path\$Installer
Write-Host "SourceTree Installed Successfully"