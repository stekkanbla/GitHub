## bortimot en kopi av 2.setSPip. så se der for dokumentasjon

Function Set-WinVMIP ($VM, $HC, $GC, $IP, $SNM, $GW, $SanIP){
 $netshIP = "c:\windows\system32\netsh.exe interface ip set address ""Local Area Connection"" static $IP $SNM $GW 1"
 $netshIPSan = "c:\windows\system32\netsh.exe interface ip set address ""Local Area Connection 2"" static $SanIP $SNM"
 Write-Host "Setting IP address for $VM..."
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $netshIP -ErrorAction SilentlyContinue
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $netshIPSan -ErrorAction SilentlyContinue
 Write-Host "Setting IP address completed."
 
  
 $netshDNS1 = "c:\windows\system32\netsh.exe interface ip set dns ""Local Area Connection"" static 158.38.43.125"
 $netshDNS2 = "c:\windows\system32\netsh.exe interface ip add dns ""Local Area Connection"" 158.38.49.10 index=2"
 Write-Host "Setting DNS"
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $netshDNS1 -ErrorAction SilentlyContinue
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $netshDNS2 -ErrorAction SilentlyContinue
 
 Write-Host "Setting DNS completed"
 
 ##logger IP til fila "ipliste.txt"
 $vmobj = Get-VM $vm
 $IP = $vmobj.guest.ipAddress 
 $vmobj.name+"    "+ $vmobj.guest.ipAddress | Out-File .\ipliste.txt -Append
 }
  
 Function Join-Domain ($DCcred, $VM, $HC, $GC ) {
 $domain = "47p.aitel.hist.no"
 $shortDomain ="47p"
 $user = $shortDomain+"\administrator"
 $joinDomain = "add-computer -domainName $domain -credential $DCcred"
 Write-Host "Joiner domenet: $domain"
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType PowerShell -ScriptText '&"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "Set-ExecutionPolicy bypass -force "' 
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType PowerShell -ScriptText '&"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "\\158.38.43.125\47p\ps\autoJoinDomain.ps1"' 
}


$ESXHost = get-vm Bach47e.dc2 | Get-VMHost

### host credentials..eneste behov for interaksjon med bruker...promptes etter dette automatisk
$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials for $ESXHost", "toroveorcli", "")
###

###først oppgir vi passord for administrator og konverterer til securestring // fungerer ikke som ventet
$PW = ConvertTo-SecureString "ZheShiWO3" -AsPlainText -Force
#så bruker vi passordet for å opprette et objekt for creds
#$GuestCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter Guest credentials for $VM", "administrator", "")
$GuestCred = New-Object System.Management.Automation.PSCredential ("administrator", $PW)
###end
	
$dcpw = ConvertTo-SecureString "ZheShiWO3" -AsPlainText -Force
##### DC cred (litt shaky i klartekst
$DCcred = New-Object System.Management.Automation.PSCredential ("47p\administrator", $DCpw)

### starter med maskin 1
$n = 1
# sett høyeste nummer her
$nmax = 2
###

### IP calc
# legger til $n på $IPstart (forutsetter at vi har en vedvarende range for alle maskinene
# bruker her 158.38.57.
# .226-228, så må trekke fra 1 (siden $n starter på 1)
$IPStart = 225
$SanIPstart = 240
###


while ($n -le $nmax)
{
	
	$IPcurrent = $IPStart+$n
	$VM = "SQL$n"
	$ESXHost = get-vm $vm | Get-VMHost

	$IP = "158.38.57.$IPcurrent"
	$SNM = "255.255.255.0"
	$GW = "158.38.43.1"

	$SanIPCurrent = $SanIPstart+$n
	$SanIP = "172.16.101.$SanIPcurrent"
### bruker samme nettmaske som $SNM

#Set-WinVMIP $VM $HostCred $GuestCred $IP $SNM $GW $SanIP
Join-Domain $DCcred $VM $HostCred $GuestCred
#Get-VM "SQL$n" | Restart-VMGuest
$n++
} #end while