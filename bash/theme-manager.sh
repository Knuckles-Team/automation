#!/bin/bash

dconfdir=/org/gnome/terminal/legacy/profiles:

function usage() {
  echo -e "
Information:
This script will make Ubuntu sexy

Flags:
-h | h | --help                Show Usage and Flags
-i | i | --install             Install all dependencies
-t | t | --terminal            Rename the file based on regex matching
-p | p | --terminal-profile    Rename the file based on regex matching
-g | g | --gnome               Rename the file based on regex matching
-u | u | --update              Updates Themes

Usage:
theme-manager.sh -i -t -p -g
theme-manager.sh --install --terminal --terminal-profile --gnome
"
}

function install_dependencies(){
  sudo apt install -y wget dconf-editor unzip snapd gnome-tweaks gnome-shell-extensions gnome-shell-extension-ubuntu-dock git
}

function install_oh_my_posh(){
  # Install Oh my Posh
  sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
  sudo chmod +x /usr/local/bin/oh-my-posh
  # Download the themes
  mkdir ~/.poshthemes
  wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
  unzip -o ~/.poshthemes/themes.zip -d ~/.poshthemes >> /dev/null
  chmod u+rw ~/.poshthemes/*.json
  rm ~/.poshthemes/themes.zip
  # Download fonts
  mkdir ~/.fonts
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip -O ~/Downloads/Meslo.zip
  unzip -o ~/Downloads/Meslo.zip -d ~/.fonts/Meslo >> /dev/null
  pushd ~/.fonts/Meslo
  fc-cache -fv
  popd
  rm ~/Downloads/Meslo.zip
  if grep -q 'eval "$(oh-my-posh --init --shell bash --config ' ~/.bashrc; then
    echo ".bashrc profile already modified"
  else
    echo 'eval "$(oh-my-posh --init --shell bash --config ~/.poshthemes/takuya.omp.json)"' | sudo tee -a ~/.bashrc
  fi
}

function configure_gnome_theme(){
  mkdir -p ~/.gnome-themes
  pushd ~/.gnome-themes
  # Download Icon Themes
  git clone https://github.com/cbrnix/Flatery.git
  pushd Flatery
  chmod +x ./*.sh
  ./install.sh -g -w
  popd

  wget https://github.com/cbrnix/Flatery/archive/refs/heads/master.zip -O ~/Downloads/flatery.zip
  unzip -o ~/Downloads/flatery.zip -d ~/.icons >> /dev/null
  wget -qO- https://git.io/papirus-icon-theme-install | sh
  # Download Shell Themes
  wget https://github.com/vinceliuice/Orchis-theme/archive/refs/heads/master.zip -O ~/Downloads/Orchis.zip
  unzip -o ~/.poshthemes/themes.zip -d ~/Downloads >> /dev/null
}


function list_profiles(){
  echo "Showing gnome-terminal profiles"
  dconf list /org/gnome/terminal/legacy/profiles:/
  echo "Showing gnome-terminal profile names"
  dconf dump /org/gnome/terminal/legacy/profiles:/ | awk '/\[:/||/visible-name=/'
  echo "List profile settings"
  dconf dump /org/gnome/terminal/legacy/profiles:/
}

function set_default_profile(){
  local profile_id="${1}"
  # Set profile as default
  dconf write ${dconfdir}/default "'${profile_id}'"
  echo "Set ${id} as default profile"
}

function create_new_profile(){
  local profile_ids=($(dconf list ${dconfdir}/ | grep ^: | sed 's/\///g' | sed 's/://g'))
  local profile_name="${1}"
  local profile_ids_old="$(dconf read "${dconfdir}"/list | tr -d "]")"
  check_id=$(get_profile_uuid ${profile_name})
  if [[ ${check_id} == "" ]]; then
    local profile_id="$(uuidgen)"
  else
    #echo -e "Profile: ${profile_name} already exists with ID: ${check_id}\nUpdating exiting profile instead"
    profile_id=${check_id}
  fi
  [ -z "${profile_ids_old}" ] && local profile_ids_old="["  # if there's no `list` key
  [ ${#profile_ids[@]} -gt 0 ] && local delimiter=,  # if the list is empty
  dconf write ${dconfdir}/list "${profile_ids_old}${delimiter} '${profile_id}']"
  dconf write "${dconfdir}/:${profile_id}"/visible-name "'$profile_name'"
  dconf write "${dconfdir}/:${profile_id}"/background-transparency-percent 30
  dconf write "${dconfdir}/:${profile_id}"/cell-height-scale 1.05
  dconf write "${dconfdir}/:${profile_id}"/cell-width-scale 1.05
  dconf write "${dconfdir}/:${profile_id}"/cursor-blink-mode "'on'"
  dconf write "${dconfdir}/:${profile_id}"/default-size-columns 90
  dconf write "${dconfdir}/:${profile_id}"/default-size-rows 27
  dconf write "${dconfdir}/:${profile_id}"/font "'MesloLGS NF 12'"
  dconf write "${dconfdir}/:${profile_id}"/background-color "'rgb(0,27,38)'"
  dconf write "${dconfdir}/:${profile_id}"/foreground-color "'rgb(239,235,255)'"
  dconf write "${dconfdir}/:${profile_id}"/use-system-font false
  dconf write "${dconfdir}/:${profile_id}"/use-theme-colors false
  dconf write "${dconfdir}/:${profile_id}"/use-theme-transparency false
  dconf write "${dconfdir}/:${profile_id}"/use-transparent-background true
  echo ${profile_id}
}

function in_array(){
  local e
  for e in "${@:2}"; do [[ $e == ${1} ]] && return 0; done
  return 1
}

# Duplicate a profile
function duplicate_profile(){
  local from_profile_id="${1}"; shift
  local to_profile_name="${1}"; shift
  local profile_ids=($(dconf list ${dconfdir}/ | grep ^: | sed 's/\///g' | sed 's/://g'))

  # If UUID doesn't exist, abort
  in_array "${from_profile_id}" "${profile_ids[@]}" || return 1
  # Create a new profile
  local id=$(create_new_profile "${to_profile_name}")
  # Copy an old profile and write it to the new
  dconf dump "${dconfdir}/:${from_profile_id}/" | dconf load "${dconfdir}/:${id}/"
  # Rename
  dconf write "${dconfdir}/:${id}"/visible-name "'${to_profile_name}'"
}

# Get profile UUID from its name
function get_profile_uuid(){
  # Print the UUID linked to the profile name sent in parameter
  local profile_ids=($(dconf list ${dconfdir}/ | grep ^: | sed 's/\///g' | sed 's/://g'))
  local profile_name="${1}"
  for i in ${!profile_ids[*]}; do
    if [[ "$(dconf read ${dconfdir}/:${profile_ids[i]}/visible-name)" == "'${profile_name}'" ]]; then
      echo "${profile_ids[i]}"
      #return 0
    fi
  done
}

# Get profile name from its UUID
#function get_profile_name(){
#  # Print the UUID linked to the profile name sent in parameter
#  local profile_ids=($(dconf list ${dconfdir}/ | grep ^: | sed 's/\///g' | sed 's/://g'))
#  local profile_id="${1}"
#  for i in ${!profile_ids[*]}; do
#    dconf dump /org/gnome/terminal/legacy/profiles:/
#    if [[ "$(dconf read ${dconfdir}/:${profile_ids[i]}/visible-name)" == "'${profile_name}'" ]]; then
#      echo "${profile_ids[i]}"
#      return 0
#    fi
#  done
#}

# Show Default UUID
#profile_name="Smooth-Jazz"
#id=$(get_profile_uuid ${profile_name})
#echo -e "Profile ${proifle_name} UUID(s): \n${id}"

# Create a profile from an existing one
# duplicate_profile $id TEST1

install_flag="false"
gnome_flag="false"
terminal_flag="false"
profile_flag="false"

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
    i | -i | --install | install)
      install_flag="true"
      ;;
    g | -g | --gnome)
      gnome_flag="true"
      shift
      ;;
    t | -t | --terminal)
      terminal_flag="true"
      shift
      ;;
    p | -p | --terminal-profile)
      profile_flag="true"
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

if [[ "${install_flag}" == "true" ]]; then
  install_dependencies
fi

if [[ "${terminal_flag}" == "true" ]]; then
  install_oh_my_posh
fi

if [[ "${profile_flag}" == "true" ]]; then
  # Create gnome-terminal profile
  profile_name="Smooth-Blues"
  id=$(create_new_profile ${profile_name})
  echo "Created Profile: ${id}"
  # Set default gnome-terminal profile
  set_default_profile "${id}"
fi

if [[ "${gnome_flag}" == "true" ]]; then
  configure_gnome_theme
fi
