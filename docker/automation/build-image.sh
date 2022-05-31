#!/bin/bash

cp -r ../../../automation ./automation
docker build -t automation:latest -f "$(pwd)/../../docker/automation/Dockerfile" . | tee ./docker_log.txt
rm -rf ./automation
docker run -v /mnt:/mnt -it automation:latest bash
