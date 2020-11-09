#!/bin/bash

sudo apt update
sudo apt install git -y

git config --global credential.helper store
