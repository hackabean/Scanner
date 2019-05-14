# Scanner
Quick UDP and TCP network sanner (Nmap + Masscan) written in bash.

![Scanner](https://raw.githubusercontent.com/hackabean/Scanner/master/Screenshot_2019-05-14_09-10-38.png)

![Scanner](https://raw.githubusercontent.com/hackabean/Scanner/master/Screenshot_2019-05-14_09-12-55.png)

Notes:

Please adjust the name of your network interface before the scan If you are using Ubuntu or Arch it will be something like: wlp1s0.
For Debian or Kali more likely the name is going to be wlan0 or wlan1 etc.

Nmap default switches can be changed, here they are set up to:

-sV - Service version detection 
-sT - Full TCP connect scan
-sU - UDP Scan
-O  - OS Detection
-A  - Aggressive
--max-rate 15000 Send packets no faster than 15000 per second
-Pn - Treat all hosts as online -- skip host discovery
-T4 - Timing template
--script vuln - simple vulnerability detection
