#!/bin/bash

#Here we define pretty colors

RESTORE='\033[0m'

RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'

LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'

OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

echo -e "${LGREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Enter domain of your Target Below example site.com      ║"              
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${RESTORE}"
read TARGET

#Translating URL to IP if neccessary
nmap -n -Pn -sn -PA $TARGET | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" > targets.txt

echo -e "${LGREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                Select your scanning interface                  ║"              
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${RESTORE}"
echo -ne "Your VLAN IP is wlp1s0: "; ip -o -4 addr show dev wlp1s0 | sed 's/.* inet \([^/]*\).*/\1/'
echo -ne "Your VPN local IP is tun0: "; ip -o -4 addr show dev tun0 | sed 's/.* inet \([^/]*\).*/\1/'
echo -ne "Your HTB IP is tun1: "; ip -o -4 addr show dev tun1 | sed 's/.* inet \([^/]*\).*/\1/'

echo -e "${LYELLOW}"
echo "Please, select a network interface for scanning:"
echo -e "${RESTORE}"
read interface

echo ""
echo -e "${OKGREEN}====================================================================================${RESET}"
echo -e "$OKRED RUNNING MASSCAN ON THE TARGET HOST $RESET"
echo -e "${OKGREEN}====================================================================================${RESET}"

#Define TARGET as IP keep the URL just in case we need it later
TARGET=$(cat ./targets.txt)
echo $TARGET > url.txt
URL=$(cat ./url.txt)

echo -e "${LYELLOW}"
echo "[+] Discovering TCP ports..."
echo -e "${RESTORE}"

#Discover open TCP ports using masscan
masscan -e $interface --open --source-port 60000 -p1-65535 --max-rate 2000 $TARGET | tee ./masscan-output-tcp.txt

echo -e "${LYELLOW}"
echo "[+] Discovering UDP ports..."
echo -e "${RESTORE}"
#Discover open UDP ports using masscan
masscan -e $interface --open --source-port 60000 -pU:1-65535 --max-rate 2000 $TARGET | tee ./masscan-output-udp.txt

echo -e "${LYELLOW}"
echo "[+] Ports discovery has finished, parsing open ports to nmap..."
echo -e "${RESTORE}"

sleep 2

#Define TCP ports for NMAP
TCPPORTS=$(cat masscan-output-tcp.txt | awk '/open/ { print $4 }' | rev | cut -f1 -d: | rev | grep -Eo '[0-9]{1,5}' | tr , "\n" | sort | tr "\n" , | sed 's/.$//')

#Define UDP ports for NMAP
UDPPORTS=$(cat masscan-output-udp.txt | awk '/open/ { print $4 }' | rev | cut -f1 -d: | rev | grep -Eo '[0-9]{1,5}' | tr , "\n" | sort | tr "\n" , | sed 's/.$//')
 
echo -e "${OKGREEN}====================================================================================${RESET}"
echo -e "$OKRED RUNNING NMAP TCP PORT ANALYSIS $RESET"
echo -e "${OKGREEN}====================================================================================${RESET}"

#If no UDP ports are found, move on to TCP Scan
if cat ./masscan-output-udp.txt | [ -s masscan-output-udp.txt ];
then
echo -e "${LYELLOW}"
echo "[+] Running UDP and TCP port scan"
echo -e "${RESTORE}"
nmap -sV -sT -sU -O -A --max-rate 15000 -Pn -T4 -n -p U:$UDPPORTS,T:$TCPPORTS -oX ./nmap-$URL.xml $URL --script vuln;
#Start TCP scan
else 
echo -e "${LYELLOW}"
echo "[+] Running only TCP port scan"
echo -e "${RESTORE}"
nmap -sV -sT -O -A --max-rate 15000 -Pn -T4 -n -p $TCPPORTS -oX ./nmap-$URL.xml $URL --script vuln;
fi
