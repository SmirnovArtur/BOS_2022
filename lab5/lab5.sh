#!/bin/bash

file="tmp.out"

ps -eo euid,ruid,comm | tail -n +2  >"$file"
exec 0<"$file"

while read euid ruid name 
do
	if [[ $euid != $ruid ]]; then
		echo "$name"
	fi
done

rm "$file"
