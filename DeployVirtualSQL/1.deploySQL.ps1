

### Legger til VMware.VimAutomation.Core snapin for tilgang på PowerCLI cmdlets ###
Add-PSSnapin VMware.VimAutomation.Core

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
$n = 1
$numberofmachines = 2
while ($n -le $numberofmachines) {
$name = "SQL$n"
Write-host $name
$Vmhost = "blad-06.virnett.aitel.hist.no"
Write-host $vmhost
$ResourcePool = "BACHELOR"
Write-host $ResourcePool
$location = "47E"
Write-host $location
$datastore = "QNAP-NFS"
Write-host $datastore
$osspec = "Bachelor47E.SQL2012Spec"
Write-host $osspec
$template = "sql2012Ready"
Write-host $template

### Kjører PowerCLI cmd for oppretting av virtuel maskin ### 
 New-VM -Name $name -VMHost $Vmhost  -ResourcePool $ResourcePool -Location $location -Datastore $datastore  -Template SharePointReady -RunAsync
#-OSCustomizationSpec $osspec
#Start-Sleep -Seconds 5
### Starter nylig opprettet VM ###
Get-VM $name | start-vm 
$n++
#Start-Sleep -Seconds 5
}

