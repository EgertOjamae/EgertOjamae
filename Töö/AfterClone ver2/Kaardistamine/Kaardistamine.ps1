function arvuti_andmed{
#################
#Monitori andmete saamine



[CmdletBinding()]
PARAM (
[Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
[String[]]$ComputerName = $env:ComputerName
)
  
#Tootjate nimed
$ManufacturerHash = @{ 
"AAC" =	"AcerView";
"ACR" = "Acer";
"AOC" = "AOC";
"AIC" = "AG Neovo";
"APP" = "Apple Computer";
"AST" = "AST Research";
"AUO" = "Asus";
"BNQ" = "BenQ";
"CMO" = "Acer";
"CPL" = "Compal";
"CPQ" = "Compaq";
"CPT" = "Chunghwa Pciture Tubes, Ltd.";
"CTX" = "CTX";
"DEC" = "DEC";
"DEL" = "Dell";
"DPC" = "Delta";
"DWE" = "Daewoo";
"EIZ" = "EIZO";
"ELS" = "ELSA";
"ENC" = "EIZO";
"EPI" = "Envision";
"FCM" = "Funai";
"FUJ" = "Fujitsu";
"FUS" = "Fujitsu-Siemens";
"GSM" = "LG Electronics";
"GWY" = "Gateway 2000";
"HEI" = "Hyundai";
"HIT" = "Hyundai";
"HSL" = "Hansol";
"HTC" = "Hitachi/Nissei";
"HWP" = "HP";
"IBM" = "IBM";
"ICL" = "Fujitsu ICL";
"IVM" = "Iiyama";
"KDS" = "Korea Data Systems";
"LEN" = "Lenovo";
"LGD" = "Asus";
"LPL" = "Fujitsu";
"MAX" = "Belinea"; 
"MEI" = "Panasonic";
"MEL" = "Mitsubishi Electronics";
"MS_" = "Panasonic";
"NAN" = "Nanao";
"NEC" = "NEC";
"NOK" = "Nokia Data";
"NVD" = "Fujitsu";
"OPT" = "Optoma";
"PHL" = "Philips";
"REL" = "Relisys";
"SAN" = "Samsung";
"SAM" = "Samsung";
"SBI" = "Smarttech";
"SGI" = "SGI";
"SNY" = "Sony";
"SRC" = "Shamrock";
"SUN" = "Sun Microsystems";
"SEC" = "Hewlett-Packard";
"TAT" = "Tatung";
"TOS" = "Toshiba";
"TSB" = "Toshiba";
"VSC" = "ViewSonic";
"ZCM" = "Zenith";
"UNK" = "Unknown";
"_YV" = "Fujitsu";
}
      
ForEach ($Computer in $ComputerName) {
  
    #Monitori objektid 
    $Monitors = Get-WmiObject -Namespace "root\WMI" -Class "WMIMonitorID" -ComputerName $Computer -ErrorAction SilentlyContinue
   

    #Array objektide jaoks 
    $Monitor_Array = @()
    
    
    #Käib kõik objektid läbi 
    ForEach ($Monitor in $Monitors) {
      
    #Converdime ASCII koodi lugevaks ja võtame ASCII null valued ära 
    If ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName) -ne $null) {
        $Mon_Model = ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)).Replace("$([char]0x0000)","")
    } else {
        $Mon_Model = $null
    }
    $Mon_Serial_Number = ([System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)).Replace("$([char]0x0000)","")
    $Mon_Attached_Computer = ($Monitor.PSComputerName).Replace("$([char]0x0000)","")
    $Mon_Manufacturer = ([System.Text.Encoding]::ASCII.GetString($Monitor.ManufacturerName)).Replace("$([char]0x0000)","")
     
    If ($Mon_Model -like "*800 AIO*" -or $Mon_Model -like "*8300 AiO*") {Break}
      
    #Paneme Tootjate nimede hulgast objektile sõbraliku nime, kui seda ei leidu, hoiame originaali alles 
    $Mon_Manufacturer_Friendly = $ManufacturerHash.$Mon_Manufacturer
    If ($Mon_Manufacturer_Friendly -eq $null) {
        $Mon_Manufacturer_Friendly = $Mon_Manufacturer
    }
    

    #Teeme eraldi objekti kuhu lisame vastavad elemendid 
    $Monitor_Obj = [PSCustomObject]@{
    Tootja	         = $Mon_Manufacturer_Friendly
    Mudel            = $Mon_Model
    Seerianumber     = $Mon_Serial_Number
    }
      
    #Lisame objekti eelnevalt defineeritud arraysse
    $Monitor_Array += $Monitor_Obj 
      
      
  } 

} 



#$arvutid = Get-Content -Path "C:\Users\Egert\Desktop\Programs\Töö_failid\AfterClone ver2\Kaardistamine\test.txt"    # kasuta siis kui tahad mitme arvuti puhul teha, salvesta siia arvuti nimed

$andmed = @()
$arvuti = hostname

#kui teed mitme arvuti kohta siis kasuta seda
# foreach ($arvuti in $arvutid)
#järgmised read kõik siis for tsükli sisse


$andmete_päring = Get-WmiObject win32_computersystem -ComputerName $arvuti

$nimi = $andmete_päring.Name

$tootja = $andmete_päring.Manufacturer

$mudel = $andmete_päring.Model

$emaplaat = Get-WmiObject win32_baseboard | Select-Object Product, Manufacturer, Serialnumber

$seerianumber = wmic bios get serialnumber

$cpu = (Get-WmiObject -Class Win32_processor -ComputerName $arvuti).Name
$cpu_kiirus = Get-CimInstance Win32_Processor | Select-Object -Expand MaxClockSpeed
$cpu_round = [Math]::Round($cpu_kiirus/1000, 2)
$cpu_parsitud = "$cpu_round" + "GHz"

$ram = $andmete_päring.TotalPhysicalMemory/1GB
$ram_parsitud = [Math]::Round($ram, 2)

$ketta_mudel = Get-PhysicalDisk | select FriendlyName
$ketta_tüüp = Get-PhysicalDisk | select Mediatype
$ketta_maht = Get-PhysicalDisk | select @{Name="Size, GB"; Expression ={[Math]::round($_.Size/1Gb,2)}}

$võrgukaart = Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed




$os = (Get-WmiObject -Class win32_operatingsystem -ComputerName $arvuti).Caption
$test_cpu = $cpu_parsitud


$info = New-Object PSObject
$info | Add-Member -MemberType NoteProperty -Name "Arvuti nimi" -Value $nimi

$info | Add-Member -MemberType NoteProperty -Name "Tootja" -Value $tootja

$info | Add-Member -MemberType NoteProperty -Name "Mudel" -Value $mudel 

$info | Add-Member -MemberType NoteProperty -Name "Emaplaat" -Value $emaplaat

$info | Add-Member -MemberType NoteProperty -Name "Seerianumber" -Value $seerianumber

$info | Add-Member -MemberType NoteProperty -Name "CPU" -Value $cpu
$info | Add-Member -MemberType NoteProperty -Name "CPU baaskiirus" -Value $cpu_parsitud

$info | Add-Member -MemberType NoteProperty -Name "RAM" -Value $ram_parsitud

$info | Add-Member -MemberType NoteProperty -Name "Ketta mudel" -Value $ketta_mudel
$info | Add-Member -MemberType NoteProperty -Name "Ketta tüüp" -Value $ketta_tüüp
$info | Add-Member -MemberType NoteProperty -Name "Ketta maht" -Value $ketta_maht

$info | Add-Member -MemberType NoteProperty -Name "OS" -Value $os
$info | Add-Member -MemberType NoteProperty -Name "Monitori andmed" -Value $Monitor_Array
$info | Add-Member -MemberType NoteProperty -Name "Võrgukaardi andmed" -Value $võrgukaart
$andmed += $info

$text = (Get-Item .).FullName


$andmed | Out-File -FilePath $text\$arvuti.txt
#echo $andmed
$office_andmed = cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus
Add-Content $text\$arvuti.txt $office_andmed

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, InstallDate, DisplayVersion, Publisher | Format-Table –AutoSize > $text\Tarkvara.txt


}




arvuti_andmed

