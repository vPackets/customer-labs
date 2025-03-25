from ncclient import manager
import xml.dom.minidom

HOST = "198.18.128.3"
PORT = 830
USERNAME = "netconf"
PASSWORD = "C1sco12345!"

vlan_config = """
<config>
  <System xmlns="http://cisco.com/ns/yang/Cisco-NX-OS-device">
    <vlan-items>
      <CktEp-list>
        <encap>vlan-1000</encap>
        <fabEncap>vlan-1000</fabEncap>
        <id>1000</id>
        <name>NETCONF_VLAN1000</name>
        <adminSt>active</adminSt>
      </CktEp-list>
    </vlan-items>
  </System>
</config>
"""


with manager.connect(host=HOST, port=PORT, username=USERNAME, password=PASSWORD,
                     hostkey_verify=False, device_params={"name": "nexus"},
                     allow_agent=False, look_for_keys=False) as m:
    print("Pushing VLAN 1000 config via NETCONF...")
    result = m.edit_config(target="running", config=vlan_config)
    formatted_output = xml.dom.minidom.parseString(result.xml).toprettyxml()

    with open("vlan_push_result.xml", "w") as f:
        f.write(formatted_output)

    print("Response written to vlan_push_result.xml")