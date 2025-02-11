from ncclient import manager
import xml.dom.minidom

# Function to change the router configuration
def write_config(device, config_filename):
    # Read the configuration from the file
    with open(config_filename, 'r') as file:
        config = file.read()

    # Connect to the device with an increased timeout (e.g., 60 seconds)
    with manager.connect(host=device["host"], port=device["port"], 
                        username=device["username"], password=device["password"], 
                        hostkey_verify=False, timeout=60) as m:
        # Execute NETCONF <edit-config> operation on the 'running' datastore
        netconf_response = m.edit_config(target="running", config=config)
        # Print the response from the device
        print(xml.dom.minidom.parseString(netconf_response.xml).toprettyxml())

# Router connection details for each device
devices = [
    {"host": "clab-AWS-DX-ceos1", "port": 830, "username": "admin", "password": "admin"},
    {"host": "clab-AWS-DX-ceos2", "port": 830, "username": "admin", "password": "admin"},
    {"host": "clab-AWS-DX-ceos3", "port": 830, "username": "admin", "password": "admin"},
    {"host": "clab-AWS-DX-ceos4", "port": 830, "username": "admin", "password": "admin"},
    {"host": "clab-AWS-DX-vpc-router", "port": 830, "username": "admin", "password": "admin"},
]

# Configuration file names for each device
config_files = ["AWS-CORE-CEOS01.xml", "AWS-CORE-CEOS02.xml", "AWS-CORE-CEOS03.xml", "AWS-CORE-CEOS04.xml", "AWS-VPC-Router.xml"]

# Apply the configurations to each device using a for loop
for device, config_file in zip(devices, config_files):
    write_config(device, config_file)
