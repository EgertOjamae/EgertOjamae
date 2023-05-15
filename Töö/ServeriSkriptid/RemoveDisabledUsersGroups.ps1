$Users = Get-ADUser -Filter "enabled -eq 'false'" -SearchBase "OU=2020,OU=students,OU=archive,OU=sillaotsa.edu.ee,DC=sillaotsa,DC=edu,DC=ee"

echo $Users

foreach ($user in $Users) {
    Remove-ADGroupMember -identity "students2020" -Members $user
}