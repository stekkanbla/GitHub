Import-Module ServerManager

$Addes = "net-framework", "failover-clustering"

foreach($Add in $Addes) {
Add-WindowsFeature $Add }