## .\3.addAdmin.ps1

Function addToAdmins ($VM, $HC, $UN ) {

$PW = ConvertTo-SecureString "ZheShiWO3" -AsPlainText -Force
$GC = New-Object System.Management.Automation.PSCredential ("administrator", $PW)

$addToAdmin = "net localgroup ""Administrators"" $UN  /add "
Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $addToAdmin 

#$installSP = "D:\Setup /config \\bach47edc2\47p\SetupFarmSilent\config.xml"
#Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $installSP
}
$VM = "SharePoint1"
$ESXHost = get-vm Bach47e.dc2 | Get-VMHost

### host credentials..eneste behov for interaksjon med bruker...promptes etter dette automatisk
$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials for $ESXHost", "toroveorcli", "")
###

###først oppgir vi passord for administrator og konverterer til securestring // fungerer ikke som ventet
#$PW = ConvertTo-SecureString "ZheShiWO3" -AsPlainText -Force
#så bruker vi passordet for å opprette et objekt for creds
#$GuestCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter Guest credentials for $VM", "administrator", "")
#$GuestCred = New-Object System.Management.Automation.PSCredential ("administrator", $PW)
###end

$n = 1
$nMax = 5
while ($n -le $nMax) {
$VMname = "SharePoint$n"
$UserName = "Bruker"+$n+"_login"
Write-Host $userName
Write-Host $VMname
addToAdmins $VMname $HostCred $UserName
$n++
}