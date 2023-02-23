#!/bin/bash
CATNAME="$1"

echo "Каталоги:"
ls "$1" -al |grep ^d
echo -e "\nОбычные файлы:"
ls "$1" -al | grep ^-
echo -e "\nСимвольные ссылки:"
ls "$1" -al | grep ^l
echo -e "\nСимвольные устройства:"
ls "$1" -al | grep ^c
echo -e "\nБлочные устройства:"
ls "$1" -al | grep ^b
