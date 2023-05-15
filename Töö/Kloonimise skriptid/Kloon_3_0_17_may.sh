#!/bin/sh

echo -e "\e[36m"
echo "Parted kloonimise programm " 
echo "Version 1.0"
echo -e "\e[0m"
echo -e "\e[101m"
echo "Kaughaldus OÜ "
echo "powerd by - Eq"
echo -e "\e[0m"


#kloonimise funktsioon, kutsutakse välja siis kui kõik vajalikud kontrollid on sooritatud
kloonimise_funktsioon () {

	if [ "$kloonitav_ketas" == "nvme0n1" ] || [ "$kloonitav_ketas" == "nvme0n2" ] || [ "$kloonitav_ketas" == "nvme0n3" ] || [ "$kloonitav_ketas" == "nvme0n4" ]
		then
			mkfs.ntfs /dev/nvme0n1p5 -QL HDD
			/usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -f sda1 restoreparts windows_10_pro_3.0 $kloonitav_ketas"p1"
			echo "Kiire paus :) "
			sleep 2
			/usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -f sda2 restoreparts windows_10_pro_3.0 $kloonitav_ketas"p2"
			echo "Kiire paus :) "
			sleep 2
			/usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -f sda3 restoreparts windows_10_pro_3.0 $kloonitav_ketas"p3"
			echo "Kiire paus :) "
			sleep 2
			/usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -p choose -f sda4 restoreparts windows_10_pro_3.0 $kloonitav_ketas"p4"

	elif [ "$kloonitav_ketas" == "sda" ] || [ "$kloonitav_ketas" == "sdb" ] || [ "$kloonitav_ketas" == "sdc" ] || [ "$kloonitav_ketas" == "sdd" ] || [ "$kloonitav_ketas" == "sde" ]
		then
			mkfs.ntfs /dev/sda5 -QL HDD
			/usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -f sda1 restoreparts windows_10_pro_3.0 $kloonitav_ketas"1"
			echo "Kiire paus :) "
			sleep 2
			/usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -f sda2 restoreparts windows_10_pro_3.0 $kloonitav_ketas"2"
			echo "Kiire paus :) "
			sleep 2
			/usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -f sda3 restoreparts windows_10_pro_3.0 $kloonitav_ketas"3"
			echo "Kiire paus :) "
			sleep 2
			/usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -p choose -f sda4 restoreparts windows_10_pro_3.0 $kloonitav_ketas"4"

		fi
}


esimene_boot (){
	if [ "$kloonitav_ketas" == "nvme0n1" ]
		then
			cp /home/partimag/pmagic/pmodules/run_AfterClone_ver2.bat /lib/modules
			cp /home/partimag/pmagic/pmodules/AfterClone_ver2.ps1 /lib/modules
			mount /dev/nvme0n1p5 /home
			cp /lib/modules/run_AfterClone_ver2.bat /home
			cp /lib/modules/AfterClone_ver2.ps1 /home
			echo "Teen restart"
			reboot
	
	else 
		
		cp /home/partimag/pmagic/pmodules/run_AfterClone_ver2.bat /lib/modules
			cp /home/partimag/pmagic/pmodules/AfterClone_ver2.ps1 /lib/modules

		mount /dev/sda5 /home
		cp /lib/modules/run_AfterClone_ver2.bat /home
			cp /lib/modules/AfterClone_ver2.ps1 /home
		
		
		echo "Teen restart"
		reboot
		
	fi
}

partitsioonide_loomine () {

	parted -s /dev/$kloonitav_ketas mktable gpt
	parted /dev/$kloonitav_ketas mkpart '"EFI system partition"' fat32 1048576B 105906175B
	parted /dev/$kloonitav_ketas mkpart '"Microsoft reserved partition"' 105906176B 122683391B
	parted /dev/$kloonitav_ketas mkpart '"Microsoft reserved partition"' ntfs 122683392B 1196425215B
	parted /dev/$kloonitav_ketas mkpart System ntfs 1196425216B 108571656191B
	parted /dev/$kloonitav_ketas mkpart HDD ntfs 108571656192B $ketta_maht
	sleep 1
	parted /dev/$kloonitav_ketas toggle 1 boot
	parted /dev/$kloonitav_ketas toggle 2 msftres
	parted /dev/$kloonitav_ketas toggle 3 hidden
	parted /dev/$kloonitav_ketas toggle 3 diag
	parted /dev/$kloonitav_ketas toggle 4 msftdata
	parted /dev/$kloonitav_ketas toggle 5 msftdata
	}

echo -e "\e[92m"
read -p "Kas soovid alustada kloonimise protsessi (jah/ei): " kontroll_parted
echo -e "\e[0m"

if [ "$kontroll_parted" == "jah" ]
then

	echo ""
	echo ""

	echo "Kuvan ketaste suurused ja asukohad: "

	echo ""
	echo ""

	lsblk
	sleep 3

	echo ""
	echo ""

	kettad=($(lsblk --nodeps -n -o name))

	echo "Näitan leituid kettaid mida kloonida "

	#käime for loopiga ketta_massiivi läbi ja näitame kasutajale mis valikud on
	i=0
	for k in ${kettad[@]}
	do
		echo $i -- $k
		((i++))

	done

	#küsib kasutajalt vastava ketta numbrit ja salvestab muutujasse - valitud_number 
	echo -e "\e[96m"
	read -p "Sisesta vastava ketta number mida soovid kloonida: " valitud_number
	echo -e "\e[0m"
	sleep 1

	echo ""
	echo ""


	#kontrollime kas sisestati number või mingi muu sümbol
	while [[ $((valitud_number)) != $valitud_number ]]
	do
		echo "Sisestasid midagi valesti, proovi uuesti: "
		echo -e "\e[96m"
		read -p "Sisesta vastava ketta number mida soovid kloonida: " valitud_number
		echo -e "\e[0m"
	done



	#võrdlen valitud numbrit for loopi iteratsiooniga, kui True, salvestan kloonitav_ketas muutujasse
	#õige ketta_massiivi elemendi
	s=0
	for j in ${kettad[@]}
	do

		if [ "$valitud_number" == "$s" ]
		then
			kloonitav_ketas=${kettad[$s]}
			echo "Hakkame kloonima ketast: " -- ${kettad[$s]}
			sleep 1
		fi
	((s++))

	done

	lsblk
	if [ "$kloonitav_ketas" == "nvme0n1" ]
	then
		ketta_maht_parsed=`smartctl -a /dev/$kloonitav_ketas | grep "Total NVM Capacity" | awk '{print$5}' | cut -b 2-4`
		ketta_maht=`parted -l | grep dev/nvme0n1 | cut -b 20-24`
		
	else
	
		ketas1=`smartctl -a /dev/$kloonitav_ketas | grep "Capacity" | awk '{print$5}' | cut -b 2-4`
		ketta_maht=$ketas1"GB"
		echo ""
	fi

	echo ""

	echo "Kloonitava ketta maht on: " $ketta_maht
	sleep 1
	echo ""
	echo ""

	#read -p "LOON PARTITSIOONID, VÕTA MÄLUPULK VÄLJA JA VAJUTA ENTER: "
	sleep 2

	echo ""
	echo ""

	partitsioonide_loomine
	sleep 1
	echo "Kontrollimiseks flagide lisamine"
	parted /dev/$kloonitav_ketas toggle 4 msftdata
	parted /dev/$kloonitav_ketas toggle 5 msftdata

	parted -l


	echo ""
	echo ""

	#vastavalt vastusele käivitame kas pulgalt kloonimise või võrgust kloonimise protsessi
	vastus="1"
	sleep 1

	if [ "$vastus" == "1" ]
	then
		#tuvastame kõik ühendatud mälupulgad
		usb_pulgad=""
		#read -p "Sisesta kloonipulk ja vajuta ENTER "
		sleep 2
		usb_pulgad=`readlink -f /dev/disk/by-id/usb-Kingston_DataTraveler_3.0_E0D55E6CBC9AF3B0C8900473-0:0-part1`


		echo ""
		echo ""

		mount $usb_pulgad /home/partimag
		lsblk
		echo ""
		#kontrollid sooritatud, kutsume kloonimise funktsiooni
		kloonimise_funktsioon
		esimene_boot


	elif [ "$vastus" == "2" ]
	then
		#sisestame käsitsi õige aadressi, kus asub kloon
		read -p "Sisesta võrgus oleva klooni ip aadress kujul x.x.x.x: " ip_aadress
		mount -t cifs "//$ip_aadress/images" /home/partimag -o user="kaughaldus",vers=1.0


		#while tsükklis niikaua kui teame et oleme kätte saanud võrgust õige klooni
		read -p "Kas kirjutasid parooli õigesti (ei/jah) ?: " kontroll
		while [ "$kontroll" != "jah" ]
		do
			echo "Kirjutasid parooli valesti, ole hea proovi uuesti :)"
			read -p "Sisesta võrgus oleva klooni ip aadress kujul x.x.x.x: " ip_aadress
			mount -t cifs "//$ip_aadress/images" /home/partimag -o user="kaughaldus",vers=1.0
			lsblk #saame üle kontrollida kas lsblk mountpointi ilmus /home/partimag
			sleep 3
			read -p "Kas kirjutasid parooli õigesti (jah/ei) ?: " kontroll
		done
		#kontrollid sooritatud, kutsume kloonimise funktsiooni
		kloonimise_funktsioon
		esimene_boot
	fi
	
else
echo "Lähen otse partedisse"
fi
