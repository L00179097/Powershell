$max=50
$primes= @()
$a = 2

do {
    $isPrime = $true
    for ($i = 2; $i -lt $a; $i++) {
        if ($a % $i -eq 0) {
            $isPrime = $false
            break
        }
    }
    if ($isPrime) {
        $primes += $a
    }
    $a++
} until ($a -ge $max)

Write-Host "Prime numbers: $primes"
