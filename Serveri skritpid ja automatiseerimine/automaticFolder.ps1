$Global:variableAdmin = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
$Global:variableSystem = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
$Global:variableEveryoneReadNotRecursive = New-Object system.security.accesscontrol.filesystemaccessrule("Everyone",”ReadAndExecute”,”Allow”)
$Global:variableEveryoneReadRecursive = New-Object system.security.accesscontrol.filesystemaccessrule("Everyone",”ReadAndExecute”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)

function arhiiviFunktsioon(){

    #defineerime kausta asukoha 
    $arhiiviAsukoht = "A:\archive"

    #keelame p2riluse ning eemaldame p2ritud objektid (yhtegi 6igust siia ei j22)
    $acl = Get-Acl -Path $arhiiviAsukoht
    $acl.SetAccessRuleProtection($true, $false)
    Set-Acl -Path $arhiiviAsukoht -AclObject $acl
    
    #Anname juurkaustale Administrators grupile Full control 6igused, mis on rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableAdmin)  
    Set-Acl $arhiiviAsukoht $acl

    #Anname SYSTEM objektile samad 6igused samuti rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableSystem) 
    Set-Acl $arhiiviAsukoht $acl

    #Anname grupile Everyone Lugemis ja kirjutamise 6igused, kehtivad ainult juurkaustale (ei p2rine allapoole)    
    $acl.SetAccessRule($Global:variableEveryoneReadNotRecursive) 
    Set-Acl $arhiiviAsukoht $acl

    #Jagame kausta v2lja, andes 6igused ainult Everyone grupile (read 6igus)
    New-SMBShare –Name archive `
             –Path $arhiiviAsukoht `
             -ReadAccess Everyone


    #Teeme uue kausta 'backups' ning anname samad 6igused nagu archive kaustal
    New-Item -ItemType Directory -Path 'A:\backups'
    $aclArhiiv = Get-Acl -Path $arhiiviAsukoht
    Set-Acl -AclObject $acl -Path 'A:\backups'

    #Jagame backups kausta v2lja, andes fullaccess 6igused grupile everyone
    New-SMBShare –Name backups `
             –Path 'A:\backups' `
             -FullAccess Everyone

    ##################
    #Erinevate kaustade loomine ning nendele 6iguste andmine

    New-Item -ItemType Directory -Path $arhiiviAsukoht\media
    $aclMedia = Get-Acl -Path $arhiiviAsukoht\media
    $aclMedia.SetAccessRule($Global:variableEveryoneReadRecursive) 
    Set-Acl $arhiiviAsukoht\media $aclMedia


    New-Item -ItemType Directory -Path $arhiiviAsukoht\public
    $aclPublic = Get-Acl -Path $arhiiviAsukoht\public
    $aclPublic.SetAccessRule($Global:variableEveryoneReadNotRecursive)
    Set-Acl $arhiiviAsukoht\public $aclPublic


    New-Item -ItemType Directory -Path $arhiiviAsukoht\users
    $aclUsers = Get-Acl -Path $arhiiviAsukoht\users
    $aclUsers.SetAccessRule($Global:variableEveryoneReadNotRecursive)
    Set-Acl $arhiiviAsukoht\users $aclUsers

    ##################

}


function installFunktsioon(){

    #defineerime kausta asukoha 
    $gpoAsukoht = "I:\GPO"
    $installAsukoht = "I:\install"
    $installServerAsukoht = "I:\install-server"

    #keelame p2riluse ning eemaldame p2ritud objektid (yhtegi 6igust siia ei j22)
    $acl = Get-Acl -Path $gpoAsukoht
    $acl.SetAccessRuleProtection($true, $false)
    Set-Acl -Path $gpoAsukoht -AclObject $acl

    ##################
    #GPO kausta 6igused

    #Anname juurkaustale Administrators grupile Full control 6igused, mis on rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableAdmin) 
    Set-Acl $gpoAsukoht $acl

    #Anname SYSTEM objektile samad 6igused samuti rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableSystem) 
    Set-Acl $gpoAsukoht $acl

    ##################




    ##################
    #install kausta 6igused

    Set-Acl $installAsukoht $acl
    Set-Acl $installAsukoht $acl

    ##################


    #Jagame install kausta v2lja, andes fullaccess 6igused grupile Administrators
    New-SMBShare –Name install$ `
             –Path 'I:\install' `
             -FullAccess Administrators #siia vaja lisada domeen

    
    ##################
    #install-server kausta 6igused

    Set-Acl $installServerAsukoht $acl
    Set-Acl $installServerAsukoht $acl

    ##################
}





function mediaFunktsioon(){

    #defineerime kausta asukoha 
    $mediaAsukoht = "M:\media"

    #keelame p2riluse ning eemaldame p2ritud objektid (yhtegi 6igust siia ei j22)
    $acl = Get-Acl -Path $mediaAsukoht
    $acl.SetAccessRuleProtection($true, $false)
    Set-Acl -Path $mediaAsukoht -AclObject $acl


    #Anname juurkaustale Administrators grupile Full control 6igused, mis on rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableAdmin) 
    Set-Acl $mediaAsukoht $acl

    #Anname SYSTEM objektile samad 6igused samuti rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableSystem) 
    Set-Acl $mediaAsukoht $acl

    #Anname grupile Everyone Lugemis ja kirjutamise 6igused samuti rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableEveryoneReadRecursive) 
    Set-Acl $mediaAsukoht $acl

    #Anname grupile media full control 6igused samuti rekursiivselt p2ritavad
    $permissionsMedia = New-Object system.security.accesscontrol.filesystemaccessrule('media',”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $aclMediaAudio = Get-Acl -Path $mediaAsukoht\Audio\2021
    $aclMediaAudio.SetAccessRule($permissionsMedia) 
    Set-Acl $mediaAsukoht\Audio\2021 $aclMediaAudio

    $aclMediaPildid = Get-Acl -Path $mediaAsukoht\Pildid\2021
    $aclMediaPildid.SetAccessRule($permissionsMedia) 
    Set-Acl $mediaAsukoht\Pildid\2021 $aclMediaPildid

    $aclMediaVideod = Get-Acl -Path $mediaAsukoht\Videod\2021
    $aclMediaVideod.SetAccessRule($permissionsMedia)
    Set-Acl $mediaAsukoht\Videod\2021 $aclMediaVideod



    #Jagame media kausta v2lja, andes fullaccess 6igused grupile everyone
    New-SMBShare –Name media `
             –Path 'M:\media' `
             -FullAccess Everyone

    
}



function publicFunktsioon(){

    #defineerime kausta asukoha 
    $publicAsukoht = "P:\public"

    #keelame p2riluse ning eemaldame p2ritud objektid (yhtegi 6igust siia ei j22)
    $acl = Get-Acl -Path $publicAsukoht
    $acl.SetAccessRuleProtection($true, $false)
    Set-Acl -Path $publicAsukoht -AclObject $acl


    #Anname juurkaustale Administrators grupile Full control 6igused, mis on rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableAdmin) 
    Set-Acl $publicAsukoht $acl

    #Anname SYSTEM objektile samad 6igused samuti rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableSystem) 
    Set-Acl $publicAsukoht $acl

    #Anname grupile Everyone Lugemis ja kirjutamise 6igused, kehtivad ainult juurkaustale (ei p2rine allapoole)
    $acl.SetAccessRule($Global:variableEveryoneReadNotRecursive) 
    Set-Acl $publicAsukoht $acl

    #Jagame public kausta v2lja, andes fullaccess 6igused grupile everyone
    New-SMBShare –Name public `
             –Path 'P:\public' `
             -FullAccess Everyone


    #Anname Direktorite kaustale Full control 6igused, mis on rekursiivselt p2ritavad
    $aclDirektor = Get-Acl -Path $publicAsukoht\Direktsioon
    $permissionsDirektor = New-Object system.security.accesscontrol.filesystemaccessrule("directorate",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”) #siia vaja lisada domeen
    $aclDirektor.SetAccessRule($permissionsDirektor) 
    Set-Acl $publicAsukoht\Direktsioon $aclDirektor

    #Anname lasteaia kaustale Full control 6igused, mis on rekursiivselt p2ritavad
    $aclLasteaed = Get-Acl -Path $publicAsukoht\Lasteaed
    $permissionsLasteaed = New-Object system.security.accesscontrol.filesystemaccessrule("kindergarten",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”) #siia vaja lisada domeen
    $aclLasteaed.SetAccessRule($permissionsLasteaed) 
    Set-Acl $publicAsukoht\Lasteaed $aclLasteaed

    #Anname opetajate kaustale Full control 6igused, mis on rekursiivselt p2ritavad
    $aclopetajad = Get-Acl -Path $publicAsukoht\Õpetajad
    $permissionsÕpetajad = New-Object system.security.accesscontrol.filesystemaccessrule("teachers",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”) #siia vaja lisada domeen
    $aclopetajad.SetAccessRule($permissionsÕpetajad) 
    Set-Acl $publicAsukoht\Õpetajad $aclopetajad

    #Anname grupile teachers Lugemis ja kirjutamise 6igused, kehtivad ainult juurkaustale (ei p2rine allapoole)
    $aclopilased = Get-Acl -Path $publicAsukoht\Õpilased
    $permissionsOpetajadReadWrite = New-Object system.security.accesscontrol.filesystemaccessrule("teachers",”ReadAndExecute”,”Allow”)
    $aclopilased.SetAccessRule($permissionsOpetajadReadWrite) 
    Set-Acl $publicAsukoht\Õpilased $aclopilased

    #Anname grupile students Lugemis ja kirjutamise 6igused, kehtivad ainult juurkaustale (ei p2rine allapoole)
    $aclopilasedGrupp = Get-Acl -Path $publicAsukoht\Õpilased
    $permissionsOpilasedReadWrite = New-Object system.security.accesscontrol.filesystemaccessrule("students",”ReadAndExecute”,”Allow”)
    $aclopilasedGrupp.SetAccessRule($permissionsOpilasedReadWrite) 
    Set-Acl $publicAsukoht\Õpilased $aclopilasedGrupp


    ################## 2013 - 2021 kaustad

    $acl2013 = Get-Acl -Path $publicAsukoht\Õpilased\2013
    $permissionsÕpetajadCustom = New-Object system.security.accesscontrol.filesystemaccessrule("teachers",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2013.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2013 $acl2013


    $acl2014 = Get-Acl -Path $publicAsukoht\Õpilased\2014
    $acl2014.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2014 $acl2014

    $acl2015 = Get-Acl -Path $publicAsukoht\Õpilased\2015
    $acl2015.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2015 $acl2015

    $acl2016 = Get-Acl -Path $publicAsukoht\Õpilased\2016
    $acl2016.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2016 $acl2016

    $acl2016 = Get-Acl -Path $publicAsukoht\Õpilased\2016
    $acl2016.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2016 $acl2016

    $acl2017 = Get-Acl -Path $publicAsukoht\Õpilased\2017
    $acl2017.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2017 $acl2017

    $acl2018 = Get-Acl -Path $publicAsukoht\Õpilased\2018
    $acl2018.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2018 $acl2018

    $acl2019 = Get-Acl -Path $publicAsukoht\Õpilased\2019
    $acl2019.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2019 $acl2019

    $acl2020 = Get-Acl -Path $publicAsukoht\Õpilased\2020
    $acl2020.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2020 $acl2020

    $acl2021 = Get-Acl -Path $publicAsukoht\Õpilased\2021
    $acl2021.SetAccessRule($permissionsÕpetajadCustom)
    Set-Acl $publicAsukoht\Õpilased\2021 $acl2021


    $permissionsÕpilased2013 = New-Object system.security.accesscontrol.filesystemaccessrule("students2013",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2013.SetAccessRule($permissionsÕpilased2013)
    Set-Acl $publicAsukoht\Õpilased\2013 $acl2013

    $permissionsÕpilased2014 = New-Object system.security.accesscontrol.filesystemaccessrule("students2014",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2014.SetAccessRule($permissionsÕpilased2014)
    Set-Acl $publicAsukoht\Õpilased\2014 $acl2014

    $permissionsÕpilased2015 = New-Object system.security.accesscontrol.filesystemaccessrule("students2015",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2015.SetAccessRule($permissionsÕpilased2015)
    Set-Acl $publicAsukoht\Õpilased\2015 $acl2015

    $permissionsÕpilased2016 = New-Object system.security.accesscontrol.filesystemaccessrule("students2016",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2016.SetAccessRule($permissionsÕpilased2016)
    Set-Acl $publicAsukoht\Õpilased\2016 $acl2016

    $permissionsÕpilased2017 = New-Object system.security.accesscontrol.filesystemaccessrule("students2017",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2017.SetAccessRule($permissionsÕpilased2017)
    Set-Acl $publicAsukoht\Õpilased\2017 $acl2017

    $permissionsÕpilased2018 = New-Object system.security.accesscontrol.filesystemaccessrule("students2018",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2018.SetAccessRule($permissionsÕpilased2018)
    Set-Acl $publicAsukoht\Õpilased\2018 $acl2018

    $permissionsÕpilased2019 = New-Object system.security.accesscontrol.filesystemaccessrule("students2019",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2019.SetAccessRule($permissionsÕpilased2019)
    Set-Acl $publicAsukoht\Õpilased\2019 $acl2019

    $permissionsÕpilased2020 = New-Object system.security.accesscontrol.filesystemaccessrule("students2020",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2020.SetAccessRule($permissionsÕpilased2020)
    Set-Acl $publicAsukoht\Õpilased\2020 $acl2020

    $permissionsÕpilased2021 = New-Object system.security.accesscontrol.filesystemaccessrule("students2021",”FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow”)
    $acl2021.SetAccessRule($permissionsÕpilased2021)
    Set-Acl $publicAsukoht\Õpilased\2021 $acl2021


    

    ##################

}


function userFunktsioon(){

    #defineerime kausta asukoha 
    $accountsAsukoht = "U:\accounts"
    $profilesAsukoht = "U:\profiles"

    #keelame p2riluse ning eemaldame p2ritud objektid (yhtegi 6igust siia ei j22)
    $acl = Get-Acl -Path $accountsAsukoht
    $acl.SetAccessRuleProtection($true, $false)
    Set-Acl -Path $accountsAsukoht -AclObject $acl


    #Anname juurkaustale Administrators grupile Full control 6igused, mis on rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableAdmin) 
    Set-Acl $accountsAsukoht $acl

    #Anname SYSTEM objektile samad 6igused samuti rekursiivselt p2ritavad
    $acl.SetAccessRule($Global:variableSystem) 
    Set-Acl $accountsAsukoht $acl

    #Anname grupile Everyone Lugemis ja kirjutamise 6igused, kehtivad ainult juurkaustale (ei p2rine allapoole)
    $acl.SetAccessRule($Global:variableEveryoneReadNotRecursive) 
    Set-Acl $accountsAsukoht $acl

    #Jagame accounts kausta v2lja, andes fullaccess 6igused grupile everyone
    New-SMBShare –Name accounts$ `
             –Path 'U:\accounts' `
             -FullAccess Everyone


    #Anname grupile students Lugemis ja kirjutamise 6igused, kehtivad ainult juurkaustale (ei p2rine allapoole)
    $aclStudents = Get-Acl -Path $accountsAsukoht\students
    $permissionsStudents = New-Object system.security.accesscontrol.filesystemaccessrule("students",”ReadAndExecute”,”Allow”)
    $aclStudents.SetAccessRule($permissionsStudents) 
    Set-Acl $accountsAsukoht\students $aclStudents



    $acl2013 = Get-Acl -Path $accountsAsukoht\students\2013
    $permissionsÕpilased2013 = New-Object system.security.accesscontrol.filesystemaccessrule("students2013",”ReadAndExecute”,”Allow”)
    $acl2013.SetAccessRule($permissionsÕpilased2013)
    Set-Acl $accountsAsukoht\students\2013 $acl2013

    $acl2014 = Get-Acl -Path $accountsAsukoht\students\2014
    $permissionsÕpilased2014 = New-Object system.security.accesscontrol.filesystemaccessrule("students2014",”ReadAndExecute”,”Allow”)
    $acl2014.SetAccessRule($permissionsÕpilased2014)
    Set-Acl $accountsAsukoht\students\2014 $acl2014

    $acl2015 = Get-Acl -Path $accountsAsukoht\students\2015
    $permissionsÕpilased2015 = New-Object system.security.accesscontrol.filesystemaccessrule("students2015",”ReadAndExecute”,”Allow”)
    $acl2015.SetAccessRule($permissionsÕpilased2015)
    Set-Acl $accountsAsukoht\students\2015 $acl2015

    $acl2016 = Get-Acl -Path $accountsAsukoht\students\2016
    $permissionsÕpilased2016 = New-Object system.security.accesscontrol.filesystemaccessrule("students2016",”ReadAndExecute”,”Allow”)
    $acl2016.SetAccessRule($permissionsÕpilased2016)
    Set-Acl $accountsAsukoht\students\2016 $acl2016

    $acl2017 = Get-Acl -Path $accountsAsukoht\students\2017
    $permissionsÕpilased2017 = New-Object system.security.accesscontrol.filesystemaccessrule("students2017",”ReadAndExecute”,”Allow”)
    $acl2017.SetAccessRule($permissionsÕpilased2017)
    Set-Acl $accountsAsukoht\students\2017 $acl2017

    $acl2018 = Get-Acl -Path $accountsAsukoht\students\2018
    $permissionsÕpilased2018 = New-Object system.security.accesscontrol.filesystemaccessrule("students2018",”ReadAndExecute”,”Allow”)
    $acl2018.SetAccessRule($permissionsÕpilased2018)
    Set-Acl $accountsAsukoht\students\2018 $acl2018

    $acl2019 = Get-Acl -Path $accountsAsukoht\students\2019
    $permissionsÕpilased2019 = New-Object system.security.accesscontrol.filesystemaccessrule("students2019",”ReadAndExecute”,”Allow”)
    $acl2019.SetAccessRule($permissionsÕpilased2019)
    Set-Acl $accountsAsukoht\students\2019 $acl2019

    $acl2020 = Get-Acl -Path $accountsAsukoht\students\2020
    $permissionsÕpilased2020 = New-Object system.security.accesscontrol.filesystemaccessrule("students2020",”ReadAndExecute”,”Allow”)
    $acl2020.SetAccessRule($permissionsÕpilased2020)
    Set-Acl $accountsAsukoht\students\2020 $acl2020

    $acl2021 = Get-Acl -Path $accountsAsukoht\students\2021
    $permissionsÕpilased2021 = New-Object system.security.accesscontrol.filesystemaccessrule("students2021",”ReadAndExecute”,”Allow”)
    $acl2021.SetAccessRule($permissionsÕpilased2021)
    Set-Acl $accountsAsukoht\students\2021 $acl2021


    #Anname grupile Everyone Lugemis ja kirjutamise 6igused, kehtivad ainult juurkaustale (ei p2rine allapoole)
    $aclWorkers = Get-Acl -Path $accountsAsukoht\workers
    $permissionsWorkers = New-Object system.security.accesscontrol.filesystemaccessrule("workers",”ReadAndExecute”,”Allow”)
    $aclWorkers.SetAccessRule($permissionsWorkers) 
    Set-Acl $accountsAsukoht\workers $aclWorkers

    
    #keelame p2riluse ning eemaldame p2ritud objektid (yhtegi 6igust siia ei j22)
    $aclProfiles = Get-Acl -Path $profilesAsukoht
    $aclProfiles.SetAccessRuleProtection($true, $false)
    Set-Acl -Path $profilesAsukoht -AclObject $aclProfiles

    #Jagame accounts kausta v2lja, andes fullaccess 6igused grupile everyone
    New-SMBShare –Name profiles$ `
             –Path 'U:\profiles' `
             -FullAccess Everyone

    #Anname juurkaustale Administrators grupile Full control 6igused, mis on rekursiivselt p2ritavad
    $aclProfiles.SetAccessRule($Global:variableAdmin) 
    Set-Acl $profilesAsukoht $aclProfiles

    #Anname SYSTEM objektile samad 6igused samuti rekursiivselt p2ritavad
    $aclProfiles.SetAccessRule($Global:variableSystem) 
    Set-Acl $profilesAsukoht $aclProfiles

    #Anname CREATOR OWNER objektile samad 6igused samuti rekursiivselt p2ritavad
    $permissionsCreatorOwner = New-Object system.security.accesscontrol.filesystemaccessrule("CREATOR OWNER","FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $aclProfiles.SetAccessRule($permissionsCreatorOwner) 
    Set-Acl $profilesAsukoht $aclProfiles

    #Anname CREATOR OWNER objektile samad 6igused samuti rekursiivselt p2ritavad
    $permissionsDomainUsers = New-Object system.security.accesscontrol.filesystemaccessrule("Domain users","ReadData, AppendData", "Allow")
    $aclProfiles.SetAccessRule($permissionsDomainUsers) 
    Set-Acl $profilesAsukoht $aclProfiles


}

arhiiviFunktsioon
installFunktsioon
mediaFunktsioon
publicFunktsioon
userFunktsioon