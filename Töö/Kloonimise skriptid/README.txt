NB !!!
SKRIPTI SAAB KASUTADA AINULT 100GB+ KETASTE KORRAL 
SKRIPT T��TAB AINULT PARTED 2020 versiooniga

NB ENNE ESIMEST K�IVITAMIST ON VAJA KORRA Eq-ga l�bi vaadata (Skriptis on muutuja, mis on igal m�lupulgal erinev) - kui soovid ise muuta siis tee j�rgnevalt:

1. Booti partedisse ilma skripti k�ivitamata
2. Sisesta see m�lupulk kus asub kloon
3. Terminalis sisesta j�rgnev k�sk 
echo readlink -f /dev/disk/by-id/usb-      /*p�rast "usb-" kohta vajuta TAB, et k�skluse ise �ra l�petaks. See on n��d vastavalt igal-usb pulgal erinev (USB_ID) 
l�pus tuleb ka valida esimene partitsioon(juhul kui pulga peal oleva skript on mingi muu partitsiooni peal siis vastavalt sellele tee ka valik) 
Kogutulemus peab olema kujul:
readlink -f /dev/disk/by-id/usb-Kingston_DataTraveler_3.0_902B341D9F41B161A947383B-0\:0-part1
			    ***-See____________koht________k�igil______erinev_______\siin-peab-sama-olema (Kui on esimesel partitsioonil kloon)

Kui kogu k�sku v�lja printida(echo) ehk ....    echo readlink -f /dev/disk/by-id/usb-Kingston_DataTraveler_3.0_902B341D9F41B161A947383B-0\:0-part1
siis peab tulemuseks tulema 
/dev/sdb1           ---- see tuleb vastavalt sellel mis pulga asukohaks tuleb, v�ib tulla sda1,sdb1 jne jne.

4. Kopeeri kogu k�sk ilma echo-ta 
5. Tee endale skriptist koopia ja pane partedi pulgale �igesse kohta. Ise valid kus kohas seda koodi editima hakkad, v�ib nii linuxis nano v�i muu tekstiredaktoriga v�i ka windowsis notepadis. 
Otsi koodis (ctrl+f) m�rget : otsimind
6. Asenda koodis olev USB_ID enda omaga (�ra kustuta `` m�rke �ra !) 
7. Salvesta muudetud kood

Klooni asukoht & kasutamine
1. Pane kloon siia ----  *pulk*:\pmagic\pmodules\scripts
2. K�ivita parted nii nagu tavaliselt 
3. J�lgi ekraanil olevaid juhiseid 



***********
Tavaliselt asub kloonitav ketas asukohal /dev/sda  (kui tegemist on hdd v�i ssd-ga)
Nvme ketta puhul on asukoht /dev/nvme0n1
See info on oluline kui skriptis k�sitakse mis ketast kloonida 