$IAC=85
$Network=90
$English=78
$TotalMarks=$IAC+$Network+$English
$Count_Of_Count=3
$Avg=[float]($TotalMarks/$Count_Of_Count)

if($Avg-ge90){$Grade="A+"}
elseif($Avg-ge80){$Grade="A"}
elseif($Avg-ge70){$Grade="B"}
elseif($Avg-ge60){$Grade="C"}
else{$Grade="Fail"}

$Summary="The total marks $TotalMarks is calculated from IAC ($IAC), Network ($Network), and English ($English). The average marks are $Avg, and the grade is $Grade."
$Summary
