﻿### .\4.installSP

### OPTIONAL bør vurdere å  gi hver student ansvar for å gjøre  skriptets formål manuelt 
### installerer grunninstallasjonen med Central Administration av farmen.
## tilkobling til database er neste steg og bør gjøres manuelt
## kjører setup fra CD-drev (her D:\Setup.exe med en ferdigkonfigurert config.xml som kjører i gang en silentInstall
### vil ta rundt 15 minutter å fullføre.

Function installSP ($VM, $HC ) {

$PW = ConvertTo-SecureString "ZheShiWO3" -AsPlainText -Force
$GC = New-Object System.Management.Automation.PSCredential ("administrator", $PW)

$installSP = "D:\Setup /config \\bach47edc2\47p\SetupFarmSilent\config.xml"


Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType PowerShell -ScriptText  $installSP -RunAsync

}

$ESXHost = get-vm Bach47e.dc2 | Get-VMHost

### host credentials..eneste behov for interaksjon med bruker...promptes etter dette automatisk
$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials for $ESXHost", "toroveorcli", "")
###


$n = 1
$nMax = 5
while ($n -le $nMax) {
$VMname = "SharePoint$n"
Write-Host $VMname
installSP $VMname $HostCred
$n++
}