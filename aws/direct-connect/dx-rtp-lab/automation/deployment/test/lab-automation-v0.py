import subprocess
import time
from ncclient import manager
import xml.dom.minidom

def wait_for_router_up(container_name, timeout=600):
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            result = subprocess.run(
                ["docker", "logs", container_name],
                capture_output=True,
                text=True,
                check=True
            )
            if "Router up" in result.stdout:
                print(f"{container_name} is up. Waiting 30 seconds for full initialization...")
                time.sleep(30)  # Wait for 30 seconds after "Router up" is detected
                print(f"{container_name} is now fully ready.")
                return True
        except subprocess.CalledProcessError as e:
            print(f"Error checking logs for {container_name}: {e.stderr}")
        time.sleep(10)  # Wait for 10 seconds before checking again
    print(f"Timeout waiting for {container_name} to be ready.")
    return False

def write_config(device, config_filename):
    with open(config_filename, 'r') as file:
        config = file.read()
    
    with manager.connect(
        host=device["host"],
        port=device["port"],
        username=device["username"],
        password=device["password"],
        hostkey_verify=False,
        timeout=60
    ) as m:
        if device["type"] == "cisco":
            netconf_response = m.edit_config(target="candidate", config=config)
            m.commit()
        elif device["type"] == "arista":
            netconf_response = m.edit_config(target="running", config=config)
        else:
            raise ValueError(f"Unknown device type: {device['type']}")
        
        print(f"Configuration applied to {device['host']}:")
        print(xml.dom.minidom.parseString(netconf_response.xml).toprettyxml())

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

# Device configurations
devices = [
    {"host": "clab-AWS-DX-Cisco8201-5", "port": 830, "username": "cisco", "password": "cisco123", "type": "cisco"},
    {"host": "clab-AWS-DX-ceos1", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
    {"host": "clab-AWS-DX-ceos2", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
    {"host": "clab-AWS-DX-ceos3", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
    {"host": "clab-AWS-DX-ceos4", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
    {"host": "clab-AWS-DX-vpc-router", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
]

# Configuration file names
config_files = [
    "AWS-DX-VC-EDGE-NETCONF.xml",
    "AWS-CORE-CEOS01.xml",
    "AWS-CORE-CEOS02.xml",
    "AWS-CORE-CEOS03.xml",
    "AWS-CORE-CEOS04.xml",
    "AWS-VPC-Router.xml"
]

# EC2 container configurations
ec2_containers = {
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

def main():
    # Wait for Cisco router to be ready
    if not wait_for_router_up("clab-AWS-DX-Cisco8201-5"):
        print("Cisco router not ready, exiting.")
        return

    # Apply configurations to network devices
    for device, config_file in zip(devices, config_files):
        try:
            write_config(device, config_file)
        except Exception as e:
            print(f"Error configuring {device['host']}: {str(e)}")

    # Configure EC2 containers
    for container, commands in ec2_containers.items():
        print(f"\nConfiguring {container}:")
        for command in commands:
            output = run_command(container, command)
            if output:
                print(output)

    print("\nConfiguration complete.")

if __name__ == "__main__":
    main()
    