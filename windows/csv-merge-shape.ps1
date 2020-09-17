$input=$args[0]
$output=$args[1]
$headerfile="header.txt"

$(Get-Content $headerfile; Get-Content $input) | Set-Content $input
get-content $input | %{$_ -replace "\|",","} | Set-Content -Encoding UTF8 $output
#Remove-Item -Path "temp.txt" -Force
