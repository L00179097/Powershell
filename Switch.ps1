$number1 = Read-Host "Enter the first number"
$number2 = Read-Host "Enter the second number"
Write-Host "Choose an operation:"
Write-Host "1. Add"
Write-Host "2. Subtract"
Write-Host "3. Multiply"
Write-Host "4. Divide"
$operationChoice = Read-Host "Enter the number corresponding to the operation"
$number1 = [float]$number1
$number2 = [float]$number2
switch ( $operationChoice )
{
    '1' {
        $result=$number1 + $number2
        $operation = 'Add'
    }
    '2' {
        $result=$number1 - $number2
        $operation = 'Subtract'
    }
    '3' {
        $result= $number1 * $number2
        $operation = 'Multiply'
    }
    '4' {
        if ($number2 -eq 0) {
            $result='Error: Division by zero is not allowed.'
        } else {
            $result=$number1 / $number2
        }
        $operation = 'Divide'
    }
    default {
        $result = 'Error: Invalid operation selection.'
        $operation = 'Unknown'
    }
}
Write-Output "The result of $operation between $number1 and $number2 is: $result"
