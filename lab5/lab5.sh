#!/bin/bash

ps axo euid,ruid,comm | tail -n +2 | while read line

do

	str=($line)
	if [ ${str[0]} != ${str[1]} ]
	then
		echo ${str[2]}
	fi

done
