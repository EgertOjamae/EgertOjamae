$username = "martin.kaldmaa"
$homedir = "\\ekuserver.kodu.ee\accounts$\$username"
New-Item -Path $homedir -ItemType "directory"

$Global:adminPermission = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
$Global:systemPermission = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
$admin = "Administrators"

$acl = Get-Acl $homedir
Get-Acl $homedir
$acl.SetAccessRuleProtection($false, $true)  
Set-Acl -Path $homedir -AclObject $acl 

$userPermission = New-Object system.security.accesscontrol.filesystemaccessrule("$username",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
$acl.SetAccessRule($userPermission)
set-acl $homedir $acl

#seame omanikuks Administrators grupi
$acl.SetOwner([System.Security.Principal.NTAccount]"$username")
set-acl $homedir $acl -Verbose 

