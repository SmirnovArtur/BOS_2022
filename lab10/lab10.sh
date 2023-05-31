#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Ошибка! Программу необходимо запустить с правами администратора."
  exit
fi


function search_audit_events {
    echo "Примеры типов событий аудита: USER_AUTH, USER_START, CRED_DISP, USER_CMD, LOGIN"
    echo "Введите тип события: "
    read -r event_type
    echo "Введите имя пользователя (оставьте пустым для всех пользователей): "
    read -r user_name
    echo "Введите строку поиска: "
    read -r search_string

    if [ -z "$user_name" ]; then
        ausearch -m "$event_type" | grep "$search_string"
    else
        ausearch -m "$event_type" -ua "$user_name" | grep "$search_string"
    fi
}

function generate_audit_reports {
    echo "Выберите период для отчета:"
    echo "1) за последний день"
    echo "2) за последнюю неделю"
    echo "3) за последний месяц"
    echo "4) за последний год"
    read -p "Введите номер вашего выбора: " choice

    case $choice in
        1)
            period=$(date -d '1 day ago' +%m/%d/%Y)
            ;;
        2)
            period=$(date -d '1 week ago' +%m/%d/%Y)
            ;;
        3)
            period=$(date -d '1 month ago' +%m/%d/%Y)
            ;;
        4)
            period=$(date -d '1 year ago' +%m/%d/%Y)
            ;;
        *)
            echo "Неверный выбор. Пожалуйста, выберите номер от 1 до 4."
            return
            ;;
    esac

    echo "Выберите тип отчета:"
    echo "1) Отчет входа пользователей в систему"
    echo "2) Отчет о нарушениях"
    read -p "Введите номер вашего выбора: " report_type

    case $report_type in
        1)
            echo "Отчеты за период с $period по текущую дату"
            echo "Отчет входа пользователей в систему: "
            aureport --start $period --end now --login --interpret --summary
            ;;
        2)
            echo "Отчеты за период с $period по текущую дату"
            echo "Отчет о нарушениях: "
            aureport --start $period --end now --failed --interpret --summary

	    ;;
        *)
            echo "Неверный выбор. Пожалуйста, выберите номер от 1 до 2."
            return
            ;;
    esac
}


function audit_file_watch {
    echo "1) Добавить каталог или файл в список наблюдения"
    echo "2) Удалить каталог из списка наблюдения"
    echo "3) Вывести отчёт по наблюдению за каталогом"
    read -p "Введите номер вашего выбора: " choice

    case $choice in
        1)
            echo "Введите путь к каталогу или файлу:"
            read path
            auditctl -w $path -p wa
            ;;
        2)
            echo "Введите путь к каталогу или файлу:"
            read path
            auditctl -W $path -p wa
            ;;
        3)
            echo "Введите путь к каталогу или файлу:"
            read path
            ausearch -f $path
            ;;
        *)
            echo "Неверный выбор. Пожалуйста, выберите номер от 1 до 3."
            return
            ;;
    esac
}



while :
do
    echo "Главное меню:"
    echo "1. Поиск событий аудита"
    echo "2. Отчёты аудита"
    echo "3. Настройка подсистемы аудита для наблюдения за файлами"
    echo "4. Выход"
    read -r -p "Выберите опцию [1-4] : " choice

    case $choice in

        1)  
            search_audit_events
            ;;
        2)  
            generate_audit_reports
            ;;
        3)  
            audit_file_watch
            ;;
        4)  
            break
            ;;

        *) echo "Ошибка: введите число из списка"

    esac
done
