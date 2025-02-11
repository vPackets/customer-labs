from netmiko import ConnectHandler
from datetime import datetime
import os

# Device details with an added 'name' field for custom filenames
devices = [
    {'device_type': 'cisco_xe', 'host': '198.18.128.5', 'username': 'admin', 'password': 'C1sco12345', 'name': 'AWS-DX-Customer_PE'},
    {'device_type': 'cisco_nxos_ssh', 'host': '198.18.128.3', 'username': 'admin', 'password': 'C1sco12345', 'name': 'AWS-DX-VC-CAS'},
    {'device_type': 'cisco_xr', 'host': '198.18.128.7', 'username': 'admin', 'password': 'C1sco12345', 'name': 'AWS-DX-VC-CAR'}
]

# Backup directory
backup_dir = "/home/netadmin/code/backup/files"

# Ensure backup directory exists
if not os.path.exists(backup_dir):
    os.makedirs(backup_dir)

# Function to backup device configuration
def backup_config(device):
    try:
        # Copy the device dictionary to avoid modifying the original
        device_info = device.copy()
        # Extract and remove the 'name' key from the device_info dictionary
        device_name = device_info.pop('name')
        # Establish SSH connection without the 'name' key
        net_connect = ConnectHandler(**device_info)
        # Get the current date and time for the filename
        now = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        # Use device name for the filename
        filename = f"{backup_dir}/{device_name}_{now}.cfg"
        # Fetching configuration
        config = net_connect.send_command("show running-config")
        # Writing configuration to file
        with open(filename, 'w') as config_file:
            config_file.write(config)
        print(f"Backup completed for {device_name} on {now}")
    except Exception as e:
        print(f"Failed to backup {device_name}: {str(e)} on {now}" )

# Backup configurations for all devices
for device in devices:
    backup_config(device)

