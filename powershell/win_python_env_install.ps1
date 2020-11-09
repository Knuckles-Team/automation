[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Download Python 3.8 to c:/temp/
mkdir C:\temp\
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe" -OutFile "C:/temp/python-installer.exe"
#Invoke-WebRequest -Uri "https://download.jetbrains.com/python/pycharm-community-2020.1.3.exe" -OutFile "C:/temp/pycharm.exe"
Invoke-WebRequest -Uri "https://github.com/serwy/tkthread/files/4258625/thread2.8.4.zip" -OutFile "C:/temp/tkthread.zip"
# Install exes
#C:/temp/python-installer.exe /quiet InstallAllUsers=0 PrependPath=1 Include_test=0
#C:/temp/pycharm.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
# Unzip tkthread and install
Expand-Archive -LiteralPath "C:/temp/tkthread.zip" -DestinationPath "C:\Program Files\Python38\tcl\tcl8.6\thread2.8.4"
# Sleep for 30 seconds to install Python
Start-Sleep -s 30
# Reload Environment Variables when installing something during script
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
# Update Pip
python -m pip install --upgrade pip
# Install Python Dependencies
python -m pip install autoconf setuptools wheel pytubex regex requests tqdm selenium mutagen tkthread pillow twitter_scraper matplotlib numpy pandas scikit-learn scipy seaborn statsmodels more-itertools pyglet shapely piexif webdriver-manager pandas_profiling ipython-genutils traitlets jupyter-core pyrsistent jsonschema nbformat tornado pickleshare wcwidth prompt-toolkit parso jedi backcall pygments ipython pyzmq jupyter-client ipykernel Send2Trash prometheus-client pywinpty terminado testpath mistune packaging bleach entrypoints pandocfilters nbconvert notebook widgetsnbextension ipywidgets numba phik xlsxwriter paramiko cx_oracle pypyodbc sqlalchemy pyhive cx_freeze ffmpeg-python m3u8 aiohttp
# Remove downloaded files and directory
rm -r C:\temp\
