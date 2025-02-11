import subprocess
import time
from ncclient import manager
import xml.dom.minidom

def log(message):
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    print(f"{timestamp} - {message}")

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
            log(f"Docker logs for {container_name}:\n{result.stdout}")
            if "Router up" in result.stdout:
                log(f"{container_name} is up. Waiting 30 seconds for full initialization...")
                time.sleep(30)  # Wait for 30 seconds after "Router up" is detected
                log(f"{container_name} is now fully ready.")
                return True
        except subprocess.CalledProcessError as e:
            log(f"Error checking logs for {container_name}: {e.stderr}")
        time.sleep(10)  # Wait for 10 seconds before checking again
    log(f"Timeout waiting for {container_name} to be ready.")
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
        try:
            if device["type"] == "cisco":
                netconf_response = m.edit_config(target="candidate", config=config)
                m.commit()
            elif device["type"] == "arista":
                netconf_response = m.edit_config(target="running", config=config)
            else:
                raise ValueError(f"Unknown device type: {device['type']}")
            
            log(f"Configuration applied to {device['host']}:")
            log(xml.dom.minidom.parseString(netconf_response.xml).toprettyxml())
        except Exception as e:
            log(f"Error applying configuration to {device['host']}: {str(e)}")

def main():
    # Wait for Cisco router to be ready
    if not wait_for_router_up("clab-AWS-DX-Cisco8201-5"):
        log("Cisco router not ready, exiting.")
        return

    # Apply configurations to network devices
    devices = [
        {"host": "clab-AWS-DX-Cisco8201-5", "port": 830, "username": "cisco", "password": "cisco123", "type": "cisco"},
        {"host": "clab-AWS-DX-ceos1", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
        {"host": "clab-AWS-DX-ceos2", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
        {"host": "clab-AWS-DX-ceos3", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
        {"host": "clab-AWS-DX-ceos4", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
        {"host": "clab-AWS-DX-vpc-router", "port": 830, "username": "admin", "password": "admin", "type": "arista"},
    ]

    config_files = [
        "AWS-DX-VC-EDGE-NETCONF.xml",
        "AWS-CORE-CEOS01.xml",
        "AWS-CORE-CEOS02.xml",
        "AWS-CORE-CEOS03.xml",
        "AWS-CORE-CEOS04.xml",
        "AWS-VPC-Router.xml"
    ]

    for device, config_file in zip(devices, config_files):
        try:
            write_config(device, config_file)
        except Exception as e:
            log(f"Error configuring {device['host']}: {str(e)}")

    log("\nConfiguration complete.")

if __name__ == "__main__":
    main()
    