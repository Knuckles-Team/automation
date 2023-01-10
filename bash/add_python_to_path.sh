#!/bin/bash

directory="/home/${USER}/.local/bin"

echo -e "if [ -d '${directory}' ]; then\nPATH="$PATH:${directory}"\nfi" >> ~/.bashrc