<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Whole_Foods_Market_logo.svg/440px-Whole_Foods_Market_logo.svg.png" height="200" class="image-margin-right">
<span style="margin-right: 100px;"></span> <!-- Adjust the 20px to whatever space you need -->
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Cisco_logo.svg/320px-Cisco_logo.svg.png" height="200"> 


<br>

# Whole Foods Market - Catalyst 9300 - Spanning Tree Portfast


## Contact Information
  
- [Nicolas Michel, Solution Architect](nicmcl@cisco.com)




*Last Updated: [2025-3-21]*


## Introduction

In fast-paced retail environments, network responsiveness is critical—especially at the edge where devices like POS terminals, IP phones, kiosks, and handheld scanners depend on immediate connectivity to serve customers efficiently. This document demonstrates the behavior and benefits of the Spanning Tree Protocol (STP) PortFast feature on Cisco Catalyst 9300 Series Switches, with a focus on how it enhances performance and uptime in a retail setting.

PortFast is designed to allow switch access ports to bypass the standard STP listening and learning phases, moving directly to the forwarding state when a device connects. This ensures minimal delay during device boot-up or reconnection—key for maintaining seamless customer service and uninterrupted store operations.

In this guide, you will find:

	•	A clear explanation of how PortFast operates on Catalyst 9300 switches.
	•	Real-time behavior logs showing how interfaces transition during link events.
	•	Guidance on best practices for safely enabling PortFast in retail networks.
	•	Key considerations for avoiding issues such as loops when connecting network infrastructure.

Our goal is to provide you with the confidence and clarity needed to deploy PortFast effectively across your store network, ensuring faster device readiness and a more resilient customer-facing experience.

## Topology

![Catalyst Spanning Tree Topology](./images/STP-topology.png)


The network consists of two Cisco Catalyst switches connected via a GigabitEthernet link, forming a structured Spanning Tree Protocol (STP) topology. The Catalyst 9300-48U switch operates as the Root Bridge, while the Catalyst 9200-48T functions as an access layer switch and will simulate a rogue switch connected at the access layer.

Network Setup:

	•	Catalyst 9300-48U (Root Bridge) – IOS-XE v16.10.1
	•	Catalyst 9200-48T (Access Switch) – IOS-XE v17.09.05

Spanning Tree Role Assignment:

	•	Catalyst 9300 (Root Bridge): Gi1/0/1 → Designated Port
	•	Catalyst 9200 (Access Switch): Gi1/0/48 → Root Port


## Rapid Spanning Tree overview and Theory

Source: [Cisco Documentation Link](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst9300/software/release/17-16/configuration_guide/lyr2/b_1716_lyr2_9300_cg.html)

Rapid PVST+—Rapid PVST+ is the default STP mode on Cisco devices. This spanning-tree mode is the same as PVST+ except that is uses a rapid convergence based on the IEEE 802.1w standard. 



## Configuration Catalyst 9300-48U

Global Spanning tree configuration

```
C9348-CoreCorpIT-1#show run | inc spanning
spanning-tree mode rapid-pvst
spanning-tree portfast default
spanning-tree extend system-id
spanning-tree vlan 102 priority 0
```

The switch is running Rapid PVST+ (Per VLAN Spanning Tree Plus), which enhances convergence speed and improves network stability.

PortFast is enabled globally by default, meaning all access ports will immediately transition to the forwarding state upon link-up unless they receive a BPDU.

This setting allows the switch to dynamically generate bridge IDs based on the VLAN number and system priority. (not relevant in our demonstration.)


Port Configuration:

```
C9348-CoreCorpIT-1#show run int gi1/0/1
Building configuration...

Current configuration : 90 bytes
!
interface GigabitEthernet1/0/1
 switchport access vlan 102
 switchport mode access
```

VLAN Assignment: The port is statically assigned to VLAN 102, ensuring all connected devices operate within this VLAN.

Access Mode Configuration: The port is explicitly configured as an access port, meaning it does not participate in VLAN trunking.

PortFast Behavior: Since spanning-tree portfast default is globally enabled, this access port automatically inherits PortFast behavior, making it a Spanning Tree Edge Port. This allows the port to bypass the traditional Listening and Learning states and transition directly to Forwarding when a device is connected.



## Configuration Catalyst 9200

Global Spanning Tree Configuration:

```
C9200-4-Aggr1CorpIT#show run | inc spanning
spanning-tree mode rapid-pvst
spanning-tree extend system-id
C9200-4-Aggr1CorpIT#

```
The switch is running Rapid PVST+ (Per VLAN Spanning Tree Plus), which enhances convergence speed and improves network stability.

We have not configured portfast default globally on that switch.


Port Configuration
```

C9200-4-Aggr1CorpIT#show run int gi1/0/48
Building configuration...

Current configuration : 91 bytes
!
interface GigabitEthernet1/0/48
 switchport access vlan 102
 switchport mode access
```

Access Mode Configuration: The port is explicitly configured as an access port, meaning it does not participate in VLAN trunking. This port is used to send BPDU frames to the Catalyst 9300 to study and understand the behavior.

## Spanning tree summary:

```
C9348-CoreCorpIT-1#show spanning summary
Switch is in rapid-pvst mode
Root bridge for: VLAN0102
EtherChannel misconfig guard            is enabled
Extended system ID                      is enabled
Portfast Default                        is enabled
PortFast BPDU Guard Default            is disabled
Portfast BPDU Filter Default           is disabled
Loopguard Default                      is disabled
UplinkFast                              is disabled
BackboneFast                            is disabled
Configured Pathcost method used is short

Name                   Blocking Listening Learning Forwarding STP Active
---------------------- -------- --------- -------- ---------- ----------
VLAN0102                     0         0        0          1          1
---------------------- -------- --------- -------- ---------- ----------
1 vlan                       0         0        0          1          1
C9348-CoreCorpIT-1#
```


## Debug and Analysis

```
9348-CoreCorpIT-1#show spanning int gi1/0/1
no spanning tree info available for GigabitEthernet1/0/1

C9348-CoreCorpIT-1#show spanning int gi1/0/1
004401: *Mar 21 05:54:28.084: Created spanning tree: VLAN0102 (7F78E3384820)
004402: *Mar 21 05:54:28.084: Setting spanning tree MAC address: VLAN0102 (7F78E3384820) to 50f7.222b.ba80
004403: *Mar 21 05:54:28.084: setting bridge id (which=3) prio 102 prio cfg 0 sysid 102 (on) id 0066.50f7.222b.ba80
004404: *Mar 21 05:54:28.084: STP PVST: Assigned bridge address of 50f7.222b.ba80 for VLAN0102 [66] @ 7F78E3384820.
004405: *Mar 21 05:54:28.084: Starting spanning tree: VLAN0102 (7F78E3384820)
004406: *Mar 21 05:54:28.084: Created spanning tree port Gi1/0/1 (7F78D77D0058) for tree VLAN0102 (7F78E3384820)
004407: *Mar 21 05:54:28.084:  STP: PVST vlan 102 port Gi1/0/1 created, ext id 7F78DEEBE700
004408: *Mar 21 05:54:28.084: Enabling spanning tree port: GigabitEthernet1/0/1 (7F78D77D0058)
004409: *Mar 21 05:54:28.084: RSTP(102): initializing port Gi1/0/1
004410: *Mar 21 05:54:28.084: STP SW: Gi1/0/1 new blocking req for 1 vlans
004411: *Mar 21 05:54:28.085: Returning spanning tree stats for VLAN0102 (7F78E3384820)
004412: *Mar 21 05:54:28.085: RSTP(102): Gi1/0/1 is now designated
004413: *Mar 21 05:54:28.085: STP SW: Gi1/0/1 new forwarding req for 1 vlans
004414: *Mar 21 05:54:28.085: Returning spanning tree stats for VLAN0102 (7F78E3384820) port
004415: *Mar 21 05:54:28.085: Returning spanning tree stats for VLAN0102 (7F78E3384820)
004416: *Mar 21 05:54:28.093: RSTP(102): starting topology change timer for 35 seconds
C9348-CoreCorpIT-1#show spanning int gi1/0/1 portfast
VLAN0102            enabled
C9348-CoreCorpIT-1#
004417: *Mar 21 05:54:30.083: %LINK-3-UPDOWN: Interface GigabitEthernet1/0/1, changed state to up
004418: *Mar 21 05:54:30.085: %LINK-3-UPDOWN: Interface Vlan102, changed state to up
004419: *Mar 21 05:54:31.054: Returning spanning tree stats for VLAN0102 (7F78E3384820)
004420: *Mar 21 05:54:31.054: Returning spanning tree port stats: GigabitEthernet1/0/1 (7F78D77D0058)show spanning int gi1/0/1 portfast
004421: *Mar 21 05:54:31.083: %LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet1/0/1, changed state to up
004422: *Mar 21 05:54:31.086: %LINEPROTO-5-UPDOWN: Line protocol on Interface Vlan102, changed state to u
C9348-CoreCorpIT-1#show spanning int gi1/0/1

Vlan                Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
VLAN0102            Desg FWD 4         128.1    P2p Edge
C9348-CoreCorpIT-1#
004423: *Mar 21 05:54:36.455: Returning spanning tree stats for VLAN0102 (7F78E3384820)
004424: *Mar 21 05:54:36.455: Returning spanning tree port stats: GigabitEthernet1/0/1 (7F78D77D0058)
C9348-CoreCorpIT-1#u all
All possible debugging has been turned off
C9348-CoreCorpIT-1#
```


The logs provide insight into the Spanning Tree Protocol (STP) negotiation and PortFast behavior on GigabitEthernet1/0/1 for VLAN 102 on the Catalyst 9300-48U switch (C9348-CoreCorpIT-1). The key observations include:


When Gi1/0/1 comes up, the switch initializes Spanning Tree for VLAN 102 and It sets the MAC address and bridge ID, confirming it is acting as the Root Bridge (priority 0 was set in previous configs).

```
004401: *Mar 21 05:54:28.084: Created spanning tree: VLAN0102
004402: *Mar 21 05:54:28.084: Setting spanning tree MAC address: VLAN0102 to 50f7.222b.ba80
004403: *Mar 21 05:54:28.084: setting bridge id prio 102 prio cfg 0 sysid 102 id 0066.50f7.222b.ba80
004404: *Mar 21 05:54:28.084: Assigned bridge address of 50f7.222b.ba80 for VLAN0102
```

Portfast enables Immediate Forwarding:

```
004408: *Mar 21 05:54:28.084: Enabling spanning tree port: GigabitEthernet1/0/1
004409: *Mar 21 05:54:28.084: RSTP(102): initializing port Gi1/0/1
004410: *Mar 21 05:54:28.084: STP SW: Gi1/0/1 new blocking req for 1 vlans
004412: *Mar 21 05:54:28.085: RSTP(102): Gi1/0/1 is now designated
004413: *Mar 21 05:54:28.085: STP SW: Gi1/0/1 new forwarding req for 1 vlans
```

The switch initializes STP for the interface, recognizez the interface as an edge port (portfast default enabled globally).

The port bypasses the normal STP states (Listening → Learning) and immediately enters Forwarding even though it receives BPDUs from the Catalyst 9200 and the port is confirmed as a designated port:

```
C9348-CoreCorpIT-1#show spanning int gi1/0/1

Vlan                Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
VLAN0102            Desg FWD 4         128.1    P2p Edge
```

## Summary

Since the Catalyst 9300 is configured with the global command "spanning-tree portfast default" and the switch operates on RPVST+,  the access port configured is considered as an edge port and does not transition through the usual LIS and LRN States.

It does transition directly to FWD even though it receives BPDUs from the Catalyst 9200.



## Extended Logs

Here are some extended logs for the spanning tree debug:

```
C9348-CoreCorpIT-1#show spannin
004436: *Mar 21 06:18:01.481: STP SW: RX ISR: 0180.c200.0000<-b44c.9092.4fb0 type/len 0027
004437: *Mar 21 06:18:01.481:     encap SAP linktype ieee-st vlan 102 len 53 on v102 Gi1/0/1
004438: *Mar 21 06:18:01.481:     42 42 03 SPAN
004439: *Mar 21 06:18:01.481:     CFG P:0000 V:02 T:02 F:0E R:8066 b44c.9092.4f80 00000000
004440: *Mar 21 06:18:01.481:     B:8066 b44c.9092.4f80 80.30 A:0000 M:1400 H:0200 F:0F00STP: pak->vlan_id: 102

004441: *Mar 21 06:18:01.482: STP SW: PROC RX: 0180.c200.0000<-b44c.9092.4fb0 type/len 0027
004442: *Mar 21 06:18:01.482:     encap SAP linktype ieee-st vlan 102 len 53 on v102 Gi1/0/1
004443: *Mar 21 06:18:01.482:     42 42 03 SPAN
004444: *Mar 21 06:18:01.482:     CFG P:0000 V:02 T:02 F:0E R:8066 b44c.9092.4f80 00000000
004445: *Mar 21 06:18:01.482:     B:8066 b44c.9092.4f80 80.30 A:0000 M:1400 H:0200 F:0F00
004446: *Mar 21 06:18:01.482: STP SW: DROP BPDU: received ieee-st(19) BPDU on interface Gi1/0/1 vlan 102: invalid port mode none(10)
004447: *Mar 21 06:18:01.561: STP SW: 1 virtual port being added single: Gi1/0/1.102
004448: *Mar 21 06:18:01.561: STP SW: 1 virtual port link up single: Gi1/0/1.102
004449: *Mar 21 06:18:01.561: Created spanning tree: VLAN0102 (7F78E3827418)
004450: *Mar 21 06:18:01.561: Setting spanning tree MAC address: VLAN0102 (7F78E3827418) to 50f7.222b.ba80
004451: *Mar 21 06:18:01.561: setting bridge id (which=3) prio 102 prio cfg 0 sysid 102 (on) id 0066.50f7.222b.ba80
004452: *Mar 21 06:18:01.561: STP PVST: Assigned bridge address of 50f7.222b.ba80 for VLAN0102 [66] @ 7F78E3827418.
004453: *Mar 21 06:18:01.561: Starting spanning tree: VLAN0102 (7F78E3827418)
004454: *Mar 21 06:18:01.561: STP CFG: found port cfg GigabitEthernet1/0/1 (7F78DEEBE700)
004455: *Mar 21 06:18:01.561: Created spanning tree port Gi1/0/1 (7F78D77D0058) for tree VLAN0102 (7F78E3827418)
004456: *Mar 21 06:18:01.561:  STP: PVST vlan 102 port Gi1/0/1 created, ext id 7F78DEEBE700
004457: *Mar 21 06:18:01.561: Enabling spanning tree port: GigabitEthernet1/0/1 (7F78D77D0058)
004458: *Mar 21 06:18:01.562: RSTP(102): initializing port Gi1/0/1
004459: *Mar 21 06:18:01.562: RSTP HA: rstp_ha_send Type=PORT_INSTANCE_STATE_CHANGE [Dropped: sync disabled]
004460: *Mar 21 06:18:01.562: STP HA: stp_ha_event (OPEN , SET_PORT_STATE, )[Dropped: sync disabled]
004461: *Mar 21 06:18:01.562: STP SW: Gi1/0/1 new blocking req for 1 vlans
004462: *Mar 21 06:18:01.562: Found no corresponding dummy port for instance 102, port_id 128.1
004463: *Mar 21 06:18:01.562: Returning spanning tree stats for VLAN0102 (7F78E3827418)
004464: *Mar 21 06:18:01.562: STP SW: VLAN102: age time is currently 300 secs
004465: *Mar 21 06:18:01.562: RSTP(102): Gi1/0/1 is now designated
004466: *Mar 21 06:18:01.562: RSTP HA: rstp_ha_send Type=TREE_INSTANCE_ROOT_INFO [Dropped: sync disabled]
004467: *Mar 21 06:18:01.562: RSTP HA: rstp_ha_send Type=PORT_INSTANCE_STATE_CHANGE [Dropped: sync disabled]
004468: *Mar 21 06:18:01.562: STP: stp_helper_remove_from_other_queues closing EV:0 for empty request
004469: *Mar 21 06:18:01.562: STP HA: stp_ha_event (CLOSE, SET_PORT_STATE, )[Dropped: sync disabled]
004470: *Mar 21 06:18:01.562: STP HA: stp_ha_event (OPEN , SET_PORT_STATE, )[Dropped: sync disabled]
004471: *Mar 21 06:18:01.562: STP SW: Gi1/0/1 new forwarding req for 1 vlans
004472: *Mar 21 06:18:01.562: Found no corresponding dummy port for instance 102, port_id 128.1
004473: *Mar 21 06:18:01.562: Returning spanning tree stats for VLAN0102 (7F78E3827418)
004474: *Mar 21 06:18:01.562: STP SW: VLAN102: age time is currently 300 secs
004475: *Mar 21 06:18:01.562: Found no corresponding dummy port for instance 102, port_id 128.1
004476: *Mar 21 06:18:01.563: Returning spanning tree stats for VLAN0102 (7F78E3827418)
004477: *Mar 21 06:18:01.563: STP SW: VLAN102: age time is currently 300 secs
004478: *Mar 21 06:18:01.563: RSTP HA: rstp_ha_send Type=PORT_INSTANCE_INFO [Dropped: sync disabled]
004479: *Mar 21 06:18:01.563: STA HA: stp_helper_task BITMAP with EV=0 TreeType=2 State=forwarding
004480: *Mar 21 06:18:01.564: STP HA: stp_ha_event (CLOSE, SET_PORT_STATE, )[Dropped: sync disabled]
004481: *Mar 21 06:18:01.564: STP Helper: Gi1/0/1 forwarding 1 vlans agg 1 q 2 dur 1ms
004482: *Mar 21 06:18:01.565: STP Helper: will sleep, processed 1, yield 0ms
004483: *Mar 21 06:18:01.565: RSTP(102): sending BPDU out Gi1/0/1
004484: *Mar 21 06:18:01.565: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004485: *Mar 21 06:18:01.565:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004486: *Mar 21 06:18:01.565:     42 42 03 SPAN
004487: *Mar 21 06:18:01.565:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004488: *Mar 21 06:18:01.565:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0F00
004489: *Mar 21 06:18:01.569: STP SW: RX ISR: 0180.c200.0000<-b44c.9092.4fb0 type/len 0027
004490: *Mar 21 06:18:01.569:     encap SAP linktype ieee-st vlan 102 len 53 on v102 Gi1/0/1
004491: *Mar 21 06:18:01.569:     42 42 03 SPAN
004492: *Mar 21 06:18:01.569:     CFG P:0000 V:02 T:02 F:39 R:0066 50f7.222b.ba80 00004E20
004493: *Mar 21 06:18:01.569:     B:8066 b44c.9092.4f80 80.30 A:0000 M:1400 H:0200 F:0F00STP: pak->vlan_id: 102

004494: *Mar 21 06:18:01.570: STP SW: PROC RX: 0180.c200.0000<-b44c.9092.4fb0 type/len 0027
004495: *Mar 21 06:18:01.570:     encap SAP linktype ieee-st vlan 102 len 53 on v102 Gi1/0/1
004496: *Mar 21 06:18:01.570:     42 42 03 SPAN
004497: *Mar 21 06:18:01.570:     CFG P:0000 V:02 T:02 F:39 R:0066 50f7.222b.ba80 00004E20
004498: *Mar 21 06:18:01.570:     B:8066 b44c.9092.4f80 80.30 A:0000 M:1400 H:0200 F:0F00
004499: *Mar 21 06:18:01.570: STP CFG: found port cfg GigabitEthernet1/0/1 (7F78DEEBE700)
004500: *Mar 21 06:18:01.570: STP: VLAN0102 rx BPDU: config protocol = rstp, packet from GigabitEthernet1/0/1  , linktype IEEE_SPANNING , enctype 2, encsize 17 g int
004501: *Mar 21 06:18:01.570: STP: enc  1 80 C2  0  0  0 B4 4C 90 92 4F B0  0 27 42 42  3
004502: *Mar 21 06:18:01.570: STP: Data      0 0 2 239 06650F7222BBA80 0 04E208066B44C90924F808030 0 014 0 2 0 F 0
004503: *Mar 21 06:18:01.570: STP: VLAN0102 Gi1/0/1: 0 0  2  2 39  06650F7222BBA80  0 04E20 8066B44C90924F80 8030  0 0 14 0  2 0  F 0
004504: *Mar 21 06:18:01.571: RSTP(102): Gi1/0/1 other msg
004505: *Mar 21 06:18:01.571: STP SW: VLAN102: topology change over - this bridge is root
004506: *Mar 21 06:18:01.571: RSTP(102): starting topology change timer for 35 seconds
004507: *Mar 21 06:18:01.571: RSTP HA: rstp_ha_send Type=PORT_INSTANCE_INFO [Dropped: sync disabled]
004508: *Mar 21 06:18:02.477: STP SW: RX ISR: 0180.c200.0000<-b44c.9092.4fb0 type/len 0027
004509: *Mar 21 06:18:02.477:     encap SAP linktype ieee-st vlan 102 len 53 on v102 Gi1/0/1
004510: *Mar 21 06:18:02.477:     42 42 03 SPAN
004511: *Mar 21 06:18:02.477:     CFG P:0000 V:02 T:02 F:39 R:0066 50f7.222b.ba80 00004E20
004512: *Mar 21 06:18:02.477:     B:8066 b44c.9092.4f80 80.30 A:0000 M:1400 H:0200 F:0F00STP: pak->vlan_id: 102

004513: *Mar 21 06:18:02.477: STP SW: PROC RX: 0180.c200.0000<-b44c.9092.4fb0 type/len 0027
004514: *Mar 21 06:18:02.477:     encap SAP linktype ieee-st vlan 102 len 53 on v102 Gi1/0/1
004515: *Mar 21 06:18:02.477:     42 42 03 SPAN
004516: *Mar 21 06:18:02.477:     CFG P:0000 V:02 T:02 F:39 R:0066 50f7.222b.ba80 00004E20
004517: *Mar 21 06:18:02.477:     B:8066 b44c.9092.4f80 80.30 A:0000 M:1400 H:0200 F:0F00
004518: *Mar 21 06:18:02.477: STP CFG: found port cfg GigabitEthernet1/0/1 (7F78DEEBE700)
004519: *Mar 21 06:18:02.477: STP: VLAN0102 rx BPDU: config protocol = rstp, packet from GigabitEthernet1/0/1  , linktype IEEE_SPANNING , enctype 2, encsize 17
004520: *Mar 21 06:18:02.478: STP: enc  1 80 C2  0  0  0 B4 4C 90 92 4F B0  0 27 42 42  3
004521: *Mar 21 06:18:02.478: STP: Data      0 0 2 239 06650F7222BBA80 0 04E208066B44C90924F808030 0 014 0 2 0 F 0gi1/0/
004522: *Mar 21 06:18:02.478: STP: VLAN0102 Gi1/0/1: 0 0  2  2 39  06650F7222BBA80  0 04E20 8066B44C90924F80 8030  0 0 14 0  2 0  F 0
004523: *Mar 21 06:18:02.479: RSTP(102): Gi1/0/1 other msg
004524: *Mar 21 06:18:02.561: RSTP(102): sending BPDU out Gi1/0/1
004525: *Mar 21 06:18:02.561: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004526: *Mar 21 06:18:02.562:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004527: *Mar 21 06:18:02.562:     42 42 03 SPAN
004528: *Mar 21 06:18:02.562:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004529: *Mar 21 06:18:02.562:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0F001

Vlan                Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
VLAN0102            Desg FWD 4         128.1    P2p Edge
C9348-CoreCorpIT-1#
004530: *Mar 21 06:18:03.559: %LINK-3-UPDOWN: Interface GigabitEthernet1/0/1, changed state to up
004531: *Mar 21 06:18:03.564: %LINK-3-UPDOWN: Interface Vlan102, changed state to up
004532: *Mar 21 06:18:04.412: Returning spanning tree stats for VLAN0102 (7F78E3827418)
004533: *Mar 21 06:18:04.412: STP SW: VLAN102: age time is currently 300 secs
004534: *Mar 21 06:18:04.412: Returning spanning tree port stats: GigabitEthernet1/0/1 (7F78D77D0058)
004535: *Mar 21 06:18:04.477: STP SW: RX ISR: 0180.c200.0000<-b44c.9092.4fb0 type/len 0027
004536: *Mar 21 06:18:04.477:     encap SAP linktype ieee-st vlan 102 len 53 on v102 Gi1/0/1
004537: *Mar 21 06:18:04.477:     42 42 03 SPAN
004538: *Mar 21 06:18:04.477:     CFG P:0000 V:02 T:02 F:39 R:0066 50f7.222b.ba80 00004E20
004539: *Mar 21 06:18:04.477:     B:8066 b44c.9092.4f80 80.30 A:0000 M:1400 H:0200 F:0F00STP: pak->vlan_id: 102

004540: *Mar 21 06:18:04.477: STP SW: PROC RX: 0180.c200.0000<-b44c.9092.4fb0 type/len 0027
004541: *Mar 21 06:18:04.477:     encap SAP linktype ieee-st vlan 102 len 53 on v102 Gi1/0/1
004542: *Mar 21 06:18:04.477:     42 42 03 SPAN
004543: *Mar 21 06:18:04.477:     CFG P:0000 V:02 T:02 F:39 R:0066 50f7.222b.ba80 00004E20
004544: *Mar 21 06:18:04.477:     B:8066 b44c.9092.4f80 80.30 A:0000 M:1400 H:0200 F:0F00
004545: *Mar 21 06:18:04.477: STP CFG: found port cfg GigabitEthernet1/0/1 (7F78DEEBE700)
004546: *Mar 21 06:18:04.477: STP: VLAN0102 rx BPDU: config protocol = rstp, packet from GigabitEthernet1/0/1  , linktype IEEE_SPANNING , enctype 2, encsize 17
004547: *Mar 21 06:18:04.477: STP: enc  1 80 C2  0  0  0 B4 4C 90 92 4F B0  0 27 42 42  3
004548: *Mar 21 06:18:04.478: STP: Data      0 0 2 239 06650F7222BBA80 0 04E208066B44C90924F808030 0 014 0 2 0 F 0
004549: *Mar 21 06:18:04.478: STP: VLAN0102 Gi1/0/1: 0 0  2  2 39  06650F7222BBA80  0 04E20 8066B44C90924F80 8030  0 0 14 0  2 0  F 0
004550: *Mar 21 06:18:04.478: RSTP(102): Gi1/0/1 other msg
004551: *Mar 21 06:18:04.560: %LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet1/0/1, changed state to up
004552: *Mar 21 06:18:04.562: RSTP(102): sending BPDU out Gi1/0/1
004553: *Mar 21 06:18:04.562: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004554: *Mar 21 06:18:04.562:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004555: *Mar 21 06:18:04.562:     42 42 03 SPAN
004556: *Mar 21 06:18:04.562:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004557: *Mar 21 06:18:04.562:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0F00
004558: *Mar 21 06:18:04.564: %LINEPROTO-5-UPDOWN: Line protocol on Interface Vlan102, changed state to upshow spanning int gi1/0/1

Vlan                Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
VLAN0102            Desg FWD 4         128.1    P2p Edge
C9348-CoreCorpIT-1#
004559: *Mar 21 06:18:06.561: RSTP(102): sending BPDU out Gi1/0/1
004560: *Mar 21 06:18:06.561: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004561: *Mar 21 06:18:06.561:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004562: *Mar 21 06:18:06.561:     42 42 03 SPAN
004563: *Mar 21 06:18:06.561:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004564: *Mar 21 06:18:06.562:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0F00
004565: *Mar 21 06:18:06.963: Returning spanning tree stats for VLAN0102 (7F78E3827418)
004566: *Mar 21 06:18:06.963: STP SW: VLAN102: age time is currently 300 secs
004567: *Mar 21 06:18:06.963: Returning spanning tree port stats: GigabitEthernet1/0/1 (7F78D77D0058)show spanning int gi1/0/1

Vlan                Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
VLAN0102            Desg FWD 4         128.1    P2p Edge
C9348-CoreCorpIT-1#
004568: *Mar 21 06:18:08.563: RSTP(102): sending BPDU out Gi1/0/1
004569: *Mar 21 06:18:08.563: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004570: *Mar 21 06:18:08.563:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004571: *Mar 21 06:18:08.563:     42 42 03 SPAN
004572: *Mar 21 06:18:08.563:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004573: *Mar 21 06:18:08.563:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0F00
004574: *Mar 21 06:18:09.490: Returning spanning tree stats for VLAN0102 (7F78E3827418)
004575: *Mar 21 06:18:09.490: STP SW: VLAN102: age time is currently 300 secsshow spanning int gi1/0/1
004576: *Mar 21 06:18:09.490: Returning spanning tree port stats: GigabitEthernet1/0/1 (7F78D77D0058)

Vlan                Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
VLAN0102            Desg FWD 4         128.1    P2p Edge
C9348-CoreCorpIT-1#
004577: *Mar 21 06:18:10.563: RSTP(102): sending BPDU out Gi1/0/1
004578: *Mar 21 06:18:10.563: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004579: *Mar 21 06:18:10.563:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004580: *Mar 21 06:18:10.563:     42 42 03 SPAN
004581: *Mar 21 06:18:10.563:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004582: *Mar 21 06:18:10.563:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0F00
004583: *Mar 21 06:18:11.458: Returning spanning tree stats for VLAN0102 (7F78E3827418)
004584: *Mar 21 06:18:11.458: STP SW: VLAN102: age time is currently 300 secs
004585: *Mar 21 06:18:11.458: Returning spanning tree port stats: GigabitEthernet1/0/1 (7F78D77D0058)
004586: *Mar 21 06:18:12.563: RSTP(102): sending BPDU out Gi1/0/1
004587: *Mar 21 06:18:12.563: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004588: *Mar 21 06:18:12.563:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004589: *Mar 21 06:18:12.563:     42 42 03 SPAN
004590: *Mar 21 06:18:12.563:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004591: *Mar 21 06:18:12.563:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0F00
C9348-CoreCorpIT-1#en
004592: *Mar 21 06:18:14.562: RSTP(102): sending BPDU out Gi1/0/1
004593: *Mar 21 06:18:14.562: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004594: *Mar 21 06:18:14.562:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004595: *Mar 21 06:18:14.562:     42 42 03 SPAN
004596: *Mar 21 06:18:14.562:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004597: *Mar 21 06:18:14.563:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0Fu ak
004598: *Mar 21 06:18:16.563: RSTP(102): sending BPDU out Gi1/0/1
004599: *Mar 21 06:18:16.563: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004600: *Mar 21 06:18:16.563:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004601: *Mar 21 06:18:16.563:     42 42 03 SPAN
004602: *Mar 21 06:18:16.563:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004603: *Mar 21 06:18:16.563:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0F0ll
All possible debugging has been turned off
C9348-CoreCorpIT-1#
004604: *Mar 21 06:18:18.563: RSTP(102): sending BPDU out Gi1/0/1
004605: *Mar 21 06:18:18.563: STP SW: TX: 0180.c200.0000<-50f7.222b.ba81 type/len 0027
004606: *Mar 21 06:18:18.563:     encap SAP linktype ieee-st vlan 102 len 60 on v102 Gi1/0/1
004607: *Mar 21 06:18:18.563:     42 42 03 SPAN
004608: *Mar 21 06:18:18.563:     CFG P:0000 V:02 T:02 F:3C R:0066 50f7.222b.ba80 00000000
004609: *Mar 21 06:18:18.563:     B:0066 50f7.222b.ba80 80.01 A:0000 M:1400 H:0200 F:0F00
```




# Backlog:

The following documentation says https://www.cisco.com/c/en/us/support/docs/lan-switching/spanning-tree-protocol/24062-146.html

An edge port that receives a BPDU immediately loses edge port status and becomes a normal spanning tree port. At this point, there is a user-configured value and an operational value for the edge port state.

