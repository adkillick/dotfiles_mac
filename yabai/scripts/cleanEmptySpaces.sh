#!/usr/bin/env bash

destroy_space_if_conditions () {
     local space=$1
     local space_info=$(yabai -m query --spaces --space $space)
     local next_space_info=$(yabai -m query --spaces --space $(($space + 1)))
     local no_windows=$(echo $space_info | jq -re '."windows" == []')
     local invisible=$(echo $space_info | jq -re '."is-visible" == false')
     local next_space_not_fullscreen=$(echo $next_space_info | jq -re '."is-native-fullscreen" == false')
     if [ -z "$next_space_not_fullscreen" ]; then
          next_space_not_fullscreen=true
     fi

     echo "no_windows: $no_windows, invisible: $invisible, next_space_not_fullscreen: $next_space_not_fullscreen"

     if $no_windows && $invisible && $next_space_not_fullscreen ; then
          echo "Destroying space $space"
          yabai -m space $space --destroy
     else
          echo "Not destroying space $space"
     fi
}
export -f destroy_space_if_conditions

yabai -m query --spaces --display | \
     jq -re 'map(select(."is-native-fullscreen" == false)) | length > 1' \
     && yabai -m query --spaces | \
          jq -re 'map(select(."windows" == [] and ."has-focus" == false).index) | reverse | .[] ' | \
          xargs -I % sh -c 'destroy_space_if_conditions %'


