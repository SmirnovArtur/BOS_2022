#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Ошибка! Программу необходимо запустить с правами администратора." 1>&2
   exit 1
fi


function show_fs_table {
  echo "Таблица файловых систем:"
  df -h -x tmpfs -x devtmpfs -x sysfs -x proc
}


function mount_fs {
  read -rp "Введите путь до устройства или файла: " device_path
  read -rp "Введите каталог монтирования: " mount_dir

  if [[ ! -d "$mount_dir" ]]; then
    mkdir -p "$mount_dir"
  fi

  if mountpoint -q "$mount_dir"; then
    echo "Ошибка: каталог монтирования не пустой. Выберите другой каталог."
    return
  fi

  if [[ -f "$device_path" ]]; then
    mount -o loop "$device_path" "$mount_dir"
  else
    mount "$device_path" "$mount_dir"
  fi
  echo "Файловая система успешно примонтирована."
}


function unmount_fs {
  mount -v | grep -vE "tmpfs|devtmpfs|sysfs|proc" > /tmp/mount_list.txt
  readarray -t mount_list < /tmp/mount_list.txt
  select mounted_fs in "${mount_list[@]}" "Ввести вручную" "Назад"; do
    case $REPLY in
      "$((${#mount_list[@]}+1))") break;;
      "$((${#mount_list[@]}+2))") return;;
      *)
        if [[ -z $mounted_fs ]]; then
          echo "Ошибка: введите число из списка"
        else
          read -rp "Введите путь для отмонтирования: " umount_path
          umount "$umount_path"
          echo "Файловая система успешно отмонтирована."
          break
        fi
      ;;
    esac
  done
}


function modify_mounted_fs {
  echo "Выберите точку монтирования для изменения параметров монтирования:"
  mounted_fs_list=$(df -h -x tmpfs -x devtmpfs -x sysfs -x proc | awk 'NR>1 {print $NF}')
  select mounted_fs in $mounted_fs_list "Назад"; do
    case $REPLY in
      "$(( $(wc -w <<< "$mounted_fs_list") + 1 ))") return;;
      *)
        if [[ -z $mounted_fs ]]; then
          echo "Ошибка: введите число из списка"
        else
          mount_point=$mounted_fs
          echo "Выбрана точка монтирования: $mount_point"
          echo "Выберите режим монтирования:"
          echo "1. Только чтение"
          echo "2. Чтение и запись"
          read -rp "Выберите действие (1-2): " mode
          case $mode in
            1)
              mount -o remount,ro "$mount_point"
              echo "Файловая система переведена в режим 'только чтение'."
              ;;
            2)
              mount -o remount,rw "$mount_point"
              echo "Файловая система переведена в режим 'чтение и запись'."
              ;;
            *)
              echo "Ошибка: введите число из списка"
              ;;
          esac
          break
        fi
      ;;
    esac
  done
}


function show_mounted_fs_info {
  echo "Выберите файловую систему для отображения параметров монтирования:"
  mounted_fs_list=$(df -h -x tmpfs -x devtmpfs -x sysfs -x proc | awk 'NR>1 {print $6}')
  select mounted_fs in $mounted_fs_list "Назад"; do
    case $REPLY in
      "$(( $(wc -w <<< "$mounted_fs_list") + 1 ))") return;;
      *)
        if [[ -z $mounted_fs ]]; then
          echo -e "\nОшибка: введите число из списка"
        else
          mount_point=$mounted_fs
          echo -e "\nВыбрана точка монтирования: $mount_point"
          findmnt "$mount_point"
          break
        fi
      ;;
    esac
  done
}


function show_ext_fs_info {
  echo "Выберите файловую систему ext* для отображения детальной информации:"
  ext_fs_list=$(lsblk -f | grep -E "ext[234]" | awk '{print $1 " " $2}')
  select ext_fs in $ext_fs_list "Назад"; do
    case $REPLY in
      "$(( $(wc -w <<< "$ext_fs_list") / 2 + 1 ))") return;;
      *)
        if [[ -z $ext_fs ]]; then
          echo "Ошибка: введите число из списка"
        else
          device_path="/dev/$(awk '{print $1}' <<< "$ext_fs")"
          fs_type=$(awk '{print $2}' <<< "$ext_fs")
          echo "Выбрана файловая система: $device_path, тип файловой системы: $fs_type"
          echo "Детальная информация о файловой системе:"
          tune2fs -l "$device_path"
          break
        fi
      ;;
    esac
  done
}


while true; do
  echo -e "\n\nГлавное меню:"
  echo "1. Вывести таблицу файловых систем"
  echo "2. Монтировать файловую систему"
  echo "3. Отмонтировать файловую систему"
  echo "4. Изменить параметры монтирования примонтированной файловой системы"
  echo "5. Вывести параметры монтирования примонтированной файловой системы"
  echo "6. Вывести детальную информацию о файловой системе ext*"
  echo -e "7. Выход\n"
  read -rp "Выберите действие (1-7): " action  && echo -e "\n"

  case $action in
    1) show_fs_table;;
    2) mount_fs;;
    3) unmount_fs;;
    4) modify_mounted_fs;;
    5) show_mounted_fs_info;;
    6) show_ext_fs_info;;
    7) echo "Выход из программы..."; break;;
    *)
      echo "Ошибка: введите число от 1 до 7."
      ;;
  esac
done


