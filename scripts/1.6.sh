#!/bin/bash
echo -e "Домашний каталог пользователя\n$USERNAME\nсодержит обычных файлов:"
find ~ -maxdepth 1 -type f | wc -l
echo "скрытых файлов:"
find ~ -maxdepth 1 -type f -name ".*"  | wc -l
