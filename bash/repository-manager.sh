#!/bin/bash

function usage(){
  echo "Flags:
-h  | h  | --help                See usage
-c  | c  | --clone               Clone repositories
-d  | d  | --directory           Directory to Clone/Pull projects
-db | db | --default-branch      Sets the default branch for the repo
-m  | m  | --merge               Merge a repository source and target branch
-p  | p  | --prune-source-branch Delete Source branch during merge
-s  | s  | --sync-projects       Pull projects in git directory provided

Usage:
repository-manager.sh --directory <directory> --sync-projects
repository-manager.sh --clone --directory <directory>
repository-manager.sh --clone --default-branch --directory <directory> --sync-projects
repository-manager.sh --clone --default-branch --directory <directory> --sync-projects --prune-source-branch --merge '<Repository Slug>' '<Source Branch>' '<Target Branch>'
"
}


function clone_projects(){
  pushd "${git_directory}" >> /dev/null || echo "Directory not found: ${git_directory}"
  echo "Cloning Repositories"
  for repository in "${project_slugs[@]}"; do
    git clone https://github.com/Knucklessg1/${repository}.git
  done
  popd >> /dev/null || echo "Unable to popd"
}

function pull_projects(){
  echo "Directory passed: ${git_directory}"
  readarray -t directories < <((find "${git_directory}" -maxdepth 1 -type d))
  directories=( "${directories[@]/.}" )
  directories=("${directories[@]:1}")
  for directory in "${directories[@]}"; do
    if [[ -d "${directory}/.git" ]]; then
      repo_name=$(basename "${directory}")
      echo -e "\nPulling from git repository ${repo_name}"
      pushd "${directory}" >> /dev/null || echo "Directory not found: ${directory}"
      git pull
      if [[ "${default_branch_flag}" == "true" ]];then
        default_branch_name=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@' 2>/dev/null)
        echo "Default Branch: ${default_branch_name}"
        git checkout "${default_branch_name}"
      fi
      popd >> /dev/null || echo "Unable to popd"
    else
      echo -e "\nNot a git repository ${directory}"
    fi
  done
  echo "Syncs Complete"
}

function merge_projects(){
  echo "Merging ${source_branch} to ${target_branch} for ${repository}"
  pushd "${git_directory}/${repository}" || echo "Project: ${git_directory}/${repository} not found"
  git fetch origin
  git checkout "${target_branch}"
  git reset --hard "origin/${target_branch}"
  git merge -m "Merge ${target_branch} to ${source_branch}" "origin/${source_branch}"
  git push origin "${target_branch}"
  if [[ "${prune_flag}" == "true" ]]; then
    git push origin --delete "${source_branch}"
  fi
  popd || echo "Unable to popd out of ${repository} directory"
  echo "Merged ${source_branch} to ${target_branch} for ${repository}"
}

clone_flag="false"
default_branch_flag="false"
merge_flag="false"
prune_flag="true"
git_directory="$HOME/Downloads"
project_slugs=("media-manager" "media-downloader" "webarchiver" "genius-bot" "subshift" "automation" "report-manager" "crypto-trader")

if [ -z "$1" ]; then
  usage
  exit 0
fi

while test -n "$1"; do
  case "$1" in
    h | -h | --help)
      usage
      exit 0
      ;;
    c | -c | --clone)
      clone_flag="true"
      shift
      ;;
    db | -db | --default-branch)
      default_branch_flag="true"
      shift
      ;;
    d | -d | --directory)
      if [[ "${2}" ]]; then
        if [[ -d "${2}" ]]; then
          git_directory="${2}"
        else
          echo "Directory entered not found: ${2}"
          exit 0
        fi
        shift
      else
        echo 'ERROR: "-d | --directory" requires a non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    m | -m | --merge)
      if [[ "${2}" ]] && [[ "${3}" ]] && [[ "${4}" ]]; then
        merge_flag="true"
        repository="${2}"
        source_branch="${3}"
        target_branch="${4}"
        declare -A map
        for project in "${project_slugs[@]}"; do
          map["${project}"]=1
        done
        if [[ ${map["${repository}"]} ]] ; then
          echo "Repository found"
        else
          echo "Please choose a valid repository"
          exit 0
        fi
        shift
        shift
        shift
      else
        echo 'ERROR: "-m | --merge" requires 3 non-empty option argument.'
        exit 0
      fi
      shift
      ;;
    p | -p | --prune-source-branch)
      prune_flag="true"
      shift
      ;;
    s | -s | --sync-projects)
      pull_flag="true"
      shift
      ;;
    --)# End of all options.
      shift
      break
      ;;
    -?*)
      printf 'WARNING: Unknown option (ignored): %s\n' "$1"
      ;;
    *)
      shift
      break
      ;;
  esac
done

if [[ "${clone_flag}" == "true" ]]; then
  clone_projects
fi

if [[ "${pull_flag}" == "true" ]]; then
  pull_projects
fi

if [[ "${merge_flag}" == "true" ]]; then
  merge_projects
fi
