#Variables
#$grupp = Read-Host -Prompt "Sisesta grupi nimi (nii nagu ilmub AD-s)"

$files = Get-Content -Path C:\Users\administrator\Desktop\grupid.txt


function getGroupMembers(){

    ForEach ($file in $files){

    $f=Get-ADGroupMember -Identity "$file" | Get-ADUser -Properties Mail | Select-Object Name,Mail |Out-File C:\Users\Administrator\Desktop\$file.txt -Encoding UTF8

    }
    
}



getGroupMembers