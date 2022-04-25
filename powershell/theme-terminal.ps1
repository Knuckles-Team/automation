[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function InstallChocolatey(){
  Write-Host "Installing Chocolatey"
  Set-ExecutionPolicy AllSigned
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
function InstallGit() {
  Write-Host "Installing Git"
  winget install --accept-package-agreements -e --id Git.Git
}

function InstallSevenzip() {
  Write-Host "Installing 7Zip"
  Choco Install 7zip.install -y
}

function InstallWindowsTerminal(){
  Write-Host "Installing Windows Terminal"
  Choco Install microsoft-windows-terminal -y
}

function InstallPowerShellCore(){
  Write-Host "Installing PowerShell Core"
  Choco Install powershell-core -y
}

function InstallNeoVim(){
  Write-Host "Installing Neovim"
  Choco Install neovim -y
}

function InstallGCC(){
  Write-Host "Installing GCC Libraries"
  Choco Install msys2 -y
}

function InstallJQ(){
  Write-Host "Installing JQ"
  Choco Install jq -y
}

function Installfzf(){
  Write-Host "Installing fzf"
  Choco Install fzf -y
}

function InstallPosh(){
  Install-PackageProvider -Name NuGet -Force
  Install-Module posh-git -Force
  Install-Module oh-my-posh -Force
  Install-Module Terminal-Icons -Repository PSGallery -Force
  Install-Module -Name z -Force -AllowClobber
  Install-Module -Name PSReadLine -Force -SkipPublisherCheck
  Install-Module -Name PSFzf -Force
  New-Item -ItemType SymbolicLink -Path (Join-Path -Path $Env:USERPROFILE -ChildPath Documents) -Name PowerShell -Target (Join-Path -Path $Env:USERPROFILE -ChildPath Documents\WindowsPowerShell)
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
  Copy-Item *.ttf c:\windows\fonts\
  Remove-Item "$Path\Hack.zip"
}

function CustomizeTerminal(){
  Write-Host "Modifying Terminal Profile"
  Set-Location $env:TEMP
  git clone https://github.com/craftzdog/dotfiles-public.git
  Copy-Item $env:TEMP/dotfiles-public/.config -Destination $home -Recurse
'{
  "$help": "https://aka.ms/terminal-documentation",
  "$schema": "https://aka.ms/terminal-profiles-schema",
  "actions":
  [
      {
          "command":
          {
              "action": "copy",
              "singleLine": false
          },
          "keys": "ctrl+c"
      },
      {
          "command": "paste",
          "keys": "ctrl+v"
      },
      {
          "command": "find",
          "keys": "ctrl+shift+f"
      },
      {
          "command":
          {
              "action": "splitPane",
              "split": "auto",
              "splitMode": "duplicate"
          },
          "keys": "alt+shift+d"
      }
  ],
  "copyFormatting": "none",
  "copyOnSelect": false,
  "defaultProfile": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
  "profiles":
  {
      "defaults":
      {
          "colorScheme": "Smooth Blues",
          "font":
          {
              "face": "Hack NF"
          },
          "opacity": 35,
          "useAcrylic": true
      },
      "list":
      [
          {
              "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
              "hidden": false,
              "name": "Windows PowerShell"
          },
          {
              "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
              "hidden": false,
              "name": "Command Prompt"
          },
          {
              "guid": "{2c4de342-38b7-51cf-b940-2309a097f518}",
              "hidden": false,
              "name": "Ubuntu",
              "source": "Windows.Terminal.Wsl"
          },
          {
              "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
              "hidden": false,
              "name": "Azure Cloud Shell",
              "source": "Windows.Terminal.Azure"
          },
          {
              "guid": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
              "hidden": false,
              "name": "PowerShell",
              "source": "Windows.Terminal.PowershellCore"
          },
          {
              "guid": "{ccfe6f05-945e-5ec7-8f07-66de909fb8f2}",
              "hidden": false,
              "name": "Developer Command Prompt for VS 2022",
              "source": "Windows.Terminal.VisualStudio"
          },
          {
              "guid": "{1d91f41f-3c07-55a0-bafa-19027cbc0e5e}",
              "hidden": false,
              "name": "Developer PowerShell for VS 2022",
              "source": "Windows.Terminal.VisualStudio"
          }
      ]
  },
  "schemes":
  [
      {
          "background": "#0C0C0C",
          "black": "#0C0C0C",
          "blue": "#0037DA",
          "brightBlack": "#767676",
          "brightBlue": "#3B78FF",
          "brightCyan": "#61D6D6",
          "brightGreen": "#16C60C",
          "brightPurple": "#B4009E",
          "brightRed": "#E74856",
          "brightWhite": "#F2F2F2",
          "brightYellow": "#F9F1A5",
          "cursorColor": "#FFFFFF",
          "cyan": "#3A96DD",
          "foreground": "#CCCCCC",
          "green": "#13A10E",
          "name": "Campbell",
          "purple": "#881798",
          "red": "#C50F1F",
          "selectionBackground": "#FFFFFF",
          "white": "#CCCCCC",
          "yellow": "#C19C00"
      },
      {
          "background": "#012456",
          "black": "#0C0C0C",
          "blue": "#0037DA",
          "brightBlack": "#767676",
          "brightBlue": "#3B78FF",
          "brightCyan": "#61D6D6",
          "brightGreen": "#16C60C",
          "brightPurple": "#B4009E",
          "brightRed": "#E74856",
          "brightWhite": "#F2F2F2",
          "brightYellow": "#F9F1A5",
          "cursorColor": "#FFFFFF",
          "cyan": "#3A96DD",
          "foreground": "#CCCCCC",
          "green": "#13A10E",
          "name": "Campbell Powershell",
          "purple": "#881798",
          "red": "#C50F1F",
          "selectionBackground": "#FFFFFF",
          "white": "#CCCCCC",
          "yellow": "#C19C00"
      },
      {
          "background": "#282C34",
          "black": "#282C34",
          "blue": "#61AFEF",
          "brightBlack": "#5A6374",
          "brightBlue": "#61AFEF",
          "brightCyan": "#56B6C2",
          "brightGreen": "#98C379",
          "brightPurple": "#C678DD",
          "brightRed": "#E06C75",
          "brightWhite": "#DCDFE4",
          "brightYellow": "#E5C07B",
          "cursorColor": "#FFFFFF",
          "cyan": "#56B6C2",
          "foreground": "#DCDFE4",
          "green": "#98C379",
          "name": "One Half Dark",
          "purple": "#C678DD",
          "red": "#E06C75",
          "selectionBackground": "#FFFFFF",
          "white": "#DCDFE4",
          "yellow": "#E5C07B"
      },
      {
          "background": "#FAFAFA",
          "black": "#383A42",
          "blue": "#0184BC",
          "brightBlack": "#4F525D",
          "brightBlue": "#61AFEF",
          "brightCyan": "#56B5C1",
          "brightGreen": "#98C379",
          "brightPurple": "#C577DD",
          "brightRed": "#DF6C75",
          "brightWhite": "#FFFFFF",
          "brightYellow": "#E4C07A",
          "cursorColor": "#4F525D",
          "cyan": "#0997B3",
          "foreground": "#383A42",
          "green": "#50A14F",
          "name": "One Half Light",
          "purple": "#A626A4",
          "red": "#E45649",
          "selectionBackground": "#FFFFFF",
          "white": "#FAFAFA",
          "yellow": "#C18301"
      },
      {
          "background": "#001B26",
          "black": "#282C34",
          "blue": "#61AFEF",
          "brightBlack": "#5A6374",
          "brightBlue": "#61AFEF",
          "brightCyan": "#56B6C2",
          "brightGreen": "#98C379",
          "brightPurple": "#C678DD",
          "brightRed": "#E06C75",
          "brightWhite": "#DCDFE4",
          "brightYellow": "#E5C07B",
          "cursorColor": "#FFFFFF",
          "cyan": "#56B6C2",
          "foreground": "#DCDFE4",
          "green": "#98C379",
          "name": "Smooth Blues",
          "purple": "#C678DD",
          "red": "#E06C75",
          "selectionBackground": "#FFFFFF",
          "white": "#DCDFE4",
          "yellow": "#E5C07B"
      },
      {
          "background": "#002B36",
          "black": "#002B36",
          "blue": "#268BD2",
          "brightBlack": "#073642",
          "brightBlue": "#839496",
          "brightCyan": "#93A1A1",
          "brightGreen": "#586E75",
          "brightPurple": "#6C71C4",
          "brightRed": "#CB4B16",
          "brightWhite": "#FDF6E3",
          "brightYellow": "#657B83",
          "cursorColor": "#FFFFFF",
          "cyan": "#2AA198",
          "foreground": "#839496",
          "green": "#859900",
          "name": "Solarized Dark",
          "purple": "#D33682",
          "red": "#DC322F",
          "selectionBackground": "#FFFFFF",
          "white": "#EEE8D5",
          "yellow": "#B58900"
      },
      {
          "background": "#FDF6E3",
          "black": "#002B36",
          "blue": "#268BD2",
          "brightBlack": "#073642",
          "brightBlue": "#839496",
          "brightCyan": "#93A1A1",
          "brightGreen": "#586E75",
          "brightPurple": "#6C71C4",
          "brightRed": "#CB4B16",
          "brightWhite": "#FDF6E3",
          "brightYellow": "#657B83",
          "cursorColor": "#002B36",
          "cyan": "#2AA198",
          "foreground": "#657B83",
          "green": "#859900",
          "name": "Solarized Light",
          "purple": "#D33682",
          "red": "#DC322F",
          "selectionBackground": "#FFFFFF",
          "white": "#EEE8D5",
          "yellow": "#B58900"
      },
      {
          "background": "#000000",
          "black": "#000000",
          "blue": "#3465A4",
          "brightBlack": "#555753",
          "brightBlue": "#729FCF",
          "brightCyan": "#34E2E2",
          "brightGreen": "#8AE234",
          "brightPurple": "#AD7FA8",
          "brightRed": "#EF2929",
          "brightWhite": "#EEEEEC",
          "brightYellow": "#FCE94F",
          "cursorColor": "#FFFFFF",
          "cyan": "#06989A",
          "foreground": "#D3D7CF",
          "green": "#4E9A06",
          "name": "Tango Dark",
          "purple": "#75507B",
          "red": "#CC0000",
          "selectionBackground": "#FFFFFF",
          "white": "#D3D7CF",
          "yellow": "#C4A000"
      },
      {
          "background": "#FFFFFF",
          "black": "#000000",
          "blue": "#3465A4",
          "brightBlack": "#555753",
          "brightBlue": "#729FCF",
          "brightCyan": "#34E2E2",
          "brightGreen": "#8AE234",
          "brightPurple": "#AD7FA8",
          "brightRed": "#EF2929",
          "brightWhite": "#EEEEEC",
          "brightYellow": "#FCE94F",
          "cursorColor": "#000000",
          "cyan": "#06989A",
          "foreground": "#555753",
          "green": "#4E9A06",
          "name": "Tango Light",
          "purple": "#75507B",
          "red": "#CC0000",
          "selectionBackground": "#FFFFFF",
          "white": "#D3D7CF",
          "yellow": "#C4A000"
      },
      {
          "background": "#000000",
          "black": "#000000",
          "blue": "#000080",
          "brightBlack": "#808080",
          "brightBlue": "#0000FF",
          "brightCyan": "#00FFFF",
          "brightGreen": "#00FF00",
          "brightPurple": "#FF00FF",
          "brightRed": "#FF0000",
          "brightWhite": "#FFFFFF",
          "brightYellow": "#FFFF00",
          "cursorColor": "#FFFFFF",
          "cyan": "#008080",
          "foreground": "#C0C0C0",
          "green": "#008000",
          "name": "Vintage",
          "purple": "#800080",
          "red": "#800000",
          "selectionBackground": "#FFFFFF",
          "white": "#C0C0C0",
          "yellow": "#808000"
      }
  ],
  "theme": "dark",
  "useAcrylicInTabRow": true
}' | Out-File -FilePath "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json"

  '. $env:USERPROFILE\.config\powershell\user_profile.ps1' | Out-File -FilePath $PROFILE
}

function InstallDependencies(){
  InstallChocolatey
  InstallGit
  InstallSevenzip
  InstallWindowsTerminal
  InstallPowerShellCore
  Installfzf
  InstallNeoVim
  InstallGCC
  InstallJQ
  InstallFonts
  InstallPosh
  $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
  Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
  refreshenv
}

function Main(){
  InstallDependencies
  CustomizeTerminal
}

Main