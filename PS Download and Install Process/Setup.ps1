Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force


Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Install-PackageProvider Nuget -MinimumVersion 2.8.5.201 -Force | Out-Null

Install-Module -Name PowerShellGet -Force -AllowClobber

mkdir c:\PowerShell 

