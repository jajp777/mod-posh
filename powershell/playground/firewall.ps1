# netsh advfirewall firewall add rule name="RPC Dynamic Ports" dir=in action=allow enable=yes profile=domain localip=any remoteip=any localport=rpc remoteport=any protocol=tcp edge=no

$FwMgr = New-Object -ComObject HNetCfg.FwMgr
$FwProfile = $FwMgr.LocalPolicy.CurrentProfile

$FwPort = New-Object -ComObject HNetCfg.FwOpenPort
$FwPort.Name = "PS WS-MAN Remoting"
$FwPort.Protocol = 6
$FwPort.Port = 5985
$FwPort.RemoteAddresses = "10.133.3.0/24"
$FwPort.Enabled = $true

$FwProfile.GloballyOpenPorts.Add($FwPort)
