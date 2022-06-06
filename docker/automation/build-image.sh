#!/bin/bash
set -x

scripts_directory="$(pwd)"
automation_directory="$(pwd)/../../../automation"
pushd "${automation_directory}"
automation_directory="$(pwd)"
cp -r "${automation_directory}" "/tmp/automation"
rm -rf "/tmp/automation/.*"
rm -rf "/tmp/automation/.gitignore"
rm -rf "/tmp/automation/.gitattributes"
popd
tar -czvf /tmp/automation.tar.gz -C "/tmp/automation" . --overwrite --exclude-vcs --exclude='.idea' || exit 1
mv /tmp/automation.tar.gz "${scripts_directory}/automation.tar.gz"
docker build -t automation:latest -f "${automation_directory}/docker/automation/Dockerfile" .
rm -rf ./automation.tar.gz
rm -rf /tmp/*
docker run -v /mnt:/mnt -it automation:latest bash
