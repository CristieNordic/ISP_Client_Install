 #Get-Content ".\settings.cfg" | Select-String Username |
 $TestDef = "Test1"
 $Test = Read-Host ("Type something (Default is $TestDef)")
 if (!$Test) {
    $Test = $TestDef
 }
 echo "$Test"