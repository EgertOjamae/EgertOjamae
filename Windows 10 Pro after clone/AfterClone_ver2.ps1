Write-Host "Tere tulemast AfterClone_ver2 programmi" -ForegroundColor Blue -BackgroundColor Black
Write-Host "Jälgige juhiseid ning enjoy! " -ForegroundColor Blue -BackgroundColor Black
Write-Host "Versioon = 2.0" -ForegroundColor Blue -BackgroundColor Black
Write-Host "Kaughaldus OÜ" -ForegroundColor Blue -BackgroundColor Black





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

Write-Host "Kogun andmeid... " -ForegroundColor Blue -BackgroundColor Black
      
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



#$arvutid = Get-Content -Path "C:\mingi_tee"    /* kasuta siis kui tahad mitme arvuti puhul teha, salvesta siia arvuti nimed

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

ProcessingAnimation

Write-Host "Andmed ning tarkvara edukalt kaardistatud, failid leiad skripti käivitamise kaustast" -ForegroundColor Green -BackgroundColor Black
}


function ProcessingAnimation() {
    $cursorTop = [Console]::CursorTop
    
    try {
        [Console]::CursorVisible = $false
        
        $counter = 0
        $frames = '|', '/', '-', '\' 
        $värviArray = New-Object string[] 9
        $värviArray[1] = "Yellow"
        $värviArray[2] = "Green"
        $värviArray[3] = "Red"
        $värviArray[4] = "Magenta"
        $värviArray[5] = "White"
        $värviArray[6] = "DarkCyan"
        $värviArray[7] = "Blue"

    
        while($counter -ne 75) {
            $frame = $frames[$counter % $frames.Length]
            $random = Get-Random -Minimum 1 -Maximum 7
            
            Write-Host "$frame" "***Loading***" "$frame" -NoNewLine -ForegroundColor $värviArray[$random]
            [Console]::SetCursorPosition(0, $cursorTop)
            
            $counter += 1
            Start-Sleep -Milliseconds 125
        }
        
        # Only needed if you use a multiline frames
        Write-Host ($frames[0] -replace '[^\s+]', ' ')
    }
    finally {
        [Console]::SetCursorPosition(0, $cursorTop)
        [Console]::CursorVisible = $true
    }
}


function changeHostname{

$uus_hostname = Read-Host -Prompt "Sisesta uus hostname: "
Rename-Computer -NewName $uus_hostname -Force
Write-Host "Arvutinimi edukalt vahetatud, rakendub pärast restarti" -ForegroundColor Green -BackgroundColor Black
Start-Sleep -s 1

}


function addToDomain{

$domeeni_nimi = Read-Host -Prompt "Sisesta domeeninimi: "
Add-Computer -DomainName $domeeni_nimi -Credential $domeeni_nimi\kaughaldus -Force
Write-Host "Arvuti domeeni edukalt lisatud, rakendub pärast restarti" -ForegroundColor Green -BackgroundColor Black
Start-Sleep -s 1

}


function chagneLocalAdminPassword{

$parool = Read-Host "Sisesta uus parool: " -AsSecureString
Get-LocalUser -Name "Administrator" | Set-LocalUser -Password $parool
Write-Host "Parool edukalt vahetatud! " -ForegroundColor Green -BackgroundColor Black 
Start-Sleep -s 1
    
}


function createUser{

$user = "kasutaja"
$kasutaja_parool = "kasutaja"
New-LocalUser $user -Password $kasutaja_parool -FullName "kasutaja" -Description "kasutaja"
Set-LocalUser -Name $user -PasswordNeverExpires $true
Add-LocalGroupMember -Group "Users" -Member "kasutaja"
Write-Host "Kasutajakonto edukalt loodud! " -ForegroundColor Green -BackgroundColor Black
Start-Sleep -s 2

}

function activateWindows{

start ms-settings:
$wshell = New-Object -ComObject wscript.shell;
Sleep 2
$wshell.SendKeys("{a}")
$wshell.SendKeys("{k}")
$wshell.SendKeys("{t}")
$wshell.SendKeys("{i}")
$wshell.SendKeys("{v}")
$wshell.SendKeys("{e}")
$wshell.SendKeys("{e}")
$wshell.SendKeys("{r}")
$wshell.SendKeys("{i}")
$wshell.SendKeys("{m}")
$wshell.SendKeys("{i}")
$wshell.SendKeys("{n}")
$wshell.SendKeys("{e}")
Sleep 1
$wshell.SendKeys("{ENTER}")
Sleep 1
$wshell.SendKeys("{ENTER}")
Sleep 2
$wshell.SendKeys("{ENTER}")
Sleep 20
$wshell.SendKeys("{TAB}")
Sleep 1 
$wshell.SendKeys("{TAB}")
Sleep 1
$wshell.SendKeys("{ENTER}")
Sleep 20
$wshell.SendKeys("{ENTER}")
Sleep 1
$wshell.SendKeys("#{F4}")

}

function Google_chrome {
$wshell = New-Object -ComObject wscript.shell;
sleep_time
$wshell.SendKeys("^{ESC}")
sleep_time
$wshell.SendKeys("{g}")
sleep_time
$wshell.SendKeys("{o}")
sleep_time
$wshell.SendKeys("{o}")
sleep_time
$wshell.SendKeys("{g}")
sleep_time
$wshell.SendKeys("{l}")
sleep_time
$wshell.SendKeys("{e}")
sleep_time 
$wshell.SendKeys("+{F10}")
Sleep 1 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{ENTER}")
sleep_time
$wshell.SendKeys("{ESC}")
} #end of Google_chrome /kutsu siin mouseclick välja


function cleanTaskbar {

$wshell = New-Object -ComObject wscript.shell;
$wshell.SendKeys("{TAB}")
sleep_time
$wshell.SendKeys("{TAB}")
sleep_time
$wshell.SendKeys("+{F10}")
Sleep 1 
$wshell.SendKeys("{DOWN}")
sleep_time 
$wshell.SendKeys("{DOWN}")
sleep_time
$wshell.SendKeys("{RIGHT}")
sleep_time
$wshell.SendKeys("{ENTER}")
sleep_time
#otsinguriba kadunud

$wshell.SendKeys("{TAB}")
sleep_time
$wshell.SendKeys("+{F10}")
Sleep 1
$wshell.SendKeys("{DOWN}")
sleep_time 
$wshell.SendKeys("{DOWN}")
sleep_time 
$wshell.SendKeys("{DOWN}")
sleep_time 
$wshell.SendKeys("{ENTER}")
sleep_time
#cortana nupp kadunud

$wshell.SendKeys("{TAB}")
sleep_time 
$wshell.SendKeys("{TAB}")
sleep_time
$wshell.SendKeys("+{F10}")
sleep_time 
$wshell.SendKeys("{DOWN}")
sleep_time 
$wshell.SendKeys("{DOWN}")
sleep_time
$wshell.SendKeys("{DOWN}")
sleep_time
$wshell.SendKeys("{DOWN}")
sleep_time 
$wshell.SendKeys("{Enter}")
sleep_time
#task view kadunud

$wshell.SendKeys("{TAB}")
sleep_time 
$wshell.SendKeys("{TAB}")
sleep_time 
$wshell.SendKeys("{TAB}")
sleep_time 
$wshell.SendKeys("{TAB}")
sleep_time
$wshell.SendKeys("+{F10}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time
$wshell.SendKeys("{Enter}")
sleep_time
#edge kadunud

$wshell.SendKeys("{TAB}")
sleep_time 
$wshell.SendKeys("{TAB}")
sleep_time
$wshell.SendKeys("{TAB}")
sleep_time
$wshell.SendKeys("{TAB}")
sleep_time
$wshell.SendKeys("{TAB}")
sleep_time
$wshell.SendKeys("{RIGHT}")
sleep_time
$wshell.SendKeys("+{F10}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{Enter}")
sleep_time
#mail läinud

$wshell.SendKeys("{RIGHT}")
sleep_time
$wshell.SendKeys("+{F10}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{UP}")
sleep_time 
$wshell.SendKeys("{Enter}")
#store läinud
}

function Minimize {

$shell = New-Object -ComObject "Shell.Application"
Sleep 1
$shell.minimizeall()

} 

function sleep_time{

sleep -Milliseconds 220

}


function Click-MouseButton{

$signature=@' 
[DllImport("user32.dll",CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@ 

$SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru 

$SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
$SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
} 


function eemaldaOnedrive {
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f /v "OneDrive"
  Write-Host "OneDrive alglaadimisest eemaldatud! " -ForegroundColor Green -BackgroundColor Black
}


function restart{

restart-computer

}

function removeItems{

Remove-Item C:\Users\*\Desktop\*lnk –Force


#Google Chrome 

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("C:\Users\Administrator\Desktop\Google Chrome.lnk")
$shortcut.TargetPath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$shortcut.Save()
Write-Host "Töölaud puhastatud ning Chrome otsetee loodud, seadistan Chrome tööribale, palun OOTA!! " -ForegroundColor Green -BackgroundColor Black
Write-Host "----------------------------"

Minimize
sleep_time -s 1
Click-MouseButton
sleep_time -s 1
cleanTaskbar
sleep_time -s 1
Click-MouseButton
sleep_time -s 1
Google_chrome


}

echo ""
echo ""
Write-Host "VEENDU ET ARVUTI ON ÜHENDATUD VÕRGUGA " -ForegroundColor Red -BackgroundColor Black
Write-Host "NUMBER 5 JA 6 PUHUL EELDATAKSE ET KÕIK ON ORIGINAALSEISUS JA KASUTAJA POLE JUBA MIDAGI MUUTNUD " -ForegroundColor Red -BackgroundColor Black
$sisend = "algus"
while ($sisend -ne "lõpp") {
    Write-Host "1 = Muuda arvutinimi" -ForegroundColor Blue -BackgroundColor White
    echo ""
    Write-Host "2 = Lisa arvuti Domeeni" -ForegroundColor Blue -BackgroundColor White
    echo ""
    Write-Host "3 = Vaheta kohaliku admini parool" -ForegroundColor Blue -BackgroundColor White
    echo ""
    Write-Host "4 = Loo kohalik kasutaja" -ForegroundColor Blue -BackgroundColor White
    echo ""
    Write-Host "5 = Aktiveeri Windows(tõrkeotsing)" -ForegroundColor Blue -BackgroundColor White
    echo ""
    Write-Host "6 = Eemalda ebavajalikud ikoonid, Google Chrome tegumiribale" -ForegroundColor Blue -BackgroundColor White
    echo ""
    Write-Host "7 = Eemalda OneDrive StartUp programmide hulgast" -ForegroundColor Blue -BackgroundColor White
    echo ""
    Write-Host "8 = Jooksuta kaardistamise programm" -ForegroundColor Blue -BackgroundColor White
    echo ""
    Write-Host "9 = Lõpeta programm" -ForegroundColor Magenta -BackgroundColor White
    echo ""
    Write-Host "10 = Taaskäivita arvuti" -ForegroundColor Red -BackgroundColor Black
    echo ""
    echo "-----------------------------------------------------------------------------"
    $sisend = Read-Host -Prompt "Sisesta number mida soovid teha" 

    if ($sisend -eq 9){

        $sisend = "lõpp"
        

        }

    ElseIf ($sisend -eq 1){
            
        changeHostname

        }

    ElseIf ($sisend -eq 2){
            
        addToDomain

        }

    ElseIf ($sisend -eq 3){
            
        chagneLocalAdminPassword

        }

     ElseIf ($sisend -eq 4){
            
        createUser

        }

    ElseIf ($sisend -eq 5){
            
        activateWindows

        }

    
    ElseIf ($sisend -eq 6){
            
        removeItems

        }

    
    ElseIf ($sisend -eq 7){
            
        eemaldaOnedrive

        }

    ElseIf ($sisend -eq 8){
            
        arvuti_andmed
        }

    ElseIf ($sisend -eq 10){
        Write-Host "Taaskäivitan 5 sekundi pärast" -ForegroundColor Red -BackgroundColor Black
        Sleep 1
        Write-Host "Taaskäivitan 4 sekundi pärast" -ForegroundColor Green -BackgroundColor Black
        Sleep 1 
        Write-Host "Taaskäivitan 3 sekundi pärast" -ForegroundColor Blue -BackgroundColor Black
        Sleep 1
        Write-Host "Taaskäivitan 2 sekundi pärast" -ForegroundColor Yellow -BackgroundColor Black
        Sleep 1
        Write-Host "Taaskäivitan 1 sekundi pärast" -ForegroundColor Cyan -BackgroundColor Black
        Sleep 1

        restart

        }
      
}