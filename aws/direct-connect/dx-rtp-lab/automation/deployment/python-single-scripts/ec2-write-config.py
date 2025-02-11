import subprocess

# Define the container names and their corresponding commands
containers = {
    "clab-AWS-DX-ec2-vpc01-01": [
        "ip addr add 172.31.10.100/24 dev eth1",
        "ip route add 172.31.0.0/16 via 172.31.10.1",
        "ip route add 10.0.0.0/24 via 172.31.10.1"
    ],
    "clab-AWS-DX-ec2-vpc02-01": [
        "ip addr add 172.31.20.100/24 dev eth1",
        "ip route add 172.31.0.0/16 via 172.31.20.1",
        "ip route add 10.0.0.0/24 via 172.31.20.1"
    ],
    "clab-AWS-DX-ec2-vpc03-01": [
        "ip addr add 172.31.30.100/24 dev eth1",
        "ip route add 172.31.0.0/16 via 172.31.30.1",
        "ip route add 10.0.0.0/24 via 172.31.30.1"
    ]
}

def run_command(container, command):
    try:
        result = subprocess.run(
            ["docker", "exec", container, "sh", "-c", command],
            capture_output=True,
            text=True,
            check=True
        )
        print(f"Successfully executed in {container}: {command}")
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error executing in {container}: {command}")
        print(f"Error message: {e.stderr}")
        return None

# Execute commands for each container
for container, commands in containers.items():
    print(f"\nConfiguring {container}:")
    for command in commands:
        output = run_command(container, command)
        if output:
            print(output)

print("\nConfiguration complete.")
