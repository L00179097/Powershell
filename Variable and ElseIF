$IAC=85
$Network=90
$Virtual=78
$TotalMarks=$IAC+$Network+$Virtual
$Count_Of_Count=3
$Avg=[float]($TotalMarks/$Count_Of_Count)

if($Avg-ge 90){$Grade="A+"}
elseif($Avg-ge 80){$Grade="A"}
elseif($Avg-ge 70){$Grade="B"}
elseif($Avg-ge 60){$Grade="C"}
else{$Grade="Fail"}

$Summary="The total marks $TotalMarks is calculated from IAC ($IAC), Network ($Network), and English ($Virtual). The average marks are $Avg, and the grade is $Grade."
$Summary
