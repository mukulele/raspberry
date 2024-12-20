#!/bin/bash
export LC_ALL=C
# LC_ALL is the environment variable that overrides all the other localisation settings

enable_disable_wwan0 ()
{
    result=$(nmcli dev | grep "wwan" | grep -w "connected")
    if [ -n "$result" ]; then
# routing set in nmcli con show wwan
        iptables -A OUTPUT -d 239.2.1.1 -j DROP
    else
        iptables -D OUTPUT -d 239.2.1.1 -j DROP
# manage hosts
        nmcli radio wifi on
    fi
}

if [ "$2" = "up" ]; then
    enable_disable_wwan0
fi

if [ "$2" = "down" ]; then
    enable_disable_wwan0
fi