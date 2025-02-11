from ncclient import manager
import xml.dom.minidom

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

# Apply the configurations to each device
for device, config_file in zip(devices, config_files):
    try:
        write_config(device, config_file)
    except Exception as e:
        print(f"Error configuring {device['host']}: {str(e)}")