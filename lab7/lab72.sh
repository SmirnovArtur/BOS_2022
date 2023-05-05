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

    #echo -e "\nОбработка службы: $unit"
    user=$(systemctl show -p User --value "$unit")
    [ -z "$user" ] && user="root"
    group=$(systemctl show -p Group --value "$unit")
    [ -z "$group" ] && group="root"

    unit_path=""
    if [ -f "/usr/lib/systemd/system/$unit" ]; then
        unit_path="/usr/lib/systemd/system/$unit"
    elif [ -f "/etc/systemd/system/$unit" ]; then
        unit_path="/etc/systemd/system/$unit"
    fi
    override_path="/etc/systemd/system/$unit.d/override.conf"

    check_files=("$unit_path")
    [ -f "$override_path" ] && check_files+=("$override_path")

    exec_start=$(systemctl show -p ExecStart --value "$unit")
    exec_start_pre=$(systemctl show -p ExecStartPre --value "$unit")

    commands=()

    if [[ -n "$exec_start" ]]; then
        while IFS= read -r line; do
            cmd=$(echo "$line" | sed -n 's/^.*[^-]path=\([^ ;]*\).*$/\1/p')
            if [[ -n "$cmd" ]] && [[ -e "$cmd" ]]; then
                commands+=("$cmd")
                check_files+=("$cmd")
            fi
        done <<< "$exec_start"
    fi

    if [[ -n "$exec_start_pre" ]]; then
        while IFS= read -r line; do
            cmd_pre=$(echo "$line" | sed -n 's/^.*path=\([^ ;]*\).*$/\1/p')
            if [[ -n "$cmd_pre" ]]; then
                commands+=("$cmd_pre")
                check_files+=("$cmd_pre")
            fi
        done <<< "$exec_start_pre"
    fi

    for file in "${check_files[@]}"; do
        if [ ! -f "$file" ]; then
            continue
        fi

        file_owner=$(stat -c '%U' "$file")
        file_group=$(stat -c '%G' "$file")

        if [ "$file_owner" != "$user" ] && [ "$(stat -c '%A' "$file" | cut -c3)" = "w" ] && [ "$file_owner" != "root" ]; then
            echo "Нарушение безопасности: служба $unit, файл $file имеет права на запись для пользователя $file_owner."
        fi

        if [ "$file_group" != "$group" ] && [ "$(stat -c '%A' "$file" | cut -c6)" = "w" ]; then
            echo "Нарушение безопасности: служба $unit, файл $file имеет права на запись для группы $file_group."
        fi

        if [ "$(stat -c '%A' "$file" | cut -c8)" = "w" ]; then
            echo "Нарушение безопасности: служба $unit, файл $file имеет права на запись для других пользователей."
        fi

        IFS=$'\n'
        acl_entries=$(getfacl -p "$file" | grep -E "^(user:|group:)" | grep -v -E "user::|group::")

        for acl_entry in $acl_entries; do
            acl_type=$(echo "$acl_entry" | cut -d':' -f1)
            acl_user_or_group=$(echo "$acl_entry" | cut -d':' -f2)
            acl_permissions=$(echo "$acl_entry" | cut -d':' -f3)

            if [ "$acl_type" = "user" ] && [ "$acl_user_or_group" != "$user" ] && echo "$acl_permissions" | grep -q "w"; then
                echo "Нарушение безопасности: служба $unit, файл $file имеет права на запись через ACL для пользователя $acl_user_or_group."
            elif [ "$acl_type" = "group" ] && [ "$acl_user_or_group" != "$group" ] && echo "$acl_permissions" | grep -q "w"; then
                echo "Нарушение безопасности: служба $unit, файл $file имеет права на запись через ACL для группы $acl_user_or_group."
            fi
        done
        unset IFS
    done

    for cmd in "${commands[@]}"; do
        executable=$cmd

        if [ -n "$executable" ]; then
            if [ "$(stat -c '%a' "$executable" | cut -c1)" = "4" ] && [ "$(stat -c '%U' "$executable")" = "root" ] && [ "$user" != "root" ]; then
                echo "Нарушение безопасности: служба $unit, SUID-файл $executable, запускается под пользователем $user."
            fi
        fi
    done
done

