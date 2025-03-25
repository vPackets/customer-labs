from ncclient import manager
from xml.dom.minidom import parseString

HOST = "198.18.128.3"
PORT = 830
USERNAME = "netconf"
PASSWORD = "C1sco12345!"

with manager.connect(
    host=HOST, port=PORT, username=USERNAME, password=PASSWORD,
    hostkey_verify=False, device_params={"name": "nexus"},
    allow_agent=False, look_for_keys=False
) as m:
    print("Getting full <running> config...")
    response = m.get_config(source="running")
    xml_str = parseString(response.xml).toprettyxml()
    with open("running_config_dump.xml", "w") as f:
        f.write(xml_str)

    print("✅ Saved to running_config_dump.xml")