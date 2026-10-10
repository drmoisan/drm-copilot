#!/usr/bin/env pwsh
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostVerification.psm1')

try {
    $result = Invoke-HostVerification
}
catch {
    $global:LASTEXITCODE = 1
    throw
}

$result.Lines | Write-Output
exit $result.ExitCode
