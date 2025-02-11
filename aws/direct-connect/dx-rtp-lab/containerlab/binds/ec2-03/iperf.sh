#!/bin/bash

# This script needs to be run on the containers in the EC2 instances

while true; do
    iperf3 -c 10.0.0.100 -p 5203 -u -b 15M -l 1400 -P 1
done