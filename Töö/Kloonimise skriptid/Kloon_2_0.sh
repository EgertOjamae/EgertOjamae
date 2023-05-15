#!/bin/bash


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
                mkfs.ntfs /dev/nvme0n1p3 -QL HDD
                /usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -f sda1 restoreparts windows_10_pro_2.0 $kloonitav_ketas"p1"
                echo "Kiire paus :) "
                sleep 2
                /usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -p choose -f sda2 restoreparts windows_10_pro_2.0 $kloonitav_ketas"p2"

        elif [ "$kloonitav_ketas" == "sda" ] || [ "$kloonitav_ketas" == "sdb" ] || [ "$kloonitav_ketas" == "sdc" ] || [ "$kloonitav_ketas" == "sdd" ]
        then
                mkfs.ntfs /dev/sda3 -QL HDD
                /usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -f sda1 restoreparts windows_10_pro_2.0 $kloonitav_ketas"1"
                echo "Kiire paus :) "
                sleep 2
                /usr/sbin/ocs-sr -e1 auto -e2 -t -r -j2 -b -k -scr -p choose -f sda2 restoreparts windows_10_pro_2.0 $kloonitav_ketas"2"

        fi
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

	#kettamahu salvestamine
	ketta_maht=`parted -l | grep dev/$kloonitav_ketas | awk ' {print $3 }'`


	echo ""

	echo "Kloonitava ketta maht on: " $ketta_maht
	sleep 1
	echo ""
	echo ""

	read -p "LOON PARTITSIOONID, VÕTA MÄLUPULK VÄLJA JA VAJUTA ENTER: "
	sleep 2

	echo ""
	echo ""

	parted /dev/$kloonitav_ketas mktable msdos
	parted /dev/$kloonitav_ketas mkpart primary ntfs 1048576B 576716799B
	parted /dev/$kloonitav_ketas mkpart primary ntfs 576716800B 107951947775B
	parted /dev/$kloonitav_ketas mkpart primary ntfs 107951947776B $ketta_maht
	parted /dev/$kloonitav_ketas toggle 1 boot

	echo ""
	echo ""

	#vastavalt vastusele käivitame kas pulgalt kloonimise või võrgust kloonimise protsessi
	read -p "Sisesta number, kas kloonid pulgalt (1)  või  kloonid võrgust (2): " vastus

	if [ "$vastus" == "1" ]
	then
		#tuvastame kõik ühendatud mälupulgad
		usb_pulgad=""
		read -p "Sisesta kloonipulk ja vajuta ENTER "
		sleep 2
		for _device in /sys/block/*/device
		do
			if echo $(readlink -f "$_device") | grep -q "usb"
			then
				_disk=$(echo "$_device" | cut -f4 -d/)
				usb_pulgad="$usb_pulgad $_disk"
			fi
		done

		echo ""
		echo ""

		value="1"
		pulga_asukoht=$usb_pulgad$value #tingimusel et kloon on mälupulga esimesel partitsioonil
		cut_pulga_asukoht=`echo $pulga_asukoht | cut -b 1-4`
		mount /dev/$cut_pulga_asukoht /home/partimag
		lsblk
		echo ""
		#kontrollid sooritatud, kutsume kloonimise funktsiooni
		kloonimise_funktsioon


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
	fi
	
else 
echo "Lähen otse partedisse"
fi