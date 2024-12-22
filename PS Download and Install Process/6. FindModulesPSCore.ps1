$PGSMC = Find-Module -Name * -Tag 'PSEdition_Core'
"There are {0:N0} modules that support Powershell Core" -f $PGSMC.Count