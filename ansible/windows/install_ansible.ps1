[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function AnsibleInstall(){
  $appToMatch = '*Python*'
  $result = Get-InstalledApps | Where-Object {$_.DisplayName -like $appToMatch}
  If ($null -eq $result) {
    Write-Host "Installing Python"
    $Path = $env:TEMP;
    $Installer = "python_installer.exe";
    if (Test-Path -Path $Path\$Installer -PathType Leaf) {
      Write-Host "SourceTree already downloaded!"
    }
    else {
      Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe" -OutFile $Path\$Installer;
      #Invoke-WebRequest -Uri "https://github.com/serwy/tkthread/files/4258625/thread2.8.4.zip" -OutFile "C:/temp/tkthread.zip"
    }
    $location = Get-Location
    $tkthread_path = "$location\thread2.8.4.zip"
    # Install exes
    Start-Process -FilePath $Path\$Installer -Args "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Verb RunAs -Wait;
    # Unzip tkthread and install
    Expand-Archive -LiteralPath $tkthread_path -DestinationPath "C:\Program Files\Python38\tcl\tcl8.6\thread2.8.4"
    # Reload Environment Variables when installing something during script
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    # Update Pip
    python -m pip install --upgrade pip
    # Install Python Dependencies
    python -m pip install autoconf setuptools wheel pytubex regex requests tqdm selenium mutagen tkthread pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle sqlalchemy pyhive cx_freeze ffmpeg-python m3u8 aiohttp
    # Remove downloaded files and directory
    Remove-Item -r $Path\$Installer
    Write-Host "Python Environment Installed Successfully"
  }
  else {
    Write-Host "Python already installed!"
  }
  python -m pip install ansible
  ansible-galaxy collection install ansible.windows
}

AnsibleInstall