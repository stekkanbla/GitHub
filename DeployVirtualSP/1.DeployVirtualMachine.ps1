### .\1.DeplyVirtualMachine
## Variabler som krever tilpasning:
#$n og $nmax

### å opprette 5 maskiner simultant tar ca 30min bare for oppretting, legg til minst 15 minutter mens de kjører Specification-konfigurasjon.
# totalt bør det påberegnes en time før man kan gå til neste steg.

### Legger til VMware.VimAutomation.Core snapin for tilgang på PowerCLI cmdlets ###
Add-PSSnapin VMware.VimAutomation.Core



### Kobler til vCenter ###
$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials for $ESXHost", "toroveorcli", "")
Connect-VIServer -Server vc-fag.studvir.aitel.hist.no -Credential $HostCred



##oppretter to looper for at maskinene skal lages kjappere
#  Hvis du vil opprette maskiner 1-5, skal $n=1 og $nMax=5
$n = 1
$nmax = 5

$m = $n ## skal brukes i start-vm-loopen
$mmax =$nmax ## skal brukes i start-vm-loopen
while ($n -le $nmax) {
$name = "SharePoint$n"
Write-host $name
$Vmhost = "blad-06.virnett.aitel.hist.no"
Write-host $vmhost
$ResourcePool = "BACHELOR"
Write-host $ResourcePool
$location = "47E"
Write-host $location
$datastore = "QNAP-NFS"
Write-host $datastore
$osspec = "Bachelor47E.Template.Win2k8R2x64"
Write-host $osspec
$template = "SharePointReady"
Write-host $template

### Kjører PowerCLI cmd for oppretting av virtuel maskin ### 
 New-VM -Name $name -VMHost $Vmhost  -ResourcePool $ResourcePool -Location $location -Datastore $datastore -OSCustomizationSpec $osspec -Template SharePointReady -RunAsync
$n++
}
## det blir mye venting mellom disse loopene, derfor har jeg funnet det best å splitte dem heller enn å kjøre alt i en loop

while ($m -le $mmax) {
### Starter nylig opprettet VM ###
$name = "SharePoint$m"
Get-VM $name | start-vm 
$m++

}