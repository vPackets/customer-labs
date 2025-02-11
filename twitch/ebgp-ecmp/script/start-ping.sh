#!/bin/sh
while true; do
    ping -c 5 1.1.1.1
    ping -c 5 2.2.2.2
    ping -c 5 3.3.3.3
    ping -c 5 4.4.4.4
    ping -c 5 5.5.5.5
    ping -c 5 6.6.6.6
    ping -c 5 7.7.7.7
    sleep 5
done

