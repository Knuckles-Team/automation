#!/bin/bash

repo_directory="~/storage/shared/development"
repos=("media-downloader", "automation", "subshift", "webarchiver", "genius-bot")
pushd "${repo_directory}"
for repo in repos; do
  git clone https://github.com/Knucklessg1/${repo}
done
popd
