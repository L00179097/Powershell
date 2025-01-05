
$Session = New-CimSession -ComputerName "localhost"
Remove-DscConfigurationDocument -Stage Current -CimSession $Session