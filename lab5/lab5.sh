#!/bin/bash

ps -eo pid,user,%cpu,%mem,comm | \

tail -n +2 | \

while read -r pid user cpu mem comm; do
  if [ "$(id -u "$user")" != "$(ps -o "ruid=" -o "euid=" -p "$pid" | awk '{ print $1 }')" ]; then
    echo "$comm"
  fi
done
