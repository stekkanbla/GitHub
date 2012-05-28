Function installSP ($VM, $HC ) {

$PW = ConvertTo-SecureString "ZheShiWO3" -AsPlainText -Force
$GC = New-Object System.Management.Automation.PSCredential ("administrator", $PW)

$installSP = "D:\Setup /config \\bach47edc2\47p\SetupFarmSilent\config.xml"
#Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $installSP

Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType PowerShell -ScriptText  $installSP -RunAsync
#'&"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "\\dc\47p\ps\SP\installSP2.ps1"'
}

$ESXHost = get-vm Bach47e.dc2 | Get-VMHost

### host credentials..eneste behov for interaksjon med bruker...promptes etter dette automatisk
$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials for $ESXHost", "toroveorcli", "")
###


$n = 4
$nMax = 4
while ($n -le $nMax) {
$VMname = "SharePoint$n"
Write-Host $VMname
installSP $VMname $HostCred
$n++
}