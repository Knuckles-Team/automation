#!/bin/bash

yes | cp -rf ../../../automation ./automation
docker build -t automation:latest -f "$(pwd)/../../docker/automation/Dockerfile" .
rm -rf ./automation
docker run -v /mnt:/mnt -it automation:latest bash
