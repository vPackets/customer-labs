#!/bin/bash
#Create a script that will create port forwarding on the linux host so that containers can be reached using ssh




sudo iptables -t nat -A PREROUTING -p tcp --dport 2222 -j DNAT --to-destination 172.20.20.2:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.2 --dport 22 -j ACCEPT

sudo iptables -t nat -A PREROUTING -p tcp --dport 2223 -j DNAT --to-destination 172.20.20.3:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.3 --dport 22 -j ACCEPT

sudo iptables -t nat -A PREROUTING -p tcp --dport 2224 -j DNAT --to-destination 172.20.20.4:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.4 --dport 22 -j ACCEPT

sudo iptables -t nat -A PREROUTING -p tcp --dport 2225 -j DNAT --to-destination 172.20.20.5:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.5 --dport 22 -j ACCEPT

sudo iptables -t nat -A PREROUTING -p tcp --dport 2226 -j DNAT --to-destination 172.20.20.6:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.6 --dport 22 -j ACCEPT

sudo iptables -t nat -A PREROUTING -p tcp --dport 2227 -j DNAT --to-destination 172.20.20.7:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.7 --dport 22 -j ACCEPT

sudo iptables -t nat -A PREROUTING -p tcp --dport 2228 -j DNAT --to-destination 172.20.20.8:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.8 --dport 22 -j ACCEPT

sudo iptables -t nat -A PREROUTING -p tcp --dport 2229 -j DNAT --to-destination 172.20.20.9:22
sudo iptables -A FORWARD -p tcp -d 172.20.20.9 --dport 22 -j ACCEPT

#sudo iptables -t nat -A PREROUTING -p tcp --dport 2230 -j DNAT --to-destination 172.20.20.11:22
#sudo iptables -A FORWARD -p tcp -d 172.20.20.11 --dport 22 -j ACCEPT

#sudo iptables -t nat -A PREROUTING -p tcp --dport 2231 -j DNAT --to-destination 172.20.20.12:22
#sudo iptables -A FORWARD -p tcp -d 172.20.20.12 --dport 22 -j ACCEPT

#sudo iptables -t nat -A PREROUTING -p tcp --dport 2232 -j DNAT --to-destination 172.20.20.13:22
#sudo iptables -A FORWARD -p tcp -d 172.20.20.13 --dport 22 -j ACCEPT

#sudo iptables -t nat -A PREROUTING -p tcp --dport 2233 -j DNAT --to-destination 172.20.20.20:22
#sudo iptables -A FORWARD -p tcp -d 172.20.20.20 --dport 22 -j ACCEPT



#if changes need to be persistant : sudo netfilter-persistent save

