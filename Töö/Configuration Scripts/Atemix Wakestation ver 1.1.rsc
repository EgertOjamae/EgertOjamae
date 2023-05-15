/system identity
set name="Wakestation YYY"

/interface bridge
add name=bridge

/interface pptp-client
add connect-to=185.14.219.170 disabled=no name=VPN password=no-pass user=wakestationYYY

/interface wireless security-profiles
add authentication-types=wpa2-psk eap-methods="" management-protection=allowed mode=dynamic-keys name=wakestation supplicant-identity="" wpa2-pre-shared-key=wifi-pass
add authentication-types=wpa2-psk eap-methods="" management-protection=allowed mode=dynamic-keys name=internet supplicant-identity="" wpa2-pre-shared-key=wakestation

/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n disabled=no radio-name=wakestation security-profile=internet ssid=internet wireless-protocol=802.11
set [ find default-name=wlan2 ] band=5ghz-a/n/ac disabled=no mode=ap-bridge radio-name=wakestation security-profile=wakestation ssid="WS YYY" wireless-protocol=802.11

/ip dhcp-client
add dhcp-options=hostname,clientid disabled=no interface=wlan1

/ip pool
add name=pool ranges=192.168.0.200-192.168.0.254

/ip dhcp-server
add address-pool=pool disabled=no interface=bridge lease-time=1d name=dhcp

/interface bridge port
add bridge=bridge interface=ether1
add bridge=bridge interface=wlan2

/ip address
add address=192.168.0.1/24 interface=bridge network=192.168.0.0

/ip dhcp-server network
add address=192.168.0.0/24 dns-server=192.168.0.1 gateway=192.168.0.1

/ip dns
set allow-remote-requests=yes

/ip firewall nat
add action=masquerade chain=srcnat src-address=192.168.0.0/24
add action=masquerade chain=srcnat src-address=10.XXX.XXX.0/24
add action=dst-nat chain=dstnat dst-address=10.XXX.XXX.2 dst-port=80 protocol=tcp to-addresses=192.168.0.100 to-ports=80
add action=dst-nat chain=dstnat dst-address=10.XXX.XXX.2 dst-port=102 protocol=tcp to-addresses=192.168.0.100 to-ports=102

/ip firewall service-port
set ftp disabled=yes
set tftp disabled=yes
set irc disabled=yes
set h323 disabled=yes
set sip disabled=yes
set pptp disabled=yes
set dccp disabled=yes
set sctp disabled=yes
set udplite disabled=yes

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh port=22
set api disabled=yes
set api-ssl disabled=yes

/system clock
set time-zone-name=Europe/Tallinn

/system ntp client
set enabled=yes primary-ntp=10.XXX.XXX.1 secondary-ntp=10.XXX.XXX.1

/tool romon
set enabled=yes

/system package
disable advanced-tools,hotspot,mpls,routing,security,ipv6

/user
set admin password=no-pass comment=""