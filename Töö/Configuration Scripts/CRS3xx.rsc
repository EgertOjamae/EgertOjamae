https://wiki.mikrotik.com/wiki/Manual:Basic_VLAN_switching

/system identity
set name="switch0x"

/system clock
set time-zone-name=Europe/Tallinn

/system ntp client
set enabled=yes 

/ip service
set telnet disabled=yes
set ssh disabled=yes
set ftp disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set www disabled=yes

/system package
disable advanced-tools
disable hotspot
disable mpls
disable ppp
disable routing
disable security
disable wireless

/interface ethernet
set sfp-sfpplus1 name=sfp1
set sfp-sfpplus2 name=sfp2
set sfp-sfpplus3 name=sfp3
set sfp-sfpplus4 name=sfp4

set ether1 name=ether-1
set ether2 name=ether-2
set ether3 name=ether-3
set ether4 name=ether-4
set ether5 name=ether-5
set ether6 name=ether-6
set ether7 name=ether-7
set ether8 name=ether-8
set ether9 name=ether-9

set ether-1 name=ether01
set ether-2 name=ether02
set ether-3 name=ether03
set ether-4 name=ether04
set ether-5 name=ether05
set ether-6 name=ether06
set ether-7 name=ether07
set ether-8 name=ether08
set ether-9 name=ether09

/interface bridge
add name=switch

/interface bridge port
add bridge=switch interface=sfp1 hw=yes
add bridge=switch interface=sfp2 hw=yes
add bridge=switch interface=sfp3 hw=yes
add bridge=switch interface=sfp4 hw=yes
add bridge=switch interface=ether01 hw=yes pvid=111
add bridge=switch interface=ether02 hw=yes pvid=111
add bridge=switch interface=ether03 hw=yes pvid=111
add bridge=switch interface=ether04 hw=yes pvid=111
add bridge=switch interface=ether05 hw=yes pvid=111
add bridge=switch interface=ether06 hw=yes pvid=111
add bridge=switch interface=ether07 hw=yes pvid=111
add bridge=switch interface=ether08 hw=yes pvid=111
add bridge=switch interface=ether09 hw=yes pvid=111
add bridge=switch interface=ether10 hw=yes pvid=111
add bridge=switch interface=ether11 hw=yes pvid=111
add bridge=switch interface=ether12 hw=yes pvid=111
add bridge=switch interface=ether13 hw=yes pvid=111
add bridge=switch interface=ether14 hw=yes pvid=111
add bridge=switch interface=ether15 hw=yes pvid=111
add bridge=switch interface=ether16 hw=yes pvid=111
add bridge=switch interface=ether17 hw=yes pvid=111
add bridge=switch interface=ether18 hw=yes pvid=111
add bridge=switch interface=ether19 hw=yes pvid=111
add bridge=switch interface=ether20 hw=yes pvid=111
add bridge=switch interface=ether21 hw=yes pvid=111
add bridge=switch interface=ether22 hw=yes pvid=111
add bridge=switch interface=ether23 hw=yes pvid=111
add bridge=switch interface=ether24 hw=yes pvid=111

/interface bridge vlan
add bridge=switch tagged=sfp1,sfp2,sfp3,sfp4,switch vlan-ids=100
add bridge=switch tagged=sfp1,sfp2,sfp3,sfp4 vlan-ids=103
add bridge=switch tagged=sfp1,sfp2,sfp3,sfp4 vlan-ids=105
add bridge=switch tagged=sfp1,sfp2,sfp3,sfp4 vlan-ids=110
add bridge=switch tagged=sfp1,sfp2,sfp3,sfp4 untagged=ether01,ether02,ether03,ether04,ether05,ether06,ether07,ether08,ether09,ether10,ether11,ether12,ether13,ether14,ether15,ether16,ether17,ether18,ether19,ether20,ether21,ether22,ether23,ether24 vlan-ids=111

/interface vlan
add interface=switch vlan-id=100 name=vlan100

/ip dhcp-client
add interface=vlan100 disabled=no

/interface bridge
set switch vlan-filtering=yes