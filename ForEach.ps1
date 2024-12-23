$n=1,2,3,4,5,6,7,8,9,10
$e=@()
foreach($x in $n) {
    if($x % 2 -eq 0) {
        $e+= $x
    }
}
Write-Host $e
