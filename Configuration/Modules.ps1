$MyModulePath = "C:\SORNA\ATU\PowerShell\HelloWorld"
$MyModule = @"
# HelloWorld.PSM1
Function Get-HelloWorld {
 "Happy New Year 2024 :-)"r
}
"@
New-Item -Path $MyModulePath -ItemType Directory -Force | Out-Null
$MyModule | Out-File -FilePath $MyModulePath\HelloWorld.PSM1
Get-Module -Name HelloWorld -ListAvailable