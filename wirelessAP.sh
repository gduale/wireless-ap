#!/bin/bash

#Check if run as root


#VARS
WAN=wlan0 #Interface already working with Internet active.
APCARD=wlan1

#Maybe bypass the Network-manager
#sudo service network-manager stop


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
#iptables -t nat -F
iptables -X
#iptables -t nat -X

#Disable routing
echo 0 > /proc/sys/net/ipv4/ip_forward

#Make an Ad-Hoc AP on the APCARD
iwconfig $APCARD mode ad-hoc
iwconfig $APCARD channel 11
iwconfig $APCARD essid 'myAP'
iwconfig $APCARD key 123456789


#Route the traffic from the AP card to the Internet's card.
#iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE

#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

