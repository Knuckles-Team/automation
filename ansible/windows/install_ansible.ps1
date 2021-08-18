[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function AnsibleInstall(){
  $appToMatch = '*Python*'
  $result = Get-InstalledApps | Where-Object {$_.DisplayName -like $appToMatch}
  If ($null -eq $result) {
    Write-Host "Installing Python"
    $Path = $env:TEMP;
    $Installer = "python_installer.exe";
    if (Test-Path -Path $Path\$Installer -PathType Leaf) {
      Write-Host "Python already downloaded!"
    }
    else {
      Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe" -OutFile $Path\$Installer;
      #Invoke-WebRequest -Uri "https://github.com/serwy/tkthread/files/4258625/thread2.8.4.zip" -OutFile "C:/temp/tkthread.zip"
    }
    # Install exes
    Start-Process -FilePath $Path\$Installer -Args "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Verb RunAs -Wait;
    # Reload Environment Variables when installing something during script
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    # Update Pip
    python -m pip install --upgrade pip
    # Remove downloaded files and directory
    Remove-Item -r $Path\$Installer
    Write-Host "Python Environment Installed Successfully"
  }
  else {
    Write-Host "Python already installed!"
  }
  # Install Python Dependencies
  python -m pip install ansible
  ansible-galaxy collection install ansible.windows
  Write-Host "Ansible Installed Successfully"
}

AnsibleInstall