[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Installing Python & PyCharm"
# Download Python 3.8 to c:/temp/
mkdir C:\temp\
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe" -OutFile "C:/temp/python-installer.exe"
Invoke-WebRequest -Uri "https://download.jetbrains.com/python/pycharm-community-2020.2.4.exe" -OutFile "C:/temp/pycharm.exe"
#Invoke-WebRequest -Uri "https://github.com/serwy/tkthread/files/4258625/thread2.8.4.zip" -OutFile "C:/temp/tkthread.zip"

$location = Get-Location
$tkthread_path = "$location\thread2.8.4.zip"

# Install exes
C:/temp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
C:/temp/pycharm.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
# Unzip tkthread and install
Expand-Archive -LiteralPath $tkthread_path -DestinationPath "C:\Program Files\Python38\tcl\tcl8.6\thread2.8.4"
# Sleep for 30 seconds to install Python
Start-Sleep -s 30
# Reload Environment Variables when installing something during script
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
# Update Pip
python -m pip install --upgrade pip
# Install Python Dependencies
python -m pip install autoconf setuptools wheel pytubex regex requests tqdm selenium mutagen tkthread pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle sqlalchemy pyhive cx_freeze ffmpeg-python m3u8 aiohttp
# Remove downloaded files and directory
rm -r C:\temp\
Write-Host "Python Environment Installed Successfully"