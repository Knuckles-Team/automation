[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function GitInstall() {
  $appToMatch = '*Git*'
  $result = Get-InstalledApps | Where-Object {$_.DisplayName -like $appToMatch}
  If ($null -eq $result) {
    Write-Host "Installing Git"
    $Path = $env:TEMP;
    $Installer = "git_installer.exe";
    if (Test-Path -Path $Path\$Installer -PathType Leaf) {
      Write-Host "Git already downloaded!"
    }
    else {
      Invoke-WebRequest "https://github.com/git-for-windows/git/releases/download/v2.29.2.windows.2/Git-2.29.2.2-64-bit.exe" -OutFile $Path\$Installer;
    }
    Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
    Remove-Item $Path\$Installer
    Write-Host "Git Installed Successfully"
  }
  else {
    Write-Host "Git already installed!"
  }
}

function SevenzipInstall() {
  $appToMatch = '*7*zip*'
  $result = Get-InstalledApps | Where-Object {$_.DisplayName -like $appToMatch}
  If ($null -eq $result) {
    Write-Host "Installing 7Zip"
    $Path = $env:TEMP;
    $Installer = "7z_installer.exe";
    if (Test-Path -Path $Path\$Installer -PathType Leaf) {
      Write-Host "7zip already downloaded!"
    }
    else {
      Invoke-WebRequest "https://www.7-zip.org/a/7z1900-x64.exe" -OutFile $Path\$Installer;
    }
    Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
    Remove-Item $Path\$Installer
    Write-Host "7Zip Installed Successfully"
  }
  else {
    Write-Host "7Zip already installed!"
  }
}

function InstallFonts(){
  $Path = $env:TEMP;
  Invoke-WebRequest "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip" -OutFile "$Path\Hack.zip";
  Expand-Archive "$Path\Hack.zip" -DestinationPath "$Path\Hack"
  Set-Location "$Path\Hack"
  $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
  foreach ($file in Get-ChildItem *.ttf)
  {
      $fileName = $file.Name
      if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
          Write-Output $fileName
          Get-ChildItem $file | ForEach-Object{ $fonts.CopyHere($_.fullname) }
      }
  }
  cp *.ttf c:\windows\fonts\
  Remove-Item "$Path\Hack.zip"
}