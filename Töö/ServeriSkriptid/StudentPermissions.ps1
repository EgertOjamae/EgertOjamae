#skritp mõeldud õpilaste kausta õiguste paika panemiseks. Kaust sisaldab õpilase enda kaustasid (eesnimi.perekonnanimi). Skript annab igale õpilasele oma kaustale Full Control.
function addPermissions(){

    #salvestame alamkaustad
    $users = get-childitem "P:\public\Õpilased\2022" #täpsusta kaust 


    Foreach ($user in $users) { #käime kõik juurkataloogis olevad kataloogid läbi
     
            $permissionGroup = New-Object system.security.accesscontrol.filesystemaccessrule($user,"FullControl",”ContainerInherit,ObjectInherit”,”None”,”Allow”)
            $acl = Get-Acl $user.FullName #küsime praegused õigused
            Get-Acl $user.FullName
            Set-Acl -Path $user.FullName -AclObject $acl #salvestame hetkeseadistuse 
            

            #Anname õigused permissionGroup grupile või kasutajale
            $acl.SetAccessRule($permissionGroup)
            set-acl $user.FullName $acl -Verbose
  

        }

}


addPermissions
