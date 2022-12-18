#!/bin/bash
echo "quantity: $#"
echo "all in one: $*"
echo "all: $@"

echo "Первые два аргумента: $1 $2"
echo "Сумма третьего, четвёртого и пятого аргументов: $(($3+$4+$5))"
