import-module failoverclusters

$mainNode = "SQL1"
$addonNode = "SQL2"

test-cluster -node $mainNode,$addonNode