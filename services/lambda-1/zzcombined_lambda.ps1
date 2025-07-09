# Write-Output "Combined files into $outputFile"
# Define the output file
$outputFile = "z-lambda-1.tf"

# Check if the file exists and remove it if it does
if (Test-Path $outputFile) {
    Remove-Item $outputFile -Force
    Write-Output "$outputFile already existed and was deleted."
}

# Combine root-level .tf files
Get-ChildItem -Path . -Filter "*.tf" | ForEach-Object {
    Add-Content -Path $outputFile -Value "### File: $($_.Name) ###"
    Get-Content $_.FullName | Add-Content $outputFile
    Add-Content $outputFile -Value "`n"
}

Write-Output "Combined files into $outputFile"

