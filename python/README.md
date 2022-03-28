Build Python Package

sudo chmod +x ./*.py
sudo pip install .
python3 setup.py bdist_wheel --universal
twine upload --repository-url https://test.pypi.org/legacy/ dist/*