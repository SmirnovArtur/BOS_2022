#!/bin/bash

systemctl list-unit-files --type=service --full --no-legend | while read -r line; do
  unit=$(echo "$line" | awk '{print $1}')
  state=$(echo "$line" | awk '{print $4}')

  if [[ "$unit" == *@* ]]; then
    continue
  fi

  if [ "$state" = "disabled" ] || [ "$state" = "static" ]; then
    continue
  fi

  echo -e "\nОбработка службы: $unit"
  user=$(systemctl show -p User --value "$unit")
  [ -z "$user" ] && user="root"
  group=$(systemctl show -p Group --value "$unit")
  [ -z "$group" ] && group="root"

  echo "User: $user"
  echo "Group: $group"

  unit_path=""
  if [ -f "/usr/lib/systemd/system/$unit" ]; then
    unit_path="/usr/lib/systemd/system/$unit"
  elif [ -f "/etc/systemd/system/$unit" ]; then
    unit_path="/etc/systemd/system/$unit"
  fi
  override_path="/etc/systemd/system/$unit.d/override.conf"

  check_files=("$unit_path")
  [ -f "$override_path" ] && check_files+=("$override_path")

  for file in "${check_files[@]}"; do
    if [ ! -f "$file" ]; then
      continue
    fi

    file_owner=$(stat -c '%U' "$file")
    file_group=$(stat -c '%G' "$file")


    echo "File: $file"
    echo "File owner: $file_owner"
    echo "File group: $file_group"

    if [ "$file_owner" != "$user" ] && [ "$(stat -c '%A' "$file" | cut -c5)" = "w" ]; then
      echo "Нарушение безопасности: служба $unit, файл $file имеет права на запись для группы $file_group."
    fi

    if [ "$file_owner" != "$user" ] && [ "$(stat -c '%A' "$file" | cut -c8)" = "w" ]; then
      echo "Нарушение безопасности: служба $unit, файл $file имеет права на запись для других пользователей."
    fi

    acl_entries=$(getfacl -p "$file" | grep -E "^user:|group:" | grep -v -E "user::|group::")

    for acl_entry in $acl_entries; do
      acl_type=$(echo "$acl_entry" | cut -d':' -f1)
      acl_user_or_group=$(echo "$acl_entry" | cut -d':' -f2)
      acl_permissions=$(echo "$acl_entry" | cut -d':' -f3)

      echo "ACL type: $acl_type"
      echo "ACL entry: $acl_entry"
      echo "ACL user_or_group: $acl_user_or_group"
      echo "ACL permissions: $acl_permissions"

      if [ "$acl_type" = "user" ] && [ "$acl_user_or_group" != "$user" ] && echo "$acl_permissions" | grep -q "w"; then
        echo "Нарушение безопасности: служба $unit, файл $file имеет права на запись через ACL для пользователя $acl_user_or_group."
      elif [ "$acl_type" = "group" ] && [ "$acl_user_or_group" != "$group" ] && echo "$acl_permissions" | grep -q "w"; then
        echo "Нарушение безопасности: служба $unit, файл $file имеет права на запись через ACL для группы $acl_user_or_group."
      fi
    done
  done

  exec_start=$(sudo systemctl cat "$unit" | grep "ExecStart=" | awk -F'=' '{print $2}')
  executable=$(echo "$exec_start" | awk -F' ' '{for(i=1;i<=NF;i++) {if ($i ~ /^\//) {print $i; exit}}}')
  
  echo "ExecStart: $exec_start"
  echo "Executable: $executable"

  if [ -n "$executable" ]; then
    if [ "$(stat -c '%a' "$executable" | cut -c4)" = "4" ] && [ "$(stat -c '%U' "$executable")" = "root" ] && [ "$user" != "root" ]; then
      echo "Нарушение безопасности: служба $unit, SUID-файл $executable, запускается под пользователем $user."
    fi
  fi
done
