##.\SetSPip.ps1

############## basert på http://www.virtu-al.net/2010/02/05/powercli-changing-a-vm-ip-address-with-invoke-vmscript/#viewSource 
### skriptet generer endel feilmeldinger, men det fungerer likevel som forventet på Guesten UPDATE: Løst ved -ErrorAction SilentlyContinue
### det tar ca 2min å sette Ip og dns per maskin

## DEL 1
## skript for å sette IP på sharepoint-vmer fra powercli
## funker best hvis alle maskiner er på samme range 
## sett $ipStart til en mindre enn egentlig start siden vi legger til $n(nummer på installasjon) på $ipStart
## forutsetter at NICet kalles "Local Area Connection"
## oppretter selve funksjonen som er av typen netsh
## variabler defineres lenger ned

### DEL 2  omhandler innmelding 
## du må oppgi konto/pw for ESX-admin  og for  guest (administrator/ZheShiWO3) skal kunne automatisere det siste


## Variabler som krever tilpasning:
## DNS1 må forandres hvis DC har en annen IP enn oppgitte 158.38.43.125
## $n og $nmax
## $ipstart
## $domain og $shortdomain


#Connect-VIServer -Server vc-fag.studvir.aitel.hist.no


Function Set-WinVMIP ($VM, $HC, $GC, $IP, $SNM, $GW){
 $netshIP = "c:\windows\system32\netsh.exe interface ip set address ""Local Area Connection"" static $IP $SNM $GW 1"
 Write-Host "Setting IP address for $VM..."
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $netshIP -ErrorAction SilentlyContinue
 Write-Host "Setting IP address completed."
 
 
 $netshDNS1 = "c:\windows\system32\netsh.exe interface ip set dns ""Local Area Connection"" static 158.38.43.125"
 $netshDNS2 = "c:\windows\system32\netsh.exe interface ip add dns ""Local Area Connection"" 158.38.49.10 index=2"
 Write-Host "Setting DNS"
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $netshDNS1 -ErrorAction SilentlyContinue
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $netshDNS2 -ErrorAction SilentlyContinue
 
 Write-Host "Setting DNS completed"
 
 ##logger VM-navn og IP til fila "ipliste.txt"
 $vmobj = Get-VM $vm
 $IP = $vmobj.guest.ipAddress 
 $vmobj.name+"    "+ $vmobj.guest.ipAddress | Out-File .\ipliste.txt -Append
 

}
 
 
 Function Join-Domain ($VM, $HC, $GC ) {

 $domain = "47p.aitel.hist.no"
 $shortDomain ="47p"
 $user = $shortDomain+"\administrator"
  ## netdom-cmd
 $joinDomain = "netdom join $VM /domain:47p.aitel.hist.no /reboot:1 " 
 Write-Host $joinDomain
 Write-Host "Joiner domenet: $domain"
  Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat  -ScriptText $joinDomain



 
}

#Connect-VIServer vc-fag.studvir.aitel.hist.no
## dette må forandres ved behov .. oppgir her domenekontroller, siden den vites å befinner seg på samme host som de kommende SharePoint-installasjonene
$ESXHost = get-vm Bach47e.dc2 | Get-VMHost

### host credentials..eneste behov for interaksjon med bruker...promptes etter dette automatisk
$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials for $ESXHost", "toroveorcli", "")
###

###først oppgir vi passord for administrator og konverterer til securestring // fungerer ikke som ventet
$PW = ConvertTo-SecureString "ZheShiWO3" -AsPlainText -Force
#så bruker vi passordet for å opprette et objekt for creds
# alternativ linje hvis du manuelt vil oppgi passord
#$GuestCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter Guest credentials for $VM", "administrator", "")
$GuestCred = New-Object System.Management.Automation.PSCredential ("administrator", $PW)
###end

	
## denne delen trengs ikke når man kjører netdom.. var brukt for powershell-varianten
$dcpw = ConvertTo-SecureString "ZheShiWO3" -AsPlainText -Force
##### DC cred (litt shaky i klartekst
$DCcred = New-Object System.Management.Automation.PSCredential ("47p\administrator", $DCpw)

### starter med maskin 1
$n = 1
$nmax = 5
###

### IP calc
# legger til $n på $IPstart (forutsetter at vi har en vedvarende range for alle maskinene
# bruker her 158.38.57.
# .143-147, så må trekke fra 1 (siden $n starter på 1)
$IPStart = 142
###


while ($n -le $nmax)
{
	
	$IPcurrent = $IPStart+$n
	$VM = "SharePoint$n"
	$ESXHost = get-vm $vm | Get-VMHost

	#$IP = "158.38.57.$IPcurrent"
	$SNM = "255.255.255.0"
	$GW = "158.38.43.1"

Set-WinVMIP $VM $HostCred $GuestCred $IP $SNM $GW
Join-Domain $VM $HostCred $GuestCred

$n++
} #end while








