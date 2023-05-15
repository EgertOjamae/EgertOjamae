/interface lte apn
remove 1

/ip address
add interface=ether2 address=192.168.0.1/24

/ip firewall filter
add chain=input action=accept protocol=udp dst-port=53 in-interface=ether2 comment="allow dns" place-before=4

add chain=forward action=accept in-interface=ether2 out-interface=lte1 place-before=12

/ip firewall nat
add chain=srcnat action=masquerade out-interface=lte1

/ip pool
add name=pool ranges=192.168.0.100-192.168.0.200

/ip dhcp-server
add address-pool=pool interface=ether2 name=dhcp disabled=no lease-time=7d

/ip dhcp-server network
add address=192.168.0.0/24 dns-server=192.168.0.1 gateway=192.168.0.1 netmask=24

/ip dns
set allow-remote-requests=yes

/system package
disable hotspot,mpls,routing,ipv6,wireless

/system reboot
y
