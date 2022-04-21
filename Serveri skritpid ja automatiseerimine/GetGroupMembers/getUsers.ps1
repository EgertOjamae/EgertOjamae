#Variables
$grupp = Read-Host -Prompt "Sisesta grupi nimi (nii nagu ilmub AD-s)"


function getGroupMembers(){

Get-ADGroupMember -Identity $grupp | Select-Object name

}

getGroupMembers | Out-File -Append C:\Users\Administrator\Desktop\$grupp.csv -Encoding UTF8