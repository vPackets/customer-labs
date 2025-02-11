from ncclient import manager
import xml.dom.minidom

# Function to back up the configuration via NETCONF
def backup_config(host, username, password, device_type):
    try:
        print(f"Connecting to {host} ({device_type})")
        with manager.connect(host=host, port=830, username=username, password=password, hostkey_verify=False) as m:
            config = m.get_config(source='running').data_xml
            config_xml = xml.dom.minidom.parseString(config)
            pretty_config = config_xml.toprettyxml(indent="  ")
            with open(f"{host}_config_backup.xml", "w") as f:
                f.write(pretty_config)
            print(f"Backup for {host} ({device_type}) completed successfully.")
    except Exception as e:
        print(f"Failed to backup {host} ({device_type}): {e}")

# List of devices in the topology with their credentials
devices = [
    {"host": "172.20.20.5", "username": "admin", "password": "admin", "device_type": "Cisco Cat8kv"},
    {"host": "172.20.20.8", "username": "admin", "password": "admin", "device_type": "Cisco Cat8kv"},
    {"host": "172.20.20.7", "username": "admin", "password": "admin", "device_type": "Cisco Cat8kv"},
    {"host": "172.20.20.3", "username": "admin", "password": "admin", "device_type": "Cisco Cat8kv"},
    {"host": "172.20.20.2", "username": "admin", "password": "admin", "device_type": "Cisco Cat8kv"},
    {"host": "172.20.20.4", "username": "admin", "password": "admin", "device_type": "Cisco Cat8kv"},
    {"host": "172.20.20.19", "username": "cisco", "password": "cisco123", "device_type": "Cisco 8000"},
    {"host": "172.20.20.18", "username": "cisco", "password": "cisco123", "device_type": "Cisco 8000"},
    {"host": "172.20.20.6", "username": "cisco", "password": "cisco123", "device_type": "Cisco 8000"},
    {"host": "172.20.20.9", "username": "cisco", "password": "cisco123", "device_type": "Cisco 8000"},
    {"host": "172.20.20.10", "username": "cisco", "password": "cisco123", "device_type": "Cisco 8000"},
]

# Loop through the devices and back up the configuration
for device in devices:
    backup_config(device["host"], device["username"], device["password"], device["device_type"])

