$outputPath = Join-Path -Path (Get-Location) -ChildPath 'artifacts/hello_pwsh.txt'
$null = New-Item -ItemType Directory -Path (Split-Path -Path $outputPath -Parent) -Force
Set-Content -Path $outputPath -Value 'hello_pwsh:ok' -Encoding UTF8
