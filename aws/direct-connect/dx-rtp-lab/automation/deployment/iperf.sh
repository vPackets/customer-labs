#!/bin/bash

# Define the container names
containers=(
    "clab-AWS-DX-ec2-vpc01-01"
    "clab-AWS-DX-ec2-vpc02-01"
    "clab-AWS-DX-ec2-vpc03-01"
)

# Set the execution time (2 minutes from now)
exec_time=$(date -d '2 minutes' +"%H:%M")

# Loop through containers and schedule the iperf.sh execution
for container in "${containers[@]}"; do
    docker exec "$container" bash -c "echo '/home/iperf.sh' | at $exec_time"
done

echo "iperf.sh scheduled to run at $exec_time on all containers."