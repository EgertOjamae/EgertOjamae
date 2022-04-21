#Globaalsed muutujad Administrators ja SYSTEM grupile 
$Global:adminPermission = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
$Global:systemPermission = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
#Globaalne muutuja sihtkoha kaustale - skript käsitleb kaustasid kolmel tasandil
#Esimene tase peab olema juurkaust - eesnimi.perekonnanimi 
#Teine tase on eesnimi.perekonnanimi\kasutad
#Kolmas tase on eesnimi.perekonnanimi\kaustad\failid

$Global:targetFolder = "U:\accounts\students\2021" #võetakse kõik 2014 aasta all olevad õpilased kujul eesnimi.perekonnanimi (esimene tase)

#funktsioon kasutab TokenPrivileges (mingi korralik kerneli maagia), et välja kutsuda privilege escalation meetodit.
#selle jaoks tehakse kaks kasuta C kettale full õigustega ning nende õigused kirjutatakse rekursiivselt target kausta ja failidega üle. 
function allowAccess(){

    # prepare for folders
    If (Test-Path C:\PTemp) { Remove-Item C:\PTemp }
    New-Item -type directory -Path C:\PTemp
    $Acl = Get-Acl -Path C:\PTemp
    $Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("BUILTIN\Administrators","FullControl","Allow")
    $Acl.SetAccessRule($Ar)
$AdjustTokenPrivileges = @"
using System;
using System.Runtime.InteropServices;
 public class TokenManipulator
 {
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
  [DllImport("kernel32.dll", ExactSpelling = true)]
  internal static extern IntPtr GetCurrentProcess();
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
  [DllImport("advapi32.dll", SetLastError = true)]
  internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct TokPriv1Luid{
   public int Count;
   public long Luid;
   public int Attr;
  }
  internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
  internal const int TOKEN_QUERY = 0x00000008;
  internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
  public static bool AddPrivilege(string privilege){
   try
   {
    bool retVal;
    TokPriv1Luid tp;
    IntPtr hproc = GetCurrentProcess();
    IntPtr htok = IntPtr.Zero;
    retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
    tp.Count = 1;
    tp.Luid = 0;
    tp.Attr = SE_PRIVILEGE_ENABLED;
    retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
    retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
    return retVal;
   }
   catch (Exception ex)
   {
    throw ex;
   }
  }
 }
"@
    add-type $AdjustTokenPrivileges
    [void][TokenManipulator]::AddPrivilege("SeRestorePrivilege") 
    [void][TokenManipulator]::AddPrivilege("SeBackupPrivilege") 
    [void][TokenManipulator]::AddPrivilege("SeTakeOwnershipPrivilege") 
    $NewOwnerACL = New-Object System.Security.AccessControl.DirectorySecurity
    $Admin = New-Object System.Security.Principal.NTAccount("BUILTIN\Administrators")
    $NewOwnerACL.SetOwner($Admin)


    # Change FOLDER owners to Admin
    $Folders = @(Get-ChildItem -Path $Global:targetFolder -Directory -Recurse | Select-Object -ExpandProperty FullName)
    foreach ($Item1 in $Folders) {
      $Folder = Get-Item $Item1
      $Folder.SetAccessControl($NewOwnerACL)
      # Add folder Admins to ACL with Full Control to descend folder structure
      Set-Acl $Item1 $Acl
    } 


    # prepare for files
    $Account = New-Object System.Security.Principal.NTAccount("BUILTIN\Administrators")
    $FileSecurity = new-object System.Security.AccessControl.FileSecurity
    $FileSecurity.SetOwner($Account)
    If (Test-Path C:\PFile) { Remove-Item C:\PFile }
    New-Item -type file -Path C:\PFile
    $PAcl = Get-Acl -Path C:\PFile
    $PAr = New-Object  system.security.accesscontrol.filesystemaccessrule("BUILTIN\Administrators","FullControl","Allow")
    $PAcl.SetAccessRule($PAr)


    # Change FILE owners to Admin
    $Files = @(Get-ChildItem -Path $Global:targetFolder -File -Recurse | Select-Object -ExpandProperty FullName)
    foreach ($Item2 in $Files){
      # Action
      [System.IO.File]::SetAccessControl($Item2, $FileSecurity)
      # Add file Admins to ACL with Full Control and activate inheritance
      Set-Acl $Item2 $PAcl
    }


    # Clean-up junk
    rm C:\PTemp
    rm C:\PFile

}

#fixPermissions meetod käib rekursiivselt kõik kaustad läbi ning kirjutab owneri Administraatorile ning annab Systemile ning Administrators grupile Full Control õigused
function fixPermissions(){
    #salvestame alamkaustad
    $users = get-childitem $Global:targetFolder
    #Administrators grupp
    $admin = "Administrators"

    Foreach ($user in $users) { #käime kõik juurkataloogis olevad kataloogid läbi
        try {

            $acl = Get-Acl $user.FullName #küsime praegused õigused
            Get-Acl $user.FullName
            $acl.SetAccessRuleProtection($false, $true) #keelame päriluse ning kustutame päritud objektid 
            Set-Acl -Path $user.FullName -AclObject $acl #salvestame hetkeseadistuse 

            $userPermission = New-Object system.security.accesscontrol.filesystemaccessrule("$user",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
            $acl.SetAccessRule($userPermission)
            set-acl $user.FullName $acl

            #seame omanikuks Administrators grupi
            $acl.SetOwner([System.Security.Principal.NTAccount]"$admin")
            set-acl $user.FullName $acl -Verbose 

            }
            Catch
            {
                echo Mingi error
            }

        
        
        #Seame administrators grupile omanikuõigused ka alamkaustadel
        $subFolders = Get-ChildItem $user.FullName -Directory -Recurse
        Foreach ($subFolder in $subFolders) {
            $acl = Get-Acl $subFolder.FullName
            $acl.SetOwner([System.Security.Principal.NTAccount]"$admin")
            set-acl $subFolder.FullName $acl -Verbose

        }

        #Seame administrators grupile omanikuõigused ka alamfailidel
        $subFiles = Get-ChildItem $user.FullName -File -Recurse
        Foreach ($subFile in $subFiles) {
            $acl = Get-Acl $subFile.FullName
            $acl.SetOwner([System.Security.Principal.NTAccount]"$admin")
            set-acl $subFile.FullName $acl -Verbose
        }
    }
}

#fixOwner funktsiooniga kirjutame õigused lõplikult paika, omanikuks jääb kasutaja ise kuid Administrators ja System grupil on rekursiivselt Full control õigused
function fixOwner(){
    #salvestame alamkaustad
    $users = get-childitem $Global:targetFolder

    Foreach ($user in $users) { #käime kõik kaustad läbi ning paneme paika omaniku
        try {
            $acl = Get-Acl $user.FullName
            Get-Acl $user.FullName  
            $acl.SetOwner([System.Security.Principal.NTAccount]"$user")
            set-acl $user.FullName $acl -Verbose

             }
            Catch
            {
                echo Mingi error
            }

            $muutus = $false
            foreach($rule in $acl.Access){
                if(-not $rule.IsInherited){
                    if($rule.IdentityReference -eq "BUILTIN\Administrators"){
                        $acl.RemoveAccessRule($rule)
                        $muutus = $true
                        }
                    }
                }
            #kui muutus on true (Ehk oleme tuvastanud mitte päritud õigusega objekti), siis eemaldame selle
            if($muutus){
                Set-Acl -Path $user.FullName -AclObject $acl
                }


        $subFolders = Get-ChildItem $user.FullName -Directory -Recurse
        Foreach ($subFolder in $subFolders) {
            $acl = Get-Acl $subFolder.FullName
            $acl.SetOwner([System.Security.Principal.NTAccount]"$user")
            set-acl $subFolder.FullName $acl -Verbose

            #kui tuvastame et kaustal on mittepäritud õigus, siis paneme $muutus true'ks
            
            }

        #käime läbi kõik alamfailid ja paneme omaniku paika
        $subFiles = Get-ChildItem $user.FullName -File -Recurse
        Foreach ($subFile in $subFiles) {
            $acl = Get-Acl $subFile.FullName
            $acl.SetOwner([System.Security.Principal.NTAccount]"$user")
            set-acl $subFile.FullName $acl -Verbose

            #kui tuvastame et failil on mittepäritud õigus, siis paneme $muutus true'ks
            $muutus = $false
            foreach($rule in $acl.Access){
                if(-not $rule.IsInherited){
                    $acl.RemoveAccessRule($rule)
                    $muutus = $true
                    }
                }

            #kui muutus on true (Ehk oleme tuvastanud mitte päritud õigusega objekti), siis eemaldame selle
            if($muutus){
                Set-Acl -Path $subFile.FullName -AclObject $acl
            }
        }
    }

}

allowAccess
fixPermissions
fixOwner