from ncclient import manager
import xml.dom.minidom

# Function to change the router configuration
def write_config(device, config_filename):
    # Read the configuration from the file
    with open(config_filename, 'r') as file:
        config = file.read()

    with manager.connect(host=device["host"], port=device["port"], username=device["username"], password=device["password"], hostkey_verify=False) as m:
        netconf_response = m.edit_config(target="candidate", config=config)
        m.commit()
        print(xml.dom.minidom.parseString(netconf_response.xml).toprettyxml())

# Router connection details
devices = [
    {"host": "clab-AWS-DX-Cisco8201-5", "port": 830, "username": "cisco", "password": "cisco123"}
]

# Configuration file names
config_files = ["AWS-DX-VC-EDGE-NETCONF.xml"]

# Apply the configurations to each device using a for loop
for device, config_file in zip(devices, config_files):
    write_config(device, config_file)
