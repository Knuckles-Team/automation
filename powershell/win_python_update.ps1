# This script will update all python packages
python -m pip install --upgrade pip
pip freeze | %{$_.split('==')[0]} | %{pip install --upgrade $_}