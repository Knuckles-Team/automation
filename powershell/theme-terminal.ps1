[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function InstallChocolatey(){
  Set-ExecutionPolicy AllSigned
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(‘https://chocolatey.org/install.ps1’))
}
function InstallGit() {
  winget install -e --id Git.Git
}

function InstallSevenzip() {
  Choco Install 7zip.install
}

function InstallWindowsTerminal(){
  Choco Install microsoft-windows-terminal
}

function InstallPowerShellCore(){
  Choco Install powershell-core
}

function InstallNeoVim(){
  Choco Install neovim
}

function InstallGCC(){
  Choco Install msys2
}

function InstallJQ(){
  Choco Install jq
}

function InstallPosh(){
  Install-Module posh-git -Scope CurrentUser -Force
  Install-Module oh-my-posh -Scope CurrentUser -Force
  Install-Module Terminal-Icons -Repository PSGallery -Force
  Install-Module -Name z -Force
  Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
  Install-Module -Name PSFzf -Scope CurrentUser -Force
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

function CustomizeTerminal(){
  Write-Host "Modifying Terminal Profile"
  cd $env:TEMP
  git clone https://github.com/craftzdog/dotfiles-public.git
  cp $env:TEMP/dotfiles-public/.config $home
}

function InstallDependencies(){
  InstallChocolatey
  InstallGit
  InstallSevenzip
  InstallWindowsTerminal
  InstallPowerShellCore
  InstallNeoVim
  InstallGCC
  InstallJQ
  InstallFonts
  InstallPosh
}

function Main(){
  InstallDependencies
  CustomizeTerminal
}

Main