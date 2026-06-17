#!/bin/bash

logins=( "user@host" )

for login in "${logins[@]}"; do
    host=${login#*@}
    if ping -c 3 -W 3 -w 12 "$host" > /dev/null 2>&1; then
        if ssh "$login" -o BatchMode=yes ConnectTimeout=4 "sudo shutdown now" > /dev/null 2>&1; then
            echo "$host - shut down"
        fi
    else
        echo "$host - unreachable"
    fi
done

echo "Bye"
