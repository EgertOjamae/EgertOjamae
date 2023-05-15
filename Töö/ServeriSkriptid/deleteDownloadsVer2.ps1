#Globaalne muutuja peab olema kolmeastmelise sügavsuega
#esimene aste on juur, kus asuvad kõik kasutajad kujul eesnimi.perekonnanimi
#teine aste on alamkaustad mis on kujul eesnimi.perekonnanimi\kaustad
#kolmas aste on failid, mis on kujul eesnimi.perekonnanimi\kaustad\failid


$Global:failideSuurus = 0

function Get-Folder($targetKaust) {
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowserDialog.RootFolder = 'MyComputer'
    if ($initialDirectory) { $FolderBrowserDialog.SelectedPath = $initialDirectory }
    [void] $FolderBrowserDialog.ShowDialog()
    return $FolderBrowserDialog.SelectedPath
}

#funktsioon võtab juures allapoole kõik alamkaustad ning Downloadsi kausta sisu suuruse 

function showSize(){

#salvestame alamkaustad
    $users = get-childitem $Global:targetFolder
    
    Foreach ($user in $users) { 
                 
        $subFolders = Get-ChildItem $user.FullName -Directory -Recurse
        
        Foreach ($subFolder in $subFolders) {
        #echo $subFolder.FullName
             

            if($subFolder.Name -eq "Downloads"){

                $failid =  Get-ChildItem $subFolder.FullName -File
                
                Foreach ($fail in $failid) {
                    $Global:failideSuurus += $fail.Length /1MB
                        
                }
           }                 
       }
   }

   Write-Host "Failide suurus on kokku: $Global:failideSuurus"MB"" -ForegroundColor DarkCyan
}


#funktsioon võtab juurest allapoole kõik alamkaustad ning otsib kausta nimega Downloads
#kui leiab kausta downloads siis kustutab kõik sisu ära.

function deleteDownloads(){
    #salvestame alamkaustad
    $users = get-childitem $Global:targetFolder
      
    Foreach ($user in $users) { 
                 
        $subFolders = Get-ChildItem $user.FullName -Directory -Recurse       

        Foreach ($subFolder in $subFolders) {
            
            try{
          
            if($subFolder.Name -eq "Downloads"){

                $failid =  Get-ChildItem $subFolder.FullName -File -Recurse
               
                Remove-Item $failid.FullName -Verbose
                }
            }
            catch{

                Write-Host "Paistab et $user Downloads kaust on tühi" -BackgroundColor Red
 

              }  
                              
           }                
       }
   }


$targetKaustaAsukoht=Get-Folder
$Global:targetFolder = "$targetKaustaAsukoht"

#Kinnituse andmine fancy GUI-ga 
$pealkiri    = "Puhastamine"
$sisend = 'Oled kindel, et soovid puhastusega jätkata?'

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&JAH'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&EI'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Näita failide suurust'))




#Funktsioon kutsutakse välja ainult sellisel juhul kui kasutaja vajutab "JAH" 
$decision = $Host.UI.PromptForChoice($pealkiri, $sisend, $choices, 2)



if ($decision -eq 0) {

    Write-Host 'Kinnitatud, jätkan kustutamisega' -ForegroundColor Magenta
    deleteDownloads

} if ($decision -eq 1) {

    Write-Host 'Vajutasid ei, peatan programmi' -ForegroundColor Red

} if ($decision -eq 2) {
    showSize
}
