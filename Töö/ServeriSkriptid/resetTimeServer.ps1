function reConfigTimeServer{

    net stop w32time
    Start-Sleep -Seconds 1
    w32tm /config /syncfromflags:manual /manualpeerlist:"ntp.easa.ee"
    Start-Sleep -Seconds 1.5
    w32tm /config /reliable:yes
    Start-Sleep -Seconds 1.5
    net start w32time
    Start-Sleep -Seconds 1.5
    w32tm /config /update
    Start-Sleep -Seconds 1.5
    w32tm /query /configuration
    Start-Sleep -Seconds 1.5
    w32tm /resync

     }



reConfigTimeServer