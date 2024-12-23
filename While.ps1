$correctPin = "9875"
$inputPin = ""

while ($inputPin -ne $correctPin) {
    $inputPin = Read-Host "Enter your mobile pin"
    if ($inputPin -ne $correctPin) {
        Write-Host "Incorrect pin. Please try again."
    }
}

Write-Host "Pin correct. Access granted."
