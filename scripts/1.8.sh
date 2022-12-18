#!/bin/bash
echo -e "Процессов пользователя:\n$USERNAME"
ps -u "$USER" | wc -l
echo "Процессов пользователя root:"
ps -u root | wc -l
