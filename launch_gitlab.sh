#!/bin/bash

mkdir -p gitlab
export GITLAB_HOME=$(pwd)/gitlab
cd gitlab
docker-compose up -d
docker exec -it gitlab-ce grep

docker exec -it gitlab-runner gitlab-runner register --url "http://gitlab-ce" --clone-url "http://gitlab-ce"


echo "network_mode = \“gitlab-network\”" | tee -a gitlab/gitlab-runner/config.tom
