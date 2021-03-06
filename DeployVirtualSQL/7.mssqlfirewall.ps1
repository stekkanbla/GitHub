$portTCP = New-Object -ComObject HNetCfg.FwOpenPort
$portTCP.Port = 1433
$portTCP.Name = "MSSQL TCP"
$portTCP.Enabled = $True

$portUDP = New-Object -ComObject HNetCfg.FwOpenPort
$portUDP.Port = 1434
$portUDP.Name = "MSSQL UDP"
$portUDP.Enabled = $True


$fwMgr = New-Object -ComObject HNetCfg.FwMgr
$profile = $fwMgr.LocalPolicy.CurrentProfile
$profile.GloballyOpenPorts.Add($portTCP)
$profile.GloballyOpenPorts.Add($portUDP)

$fw = New-Object -ComObject hnetcfg.fwpolicy2


##enbler bare for domenetrafikk
## 1 = domene, 2= private, 4 = public
$t = $fw.rules |where {$_.Name -eq "MSSQL TCP"}
$t.Profiles = 1
$u = $fw.rules |where {$_.Name -eq "MSSQL UDP"}
$u.Profiles = 1