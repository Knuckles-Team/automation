# This script will update all python packages

pip freeze | %{$_.split('==')[0]} | %{pip install --upgrade $_}