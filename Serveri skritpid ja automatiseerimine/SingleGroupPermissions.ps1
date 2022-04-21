function addPermissions(){

    #salvestame alamkaustad
    $users = get-childitem $Global:targetFolder


    Foreach ($user in $users) { #käime kõik juurkataloogis olevad kataloogid läbi
        try {

            $acl = Get-Acl $user.FullName #küsime praegused õigused
            Get-Acl $user.FullName
            Set-Acl -Path $user.FullName -AclObject $acl #salvestame hetkeseadistuse 
            

            #Anname õigused permissionGroup grupile või kasutajale
            $acl.SetAccessRule($Global:permissionGroup)
            set-acl $user.FullName $acl
  
            }
            Catch
            {
                echo Ei õnnestunud õiguseid lisada
        }     
        
    }
}


function removePermissions(){
    
    #salvestame alamkaustad
    $users = get-childitem $Global:targetFolder


    Foreach ($user in $users) { #käime kõik juurkataloogis olevad kataloogid läbi
        try {

            $acl = Get-Acl $user.FullName #küsime praegused õigused
            Get-Acl $user.FullName
            Set-Acl -Path $user.FullName -AclObject $acl #salvestame hetkeseadistuse 
            

            #Eemaldame õigused permissionGroup grupilt või kasutajalt
            $acl.RemoveAccessRule($Global:permissionGroup)
            set-acl $user.FullName $acl
  
            }
            Catch
            {
                echo Ei õnnestunud õiguseid ära võtta
        }     
        
    }

}



function guiKontroll(){

    #Kinnituse andmine fancy GUI-ga 
    $pealkiri    = "Õiguste Valimine"
    $sisend = 'Palun vali sobivad õigused'

    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&FullControl'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&ReadAndExecute'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Peata programm'))

    $decision = $Host.UI.PromptForChoice($pealkiri, $sisend, $choices, 2)



    if ($decision -eq 0) {

        Write-Host 'Valisid FullControl õigused' -ForegroundColor Magenta
        $Global:grupiÕigused = "FullControl"

    } if ($decision -eq 1) {

        Write-Host 'Valisid ReadAndExecute õigused' -ForegroundColor Blue
        $Global:grupiÕigused = "ReadAndExecute"

    } if ($decision -eq 2) {
        Write-Host 'Programm peatatud' -ForegroundColor Red
    }

}


function Get-Folder($targetKaust) {
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowserDialog.RootFolder = 'MyComputer'
    if ($initialDirectory) { $FolderBrowserDialog.SelectedPath = $initialDirectory }
    [void] $FolderBrowserDialog.ShowDialog()
    return $FolderBrowserDialog.SelectedPath
}

Write-Host "Vali target kaust" -ForegroundColor Red

$targetKaustaAsukoht=Get-Folder

$Global:valitudGrupp = Read-Host -Prompt "Grupi nimi"

$Global:targetFolder = "$targetKaustaAsukoht"

#Kinnituse andmine fancy GUI-ga 
$pealkiri    = "Kontroll"
$sisend = 'Kas soovid õiguseid lisada või ära võtta'

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Lisan õigused'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Eemaldan õigused'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Peata programm'))

$decision = $Host.UI.PromptForChoice($pealkiri, $sisend, $choices, 2)



if ($decision -eq 0) {

    Write-Host 'Lisan Õigused' -ForegroundColor Magenta
    guiKontroll
    $Global:permissionGroup = New-Object system.security.accesscontrol.filesystemaccessrule($valitudGrupp,$grupiÕigused,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    addPermissions
    

} if ($decision -eq 1) {

    Write-Host 'Eemaldan õigused' -ForegroundColor Blue
    $Global:permissionGroup = New-Object system.security.accesscontrol.filesystemaccessrule($valitudGrupp,"FullControl",”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    removePermissions

} if ($decision -eq 2) {
    Write-Host 'Programm peatatud' -ForegroundColor Red
}
