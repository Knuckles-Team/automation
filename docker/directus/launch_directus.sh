#!/bin/bash

mkdir -p ./data/database ./uploads ./extensions
sudo docker-compose up #-d
# https://www.czerniga.it/2021/11/14/how-to-install-gitlab-using-docker-compose/
#docker exec -it gitlab-ce grep

#docker exec -it gitlab-runner gitlab-runner register --url "http://gitlab-ce" --clone-url "http://gitlab-ce"


#echo "network_mode = \“gitlab-network\”" | tee -a gitlab/gitlab-runner/config.tom
