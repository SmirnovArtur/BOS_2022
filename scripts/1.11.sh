#!/bin/bash
echo "Каталоги:"
ls -l |grep ^d
echo -e "Обычные файлы:"
ls -l | grep ^-
echo -e "Символьные ссылки:"
ls -l | grep ^l
echo -e "Символьные устройства:"
ls -l | grep ^c
echo -e "Блочные устройства:"
ls -l | grep ^b
