NB !!!
SKRIPTI SAAB KASUTADA AINULT 100GB+ KETASTE KORRAL 
SKRIPT TÖÖTAB AINULT PARTED 2020 versiooniga

NB ENNE ESIMEST KÄIVITAMIST ON VAJA KORRA Eq-ga läbi vaadata (Skriptis on muutuja, mis on igal mälupulgal erinev) - kui soovid ise muuta siis tee järgnevalt:

1. Booti partedisse ilma skripti käivitamata
2. Sisesta see mälupulk kus asub kloon
3. Terminalis sisesta järgnev käsk 
echo readlink -f /dev/disk/by-id/usb-      /*pärast "usb-" kohta vajuta TAB, et käskluse ise ära lõpetaks. See on nüüd vastavalt igal-usb pulgal erinev (USB_ID) 
lõpus tuleb ka valida esimene partitsioon(juhul kui pulga peal oleva skript on mingi muu partitsiooni peal siis vastavalt sellele tee ka valik) 
Kogutulemus peab olema kujul:
readlink -f /dev/disk/by-id/usb-Kingston_DataTraveler_3.0_902B341D9F41B161A947383B-0\:0-part1
			    ***-See____________koht________kõigil______erinev_______\siin-peab-sama-olema (Kui on esimesel partitsioonil kloon)

Kui kogu käsku välja printida(echo) ehk ....    echo readlink -f /dev/disk/by-id/usb-Kingston_DataTraveler_3.0_902B341D9F41B161A947383B-0\:0-part1
siis peab tulemuseks tulema 
/dev/sdb1           ---- see tuleb vastavalt sellel mis pulga asukohaks tuleb, võib tulla sda1,sdb1 jne jne.

4. Kopeeri kogu käsk ilma echo-ta 
5. Tee endale skriptist koopia ja pane partedi pulgale õigesse kohta. Ise valid kus kohas seda koodi editima hakkad, võib nii linuxis nano või muu tekstiredaktoriga või ka windowsis notepadis. 
Otsi koodis (ctrl+f) märget : otsimind
6. Asenda koodis olev USB_ID enda omaga (ära kustuta `` märke ära !) 
7. Salvesta muudetud kood

Klooni asukoht & kasutamine
1. Pane kloon siia ----  *pulk*:\pmagic\pmodules\scripts
2. Käivita parted nii nagu tavaliselt 
3. Jälgi ekraanil olevaid juhiseid 



***********
Tavaliselt asub kloonitav ketas asukohal /dev/sda  (kui tegemist on hdd või ssd-ga)
Nvme ketta puhul on asukoht /dev/nvme0n1
See info on oluline kui skriptis küsitakse mis ketast kloonida 