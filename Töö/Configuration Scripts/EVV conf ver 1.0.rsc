/system identity
set name="EVV XXX"

/system clock
set time-zone-name=Europe/Tallinn

/system ntp client
set enabled=yes primary-ntp=216.239.35.0 secondary-ntp=216.239.35.4

/interface l2tp-client
add connect-to=vpn.atemix.ee disabled=no ipsec-secret=XXX name=l2tp password=XXX use-ipsec=yes user=evvXX

/ip ipsec profile
add dh-group=modp2048 enc-algorithm=aes-256 hash-algorithm=sha256 name=EVV

/ip ipsec peer
add address=80.235.104.130 exchange-mode=aggressive profile=EVV name=EVV

/ip ipsec proposal
add auth-algorithms=sha256 enc-algorithms=aes-256-cbc lifetime=12h pfs-group=modp2048 name=EVV

/ip ipsec identity
add peer=EVV my-id=key-id:XXX secret=XXX

/ip ipsec policy
add peer=EVV proposal=EVV tunnel=yes dst-address=172.20.0.0/24 src-address=172.28.XXX.XXX/28 

/ip address
add interface=ether1 address=172.28.XXX.XXX/28

/ip firewall filter
add chain=input action=accept connection-state=established comment="allow established connections" 
add chain=input action=accept connection-state=related comment="allow related connections" 
add chain=input action=drop connection-state=invalid comment="drop invalid connections" 
add chain=input action=accept protocol=tcp dst-port=8291 in-interface=l2tp comment="allow WinBox"
add chain=input action=accept protocol=icmp comment="allow ping"
add chain=input action=log disabled=yes
add chain=input action=drop

add chain=forward action=accept connection-state=established comment="allow established connections" 
add chain=forward action=accept connection-state=related comment="allow related connections" 
add chain=forward action=drop connection-state=invalid comment="drop invalid connections" 
add chain=forward action=accept src-address=172.28.XXX.XXX/28 dst-address=172.20.0.0/24
add chain=forward action=accept src-address=172.20.0.0/24 dst-address=172.28.XXX.XXX/28
add chain=forward action=log disabled=yes
add chain=forward action=drop

/ip firewall nat
add chain=srcnat action=accept dst-address=172.20.0.0/24 src-address=172.28.XXX.XXX/28

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set api-ssl disabled=yes

/system package
disable hotspot,mpls,routing,ipv6,wireless

/system package update
set channel=long-term

/user
set admin password=no-pass comment=""