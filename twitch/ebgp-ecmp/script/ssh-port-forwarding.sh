#!/bin/bash
#Create a script that will create port forwarding on the linux host so that containers can be reached using ssh


# ISPX-01
sudo iptables -t nat -A PREROUTING -p tcp --dport 2222 -j DNAT --to-destination 172.20.20.2:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.2 --dport 22 -j ACCEPT

# ISPX-02
sudo iptables -t nat -A PREROUTING -p tcp --dport 2223 -j DNAT --to-destination 172.20.20.3:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.3 --dport 22 -j ACCEPT

# ISPX-10
sudo iptables -t nat -A PREROUTING -p tcp --dport 2224 -j DNAT --to-destination 172.20.20.4:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.4 --dport 22 -j ACCEPT


# ISPZ-01
sudo iptables -t nat -A PREROUTING -p tcp --dport 2225 -j DNAT --to-destination 172.20.20.10:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.10 --dport 22 -j ACCEPT

# ISPZ-02
sudo iptables -t nat -A PREROUTING -p tcp --dport 2226 -j DNAT --to-destination 172.20.20.11:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.11 --dport 22 -j ACCEPT

# ISPZ-10
sudo iptables -t nat -A PREROUTING -p tcp --dport 2227 -j DNAT --to-destination 172.20.20.12:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.12 --dport 22 -j ACCEPT


# TWITCH-R1
sudo iptables -t nat -A PREROUTING -p tcp --dport 2228 -j DNAT --to-destination 172.20.20.20:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.20 --dport 22 -j ACCEPT

# TWITCH-R2
sudo iptables -t nat -A PREROUTING -p tcp --dport 2229 -j DNAT --to-destination 172.20.20.21:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.21 --dport 22 -j ACCEPT

# TWITCH-R3
sudo iptables -t nat -A PREROUTING -p tcp --dport 2230 -j DNAT --to-destination 172.20.20.22:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.22 --dport 22 -j ACCEPT

# TWITCH-R4
sudo iptables -t nat -A PREROUTING -p tcp --dport 2231 -j DNAT --to-destination 172.20.20.23:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.23 --dport 22 -j ACCEPT

# TWITCH-R5
sudo iptables -t nat -A PREROUTING -p tcp --dport 2232 -j DNAT --to-destination 172.20.20.24:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.24 --dport 22 -j ACCEPT

# TWITCH-RR-01
sudo iptables -t nat -A PREROUTING -p tcp --dport 2233 -j DNAT --to-destination 172.20.20.25:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.25 --dport 22 -j ACCEPT

# TWITCH-RR-02
sudo iptables -t nat -A PREROUTING -p tcp --dport 2234 -j DNAT --to-destination 172.20.20.26:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.26 --dport 22 -j ACCEPT

#if changes need to be persistant : sudo netfilter-persistent save

# Verify the rules:

# sudo iptables -t nat --line-numbers -L PREROUTING
# sudo iptables --line-numbers -L FORWARD

# This line needs to be uncommented as well:
# netadmin@srv-containerlab-02:/home/netadmin $ cat /etc/sysctl.conf


# Uncomment the next line to enable packet forwarding for IPv4
#net.ipv4.ip_forward=1











# ALTERNATE SCRIPT




## # Enable IPv4 forwarding if not enabled
## if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
##     echo "Enabling IPv4 forwarding..."
##     echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
##     sudo sysctl -p
## fi
## 
## # Flush existing rules (optional: backup current rules)
## sudo iptables-save > ~/iptables-backup-$(date +%F).txt
## sudo iptables -t nat -F
## sudo iptables -F FORWARD
## 
## # Add forwarding rules
## declare -A containers=(
##     [2222]=172.20.20.2
##     [2223]=172.20.20.3
##     [2224]=172.20.20.4
##     [2225]=172.20.20.10
##     [2226]=172.20.20.11
##     [2227]=172.20.20.12
##     [2228]=172.20.20.20
##     [2229]=172.20.20.21
##     [2230]=172.20.20.22
##     [2231]=172.20.20.23
##     [2232]=172.20.20.24
##     [2233]=172.20.20.25
##     [2234]=172.20.20.26
## )
## 
## for port in "${!containers[@]}"; do
##     ip=${containers[$port]}
##     echo "Adding forwarding rule for $ip on port $port..."
##     sudo iptables -t nat -A PREROUTING -p tcp --dport "$port" -j DNAT --to-destination "$ip:22"
##     sudo iptables -A FORWARD -p tcp -d "$ip" --dport 22 -j ACCEPT || {
##         echo "Failed to add rule for $ip" >&2
##         exit 1
##     }
## done
## 
## # Save the rules persistently
## sudo netfilter-persistent save
## 
## # Display rules for verification
## echo "Current NAT rules:"
## sudo iptables -t nat --line-numbers -L PREROUTING
## echo "Current FORWARD rules:"
## sudo iptables --line-numbers -L FORWARD









#Verification : 

# netadmin@srv-containerlab-03:/home/netadmin $ sudo iptables -t nat -L PREROUTING -n --line-numbers
# Chain PREROUTING (policy ACCEPT)
# num  target     prot opt source               destination
# 1    DOCKER     0    --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL
# 2    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2222 to:172.20.20.2:22
# 3    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2223 to:172.20.20.3:22
# 4    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2224 to:172.20.20.4:22
# 5    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2225 to:172.20.20.10:22
# 6    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2226 to:172.20.20.11:22
# 7    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2227 to:172.20.20.12:22
# 8    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2228 to:172.20.20.20:22
# 9    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2229 to:172.20.20.21:22
# 10   DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2230 to:172.20.20.22:22
# 11   DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2231 to:172.20.20.23:22
# 12   DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2232 to:172.20.20.24:22
# 13   DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2233 to:172.20.20.25:22
# 14   DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2234 to:172.20.20.26:22


# netadmin@srv-containerlab-03:/home/netadmin $ sudo iptables -L FORWARD -n --line-numbers          [12/05/24 - 6:26:22]
# Chain FORWARD (policy DROP)
# num  target     prot opt source               destination
# 1    DOCKER-USER  0    --  0.0.0.0/0            0.0.0.0/0
# 2    DOCKER-ISOLATION-STAGE-1  0    --  0.0.0.0/0            0.0.0.0/0
# 3    ACCEPT     0    --  0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
# 4    DOCKER     0    --  0.0.0.0/0            0.0.0.0/0
# 5    ACCEPT     0    --  0.0.0.0/0            0.0.0.0/0
# 6    ACCEPT     0    --  0.0.0.0/0            0.0.0.0/0
# 7    LIBVIRT_FWX  0    --  0.0.0.0/0            0.0.0.0/0
# 8    LIBVIRT_FWI  0    --  0.0.0.0/0            0.0.0.0/0
# 9    LIBVIRT_FWO  0    --  0.0.0.0/0            0.0.0.0/0
# 10   ACCEPT     0    --  0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
# 11   DOCKER     0    --  0.0.0.0/0            0.0.0.0/0
# 12   ACCEPT     0    --  0.0.0.0/0            0.0.0.0/0
# 13   ACCEPT     0    --  0.0.0.0/0            0.0.0.0/0
# 14   ACCEPT     6    --  0.0.0.0/0            172.20.20.2          tcp dpt:22
# 15   ACCEPT     6    --  0.0.0.0/0            172.20.20.3          tcp dpt:22
# 16   ACCEPT     6    --  0.0.0.0/0            172.20.20.4          tcp dpt:22
# 17   ACCEPT     6    --  0.0.0.0/0            172.20.20.10         tcp dpt:22
# 18   ACCEPT     6    --  0.0.0.0/0            172.20.20.11         tcp dpt:22
# 19   ACCEPT     6    --  0.0.0.0/0            172.20.20.12         tcp dpt:22
# 20   ACCEPT     6    --  0.0.0.0/0            172.20.20.20         tcp dpt:22
# 21   ACCEPT     6    --  0.0.0.0/0            172.20.20.21         tcp dpt:22
# 22   ACCEPT     6    --  0.0.0.0/0            172.20.20.22         tcp dpt:22
# 23   ACCEPT     6    --  0.0.0.0/0            172.20.20.23         tcp dpt:22
# 24   ACCEPT     6    --  0.0.0.0/0            172.20.20.24         tcp dpt:22
# 25   ACCEPT     6    --  0.0.0.0/0            172.20.20.25         tcp dpt:22
# 26   ACCEPT     6    --  0.0.0.0/0            172.20.20.26         tcp dpt:22


#

# netadmin@srv-containerlab-03:/home/netadmin $ sudo iptables -t nat -L PREROUTING -v               [12/05/24 - 6:27:34]
# Chain PREROUTING (policy ACCEPT 78906 packets, 18M bytes)
#  pkts bytes target     prot opt in     out     source               destination
#    82  6452 DOCKER     all  --  any    any     anywhere             anywhere             ADDRTYPE match dst-type LOCAL
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2222 to:172.20.20.2:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2223 to:172.20.20.3:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2224 to:172.20.20.4:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2225 to:172.20.20.10:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2226 to:172.20.20.11:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2227 to:172.20.20.12:22
#     2   128 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2228 to:172.20.20.20:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2229 to:172.20.20.21:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2230 to:172.20.20.22:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2231 to:172.20.20.23:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2232 to:172.20.20.24:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2233 to:172.20.20.25:22
#     0     0 DNAT       tcp  --  any    any     anywhere             anywhere             tcp dpt:2234 to:172.20.20.26:22