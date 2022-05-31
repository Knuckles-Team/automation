#!/bin/bash
set -x

scripts_directory="$(pwd)"
automation_directory="$(pwd)/../../../automation"
pushd "${automation_directory}"
automation_directory="$(pwd)"
popd
tar -czvf /tmp/automation.tar.gz -C "${automation_directory}" * --overwrite || exit 1
mv /tmp/automation.tar.gz "${scripts_directory}/automation.tar.gz"
docker build -t automation:latest -f "$(pwd)/../../docker/automation/Dockerfile" .
# rm -rf ./automation.tar.gz
docker run -it automation:latest bash
# docker run -v /mnt:/mnt -it automation:latest bash
