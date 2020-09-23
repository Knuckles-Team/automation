#!/bin/sh

# Update & Install Dependencies
sudo yum update -y
sudo yum -y install wget php-cli php-xml bzip2 json php-pear php-devel gcc make php-pecl-json
# Download Phoronix rpm
cd ~/Downloads
wget https://phoronix-test-suite.com/releases/phoronix-test-suite-9.8.0.tar.gz
# Unzip in Downloads
sudo tar xvfz phoronix-test*.tar.gz
cd phoronix-test-suite
sudo ./install-sh
# Setup Batch Tests and Install a few
pwd
#phoronix-test-suite batch-setup
#phoronix-test-suite list-tests
phoronix-test-suite install povray
phoronix-test-suite install hpcc
phoronix-test-suite install ocrmypdf
phoronix-test-suite install stress-ng
phoronix-test-suite install pybench
phoronix-test-suite install gromacs
phoronix-test-suite install geekbench
phoronix-test-suite install ffmpeg
