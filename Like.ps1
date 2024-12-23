$IP='192.168.1.1'
if($IP -like '192.168.*')
{
    Write-Output "Found a valid local IP address"
}
