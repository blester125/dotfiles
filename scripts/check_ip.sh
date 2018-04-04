#!/bin/bash

ip=""

while [ 1 ]
do
    new_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
    if [ "$ip" != "$new_ip" ]
    then
        ip=$new_ip
        echo -e "$ip" | mailx -A gmail -s "IP Address Changed" blester125@gmail.com
    fi
    sleep 5m
done
