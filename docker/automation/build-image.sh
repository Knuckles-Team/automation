#!/bin/bash

cp -r ../../bash ./bash
docker build -t automation:latest -f "$(pwd)/../../docker/automation/Dockerfile" .
rm ./bash
docker run -v /mnt:/mnt -it automation:latest bash
