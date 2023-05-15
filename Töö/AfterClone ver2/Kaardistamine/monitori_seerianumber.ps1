 function monitori_andmed{

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
      #Eraldi objekt arvuti SN jaoks 
      $Arvuti_Obj = [PSCustomObject]@{
        Arvuti_SN        = $Arvuti_SN
      }

      #Teeme eraldi objekti kuhu lisame vastavad elemendid 
      $Monitor_Obj = [PSCustomObject]@{
        Tootja	         = $Mon_Manufacturer_Friendly
        Mudel            = $Mon_Model
        Seerianumber     = $Mon_Serial_Number
        Arvuti_hostname  = $Mon_Attached_Computer
      }
      
      #Lisame objekti eelnevalt defineeritud arraysse
      $Monitor_Array += $Monitor_Obj 
      
      
    } 
  
    #OUTPUT
    $Monitor_Array
    get-ciminstance win32_bios | format-list serialnumber
    
    } 
}
monitori_andmed | Export-Excel -Path '.\Proov.xlsx' -AutoSize