$I = 0 
$env:PSModulePAth -split ';'
Foreach-Object {"[{0:N0}] {1}" -f $I++, $_}