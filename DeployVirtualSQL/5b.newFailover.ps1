import-module failoverclusters

$mainNode = "SQL1"
$addonNode = "SQL2"
$clusterName = "sqlCluster1"
$clusterIP = "158.38.43.126"

#test-cluster -node $mainNode,$addonNode
new-cluster -Name $clusterName -Node $mainNode,$addonNode -staticAddress $clusterIP
