function ühenda{

$target_ip = Read-Host -Prompt "Sisesta arvuti IP aadress"

for ($i=1; $i -le 10; $i++){
    mstsc /shadow:$i /v:$target_ip /noConsentPrompt /control /prompt

    }
}
ühenda