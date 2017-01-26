#!/bin/bash
#Tested on Debian 8

#Check if run as root
if [ `whoami` == "root" ];then
  echo "root user OK"
else
  echo "Please run it as root"
fi

#Stop the network manager to manage network card in command line
service network-manager stop

#VARS
WAN=wlan0 #Interface already working with Internet active. (/etc/network/interfaces)
APCARD=wlan1

##IPTABLES
#ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

#ACCEPT NAT
#iptables -t nat -P PREROUTING ACCEPT
#iptables -t nat -P POSTROUTING ACCEPT
#iptables -t nat -P OUTPUT ACCEPT

#FLUSH all & clean the rest
iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X

#Enable routing
echo 1 > /proc/sys/net/ipv4/ip_forward

#Make an Ad-Hoc AP on the APCARD
iwconfig $APCARD mode Ad-Hoc
iwconfig $APCARD channel 11
iwconfig $APCARD essid 'myAP'
iwconfig $APCARD key off

#Setup the ip
IP=192.168.8.55
ifconfig $APCARD $IP/24

#Route the traffic from the AP card to the Internet's card.
iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE

#Send http traffic to Burp (Option for Burp : Proxy->Options->Proxy Listener->Request handling->Support invisible proxying (enable ony if needed)
iptables -t nat -A PREROUTING -i $APCARD -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i $APCARD -p tcp --dport 443 -j REDIRECT --to-port 8080

#dnsmasq / dhcp
dnsmasq -d -q -i $APCARD -F 192.168.8.5,192.168.8.9,4h

