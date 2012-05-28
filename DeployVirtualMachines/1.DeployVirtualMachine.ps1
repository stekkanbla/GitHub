### Legger til VMware.VimAutomation.Core snapin for tilgang på PowerCLI cmdlets ###
#Add-PSSnapin VMware.VimAutomation.Core

### Henter loggin fra cred.xml for automatisk innloggin på vc-fag.studvir.aitel.hist. Passord hashed ###
### Før du benytter denne metoden må du kjøre et script som lager XML-fila. Se under ###
### New-VICredentialStoreItem -Host vc-fag.studvir.aitel.hist.no -User Administrator -Password "superduperpassword" -File "C:\whateverfolder\whatevername.xml" ###
### Etter at du har kjørt script overfor vil det lages en XML-fil med brukernavn og hashed passord. Slett deretter scriptet med passord i klartekst ###
### Brukes ikke for ESX senere i scriptet siden host må være med og dette vet en ikke før lengre ut i scriptet, kan ordnes med if ###

### Kobler til vCenter ###
$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials for $ESXHost", "toroveorcli", "")
Connect-VIServer -Server vc-fag.studvir.aitel.hist.no -Credential $HostCred
#Get-Template -Name SharePointReady
#Get-OSCustomizationSpec -id Bachelor47E.Template.Win2k8R2x64
#New-vm -Name "MinVM" -VMHost "blad-06.virnett.aitel.hist.no" -ResourcePool "BACHELOR" -Location "47E" -DiskStorageFormat Thin -Datastore "QNAP-NFS"  -Template "W2k8R2.x64.template.47E"


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
## det blir mye venting mellom disse loopene, muligens best å splitte dem

while ($m -le $mmax) {
### Starter nylig opprettet VM ###
$name = "SharePoint$m"
Get-VM $name | start-vm 
$m++
#Start-Sleep -Seconds 5
}