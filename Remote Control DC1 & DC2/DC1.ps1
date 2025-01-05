$SERVERNAME = "dc1"
$FOREST = "l00179097.ie"
$DNSNAME = $SERVERNAME + "." + $FOREST

# Set the IP address for the DC
Rename-Computer -NewName $SERVERNAME
Get-NetIPAddress
New-NetIPAddress -InterfaceIndex 2 -IPAddress 192.168.1.80 -PrefixLength 24 -DefaultGateway 192.168.1.20
Restart-Computer

# Configure AD, DNS
Install-ADDSForest -DomainName $FOREST
Install-WindowsFeature DHCP -IncludeManagementTools

# Configure DHCP, add a single scope
Add-DhcpServerInDC -DnsName $DNSNAME -IPAddress 192.168.1.11
Add-DhcpServerv4Scope -Name InfraServers -StartRange 192.168.1.150 -EndRange 192.168.1.199 -SubnetMask 255.255.255.0

# Set time to sync'h with a local NTP server.
w32tm /config /manualpeerlist:192.168.1.254 /syncfromflags:manual /update