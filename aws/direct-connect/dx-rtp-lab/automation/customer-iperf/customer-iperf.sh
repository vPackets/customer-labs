#!/bin/bash

#This script needs to be ran on the SERVER (Customer side)

# Array of ports
ports=(5201 5202 5203)

# Loop through the ports and start iperf3 servers
for port in "${ports[@]}"; do
    iperf3 -s -p $port &
    echo "Started iperf3 server on port $port"
done

echo "All iperf3 servers are running in the background."
echo "To stop them, you'll need to find their process IDs and kill them manually."
echo "You can use 'ps aux | grep iperf3' to find the processes."

