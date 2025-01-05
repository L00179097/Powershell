$SERVERNAME = "DC2"
$FOREST = "l00179097.ie"
$DNSNAME = $SERVERNAME + "." + $FOREST
 
# Set the IP address for the DC
Rename-Computer -NewName $SERVERNAME
Get-NetIPAddress
New-NetIPAddress -InterfaceIndex 2 -IPAddress 192.168.13.152 -PrefixLength 24 -DefaultGateway 192.168.13.1
Set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses 192.168.1.80
Restart-Computer
 
# Join the existing Domain
Add-Computer -DomainName $FOREST -Restart
 
# Install software
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
 
# Add this as a second DC
Install-ADDSDomainController -DomainName $FOREST -InstallDns:$true -Credential (Get-Credential "sorna\administrator")
 
# Configure DHCP
Install-WindowsFeature DHCP -IncludeManagementTools
Add-DhcpServerInDC -DnsName $DNSNAME -IPAddress 192.168.13.10