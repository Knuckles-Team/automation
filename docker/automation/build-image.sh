#!/bin/bash

cp -r ../../bash ./
docker build -t automation:latest -f "$(pwd)/../../docker/automation/Dockerfile" .
rm -rf ./bash
docker run -v /mnt:/mnt -it automation:latest bash
