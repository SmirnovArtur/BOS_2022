#!/bin/bash

# check if root
if [[ $EUID -ne 0 ]]; then
    echo "Ошибка! Программу необходимо запустить с правами администратора."
    exit 1
fi

# functions
function change_port {
    read -p "Введите имя службы: " services
    echo "Службы и порты:"
    semanage port -l | grep $services
    read -p "Введите имя необходимой службы: " service
    read -p "Введите тип протокола (tcp/udp): " protocol
    read -p "Выберите порт для изменения: " old_port
    read -p "Введите новый номер порта: " new_port

    semanage port -d -t $service -p $protocol $old_port
    semanage port -a -t $service -p $protocol $new_port

}

function add_port {
    read -p "Введите имя службы: " service
    read -p "Введите новый номер порта: " new_port
    semanage port -a -t $service -p tcp $new_port
}

function relabel_dir {
    read -p "Введите путь к каталогу для переразметки: " dir
    restorecon -R $dir
}

function relabel_on_reboot {
    touch /.autorelabel
}

function change_file_context {
    read -p "Введите путь к файлу или каталогу: " path
    read -p "Введите новый домен (тип контекста безопасности): " new_domain
    semanage fcontext -a -t $new_domain $path
    restorecon -R $path
}

function list_bool {
    getsebool -a
}

function change_bool {
    read -p "Введите имя переключателя: " bool
    status=$(getsebool $bool | awk '{print $NF}')
    echo "Текущее состояние: $status"
    if [[ $status == "on" ]]
    then
        read -p "Выключить? (y/n) " ans
        if [[ $ans == "y" ]]
        then
            setsebool $bool 0
        fi
    else
        read -p "Включить? (y/n) " ans
        if [[ $ans == "y" ]]
        then
            setsebool $bool 1
        fi
    fi
}

# menu
while true
do
    echo "
    1) Управление портами
    2) Управление файлами
    3) Управление переключателями
    4) Выход
    "
    read -p "> " choice

    case $choice in
        1)
            echo "1) Изменить существующий порт службы"
            echo "2) Добавить новый порт для службы"
            read -p "> " port_choice
            if [[ $port_choice -eq 1 ]]
            then
                change_port
            else
                add_port
            fi
            ;;
        2)
            echo "1) Переразметка каталога (рекурсивно)"
            echo "2) Запустить полную переразметку файловой системы при перезагрузке"
            echo "3) Изменить домен файла или каталога (рекурсивно)"
            read -p "> " file_choice
            if [[ $file_choice -eq 1 ]]
            then
                relabel_dir
            elif [[ $file_choice -eq 2 ]]
            then
                relabel_on_reboot
            else
                change_file_context
            fi
            ;;
        3)
            echo "1) Вывести список переключателей с описанием и состоянием"
            echo "2) Изменить переключатель"
            read -p "> " bool_choice
            if [[ $bool_choice -eq 1 ]]
            then
                list_bool
            else
                change_bool
            fi
            ;;
        4) exit 0;;
        *) echo "Неверный выбор, пожалуйста, введите число 1-4";;
    esac
done

